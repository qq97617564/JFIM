//
//  TIOVideoChatManager.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/5/26.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TIOVideoChatManager.h"
#import "TIOBroadcastDelegate.h"
#import "NSObject+CBJSONSerialization.h"
#import "TIOChat.h"
#import "TIOSocketPackage.h"
#import "TIOCmdConfiguator.h"
#import "TIOHTTPSManager.h"
#import "TIOMacros.h"

#import <WebRTC/WebRTC.h>
#import <YYModel/YYModel.h>
#import <UIKit/UIKit.h>

static NSString * const kARDMediaStreamId = @"ARDAMS";
static NSString * const kARDAudioTrackId = @"ARDAMSa0";
static NSString * const kARDVideoTrackId = @"ARDAMSv0";
static NSString * const kARDVideoTrackKind = @"video";
static int64_t const kARDAppClientAecDumpMaxSizeInBytes = 9e6;  // 5 MB.
static int const kKbpsMultiplier = 1000;

@interface TIOVideoChatManager () <TIORTCDelegate,TIORTCDelegate, RTCPeerConnectionDelegate, RTCAudioSessionDelegate, RTCVideoViewDelegate>
@property (nonatomic, strong) TIOBroadcastDelegate<TIOVideoChatDelegate> *multiDelegate;
@property (copy, nonatomic) TIOCallStartHandler callStartHandler;
@property (nonatomic, strong) RTCEAGLVideoView *remoteVideoView;
@property (nonatomic, strong) RTCCameraPreviewView *localVideoView;
@property (nonatomic, strong) RTCPeerConnection *peerConnection;
@property (nonatomic, strong) RTCPeerConnectionFactory *factory;
@property (nonatomic, strong) RTCCameraVideoCapturer *capture;

@property (nonatomic, strong) RTCMediaStream* localMediaStream;
@property (nonatomic, strong) RTCMediaStream *meidaStream;

@property (nonatomic, strong) RTCVideoSource *source;

@property (nonatomic, strong) RTCVideoTrack *remoteVideoTrack;
@property (nonatomic, strong) RTCAudioTrack* audioTrack;

@property (nonatomic, strong) NSMutableArray *iceservers;

@property (nonatomic, strong) RTCSessionDescription *remoteSDP;
@property (nonatomic, strong) RTCSessionDescription *localSDP;
@property (nonatomic, strong) NSMutableArray<RTCIceCandidate *> *remoteIces;
@property (nonatomic, assign) BOOL isInitiator;
@property (nonatomic, copy) NSString *callId;
@property (nonatomic, assign) BOOL isSpeaker;
@property (nonatomic, assign) TIOCallCamera callCamera;
@property (nonatomic, assign) TIORTCStatus rtcStatus; // 事物的状态
@property (nonatomic, assign) TIORTCType rtcType;

@property (nonatomic, assign) RTCIceGatheringState iceGatheringState;

@property (nonatomic, copy) NSString *toCallId; // 要呼叫的人ID
@property (nonatomic, assign) TIORTCType callType;

@property (nonatomic,   assign) NSInteger canSendICE;

@property (nonatomic,   assign) TIORTCReplyResult replyResult;

@end

@implementation TIOVideoChatManager

- (instancetype)init
{
    self = [super init];
    
    if (self) {
        // 多播委托管理初始化
        _multiDelegate = (TIOBroadcastDelegate<TIOVideoChatDelegate> *)[TIOBroadcastDelegate.alloc init];
        
        _callCamera = TIOCallCameraFront;
        
        [TIOChat.shareSDK.singalManager addDelegate:self];
    }
    
    return self;
}

- (void)dealloc
{
    [TIOChat.shareSDK.singalManager removeDelegate:self];
}

#pragma mark - get

- (RTCCameraPreviewView *)localVideoView
{
    if (!_localVideoView) {
        _localVideoView = [RTCCameraPreviewView.alloc initWithFrame:CGRectZero];
    }
    return _localVideoView;
}

- (RTCEAGLVideoView *)remoteVideoView
{
    if (!_remoteVideoView) {
        _remoteVideoView = [RTCEAGLVideoView.alloc initWithFrame:CGRectZero];
        _remoteVideoView.delegate = self;
    }
    return _remoteVideoView;
}

#pragma mark - public

- (void)call:(NSString *)callee type:(TIORTCType)type completion:(TIOCallStartHandler)completion
{
    self.rtcType = type;
    if (callee.length == 0) {
        NSError *error = [NSError errorWithDomain:UIPrintErrorDomain code:5000 userInfo:@{NSLocalizedDescriptionKey: @"被呼叫者不能为空"}];
        completion(error, @"");
        return;
    }
    
    self.callType = type;
    self.toCallId = callee;
    self.isInitiator = YES;
 
    self.callStartHandler = completion;
    
    self.rtcStatus = TIORTCStatusCalling;
    // 通过信令发起呼叫
    [TIOChat.shareSDK.singalManager caller_callUser:self.toCallId callType:self.callType];
    
    [NSUserDefaults.standardUserDefaults setBool:YES forKey:@"isRtcing"];
    [NSUserDefaults.standardUserDefaults synchronize];
}

