//
//  TSortString.m
//  tio-chat-ios
//
//  Created by 刘宇 on 2020/2/7.
//  Copyright © 2020 刘宇. All rights reserved.
//

#import "TSortString.h"
#import <objc/runtime.h>
#import <ImageIO/ImageIO.h>
#import <libkern/OSAtomic.h>


NSString *const CYPinyinGroupResultArray = @"CYPinyinGroupResultArray";

NSString *const CYPinyinGroupCharArray = @"CYPinyinGroupCharArray";

@implementation TSortString


static dispatch_queue_t YYAsyncLayerGetDisplayQueue() {
//最大队列数量
#define MAX_QUEUE_COUNT 16
//队列数量
    static int queueCount;
//使用栈区的数组存储队列
    static dispatch_queue_t queues[MAX_QUEUE_COUNT];
    static dispatch_once_t onceToken;
    static int32_t counter = 0;
    dispatch_once(&onceToken, ^{
//串行队列数量和处理器数量相同
        queueCount = (int)[NSProcessInfo processInfo].activeProcessorCount;
        queueCount = queueCount < 1 ? 1 : queueCount > MAX_QUEUE_COUNT ? MAX_QUEUE_COUNT : queueCount;
//创建串行队列，设置优先级
        if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0) {
            for (NSUInteger i = 0; i < queueCount; i++) {
                dispatch_queue_attr_t attr = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_SERIAL, QOS_CLASS_USER_INITIATED, 0);
                queues[i] = dispatch_queue_create("com.ibireme.yykit.render", attr);
            }
        } else {
            for (NSUInteger i = 0; i < queueCount; i++) {
                queues[i] = dispatch_queue_create("com.ibireme.yykit.render", DISPATCH_QUEUE_SERIAL);
                dispatch_set_target_queue(queues[i], dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
            }
        }
    });
//轮询返回队列
    uint32_t cur = (uint32_t)OSAtomicIncrement32(&counter);
    return queues[cur % queueCount];
#undef MAX_QUEUE_COUNT
}

+ (NSMutableArray *)sortForStringAry:(NSArray *)ary {
    NSMutableArray *sortAry = [NSMutableArray arrayWithArray:ary];
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:nil ascending:YES];
    NSArray *descriptorAry = [NSArray arrayWithObject:descriptor];
    [sortAry sortUsingDescriptors:descriptorAry];
    
    //将 # 数据放到末尾
    NSMutableArray *removeAry = [NSMutableArray new];
    for (NSString *str in sortAry){
        if ([str isEqualToString:@"#"]) {
            [removeAry addObject:str];
            break;
        }
    }
    [sortAry removeObjectsInArray:removeAry];
    [sortAry addObjectsFromArray:removeAry];
    
    return sortAry;
}

+ (NSMutableArray *)getAllValuesFromDict:(NSDictionary *)dict {
    NSMutableArray *valuesAry = [NSMutableArray new];
    NSArray *keyAry = [self sortForStringAry:[dict allKeys]];
    for (NSString *key in keyAry){
        NSArray *value = [dict objectForKey:key];
        [valuesAry addObjectsFromArray:value];
    }
    return valuesAry;
}

+ (NSMutableDictionary *)sortAndGroupForArray:(NSArray *)ary PropertyName:(NSString *)name nextPropertyName:(NSString *)nextName
{
    NSMutableDictionary *sortDic = [NSMutableDictionary new];
    
    return sortDic;
}

