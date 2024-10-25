//
//  TIOBroadcastDelegate.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2019/12/23.
//  Copyright © 2019 刘宇. All rights reserved.
//

#import "TIOBroadcastDelegate.h"
#import <libkern/OSAtomic.h>

@interface TIOBoradcastDelegateEnumerator : NSObject
{
    NSUInteger numNodes;
    NSUInteger currentNodeIndex;
    NSArray *delegateNodes;
}

@property (nonatomic, readonly) NSUInteger count;
- (NSUInteger)countOfClass:(Class)aClass;
- (NSUInteger)countForSelector:(SEL)aSelector;

- (BOOL)getNextDelegate:(id _Nullable * _Nonnull)delPtr delegateQueue:(dispatch_queue_t _Nullable * _Nonnull)dqPtr;
- (BOOL)getNextDelegate:(id _Nullable * _Nonnull)delPtr delegateQueue:(dispatch_queue_t _Nullable * _Nonnull)dqPtr ofClass:(Class)aClass;
- (BOOL)getNextDelegate:(id _Nullable * _Nonnull)delPtr delegateQueue:(dispatch_queue_t _Nullable * _Nonnull)dqPtr forSelector:(SEL)aSelector;

- (id)initFromDelegateNodes:(NSMutableArray *)inDelegateNodes;

@end


@interface TIOBoradcastDelegateNode : NSObject {
@private
    
  #if __has_feature(objc_arc_weak)
    __weak id delegate;
  #if !TARGET_OS_IPHONE
    __unsafe_unretained id unsafeDelegate;
  #endif
  #else
    __unsafe_unretained id delegate;
  #endif
    
    dispatch_queue_t delegateQueue;
}

- (id)initWithDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue;

#if __has_feature(objc_arc_weak)
@property (/* atomic */ readwrite, weak) id delegate;
#if !TARGET_OS_IPHONE
@property (/* atomic */ readwrite, unsafe_unretained) id unsafeDelegate;
#endif
#else
@property (/* atomic */ readwrite, unsafe_unretained) id delegate;
#endif

@property (nonatomic, readonly) dispatch_queue_t delegateQueue;

@end


@interface TIOBroadcastDelegate ()
{
    NSMutableArray *delegateNodes;
}

@property (nonatomic, readonly) NSUInteger count;
- (NSUInteger)countOfClass:(Class)aClass;
- (NSUInteger)countForSelector:(SEL)aSelector;
/// 检测代理是否实现方法
- (BOOL)hasDelegateThatRespondsToSelector:(SEL)aSelector;
/// 代理遍厉器
- (TIOBoradcastDelegateEnumerator *)delegateEnumerator;

- (NSInvocation *)duplicateInvocation:(NSInvocation *)origInvocation;
@end

#pragma implementation
@implementation TIOBroadcastDelegate