- (void)answer:(NSString *)callId type:(TIORTCType)type accept:(BOOL)accept ext:(nonnull NSString *)message
{
    [NSUserDefaults.standardUserDefaults setBool:YES forKey:@"isRtcing"];
    [NSUserDefaults.standardUserDefaults synchronize];
    
    self.rtcStatus = TIORTCStatusCalling;
    self.rtcType = type;
    self.callId = callId;
    self.replyResult = accept?TIORTCReplyResultAgree:TIORTCReplyResultCancel;
    if (accept) {
        self.isInitiator = NO;
        // 1、开始获取turn
        TIOLog(@"开始获取turn服务器");
        [TIOChat.shareSDK.singalManager start];
    } else {
        // 拒接
        [TIOChat.shareSDK.singalManager reciver_replyCall:callId?:@"" result:TIORTCReplyResultCancel resaon:@""];
        [NSUserDefaults.standardUserDefaults setBool:NO forKey:@"isRtcing"];
        [NSUserDefaults.standardUserDefaults synchronize];
    }
}

- (void)hangup:(TIOCallHangupType)hangupType
{
    [NSUserDefaults.standardUserDefaults setBool:NO forKey:@"isRtcing"];
    [NSUserDefaults.standardUserDefaults synchronize];
    if (self.callId) {
        [TIOChat.shareSDK.singalManager hangup:self.callId type:hangupType];
    }
}

- (void)hangupInDisconnected:(TIOCallHangupType)hangupType
{
    [NSUserDefaults.standardUserDefaults setBool:NO forKey:@"isRtcing"];
    [NSUserDefaults.standardUserDefaults synchronize];
    if (self.callId) {
        [TIOChat.shareSDK.singalManager hangup:self.callId type:hangupType];
    }
    TIOWxCallItem *callItem = [TIOWxCallItem.alloc init];
    callItem.fromuid = TIOChat.shareSDK.loginManager.userInfo.userId;
    callItem.hanguptype = hangupType;
    [_multiDelegate tio_hangup:callItem];
}

- (void)cancelCall:(NSString *)callId
{
    TIOLog(@"\n[%s] isMainThread %i",__func__, NSThread.isMainThread);
    [TIOChat.shareSDK.singalManager cancelCall:callId];
    
    TIOWxCallItem *object = [TIOWxCallItem.alloc init];
    object.hanguptype = TIOCallHangupTypeNormal;
    object.fromuid = callId;
    [self onCancelCall:object];
    
    [NSUserDefaults.standardUserDefaults setBool:NO forKey:@"isRtcing"];
    [NSUserDefaults.standardUserDefaults synchronize];
}

- (BOOL)setCameraEnable:(BOOL)enable
{
    return NO;
}

- (void)switchCamera:(TIOCallCamera)camera
{
    _callCamera = camera;
    [self localSwitchCamera];
}

#pragma mark - RTCPeerConnectionDelegate

/// 有新的ICE
- (void)peerConnection:(RTCPeerConnection *)peerConnection didGenerateIceCandidate:(RTCIceCandidate *)candidate
{
//    if (!self.canSendICE) {
//        return;
//    }
    
    NSDictionary *ice = @{
        @"sdpMid" : candidate.sdpMid,
        @"sdpMLineIndex" : @(candidate.sdpMLineIndex),
        @"candidate" : candidate.sdp,
    };
    
    
    if (self->_isInitiator) {
        TIOLog(@"ClientA -> ClientB 发送ICE");
        [TIOChat.shareSDK.singalManager caller_offerCandidate:ice toCallId:self.callId];
    } else {
        TIOLog(@"ClientB -> ClientA 发送ICE");
        [TIOChat.shareSDK.singalManager reciever_offerCandidate:ice toCallId:self.callId];
    }
}

