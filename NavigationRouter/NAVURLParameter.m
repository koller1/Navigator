//
//  NAVParameter.m
//  Created by Ty Cobb on 7/17/14.
//

#import "NAVURLParameter.h"

@implementation NAVURLParameter

- (instancetype)initWithKey:(NSString *)key options:(NSNumber *)optionsValue
{
    if(self = [super initWithKey:key])
        _options = [optionsValue integerValue];
    return self;
}

- (BOOL)isVisible
{
    return self.options & NAVParameterOptionsVisible;
}

# pragma mark - Description

- (NSString *)description
{
    return [[super description] stringByAppendingFormat:@" %@: %@", self.key, [self stringFromOptions:self.options]];
}

- (NSString *)stringFromOptions:(NAVParameterOptions)options
{
    NSMutableString *optionString = [NSMutableString new];
    if(options & NAVParameterOptionsHidden)
        [optionString appendString:@"h"];
    if(options & NAVParameterOptionsVisible)
        [optionString appendString:@"v"];
    if(options & NAVParameterOptionsUnanimated)
        [optionString appendString:@"u"];
    return [optionString copy];
}

@end