- (id)init
{
    if ((self = [super init]))
    {
        delegateNodes = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)addDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue
{
    if (delegate == nil) return;
    if (delegateQueue == NULL) return;
    
    TIOBoradcastDelegateNode *node =
        [[TIOBoradcastDelegateNode alloc] initWithDelegate:delegate delegateQueue:delegateQueue];
    
    [delegateNodes addObject:node];
}

- (void)removeDelegate:(id)delegate delegateQueue:(dispatch_queue_t)delegateQueue
{
    if (delegate == nil) return;
    
    NSUInteger i;
    for (i = [delegateNodes count]; i > 0; i--)
    {
        TIOBoradcastDelegateNode *node = delegateNodes[i - 1];
        
        id nodeDelegate = node.delegate;
        #if __has_feature(objc_arc_weak) && !TARGET_OS_IPHONE
        if (nodeDelegate == [NSNull null])
            nodeDelegate = node.unsafeDelegate;
        #endif
        
        if (delegate == nodeDelegate)
        {
            if ((delegateQueue == NULL) || (delegateQueue == node.delegateQueue))
            {
                node.delegate = nil;
                #if __has_feature(objc_arc_weak) && !TARGET_OS_IPHONE
                node.unsafeDelegate = nil;
                #endif
                
                [delegateNodes removeObjectAtIndex:(i-1)];
            }
        }
    }
}

- (void)removeDelegate:(id)delegate
{
    [self removeDelegate:delegate delegateQueue:NULL];
}

- (void)removeAllDelegates
{
    for (TIOBoradcastDelegateNode *node in delegateNodes)
    {
        node.delegate = nil;
        #if __has_feature(objc_arc_weak) && !TARGET_OS_IPHONE
        node.unsafeDelegate = nil;
        #endif
    }
    
    [delegateNodes removeAllObjects];
}

- (NSUInteger)count
{
    return [delegateNodes count];
}

- (NSUInteger)countOfClass:(Class)aClass
{
    NSUInteger count = 0;
    
    for (TIOBoradcastDelegateNode *node in delegateNodes)
    {
        id nodeDelegate = node.delegate;
        #if __has_feature(objc_arc_weak) && !TARGET_OS_IPHONE
        if (nodeDelegate == [NSNull null])
            nodeDelegate = node.unsafeDelegate;
        #endif
        
        if ([nodeDelegate isKindOfClass:aClass])
        {
            count++;
        }
    }
    
    return count;
}

- (NSUInteger)countForSelector:(SEL)aSelector
{
    NSUInteger count = 0;
    
    for (TIOBoradcastDelegateNode *node in delegateNodes)
    {
        id nodeDelegate = node.delegate;
        #if __has_feature(objc_arc_weak) && !TARGET_OS_IPHONE
        if (nodeDelegate == [NSNull null])
            nodeDelegate = node.unsafeDelegate;
        #endif
        
        if ([nodeDelegate respondsToSelector:aSelector])
        {
            count++;
        }
    }
    
    return count;
}

- (BOOL)hasDelegateThatRespondsToSelector:(SEL)aSelector
{
    for (TIOBoradcastDelegateNode *node in delegateNodes)
    {
        id nodeDelegate = node.delegate;
        #if __has_feature(objc_arc_weak) && !TARGET_OS_IPHONE
        if (nodeDelegate == [NSNull null])
            nodeDelegate = node.unsafeDelegate;
        #endif
        
        if ([nodeDelegate respondsToSelector:aSelector])
        {
            return YES;
        }
    }
    
    return NO;
}

- (TIOBoradcastDelegateEnumerator *)delegateEnumerator
{
    return [[TIOBoradcastDelegateEnumerator alloc] initFromDelegateNodes:delegateNodes];
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    for (TIOBoradcastDelegateNode *node in delegateNodes)
    {
        id nodeDelegate = node.delegate;
        #if __has_feature(objc_arc_weak) && !TARGET_OS_IPHONE
        if (nodeDelegate == [NSNull null])
            nodeDelegate = node.unsafeDelegate;
        #endif
        
        NSMethodSignature *result = [nodeDelegate methodSignatureForSelector:aSelector];
        
        if (result != nil)
        {
            return result;
        }
    }
    
    // This causes a crash...
    // return [super methodSignatureForSelector:aSelector];
    
    // This also causes a crash...
    // return nil;
    
    return [[self class] instanceMethodSignatureForSelector:@selector(doNothing)];
}

- (void)forwardInvocation:(NSInvocation *)origInvocation
{
    SEL selector = [origInvocation selector];
    BOOL foundNilDelegate = NO;
    
    for (TIOBoradcastDelegateNode *node in delegateNodes)
    {
        id nodeDelegate = node.delegate;
        #if __has_feature(objc_arc_weak) && !TARGET_OS_IPHONE
        if (nodeDelegate == [NSNull null])
            nodeDelegate = node.unsafeDelegate;
        #endif
        
        if ([nodeDelegate respondsToSelector:selector])
        {
            // All delegates MUST be invoked ASYNCHRONOUSLY.
            
            NSInvocation *dupInvocation = [self duplicateInvocation:origInvocation];
            
            dispatch_async(node.delegateQueue, ^{ @autoreleasepool {
                
                [dupInvocation invokeWithTarget:nodeDelegate];
                
            }});
        }
        else if (nodeDelegate == nil)
        {
            foundNilDelegate = YES;
        }
    }
    
    if (foundNilDelegate)
    {
        // At lease one weak delegate reference disappeared.
        // Remove nil delegate nodes from the list.
        //
        // This is expected to happen very infrequently.
        // This is why we handle it separately (as it requires allocating an indexSet).
        
        NSMutableIndexSet *indexSet = [[NSMutableIndexSet alloc] init];
        
        NSUInteger i = 0;
        for (TIOBoradcastDelegateNode *node in delegateNodes)
        {
            id nodeDelegate = node.delegate;
            #if __has_feature(objc_arc_weak) && !TARGET_OS_IPHONE
            if (nodeDelegate == [NSNull null])
                nodeDelegate = node.unsafeDelegate;
            #endif
            
            if (nodeDelegate == nil)
            {
                [indexSet addIndex:i];
            }
            i++;
        }
        
        [delegateNodes removeObjectsAtIndexes:indexSet];
    }
}

- (void)doesNotRecognizeSelector:(SEL)aSelector
{
    // Prevent NSInvalidArgumentException
}

- (void)doNothing {}

- (void)dealloc
{
    [self removeAllDelegates];
}

- (NSInvocation *)duplicateInvocation:(NSInvocation *)origInvocation
{
    NSMethodSignature *methodSignature = [origInvocation methodSignature];
    
    NSInvocation *dupInvocation = [NSInvocation invocationWithMethodSignature:methodSignature];
    [dupInvocation setSelector:[origInvocation selector]];
    
    NSUInteger i, count = [methodSignature numberOfArguments];
    for (i = 2; i < count; i++)
    {
        const char *type = [methodSignature getArgumentTypeAtIndex:i];
        
        if (*type == *@encode(BOOL))
        {
            BOOL value;
            [origInvocation getArgument:&value atIndex:i];
            [dupInvocation setArgument:&value atIndex:i];
        }
        else if (*type == *@encode(char) || *type == *@encode(unsigned char))
        {
            char value;
            [origInvocation getArgument:&value atIndex:i];
            [dupInvocation setArgument:&value atIndex:i];
        }
        else if (*type == *@encode(short) || *type == *@encode(unsigned short))
        {
            short value;
            [origInvocation getArgument:&value atIndex:i];
            [dupInvocation setArgument:&value atIndex:i];
        }
        else if (*type == *@encode(int) || *type == *@encode(unsigned int))
        {
            int value;
            [origInvocation getArgument:&value atIndex:i];
            [dupInvocation setArgument:&value atIndex:i];
        }
        else if (*type == *@encode(long) || *type == *@encode(unsigned long))
        {
            long value;
            [origInvocation getArgument:&value atIndex:i];
            [dupInvocation setArgument:&value atIndex:i];
        }
        else if (*type == *@encode(long long) || *type == *@encode(unsigned long long))
        {
            long long value;
            [origInvocation getArgument:&value atIndex:i];
            [dupInvocation setArgument:&value atIndex:i];
        }
        else if (*type == *@encode(double))
        {
            double value;
            [origInvocation getArgument:&value atIndex:i];
            [dupInvocation setArgument:&value atIndex:i];
        }
        else if (*type == *@encode(float))
        {
            float value;
            [origInvocation getArgument:&value atIndex:i];
            [dupInvocation setArgument:&value atIndex:i];
        }
        else if (*type == '@')
        {
            void *value;
            [origInvocation getArgument:&value atIndex:i];
            [dupInvocation setArgument:&value atIndex:i];
        }
        else if (*type == '^')
        {
            void *block;
            [origInvocation getArgument:&block atIndex:i];
            [dupInvocation setArgument:&block atIndex:i];
        }
        else
        {
            NSString *selectorStr = NSStringFromSelector([origInvocation selector]);
            
            NSString *format = @"Argument %lu to method %@ - Type(%c) not supported";
            NSString *reason = [NSString stringWithFormat:format, (unsigned long)(i - 2), selectorStr, *type];
            
            [[NSException exceptionWithName:NSInvalidArgumentException reason:reason userInfo:nil] raise];
        }
    }
    
    [dupInvocation retainArguments];
    
    return dupInvocation;
}

@end

@implementation TIOBoradcastDelegateNode

@synthesize delegate;       // atomic
#if __has_feature(objc_arc_weak) && !TARGET_OS_IPHONE
@synthesize unsafeDelegate; // atomic
#endif
@synthesize delegateQueue;  // non-atomic

#if __has_feature(objc_arc_weak) && !TARGET_OS_IPHONE
static BOOL SupportsWeakReferences(id delegate)
{
    // From Apple's documentation:
    //
    // > Which classes don’t support weak references?
    // >
    // > You cannot currently create weak references to instances of the following classes:
    // >
    // > NSATSTypesetter, NSColorSpace, NSFont, NSFontManager, NSFontPanel, NSImage, NSMenuView,
    // > NSParagraphStyle, NSSimpleHorizontalTypesetter, NSTableCellView, NSTextView, NSViewController,
    // > NSWindow, and NSWindowController.
    // >
    // > In addition, in OS X no classes in the AV Foundation framework support weak references.
    //
    // NSMenuView is deprecated (and not available to 64-bit applications).
    // NSSimpleHorizontalTypesetter is an internal class.
    
    if ([delegate isKindOfClass:[NSATSTypesetter class]])    return NO;
    if ([delegate isKindOfClass:[NSColorSpace class]])       return NO;
    if ([delegate isKindOfClass:[NSFont class]])             return NO;
    if ([delegate isKindOfClass:[NSFontManager class]])      return NO;
    if ([delegate isKindOfClass:[NSFontPanel class]])        return NO;
    if ([delegate isKindOfClass:[NSImage class]])            return NO;
    if ([delegate isKindOfClass:[NSParagraphStyle class]])   return NO;
    if ([delegate isKindOfClass:[NSTableCellView class]])    return NO;
    if ([delegate isKindOfClass:[NSTextView class]])         return NO;
    if ([delegate isKindOfClass:[NSViewController class]])   return NO;
    if ([delegate isKindOfClass:[NSWindow class]])           return NO;
    if ([delegate isKindOfClass:[NSWindowController class]]) return NO;
    
    return YES;
}
#endif

- (id)initWithDelegate:(id)inDelegate delegateQueue:(dispatch_queue_t)inDelegateQueue
{
    if ((self = [super init]))
    {
        #if __has_feature(objc_arc_weak) && !TARGET_OS_IPHONE
        {
            if (SupportsWeakReferences(inDelegate))
            {
                delegate = inDelegate;
                delegateQueue = inDelegateQueue;
            }
            else
            {
                delegate = [NSNull null];
                
                unsafeDelegate = inDelegate;
                delegateQueue = inDelegateQueue;
            }
        }
        #else
        {
            delegate = inDelegate;
            delegateQueue = inDelegateQueue;
        }
        #endif
        
        #if !OS_OBJECT_USE_OBJC
        if (delegateQueue)
            dispatch_retain(delegateQueue);
        #endif
    }
    return self;
}

- (void)dealloc
{
    #if !OS_OBJECT_USE_OBJC
    if (delegateQueue)
        dispatch_release(delegateQueue);
    #endif
}

@end

#pragma mark - TIOBoradcastDelegateEnumerator

@implementation TIOBoradcastDelegateEnumerator

- (id)initFromDelegateNodes:(NSMutableArray *)inDelegateNodes
{
    if ((self = [super init]))
    {
        delegateNodes = [inDelegateNodes copy];
        
        numNodes = [delegateNodes count];
        currentNodeIndex = 0;
    }
    return self;
}

- (NSUInteger)count
{
    return numNodes;
}

- (NSUInteger)countOfClass:(Class)aClass
{
    NSUInteger count = 0;
    
    for (TIOBoradcastDelegateNode *node in delegateNodes)
    {
        id nodeDelegate = node.delegate;
        #if __has_feature(objc_arc_weak) && !TARGET_OS_IPHONE
        if (nodeDelegate == [NSNull null])
            nodeDelegate = node.unsafeDelegate;
        #endif
        
        if ([nodeDelegate isKindOfClass:aClass])
        {
            count++;
        }
    }
    
    return count;
}

- (NSUInteger)countForSelector:(SEL)aSelector
{
    NSUInteger count = 0;
    
    for (TIOBoradcastDelegateNode *node in delegateNodes)
    {
        id nodeDelegate = node.delegate;
        #if __has_feature(objc_arc_weak) && !TARGET_OS_IPHONE
        if (nodeDelegate == [NSNull null])
            nodeDelegate = node.unsafeDelegate;
        #endif
        
        if ([nodeDelegate respondsToSelector:aSelector])
        {
            count++;
        }
    }
    
    return count;
}

- (BOOL)getNextDelegate:(id *)delPtr delegateQueue:(dispatch_queue_t *)dqPtr
{
    while (currentNodeIndex < numNodes)
    {
        TIOBoradcastDelegateNode *node = delegateNodes[currentNodeIndex];
        currentNodeIndex++;
        
        id nodeDelegate = node.delegate;
        #if __has_feature(objc_arc_weak) && !TARGET_OS_IPHONE
        if (nodeDelegate == [NSNull null])
            nodeDelegate = node.unsafeDelegate;
        #endif
        
        if (nodeDelegate)
        {
            if (delPtr) *delPtr = nodeDelegate;
            if (dqPtr)  *dqPtr  = node.delegateQueue;
            
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)getNextDelegate:(id *)delPtr delegateQueue:(dispatch_queue_t *)dqPtr ofClass:(Class)aClass
{
    while (currentNodeIndex < numNodes)
    {
        TIOBoradcastDelegateNode *node = delegateNodes[currentNodeIndex];
        currentNodeIndex++;
        
        id nodeDelegate = node.delegate; // snapshot atomic property
        #if __has_feature(objc_arc_weak) && !TARGET_OS_IPHONE
        if (nodeDelegate == [NSNull null])
            nodeDelegate = node.unsafeDelegate;
        #endif
        
        if ([nodeDelegate isKindOfClass:aClass])
        {
            if (delPtr) *delPtr = nodeDelegate;
            if (dqPtr)  *dqPtr  = node.delegateQueue;
            
            return YES;
        }
    }
    
    return NO;
}

- (BOOL)getNextDelegate:(id *)delPtr delegateQueue:(dispatch_queue_t *)dqPtr forSelector:(SEL)aSelector
{
    while (currentNodeIndex < numNodes)
    {
        TIOBoradcastDelegateNode *node = delegateNodes[currentNodeIndex];
        currentNodeIndex++;
        
        id nodeDelegate = node.delegate; // snapshot atomic property
        #if __has_feature(objc_arc_weak) && !TARGET_OS_IPHONE
        if (nodeDelegate == [NSNull null])
            nodeDelegate = node.unsafeDelegate;
        #endif
        
        if ([nodeDelegate respondsToSelector:aSelector])
        {
            if (delPtr) *delPtr = nodeDelegate;
            if (dqPtr)  *dqPtr  = node.delegateQueue;
            
            return YES;
        }
    }
    
    return NO;
}

@end