/// 监听ICE的链接状态
- (void)peerConnection:(RTCPeerConnection *)peerConnection didChangeIceConnectionState:(RTCIceConnectionState)newState
{
    TIOLog(@"ICE状态变更:");
    switch (newState) {
        case RTCIceConnectionStateChecking:
        {
            TIOLog(@"-> RTCIceConnectionStateChecking");
        }
            break;
        case RTCIceConnectionStateConnected:
        {
            self.rtcStatus = TIORTCStatusMediaConnected;
            TIOLog(@"-> RTCIceConnectionStateConnected");
        }
            break;
            
        case RTCIceConnectionStateClosed:
        {
            TIOLog(@"-> RTCIceConnectionStateClosed");
            // 如果流媒体没有接通之前 还处于连接时 ICE出现问题
            // 默认挂断
            if (self.rtcStatus == TIORTCStatusCalling) {

            }
        }
            break;

        case RTCIceConnectionStateFailed:
        {
            TIOLog(@"-> RTCIceConnectionStateFailed");
            [TIOChat.shareSDK.singalManager hangup:self.callId type:TIOCallHangupTypeIceError];
        }
            break;
        case RTCIceConnectionStateDisconnected:
        {
            TIOLog(@"-> RTCIceConnectionStateDisconnected");
        }
            break;
            
        default:
            break;
    }
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection didChangeConnectionState:(RTCPeerConnectionState)newState
{
    TIOLog(@"链接状态变更:");
    switch (newState) {
        case RTCPeerConnectionStateNew:
        {
            TIOLog(@"-> RTCPeerConnectionStateNew");
        }
            break;
        case RTCPeerConnectionStateConnecting:
        {
            TIOLog(@"-> RTCPeerConnectionStateConnecting");
        }
            break;
        case RTCPeerConnectionStateConnected:
        {
            TIOLog(@"-> RTCPeerConnectionStateConnected");
            [self->_multiDelegate tio_callConnected];
            self.isChating = YES;
        }
            break;
        case RTCPeerConnectionStateDisconnected:
        {
            TIOLog(@"-> RTCPeerConnectionStateDisconnected");
            NSError *error = [NSError errorWithDomain:@"" code:0 userInfo:@{NSLocalizedDescriptionKey:@"RTCPeerConnectionStateDisconnected"}];
         
            [self->_multiDelegate tio_callDisconnected:error];
            self.isChating = NO;
        }
            break;
        case RTCPeerConnectionStateClosed:
        {
            TIOLog(@"-> RTCPeerConnectionStateClosed");
        }
            break;
        default:
            TIOLog(@"-> RTCPeerConnectionStateFailed");
            [TIOChat.shareSDK.singalManager hangup:self.callId type:TIOCallHangupTypeMobileError];
            break;
    }
}

- (void)peerConnection:(RTCPeerConnection *)peerConnection didAddReceiver:(RTCRtpReceiver *)rtpReceiver streams:(NSArray<RTCMediaStream *> *)mediaStreams
{
    dispatch_async(dispatch_get_main_queue(), ^{
        RTCMediaStreamTrack* track = rtpReceiver.track;
        if([track.kind isEqualToString:kRTCMediaStreamTrackKindVideo]){
           
            if(!self.remoteVideoView){
                TIOLog(@"error:remoteVideoView have not been created!");
                return;
            }
            
            self->_remoteVideoTrack = (RTCVideoTrack*)track;
            [self->_remoteVideoTrack addRenderer: self.remoteVideoView];
            [self->_multiDelegate tio_remoteViewReady:self.remoteVideoView];
        }
    });
    TIOLog(@"didAddReceiver:streams:");
}

/** Called when the SignalingState changed. */
- (void)peerConnection:(RTCPeerConnection *)peerConnection didChangeSignalingState:(RTCSignalingState)stateChanged
{
    
}

/** Called when media is received on a new stream from remote peer. */
- (void)peerConnection:(RTCPeerConnection *)peerConnection didAddStream:(RTCMediaStream *)stream
{
//    dispatch_async(dispatch_get_main_queue(), ^{
//      RTCLog(@"Received %lu video tracks and %lu audio tracks",
//          (unsigned long)stream.videoTracks.count,
//          (unsigned long)stream.audioTracks.count);
//      if (stream.videoTracks.count) {
//          TIOLog(@"收到远端stream");
//          RTCVideoTrack *videoTrack = stream.videoTracks[0];
//
//          [self->_remoteVideoTrack removeRenderer:self.remoteVideoView];
//          self->_remoteVideoTrack = nil;
//          [self->_remoteVideoView renderFrame:nil];
//          self->_remoteVideoTrack = videoTrack;
//          [self->_remoteVideoTrack addRenderer:self.remoteVideoView];
//
//          [self->_multiDelegate tio_remoteViewReady:self.remoteVideoView];
//      }
//    });
}

/** Called when a remote peer closes a stream.
 *  This is not called when RTCSdpSemanticsUnifiedPlan is specified.
 */
- (void)peerConnection:(RTCPeerConnection *)peerConnection didRemoveStream:(RTCMediaStream *)stream
{
    TIOLog(@"didRemoveStream");
}

/** Called when negotiation is needed, for example ICE has restarted. */
- (void)peerConnectionShouldNegotiate:(RTCPeerConnection *)peerConnection
{
//    TIOLog(@"peerConnectionShouldNegotiate");
}

/** Called any time the IceGatheringState changes. */
- (void)peerConnection:(RTCPeerConnection *)peerConnection
    didChangeIceGatheringState:(RTCIceGatheringState)newState
{
    self.iceGatheringState = newState;
    switch (newState) {
        case RTCIceGatheringStateGathering:
        {
            TIOLog(@"RTCIceGatheringStateGathering - addIceCandidat");
            [self.remoteIces enumerateObjectsUsingBlock:^(RTCIceCandidate * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                TIOLog(@"add remote ice");
                [self->_peerConnection addIceCandidate:obj];
            }];
            [self.remoteIces removeAllObjects];
        }
            break;
        case RTCIceGatheringStateComplete:
        {
            TIOLog(@"RTCIceGatheringStateComplete");
        }
            break;
        case RTCIceGatheringStateNew:
        {
            TIOLog(@"RTCIceGatheringStateNew");
        }
            break;
            
        default:
            break;
    }
}

/** Called when a group of local Ice candidates have been removed. */
- (void)peerConnection:(RTCPeerConnection *)peerConnection
    didRemoveIceCandidates:(NSArray<RTCIceCandidate *> *)candidates
{
    
}

/** New data channel has been opened. */
- (void)peerConnection:(RTCPeerConnection *)peerConnection
    didOpenDataChannel:(RTCDataChannel *)dataChannel
{
    
}


#pragma mark - RTC

- (void)configure
{
    _remoteIces = [NSMutableArray array];
    
    RTCAudioSessionConfiguration *webRTCConfig = [RTCAudioSessionConfiguration webRTCConfiguration];
    webRTCConfig.categoryOptions = webRTCConfig.categoryOptions | AVAudioSessionCategoryOptionDefaultToSpeaker;
    [RTCAudioSessionConfiguration setWebRTCConfiguration:webRTCConfig];

    RTCAudioSession *session = [RTCAudioSession sharedInstance];
    [session addDelegate:self];
    
//    [self configureAudioSession];
    
    [RTCPeerConnectionFactory initialize];
    
    if (!_factory)
    {
        RTCDefaultVideoDecoderFactory* decoderFactory = [[RTCDefaultVideoDecoderFactory alloc] init];
        RTCDefaultVideoEncoderFactory* encoderFactory = [[RTCDefaultVideoEncoderFactory alloc] init];
        NSArray* codecs = [encoderFactory supportedCodecs];
        [encoderFactory setPreferredCodec:codecs[2]];
        
        _factory = [[RTCPeerConnectionFactory alloc] initWithEncoderFactory: encoderFactory
                                                            decoderFactory: decoderFactory];
        

    }
    
    NSString *filePath = [self documentsFilePathForFileName:@"webrtc-audio.aecdump"];
    if (![_factory startAecDumpWithFilePath:filePath
                             maxSizeInBytes:kARDAppClientAecDumpMaxSizeInBytes]) {
        TIOLog(@"Failed to start aec dump.");
    }
    
}

- (void)createPeer
{
    RTCConfiguration* configuration = [[RTCConfiguration alloc] init];
    configuration.iceServers = _iceservers;
//    configuration.iceConnectionReceivingTimeout = 9000;
//    configuration.iceTransportPolicy = RTCIceTransportPolicyAll;
//    configuration.audioJitterBufferMaxPackets = 50;
//    configuration.bundlePolicy = RTCBundlePolicyBalanced;
//    configuration.rtcpMuxPolicy = RTCRtcpMuxPolicyRequire;
//    configuration.candidateNetworkPolicy = RTCCandidateNetworkPolicyAll;
    _peerConnection = [_factory
                       peerConnectionWithConfiguration:configuration
                       constraints:[self defaultPeerConnContraints]
                       delegate:self];
    [_peerConnection addStream:self.localMediaStream];
    
    // 音频
    RTCAudioSource *audioSource = [_factory audioSourceWithConstraints:[self defaultMediaAudioConstraints]];
    self.audioTrack = [_factory audioTrackWithSource:audioSource trackId:kARDAudioTrackId];
    [_peerConnection addTrack:self.audioTrack streamIds:@[kARDMediaStreamId]];
    
    [self.localMediaStream addAudioTrack:self.audioTrack];
    
    if (self.rtcType == TIORTCTypeVideo) {
        
        NSArray<AVCaptureDevice*>* captureDevices = [RTCCameraVideoCapturer captureDevices];
        AVCaptureDevice* device = nil;
        for (AVCaptureDevice *devicee in captureDevices) {
            if (devicee.position == AVCaptureDevicePositionFront) {
                device = devicee;
                break;
            }
        }
        
        if (!device) {
            device = captureDevices[0];
        }
        
        // 视频
        RTCVideoSource* videoSource = [_factory videoSource];
        _capture = [[RTCCameraVideoCapturer alloc] initWithDelegate:videoSource];
        RTCVideoTrack *videoTrack = [_factory videoTrackWithSource:videoSource trackId:kARDVideoTrackId];
        [_peerConnection addTrack:videoTrack streamIds:@[kARDMediaStreamId]];
        [self.localMediaStream addVideoTrack:videoTrack];
        
        // 获取本地视频
        AVCaptureDeviceFormat *format = [self selectFormatForDevice:device];
        NSInteger fps = [self selectFpsForFormat:format];
        _capture.captureSession.sessionPreset = AVCaptureSessionPreset1920x1080;
        
        [_capture startCaptureWithDevice:device format:format fps:fps completionHandler:^(NSError * _Nonnull error) {
            if (error) {
                TIOLog(@"error %@",error.localizedDescription);
            }
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                //展示预览
                self.localVideoView.captureSession = self->_capture.captureSession;
                // 通知上层，本地视频可以预览
                [self->_multiDelegate tio_localReviewReady:self.localVideoView];
            });
        }];
    }
    
}

