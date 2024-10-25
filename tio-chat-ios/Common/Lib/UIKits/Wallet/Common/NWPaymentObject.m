//
//  NWPaymentObject.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2021/3/5.
//  Copyright © 2021 刘宇. All rights reserved.
//

#import "NWPaymentObject.h"
#import "NSString+T_HTTP.h"

@implementation NWPaymentObject

@synthesize cardNo;

@synthesize channelId;

@synthesize iconImage;

@synthesize type;

@synthesize name;

@synthesize iconUrl;

@synthesize waterImageUrl;

@synthesize back_color;

@synthesize backFourCardNo;

@synthesize bank_phone;

@synthesize agreementNo;

@synthesize amount;

- (instancetype)initWithModel:(TIOBankCard *)model
{
    self = [super init];
    if (self) {
        /**
         @property (copy,    nonatomic) NSString *agrno;
         @property (copy,    nonatomic) NSString *backcolor;
         @property (copy,    nonatomic) NSString *bankcode;
         @property (copy,    nonatomic) NSString *banklogo;
         @property (copy,    nonatomic) NSString *bankname;
         @property (copy,    nonatomic) NSString *bankwatermark;
         @property (copy,    nonatomic) NSString *cardno;
         @property (assign,  nonatomic) NSString *card_id;
         */
        self.agrno = model.agrno;
        self.backcolor = model.backcolor;
        self.bankcode = model.bankcode;
        self.banklogo = model.banklogo;
        self.bankname = model.bankname;
        self.bankwatermark = model.bankwatermark;
        self.cardno = model.cardno;
        self.card_id = model.card_id;
        self.phone = model.phone;
        
        type = NWPaymentTypeDepositCard;
    }
    return self;
}

- (NSString *)channelId
{
    return self.card_id;
}


- (NSString *)name
{
    return self.bankname;
}

- (NSString *)iconUrl
{
    return self.banklogo.resourceURLString;
}

- (NSString *)cardNo
{
    return self.cardno;
}

- (NSString *)waterImageUrl
{
    return self.bankwatermark.resourceURLString;
}

- (NSString *)back_color
{
    return self.backcolor;
}

- (NSString *)backFourCardNo
{
    if (self.cardno.length > 4) {
        return [self.cardno substringWithRange:NSMakeRange(self.cardno.length - 4, 4)];
    } else {
        return self.cardno;
    }
}

- (NSString *)agreementNo
{
    return self.agrno;
}

- (NSString *)bank_phone
{
    return self.phone;
}

@end
