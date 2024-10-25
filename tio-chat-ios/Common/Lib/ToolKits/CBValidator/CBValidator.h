//
//  CBValidator.h
//  CawBar
//
//  Created by 刘宇 on 2017/10/17.
//

#ifndef CBValidator_h
#define CBValidator_h

@protocol CBValidator <NSObject>

@required

+ (BOOL)validateText:(NSString *)text error:(NSError **)error;

@end

#endif /* CBValidator_h */