#pragma mark - private

- (NSString *)documentsFilePathForFileName:(NSString *)fileName {
  NSParameterAssert(fileName.length);
  NSArray *paths = NSSearchPathForDirectoriesInDomains(
      NSDocumentDirectory, NSUserDomainMask, YES);
  NSString *documentsDirPath = paths.firstObject;
  NSString *filePath =
      [documentsDirPath stringByAppendingPathComponent:fileName];
  return filePath;
}

- (AVCaptureDeviceFormat *)selectFormatForDevice:(AVCaptureDevice *)device {
  NSArray<AVCaptureDeviceFormat *> *formats =
      [RTCCameraVideoCapturer supportedFormatsForDevice:device];
    
    int targetWidth = 1280;//UIScreen.mainScreen.bounds.size.width * 2;
    int targetHeight = 720;//UIScreen.mainScreen.bounds.size.height * 2;
    AVCaptureDeviceFormat *selectedFormat = nil;
    int currentDiff = INT_MAX;
    
    for (AVCaptureDeviceFormat *format in formats) {
        CMVideoDimensions dimension = CMVideoFormatDescriptionGetDimensions(format.formatDescription);
        int diff = abs(targetWidth - dimension.width) + abs(targetHeight - dimension.height);
        if (diff < currentDiff) {
            selectedFormat = format;
            currentDiff = diff;
        }
  }

    NSAssert(selectedFormat != nil, @"No suitable capture format found.");
    return selectedFormat;
}

- (NSInteger)selectFpsForFormat:(AVCaptureDeviceFormat *)format {
    Float64 maxFramerate = 0;
    for (AVFrameRateRange *fpsRange in format.videoSupportedFrameRateRanges) {
        maxFramerate = fmax(maxFramerate, fpsRange.maxFrameRate);
    }
    return maxFramerate;
}