+ (void)sortAndGroupForArray:(NSArray *)ary PropertyName:(NSString *)name nextPropertyName:(nullable NSString *)nextName callback:(void(^)(NSMutableDictionary *))callback
{
    __block NSMutableDictionary *sortDic = [NSMutableDictionary new];
    __block NSMutableArray *sortAry = [NSMutableArray new];
    NSMutableArray *objAry = [NSMutableArray new];
    NSString *type;
    
    if (ary.count <= 0) {
        callback(sortDic);
    }
    
    id objc = ary.firstObject;
    if ([objc isKindOfClass:[NSString class]]) {
        type = @"string";
        for (NSString *str in ary){
            TSortString *sortString = [TSortString new];
            sortString.string = str;
            [objAry addObject:sortString];
        }
    }else if ([objc isKindOfClass:[NSDictionary class]]){
        type = @"dict";
        for (NSDictionary *dict in ary){
            TSortString *sortString = [TSortString new];
            sortString.string = dict[name];
            [objAry addObject:sortString];
        }
    }else{
        type = @"model";
        unsigned int propertyCount, i;
        objc_property_t *properties = class_copyPropertyList([objc class], &propertyCount);
        for (NSObject *obj in ary){
            TSortString *sortString = [TSortString new];
            sortString.model = obj;
            for (i = 0; i < propertyCount; i++) {
                objc_property_t property = properties[i];
                const char *char_name = property_getName(property);
                NSString *propertyName = [NSString stringWithUTF8String:char_name];
                if ([propertyName isEqualToString:name]) {
                    id propertyValue = [obj valueForKey:(NSString *)propertyName];
                    
                    if ([propertyValue isKindOfClass:[NSString class]]) {
                        NSString *value = propertyValue;
                        if (value.length != 0) {
                            sortString.string = propertyValue;
                            [objAry addObject:sortString];
                        } else {
                            id propertyValue = [obj valueForKey:(NSString *)nextName];
                            sortString.string = propertyValue;
                            [objAry addObject:sortString];
                        }
                    } else {
                        id propertyValue = [obj valueForKey:(NSString *)nextName];
                        sortString.string = propertyValue;
                        [objAry addObject:sortString];
                    }
                    break;
                }
                if (i == propertyCount -1) {
                    //
                    callback(sortDic);
                }
            }
        }
    }
    
    NSLog(@"sortAsInitialWithArray - start");
    [self sortAsInitialWithArray:objAry callback:^(NSMutableArray *arr) {
        NSLog(@"sortAsInitialWithArray - end");
        sortAry = arr;
        NSMutableArray *item = [NSMutableArray array];
        NSString *itemString;
        for (TSortString *sort in sortAry){
            //首字母不同则item重新初始化，相同则共用一个item
            if (![itemString isEqualToString:sort.initial]) {
                itemString = sort.initial;
                item = [NSMutableArray array];
                if ([type isEqualToString:@"string"]) {
                    [item addObject:sort.string];
                }else if ([type isEqualToString:@"model"]){
                    [item addObject:sort.model];
                }else {
                    [item addObject:sort.string];
                }
                [sortDic setObject:item forKey:itemString];
            }else{
                //item已添加到 regularAry，所以item数据改变时，对应regularAry中也会改变
                if ([type isEqualToString:@"string"]) {
                    [item addObject:sort.string];
                }else if ([type isEqualToString:@"model"]){
                    [item addObject:sort.model];
                }else {
                    [item addObject:sort.string];
                }
            }
        }
        
        callback(sortDic);
    }];
}

/**
 *  将数组按首字母排序
 */
