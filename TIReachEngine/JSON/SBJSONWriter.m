//
//	Copyright (C) 2009 Stig Brautaset. All rights reserved.
// 
//	Redistribution and use in source and binary forms, with or without
//	modification, are permitted provided that the following conditions are met:
//
//		1. Redistributions of source code must retain the above copyright notice, this
//		   list of conditions and the following disclaimer.
// 
//		2. Redistributions in binary form must reproduce the above copyright notice,
//		   this list of conditions and the following disclaimer in the documentation
//		   and/or other materials provided with the distribution.
// 
//		3. Neither the name of the author nor the names of its contributors may be used
//		   to endorse or promote products derived from this software without specific
//		   prior written permission.
// 
//	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
//	AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
//	IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
//	DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
//	FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
//	DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
//	SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
//	CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
//	OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
//	OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
//

#import "SBJSONWriter.h"

@interface SBJSONWriter ()
- (BOOL)appendValue:(id)fragment into:(NSMutableString *)JSON;
- (BOOL)appendArray:(NSArray *)fragment into:(NSMutableString *)JSON;
- (BOOL)appendDictionary:(NSDictionary *)fragment into:(NSMutableString *)JSON;
- (BOOL)appendString:(NSString *)fragment into:(NSMutableString *)JSON;
@end

@implementation SBJSONWriter
@synthesize sortKeys;

static NSMutableCharacterSet *kEscapeChars;

+ (void)initialize {
	kEscapeChars = [[NSMutableCharacterSet characterSetWithRange: NSMakeRange(0,32)] retain];
	[kEscapeChars addCharactersInString: @"\"\\"];
}

- (NSString *)stringWithObject:(id)value {
    [self clearErrorTrace];
    
    if ([value isKindOfClass:[NSDictionary class]] || [value isKindOfClass:[NSArray class]]){
        depth = 0;
        NSMutableString *JSON = [NSMutableString stringWithCapacity:128];
        if ([self appendValue:value into:JSON])
            return JSON;
    }
    
    if ([value respondsToSelector:@selector(proxyForJSON)]){
        NSString *tmp = [self stringWithObject:[value proxyForJSON]];
        if (tmp)
            return tmp;
    }
        
    [self addErrorWithCode:EFRAGMENT description:@"Not valid type for JSON"];
    return nil;
}

- (NSString *)stringWithObject:(id)value error:(NSError **)error {
	
    NSString * tmp = [self stringWithObject:value];
	
    if (tmp){
        return tmp;
	}
    
    if (error){
        *error = [self.errorTrace lastObject];
	}
	
    return nil;
}

- (BOOL)appendValue:(id)fragment into:(NSMutableString *)JSON {
	
    if ([fragment isKindOfClass:[NSDictionary class]]){
		
        if (![self appendDictionary:fragment into:JSON]){
            return NO;
		}
        
    }
	
	else if ([fragment isKindOfClass:[NSArray class]]){
		
        if (![self appendArray:fragment into:JSON]){
            return NO;
		}
        
    } 
	
	else if ([fragment isKindOfClass:[NSString class]]){
		
        if (![self appendString:fragment into:JSON]){
            return NO;
		}
        
    } 
	
	else if ([fragment isKindOfClass:[NSNumber class]]){
		
        if ('c' == *[fragment objCType]){
            [JSON appendString:[fragment boolValue] ? @"true" : @"false"];
        } 
		else if ([fragment isEqualToNumber:[NSDecimalNumber notANumber]]){
            [self addErrorWithCode:EUNSUPPORTED description:@"NaN is not a valid number in JSON"];
            return NO;

        } 
		else if ([fragment isEqualToNumber:[NSNumber numberWithDouble:INFINITY]] || [fragment isEqualToNumber:[NSNumber numberWithDouble:-INFINITY]]){
            [self addErrorWithCode:EUNSUPPORTED description:@"Infinity is not a valid number in JSON"];
            return NO;

        } 
		else 
		{
            [JSON appendString:[fragment stringValue]];
        }
		
    } 
	
	else if ([fragment isKindOfClass:[NSNull class]]){
        [JSON appendString:@"null"];
    } 
	
	else if ([fragment respondsToSelector:@selector(proxyForJSON)]){
        [self appendValue:[fragment proxyForJSON] into:JSON];
        
    }
	
	else
	{
        [self addErrorWithCode:EUNSUPPORTED description:[NSString stringWithFormat:@"JSON serialisation not supported for %@", [fragment class]]];
        return NO;
    }
	
    return YES;
}

- (BOOL)appendArray:(NSArray *)fragment into:(NSMutableString *)JSON {
	
    if (maxDepth && ++depth > maxDepth){
        [self addErrorWithCode:EDEPTH description: @"Nested too deep"];
        return NO;
    }
	
    [JSON appendString:@"["];
	
    for (id value in fragment){
        
        if (![self appendValue:value into:JSON]){
            return NO;
        }
		
		if (value != [fragment lastObject]){
			[JSON appendString:@","];
		}
    }
    
    depth--;
	
    [JSON appendString:@"]"];
	
    return YES;
}

- (BOOL)appendDictionary:(NSDictionary *)fragment into:(NSMutableString *)JSON {
	
    if (maxDepth && ++depth > maxDepth){
        [self addErrorWithCode:EDEPTH description: @"Nested too deep"];
        return NO;
    }
	
    [JSON appendString:@"{"];
	
    NSArray * keys = [fragment allKeys];
    if (sortKeys){
        keys = [keys sortedArrayUsingSelector:@selector(compare:)];
	}
    
    for (id value in keys){
        
        if (![value isKindOfClass:[NSString class]]){
            [self addErrorWithCode:EUNSUPPORTED description: @"JSON object key must be string"];
            return NO;
        }
        
        if (![self appendString:value into:JSON]){
            return NO;
		}
        
        [JSON appendString:@":"];
		
        if (![self appendValue:[fragment objectForKey:value] into:JSON]){
            [self addErrorWithCode:EUNSUPPORTED description:[NSString stringWithFormat:@"Unsupported value for key %@ in object", value]];
            return NO;
        }
		
		if (value != [keys lastObject]){
			[JSON appendString:@","];
		}
    }
    
    depth--;
	
    [JSON appendString:@"}"];
	
    return YES;    
}

- (BOOL)appendString:(NSString *)fragment into:(NSMutableString *)JSON {
    
    [JSON appendString:@"\""];
	
    if (![fragment rangeOfCharacterFromSet:kEscapeChars].length){
        [JSON appendString:fragment];
    } 
	else
	{
        NSUInteger length = [fragment length];
		
        for (NSUInteger i = 0; i < length; i++){
			
            unichar uc = [fragment characterAtIndex:i];
            switch (uc){
                case '"':
					[JSON appendString:@"\\\""];
					break;
                case '\\':
					[JSON appendString:@"\\\\"];
					break;
                case '\t':
					[JSON appendString:@"\\t"];
					break;
                case '\n':
					[JSON appendString:@"\\n"];
					break;
                case '\r':
					[JSON appendString:@"\\r"];
					break;
                case '\b':
					[JSON appendString:@"\\b"];
					break;
                case '\f':
					[JSON appendString:@"\\f"];
					break;
                default:    
                    if (uc < 0x20){
                        [JSON appendFormat:@"\\u%04x", uc];
                    } 
					else
					{
                        CFStringAppendCharacters((CFMutableStringRef)JSON, &uc, 1);
                    }
                    break;
                    
            }
        }
    }
    
    [JSON appendString:@"\""];
	
    return YES;
}


@end