- (void)setLocalOffer:(RTCPeerConnection *)conn withSdp:(RTCSessionDescription *)sdp
{
    [conn setLocalDescription:sdp completionHandler:^(NSError * _Nullable error) {
        if (!error) {
            
            if (self->_isInitiator) {
                // 呼叫方
                TIOLog(@"Successed to set local offer sdp!");
                NSDictionary* dict = [[NSDictionary alloc] initWithObjects:@[@"offer", sdp.sdp]
                                                                   forKeys: @[@"type", @"sdp"]];
                [TIOChat.shareSDK.singalManager caller_offerSDP:dict toCallId:self.callId];
            } else {
                // 接听方
                TIOLog(@"Successed to set local answer sdp!");
                NSDictionary* dict = [[NSDictionary alloc] initWithObjects:@[@"answer", sdp.sdp]
                                                                   forKeys: @[@"type", @"sdp"]];
                // 通过信令 将SDP发送给呼叫方
                [TIOChat.shareSDK.singalManager reciver_offerSDP:dict toCallId:self.callId];
                TIOLog(@"Send SDP to ClientA");
            }
            
        }else{
            TIOLog(@"Failed to set local offer sdp, err=%@", error);
        }
    }];
}

-(void)localSwitchCamera
{
  NSArray<AVCaptureDevice *> *captureDevices = [RTCCameraVideoCapturer captureDevices];
  AVCaptureDevicePosition position = _callCamera == TIOCallCameraFront ? AVCaptureDevicePositionFront : AVCaptureDevicePositionBack;
  AVCaptureDevice * device = captureDevices[0];
  for (AVCaptureDevice *obj in captureDevices)
  {
    if (obj.position == position)
    {
      device = obj;
      break;
    }
  }
  //检测摄像头权限
  AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
  if(authStatus == AVAuthorizationStatusRestricted || authStatus == AVAuthorizationStatusDenied)
  {
      TIOLog(@"相机访问受限");
  }
  else
  {
    if (device)
    {
        AVCaptureDeviceFormat *format = [self selectFormatForDevice:device];
        NSInteger fps = [self selectFpsForFormat:format];
        
        [_capture startCaptureWithDevice:device format:format fps:fps completionHandler:^(NSError * _Nonnull error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.localVideoView.captureSession = self->_capture.captureSession;
            });
        }];
    }
    else
    {
        TIOLog(@"该设备不能打开摄像头");
    }
  }
}

//- (void)setMaxBitrateForPeerConnectionVideoSender {
//  for (RTCRtpSender *sender in _peerConnection.senders) {
//    if (sender.track != nil) {
//      if ([sender.track.kind isEqualToString:kARDVideoTrackKind]) {
//        [self setMaxBitrate:_maxBitrate forVideoSender:sender];
//      }
//    }
//  }
//}

- (void)setMaxBitrate:(NSNumber *)maxBitrate forVideoSender:(RTCRtpSender *)sender {
  if (maxBitrate.intValue <= 0) {
    return;
  }

  RTCRtpParameters *parametersToModify = sender.parameters;
  for (RTCRtpEncodingParameters *encoding in parametersToModify.encodings) {
    encoding.maxBitrateBps = @(maxBitrate.intValue * kKbpsMultiplier);
  }
  [sender setParameters:parametersToModify];
}

#pragma mark - Constraints

/// peer 的 约束
- (RTCMediaConstraints *)defaultPeerConnContraints
{
    NSDictionary *optionalConstraints = @{@"DtlsSrtpKeyAgreement" : @"true" };

//    NSDictionary *optionalConstraints = @{@"DtlsSrtpKeyAgreement" : @"true"};
    RTCMediaConstraints* constraints =
        [[RTCMediaConstraints alloc]
            initWithMandatoryConstraints:nil
                     optionalConstraints:optionalConstraints];
    return constraints;
}

/// offer 的约束
- (RTCMediaConstraints *)defaultOfferContraints
{
    NSDictionary *mandatoryConstraints =@{kRTCMediaConstraintsOfferToReceiveAudio:kRTCMediaConstraintsValueTrue,
                                          kRTCMediaConstraintsOfferToReceiveVideo:kRTCMediaConstraintsValueTrue,
    };

    RTCMediaConstraints* constraints = [RTCMediaConstraints.alloc initWithMandatoryConstraints:mandatoryConstraints
                                                                           optionalConstraints:nil];
    return constraints;
}

- (RTCRtpSender *)createAudioSender {
  RTCMediaConstraints *constraints = [self defaultMediaAudioConstraints];
  RTCAudioSource *source = [_factory audioSourceWithConstraints:constraints];
  RTCAudioTrack *track = [_factory audioTrackWithSource:source
                                                trackId:kARDAudioTrackId];
  RTCRtpSender *sender =
    [_peerConnection senderWithKind:kRTCMediaStreamTrackKindAudio streamId:kARDMediaStreamId];
  sender.track = track;
  return sender;
}

- (RTCRtpSender *)createVideoSender {
  RTCRtpSender *sender =
      [_peerConnection senderWithKind:kRTCMediaStreamTrackKindVideo
                             streamId:kARDMediaStreamId];
  RTCVideoTrack *track = [self createLocalVideoTrack];
  if (track) {
    sender.track = track;
  }

  return sender;
}
//
- (RTCVideoTrack *)createLocalVideoTrack {
    RTCVideoTrack* localVideoTrack = nil;
  // The iOS simulator doesn't provide any sort of camera capture
  // support or emulation (http://goo.gl/rHAnC1) so don't bother
  // trying to open a local stream.
    RTCVideoSource *source = [_factory videoSource];
    localVideoTrack = [_factory videoTrackWithSource:source
                                             trackId:kARDVideoTrackId];
    return localVideoTrack;
}
//
- (RTCMediaConstraints *)defaultMediaAudioConstraints {
    
     NSString *valueLevelControl = kRTCMediaConstraintsValueTrue;
     NSDictionary *mandatoryConstraints = @{kRTCMediaConstraintsOfferToReceiveAudio : valueLevelControl};
     RTCMediaConstraints *constraints =
       [[RTCMediaConstraints alloc] initWithMandatoryConstraints:mandatoryConstraints
                                             optionalConstraints:nil];
     return constraints;
}

