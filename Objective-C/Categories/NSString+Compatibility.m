#import "NSString+Compatibility.h"

@implementation NSString (Compatibility)
- (NSString *)compatibilityString {
    NSString *string = [self copy];
    string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    string = [string stringByReplacingCurlyWithStraight];
    return string;
}
- (NSString *)stringByReplacingCurlyWithStraight {
    NSString *string = [self copy];
    string = [string stringByReplacingOccurrencesOfString:@"“" withString:@"\""];
    string = [string stringByReplacingOccurrencesOfString:@"”" withString:@"\""];
    string = [string stringByReplacingOccurrencesOfString:@"‘" withString:@"'"];
    string = [string stringByReplacingOccurrencesOfString:@"’" withString:@"'"];
    return string;
}
@end