+ (void)sortAsInitialWithArray:(NSArray *)ary callback:(void(^)(NSMutableArray *))callback
{
    //存储包含首字母和字符串的对象
    
    NSMutableArray *objectAry = [NSMutableArray array];
    
    //遍历的同时把首字符和对应的字符串存入到srotString对象属性中
    NSLog(@"遍历数组，计算首字母");
    
    if (ary.count > 4000) {
        
        NSInteger count = 2;
        
        NSMutableArray<NSArray *> *nArrays = [NSMutableArray arrayWithCapacity:count];
        NSMutableArray<NSMutableArray *> *dataArrays = [NSMutableArray arrayWithCapacity:count];
        
        NSInteger avrageCount = ary.count / count;
        
        for (int i = 0; i < count; i++) {
            if (i == count-1) {
                [nArrays addObject:[NSArray arrayWithArray:[ary subarrayWithRange:NSMakeRange(i * avrageCount, ary.count - i * avrageCount)]]];
                [dataArrays addObject:[NSMutableArray arrayWithCapacity:ary.count - i * avrageCount]];
            } else {
                [nArrays addObject:[NSArray arrayWithArray:[ary subarrayWithRange:NSMakeRange(i * avrageCount, avrageCount)]]];
                [dataArrays addObject:[NSMutableArray arrayWithCapacity:avrageCount]];
            }
        }
        
        dispatch_queue_t queue = dispatch_queue_create("myqueue", DISPATCH_QUEUE_CONCURRENT);
        dispatch_group_t group = dispatch_group_create();
        
        
        for (int m = 0; m < count; m++) {
            dispatch_group_enter(group);
            dispatch_group_async(group, queue, ^{
                for (int i = 0; i  < nArrays[m].count; i++) {
                    TSortString *sortString = nArrays[m][i];
                    sortString.englishString = [TSortString transform:sortString.string];
                    
                    if (sortString.string == nil) {
                        sortString.string = @"";
                    }
                    
                    //判断首字符是否为字母
                    NSString *regex = @"[A-Za-z]+";
                    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
                    //得到字符串首个字符
                    NSString *header = [sortString.string substringToIndex:1];
                    if ([predicate evaluateWithObject:header]) {
                        sortString.initial = [header capitalizedString];
                    }else{
                        
                        if (![sortString.string isEqualToString:@""]) {
                            //特殊处理的一个字
                            if ([header isEqualToString:@"长"]) {
                                sortString.initial = @"C";
                                sortString.englishString = [sortString.englishString stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@"C"];
                            }else{
                                
                                char initial = [sortString.englishString characterAtIndex:0];
                                if (initial >= 'A' && initial <= 'Z') {
                                    sortString.initial = [NSString stringWithFormat:@"%c",initial];
                                }else{
                                    sortString.initial = @"#";
                                }
                            }
                        }else{
                            sortString.initial = @"#";
                        }
                    }
                    [dataArrays[m] addObject:sortString];
                }
                dispatch_group_leave(group);
            });
        }
        
        dispatch_group_notify(group, dispatch_get_main_queue(), ^{
            NSLog(@"首字母计算完成");

            for (NSMutableArray *arr  in dataArrays) {
                [objectAry addObjectsFromArray:arr];
            }
            
            NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"initial" ascending:YES];
            NSSortDescriptor *descriptor2 = [NSSortDescriptor sortDescriptorWithKey:@"englishString" ascending:YES];
            NSArray *descriptorAry = [NSArray arrayWithObjects:descriptor,descriptor2, nil];
            [objectAry sortUsingDescriptors:descriptorAry];
            
            callback(objectAry);
        });
        
    } else {
        dispatch_async(YYAsyncLayerGetDisplayQueue(), ^{
            [ary enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                TSortString *sortString = ary[idx];
                sortString.englishString = [TSortString transform:sortString.string];
                
                if (sortString.string == nil) {
                    sortString.string = @"";
                }
                
                //判断首字符是否为字母
                NSString *regex = @"[A-Za-z]+";
                NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
                //得到字符串首个字符
                NSString *header = [sortString.string substringToIndex:1];
                if ([predicate evaluateWithObject:header]) {
                    sortString.initial = [header capitalizedString];
                }else{
                    
                    if (![sortString.string isEqualToString:@""]) {
                        //特殊处理的一个字
                        if ([header isEqualToString:@"长"]) {
                            sortString.initial = @"C";
                            sortString.englishString = [sortString.englishString stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@"C"];
                        }else{
                            
                            char initial = [sortString.englishString characterAtIndex:0];
                            if (initial >= 'A' && initial <= 'Z') {
                                sortString.initial = [NSString stringWithFormat:@"%c",initial];
                            }else{
                                sortString.initial = @"#";
                            }
                        }
                    }else{
                        sortString.initial = @"#";
                    }
                }
                [objectAry addObject:sortString];
            }];
            
            NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:@"initial" ascending:YES];
            NSSortDescriptor *descriptor2 = [NSSortDescriptor sortDescriptorWithKey:@"englishString" ascending:YES];
            NSArray *descriptorAry = [NSArray arrayWithObjects:descriptor,descriptor2, nil];
            [objectAry sortUsingDescriptors:descriptorAry];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                callback(objectAry);
            });
        });
    }
//    for (NSInteger index = 0; index < ary.count; index++) {
//        TSortString *sortString = ary[index];
//        sortString.englishString = [TSortString transform:sortString.string];
//
//        if (sortString.string == nil) {
//            sortString.string = @"";
//        }
//
//        //判断首字符是否为字母
//        NSString *regex = @"[A-Za-z]+";
//        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
//        //得到字符串首个字符
//        NSString *header = [sortString.string substringToIndex:1];
//        if ([predicate evaluateWithObject:header]) {
//            sortString.initial = [header capitalizedString];
//        }else{
//
//            if (![sortString.string isEqualToString:@""]) {
//                //特殊处理的一个字
//                if ([header isEqualToString:@"长"]) {
//                    sortString.initial = @"C";
//                    sortString.englishString = [sortString.englishString stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@"C"];
//                }else{
//
//                    char initial = [sortString.englishString characterAtIndex:0];
//                    if (initial >= 'A' && initial <= 'Z') {
//                        sortString.initial = [NSString stringWithFormat:@"%c",initial];
//                    }else{
//                        sortString.initial = @"#";
//                    }
//                }
//            }else{
//                sortString.initial = @"#";
//            }
//        }
//        [objectAry addObject:sortString];
//    }
    //先按照首字母initial排序，然后对于首字母相同的再按照englishString排序
}

/**
 * 将中文转化为英文(英文不变)
 *@param   chinese   传入的字符串
 *@return  返回去掉空格并大写的字符串
 */