- (RTCMediaStream *)meidaStream {
    if (!_meidaStream) {
        _meidaStream = [_factory mediaStreamWithStreamId:kARDMediaStreamId];//`ARDAMS`固定就这么写
    }
    return _meidaStream;
}

- (RTCMediaStream *)localMediaStream
{
    if (!_localMediaStream) {
        _localMediaStream = [_factory mediaStreamWithStreamId:kARDMediaStreamId];
    }
    return _localMediaStream;
}



#pragma mark - RTC

- (void)configureAudioSession
{
    // 音频配置
    RTCAudioSessionConfiguration* configuration =
        [RTCAudioSessionConfiguration webRTCConfiguration];
    // change config

    RTCAudioSession* session = [RTCAudioSession sharedInstance];
    [session lockForConfiguration];
    NSError* error = nil;
    BOOL hasSucceeded =
        [session setConfiguration:configuration active:YES error:&error];
    if (!hasSucceeded) {
        // error
        TIOLog(@"音频初始化失败:%@",error);
    }
    [session unlockForConfiguration];
}

/// 呼叫方提供SDP
- (void)offerSDP
{
    [_peerConnection offerForConstraints:[self defaultOfferContraints] completionHandler:^(RTCSessionDescription * _Nullable sdp, NSError * _Nullable error) {
        if (error) {
            TIOLog(@"Failed to create offer SDP, err=%@", error);
        } else {
            TIOLog(@"Successed to create offer SDP!");
            __weak RTCPeerConnection* weakPeerConnction = self->_peerConnection;
            [self setLocalOffer: weakPeerConnction withSdp: sdp];
        }
    }];
}

// 向呼叫方响应SDP
- (void)createAnswerSDP
{
    [_peerConnection answerForConstraints:[self defaultOfferContraints] completionHandler:^(RTCSessionDescription * _Nullable sdp, NSError * _Nullable error) {
        if (error) {
            TIOLog(@"Failed to create answer SDP, err=%@", error);
        } else {
            TIOLog(@"Successed to create answer SDP!");
            [self setLocalOffer:self->_peerConnection withSdp:sdp];
        }
    }];
}

//监听声道的变化
- (void)observeHeadset {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(roteChange:) name:AVAudioSessionRouteChangeNotification object:nil];
}

- (void)roteChange:(NSNotification *)noti {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (![self isHeadPhoneEnable]) {//没有耳机根据当前状态切换
            if (self.isSpeaker) {
                [self switchAudioCategaryWithSpeaker:YES];
            } else {
               [self switchAudioCategaryWithSpeaker:NO];
            }
        } else {//有耳机走听筒
           [self switchAudioCategaryWithSpeaker:NO];
        }
    });
}

- (BOOL)isHeadPhoneEnable {//判断是否插入耳机
    AVAudioSessionRouteDescription *route = [[AVAudioSession sharedInstance] currentRoute];
    BOOL isHeadPhoneEnable = NO;
    for (AVAudioSessionPortDescription *desc in [route outputs]) {
        if ([[desc portType] isEqualToString:AVAudioSessionPortHeadphones]) {
            isHeadPhoneEnable = YES;
        }
    }
    return isHeadPhoneEnable;
}
//扬声器和听筒的切换
- (void)switchAudioCategaryWithSpeaker:(BOOL)isSpeaker {
    
    RTCAudioSession *session = [RTCAudioSession sharedInstance];
    [session lockForConfiguration];
    NSError *error = nil;
    
    if (isSpeaker) {
        [session setCategory:AVAudioSessionCategoryPlayAndRecord
                 withOptions:AVAudioSessionCategoryOptionDefaultToSpeaker error:&error];
    } else {
        [session setCategory:AVAudioSessionCategoryPlayAndRecord
                 withOptions:AVAudioSessionCategoryOptionMixWithOthers|AVAudioSessionCategoryOptionAllowBluetooth error:&error];
    }
    [session setActive:YES error:nil];  // 只有当前APP占据音频输出
    if (error) {
        RTCLogError(@"Error overriding output port: %@",
        error.localizedDescription);
    }
    
    [session unlockForConfiguration];
}

- (BOOL)setMute:(BOOL)mute
{
//    self.audioTrack.isEnabled = mute;
    [RTCDispatcher dispatchAsyncOnType:RTCDispatcherTypeAudioSession
                                   block:^{
        RTCAudioSession *session = [RTCAudioSession sharedInstance];
        [session lockForConfiguration];
        
        NSError *error = nil;
        if ([session setActive:mute error:&error]) {
            
        } else {
          RTCLogError(@"Error overriding output port: %@",
                      error.localizedDescription);
        }
        [session unlockForConfiguration];
    }];
    
    return YES;
}

- (void)setMicMutex:(BOOL)mutex
{
//    self.audioTrack.isEnabled = mutex;
    self.localMediaStream.audioTracks[0].isEnabled = mutex;
}

- (void)switchAudioDevice:(TIOCallAudioDevice)device
{
    [self switchAudioCategaryWithSpeaker:device == TIOCallAudioDeviceSpeaker];
}

#pragma mark - RTCAudioSessionDelegate

/// 开始播放
- (void)audioSessionDidStartPlayOrRecord:(RTCAudioSession *)session;
{
    TIOLog(@"开始播放声音");
}