+ (NSString *)transform:(NSString *)chinese
{
    NSMutableString *english = [chinese mutableCopy];
    CFStringTransform((__bridge CFMutableStringRef)english, NULL, kCFStringTransformMandarinLatin, NO);
    CFStringTransform((__bridge CFMutableStringRef)english, NULL, kCFStringTransformStripCombiningMarks, NO);
    
    //去除两端空格和回车 中间空格不用去，用以区分不同汉字
    [english stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    return [english uppercaseString];
}

+ (void)sortObjectsAccordingToInitialWith:(NSArray *)willSortArr SortKey:(NSString *)sortkey subSortKey:(nonnull NSString *)subSortKey callback:(nonnull void (^)(NSDictionary * _Nonnull))callback
{
//    willSortArr = [willSortArr subarrayWithRange:NSMakeRange(0, willSortArr.count/2)];
    NSLog(@"开始排序");
    
    // 初始化UILocalizedIndexedCollation
    UILocalizedIndexedCollation *collation = [UILocalizedIndexedCollation currentCollation];
    //得出collation索引的数量，这里是27个（26个字母和1个#）
    NSInteger sectionTitlesCount = [[collation sectionTitles] count];
    
    //初始化一个数组newSectionsArray用来存放最终的数据，我们最终要得到的数据模型应该形如@[@[以A开头的数据数组], @[以B开头的数据数组], @[以C开头的数据数组], ... @[以#(其它)开头的数据数组]]
    NSMutableArray *newSectionsArray = [[NSMutableArray alloc] initWithCapacity:sectionTitlesCount];
    
    //初始化27个空数组加入newSectionsArray
    for (NSInteger index = 0; index < sectionTitlesCount; index++) {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        [newSectionsArray addObject:array];
    }
    NSLog(@"newSectionsArray %@ %@",newSectionsArray,collation.sectionTitles);
    NSMutableArray *firstChar = [NSMutableArray arrayWithCapacity:10];
    //将每个名字分到某个section下
    NSLog(@"将每个名字分到某个section下");
    for (id Model in willSortArr) {
         //获取name属性的值所在的位置，比如"林丹"，首字母是L，在A~Z中排第11（第一位是0），sectionNumber就为11
        NSInteger sectionNumber = [collation sectionForObject:Model collationStringSelector:NSSelectorFromString(sortkey)];
         //把name为“林丹”的p加入newSectionsArray中的第11个数组中去
        NSMutableArray *sectionNames = newSectionsArray[sectionNumber];
        [sectionNames addObject:Model];
        NSString * str= collation.sectionTitles[sectionNumber];
        [firstChar addObject:str];
        NSLog(@"sectionNumbersectionNumber %ld %@",sectionNumber,str);
    }
    NSArray *firstCharResult = [self SortFirstChar:firstChar];

    NSLog(@"firstCharResult== %@",firstCharResult);
    //对每个section中的数组按照name属性排序
    
    
    
    
    
    
//    NSLog(@"对每个section中的数组按照name属性排序");
//
//    dispatch_queue_t queue = dispatch_queue_create("myqueue", DISPATCH_QUEUE_CONCURRENT);;// YYAsyncLayerGetDisplayQueue();
//    dispatch_group_t group = dispatch_group_create();
//
//
//
//
//    for (int i = 0; i < newSectionsArray.count; i++) {
//        // 遍历每一个sectionArray
//        dispatch_group_enter(group);
//        dispatch_async(dispatch_get_global_queue(0, 0), ^{
//            NSLog(@"start %d",i);
//            NSArray *personArrayForSection = newSectionsArray[i];
//            dispatch_async(queue, ^{
//                NSArray *sortedPersonArrayForSection = [collation sortedArrayFromArray:personArrayForSection collationStringSelector:NSSelectorFromString(sortkey)];
//                newSectionsArray[i] = sortedPersonArrayForSection;
//                NSLog(@"end %d",i);
//                dispatch_group_leave(group);
//            });
//        });
//    }
//
    
//    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
//        NSLog(@"首字母计算完成");
        
        //删除空的数组
        NSMutableArray *finalArr = [NSMutableArray new];
        for (NSInteger index = 0; index < sectionTitlesCount; index++) {
             if (((NSMutableArray *)(newSectionsArray[index])).count != 0) {
                 [finalArr addObject:newSectionsArray[index]];
             }
        }
        
        callback(@{CYPinyinGroupResultArray:finalArr,
                   CYPinyinGroupCharArray:firstCharResult});
//    });
}

+ (NSArray *)SortFirstChar:(NSArray *)firstChararry
{
    //数组去重复
    NSMutableArray *noRepeat = [[NSMutableArray alloc]initWithCapacity:8];
    NSMutableSet *set = [[NSMutableSet alloc]initWithArray:firstChararry];
    [set enumerateObjectsUsingBlock:^(id obj , BOOL *stop){
        [noRepeat addObject:obj];
    }];
    //字母排序
    NSArray *resultkArrSort1 = [noRepeat sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [obj1 compare:obj2 options:NSNumericSearch];
    }];
    //把”#“放在最后一位
    NSMutableArray *resultkArrSort2 = [[NSMutableArray alloc]initWithArray:resultkArrSort1];
    if ([resultkArrSort2 containsObject:@"#"]) {
        [resultkArrSort2 removeObject:@"#"];
        [resultkArrSort2 addObject:@"#"];
    }

    return resultkArrSort2;
}

@end