/// 结束播放
- (void)audioSessionDidStopPlayOrRecord:(RTCAudioSession *)session;
{
    TIOLog(@"结束播放声音");
}

#pragma mark - RTCVideoViewDelegate

- (void)videoView:(id<RTCVideoRenderer>)videoView didChangeVideoSize:(CGSize)size
{
    [self.multiDelegate tio_remoteview:_remoteVideoView changeWidth:size.width height:size.height];
}

#pragma mark - TIORTCDelegate

- (void)onHangup:(TIOWxCallItem *)callItem {
    
    // 不是自己设备接听
    self.isChating = NO;
//    [_capture stopCapture];
    [_peerConnection removeStream:self.localMediaStream];
    [_peerConnection removeStream:self.meidaStream];
    [_peerConnection close];
    _peerConnection = nil;
    _localSDP = nil;
    _remoteSDP = nil;
    _localMediaStream = nil;
    _remoteVideoTrack = nil;
    
    self.callId = nil;
    _peerConnection = nil;
 
    [self.multiDelegate tio_hangup:callItem];
    [NSUserDefaults.standardUserDefaults setBool:NO forKey:@"isRtcing"];
    [NSUserDefaults.standardUserDefaults synchronize];
}

- (void)onCaller_recieveAnswerCall:(nonnull TIOWxCallItemReply *)result {
    TIOLog(@"收到接听者的接听处理");
    self.isInitiator = YES;
    
    if (result.result == TIORTCReplyResultCancel) {
        NSError *error = [NSError errorWithDomain:UIPrintErrorDomain code:5001 userInfo:@{NSLocalizedDescriptionKey: result.reason}];
        if (self.callStartHandler) {
            self.callStartHandler(error, @"");
        }
    } else {
        TIOLog(@"callId = %@",result.callId);
        self.callStartHandler(nil, result.callId);
    }
    // 防止上层VC被持有无法被释放
    self.callStartHandler = nil;
    
    if (result.result == TIORTCReplyResultAgree) {
        // 发送SDP
        // caller：收到对方接听同意后，触发此回调
        self.callId = result.callId;
        // Create Perrconnection and Add Streams
        [self configure];
        [self createPeer];
        // Create offer ans Send offer
        [self offerSDP];
    } else {
        // 关闭链接
//        [_capture stopCapture];
        [_peerConnection removeStream:self.localMediaStream];
        [_peerConnection removeStream:self.meidaStream];
        [_peerConnection close];
        _peerConnection = nil;
        _localSDP = nil;
        _remoteSDP = nil;
        _localMediaStream = nil;
        _remoteVideoTrack = nil;
        
        self.callId = nil;
        _peerConnection = nil;
    }
    // 通知上层开发者
    [self.multiDelegate tio_responseAccept:result];
}

- (void)onCaller_recieveAnswerSDP:(nonnull TIOWxCallItemAnswerSDP *)callItem {
    if (callItem.sdp) {
        TIOLog(@"收到callee的SDP");
        RTCSessionDescription *sdp = [RTCSessionDescription.alloc initWithType:RTCSdpTypeAnswer sdp:callItem.sdp.sdp];
        
        // Set remote SDP to Local
        [_peerConnection setRemoteDescription:sdp completionHandler:^(NSError * _Nullable error) {
            if (error) {
                TIOLog(@"\n呼叫方设置远端SDP失败：%@\n",error.localizedDescription);
            } else {
                self->_canSendICE = YES;
                [TIOChat.shareSDK.singalManager start];
            }
        }];
    }
}

/// 从服务端获取自己的ICE服务器
- (void)onIceServer:(nonnull NSArray<RTCIceServer *> *)iceservers error:(NSError * _Nullable)error {
    if (error) {
        TIOLog(@"turn 获取失败");
        return;
    }
    _iceservers = [NSMutableArray arrayWithArray:iceservers];
//    RTCIceServer *stunServer = [RTCIceServer.alloc initWithURLStrings:@[@"stun:stun1.l.google.com:19302",@"stun:stun2.l.google.com:19302",@"stun:stun3.l.google.com:19302",@"stun:stun4.l.google.com:19302",@"stun:23.21.150.121",@"stun:stun01.sipphone.com",@"stun:stun.ekiga.net",@"stun:stun.fwdnet.net",@"stun:stun.ideasip.com",@"stun:stun.iptel.org",@"stun:stun.rixtelecom.se",@"stun:stun.schlund.de",@"stun:stunserver.org",@"stun:stun.softjoys.com",@"stun:stun.voiparound.com",@"stun:stun.voipbuster.com",@"stun:stun.voipstunt.com",@"stun:stun.voxgratia.org",@"stun:stun.xten.com"]];
//    [_iceservers addObject:stunServer];
    
    if (self.isInitiator) {
        TIOLog(@"呼叫方ClientA 收到turn://iceServer");
        RTCConfiguration *reConfiguration = [RTCConfiguration.alloc init];
        reConfiguration.iceServers = _iceservers;
        [self.peerConnection setConfiguration:reConfiguration];
    } else {
        TIOLog(@"接听方ClientB 收到turn://iceServer");
        // 接听方：
        // 已经获取ICE服务
        // 更新 peersonnection 的 iceServers
        // 2、建立 peerconnection
        [self configure];
        [self createPeer];
        // 3、同意接听
        [TIOChat.shareSDK.singalManager reciver_replyCall:self.callId result:TIORTCReplyResultAgree resaon:@""];
    }
}

- (void)onCaller_recieveAnswerCandidate:(nonnull TIOWxCallItemAnswerCandidate *)callItem {
    if (callItem.candidate) {
        RTCIceCandidate *ice = [RTCIceCandidate.alloc initWithSdp:callItem.candidate.candidate sdpMLineIndex:callItem.candidate.sdpMLineIndex sdpMid:callItem.candidate.sdpMid];
//        [_peerConnection addIceCandidate:ice];
//        if (self.iceGatheringState == RTCIceGatheringStateGathering) {
//            TIOLog(@"clientA add ice directly！");
//            [self->_peerConnection addIceCandidate:ice];
//        } else {
//            [self.remoteIces addObject:ice];
//            TIOLog(@"clientA 收到 -> 缓存：caller 的 ICE");
//            if (_peerConnection) {
//                [_peerConnection addIceCandidate:ice];
//            }
//        }
        
        if (_peerConnection) {
            TIOLog(@"clientA add ice directly！");
            [_peerConnection addIceCandidate:ice];
        } else {
            TIOLog(@"clientA 收到 -> 缓存：caller 的 ICE");
            [self.remoteIces addObject:ice];
        }
    }
}

/// 收到信令：有人呼叫自己
/// cmd:801
- (void)onReciver_recieveCall:(nonnull TIOWxCallItem *)model {
    // 判断是不是呼叫本设备
    
    NSString *selfUid = [TIOChat.shareSDK.loginManager userInfo].userId;
    
    // 自己账号呼叫 && 当前设备呼叫
    if ([model.fromuid isEqualToString:selfUid] && model.fromdevice == TIORTCDeviceTypeIOS) {
        // 直接pass
        // 不告诉上层开发者有电话进来
        return;
    }
    
    // 通知上层开发者接听
    [self.multiDelegate tio_receiveCall:model];
}

- (void)onReciver_SingnalConnected
{
    [self.multiDelegate tio_SingnalConnected];
}

- (void)onReciver_recieveSDP:(nonnull TIOWxCallItemAnswerSDP *)callItem {
    self.isInitiator = NO;
    self.callId = callItem.callId;
    TIOLog(@"收到 ClientA 的SDP");
    RTCSessionDescription *sdp = [RTCSessionDescription.alloc initWithType:RTCSdpTypeOffer sdp:callItem.sdp.sdp];
    self.remoteSDP = sdp;

    // 2、设置远端SDP
    __weak TIOVideoChatManager *wSelf = self;
    [_peerConnection setRemoteDescription:self.remoteSDP completionHandler:^(NSError * _Nullable error) {
        if (error) {
            TIOLog(@"setRemoteDescription error：%@\n",error.localizedDescription);
        } else {
            TIOLog(@"setRemoteDescription successed!");
            //3、Send Answer SDP
            [wSelf createAnswerSDP];
            self->_canSendICE = YES;
        }
    }];
}

- (void)onReciever_recieveCandidate:(nonnull TIOWxCallItemAnswerCandidate *)callItem {
    if (callItem.candidate) {
        RTCIceCandidate *ice = [RTCIceCandidate.alloc initWithSdp:callItem.candidate.candidate sdpMLineIndex:callItem.candidate.sdpMLineIndex sdpMid:callItem.candidate.sdpMid];

        if (self.iceGatheringState == RTCIceGatheringStateGathering) {
            TIOLog(@"ice正处于收集状态，直接addice");
            [self->_peerConnection addIceCandidate:ice];
        } else {
            [self.remoteIces addObject:ice];
            TIOLog(@"因为ice 目前未处于收集状态 先缓存：caller发来的ICE");
        }
    }
}

- (void)onCancelCall:(TIOWxCallItem *)callItem
{
    self.isChating = NO;
//    [RTCDispatcher dispatchAsyncOnType:RTCDispatcherTypeCaptureSession block:^{
        TIOLog(@"isMainThread = %i",NSThread.isMainThread);
//        [self->_capture stopCapture];
        [self->_peerConnection removeStream:self.localMediaStream];
        [self->_peerConnection close];
        self->_peerConnection = nil;
        self->_localSDP = nil;
        self->_remoteSDP = nil;
        self->_localMediaStream = nil;
        self->_remoteVideoTrack = nil;
        
        self.callId = nil;
    [self->_multiDelegate tio_hangup:callItem];
    [NSUserDefaults.standardUserDefaults setBool:NO forKey:@"isRtcing"];
    [NSUserDefaults.standardUserDefaults synchronize];
//    }];
}

- (void)onNetworkChange:(BOOL)connected
{
    if (connected && self.callId) {
        // 网络恢复
        // 重连
//        [self call:self.callId type:TIORTCTypeVideo completion:^(NSError * _Nullable error, NSString * _Nonnull callId) {
//
//        }];
    }
}

- (void)destory
{
    // 不是自己设备接听
    self.isChating = NO;
    [_peerConnection removeStream:self.localMediaStream];
    [_peerConnection removeStream:self.meidaStream];
    [_peerConnection close];
    _peerConnection = nil;
    _localSDP = nil;
    _remoteSDP = nil;
    _localMediaStream = nil;
    _remoteVideoTrack = nil;
    
    self.callId = nil;
    _peerConnection = nil;
    [NSUserDefaults.standardUserDefaults setBool:NO forKey:@"isRtcing"];
    [NSUserDefaults.standardUserDefaults synchronize];
}

#pragma mark -

- (void)addDelegate:(id<TIOVideoChatDelegate>)delegate
{
    [_multiDelegate addDelegate:delegate delegateQueue:dispatch_get_main_queue()];
}

- (void)removeDelegate:(id<TIOVideoChatDelegate>)delegate
{
    [_multiDelegate removeDelegate:delegate delegateQueue:dispatch_get_main_queue()];
}

@end
