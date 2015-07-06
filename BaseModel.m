#import "BaseModel.h"
#import <objc/runtime.h>
@implementation BaseModel

- (id)initWithDictionary:(NSDictionary *)dic
{
    if (dic != nil) {
        
        self = [super init];
        [self ConfigureWithDictionary:dic];
        return self;
    }

    return nil;
}
//从c++命名方案转换成OC命名方案
//已知user_ID 赋值到userID
//已知pictures_thumb_small 赋值到picturesThumbSmall
//- (NSString *)convertCNameSpaceToObjectCNameSpace:(NSString *)gnamespace
//{
//    
//    NSString *objNameSpaceString = gnamespace;
//    NSRange sepRange = [objNameSpaceString rangeOfString:@"_"];
//    
//    while (sepRange.length!=0) {
//        if(sepRange.location<objNameSpaceString.length)
//        {
//            NSString *mark = [objNameSpaceString substringWithRange:NSMakeRange(sepRange.location, 2)];
//            NSString *lastMark = [[mark substringWithRange:NSMakeRange(mark.length-1, 1)] uppercaseString];
//            objNameSpaceString   = [objNameSpaceString stringByReplacingOccurrencesOfString:mark withString:lastMark];
//            sepRange = [objNameSpaceString rangeOfString:@"_"];
//        }
//        else
//        {
//            break;
//        }
//    }
//    return objNameSpaceString;
//}
//从OC命名方案转换成C++命名方案
//已知userID 赋值到user_id
//已知picturesThumbSmall 赋值到pictures_thumb_small
//- (NSString *)convertOCNameSpaceToCNameSpace:(NSString *)ocnamespace
//{
//    NSString *regexStr = @"[A-Z]+";
//    NSString *ocNameSpaceStr = ocnamespace;
//    NSRegularExpression* regex = [[NSRegularExpression alloc]
//                                  initWithPattern:regexStr
//                                  options:NSRegularExpressionDotMatchesLineSeparators
//                                  error:nil];
//    NSArray* chunks = [regex matchesInString:ocNameSpaceStr options:0 range:NSMakeRange(0, [ocNameSpaceStr length])];
//    NSUInteger checkCount = 0;
//    for(int i = 0 ; i<chunks.count;i++)
//    {
//        NSTextCheckingResult *currentResult = [chunks objectAtIndex:i];
//        
//        //匹配到大写字母
//        NSString *mark = [ocNameSpaceStr substringWithRange:NSMakeRange(currentResult.range.location+checkCount, currentResult.range.length)];
//        
//        NSString *convertMark = [NSString stringWithFormat:@"_%@",[mark lowercaseString]];
//        ocNameSpaceStr = [ocNameSpaceStr stringByReplacingCharactersInRange:NSMakeRange(currentResult.range.location+checkCount, currentResult.range.length) withString:convertMark];
//        checkCount++;
//    }
//    return ocNameSpaceStr;
//}
//这个方法用于替换掉一些与命名规则冲突的情况如userID 转换成user_id 但是项目中的key值是user_ID
- (NSString *)checkTheKeyDataSource:(NSString *)key
{
    if([key isEqualToString:@"accountName"])
    {
        return @"accountTitle";
    }
    if([key isEqualToString:@"roomId"])
    {
        return @"id";
    }
    if([key isEqualToString:@"cid"]||[key isEqualToString:@"ID"])
    {
        return @"id";
    }
    return key;
}
- (BOOL)getNecessaryNilKey:(NSString *)key
{
    
    if([key isEqualToString:@"hConfNo"])
    {
        return NO;
    }
    return YES;
}
- (void)ConfigureWithDictionary:(NSDictionary *)dict
{
    
    // This check serves to make sure that a non-NSDictionary object
    // passed into the model class doesn't break the parsing.
    if(self && [dict isKindOfClass:[NSDictionary class]]) {
        
        NSMutableArray *propertyArray = [NSMutableArray arrayWithArray: [self getClassPropertys:[self class]]];
        if([[self class] isSubclassOfClass:[BaseModel class]])
        {
            [propertyArray addObjectsFromArray:[self getClassPropertys:[BaseModel class]]];
        }
        for(NSDictionary *keyAndtype in propertyArray)
        {
            [keyAndtype enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                NSString *classType = (NSString *)obj;
                Class Subclass = NSClassFromString(classType);
                if([Subclass isSubclassOfClass:[BaseModel class]])
                {
                    //得到下级数据的字典
                    id obj = [dict objectForKey:key];
                    if([obj isKindOfClass:[NSDictionary class]])
                    {
                        NSDictionary *AttributeDict = (NSDictionary *)obj;
                        BaseModel *subkindobject = [[Subclass alloc]init];
                        [subkindobject ConfigureWithDictionary:AttributeDict];
                        [self setValue:subkindobject forKey:key];
                    }
                }
                else if([Subclass isSubclassOfClass:[NSArray class]])
                {
                    //得到下级数据的字典/数组(此处的key对应的是关系有一对一 一对多)
                    id obj = [dict objectForKey:key];
                    Class SetSubClass = [self getSetEntityClassWithKey:key];
                    if([obj isKindOfClass:[NSArray class]])
                    {
                        NSMutableArray *GoalArray = [[NSMutableArray alloc]init];
                        NSArray *AttributeDict = (NSArray *)obj;
                        for(NSDictionary *subDict in AttributeDict)
                        {
                            BaseModel *subkindobject = [[SetSubClass alloc]init];
                            [subkindobject ConfigureWithDictionary:subDict];
                            //                            [self setValue:subkindobject forKey:key];
                            [GoalArray addObject:subkindobject];
                        }
                        [self setValue:GoalArray forKey:key];
                    }
                    else
                    {
                        [self setValue:[[NSArray alloc]init] forKey:key];
                    }
                }
                else if ([Subclass isSubclassOfClass:[NSString class]])
                {
                    
                    NSString *dictKey = key;
                    id obj = [dict objectForKey:[self checkTheKeyDataSource:dictKey]];
                    if([obj isKindOfClass:[NSArray class]])
                    {
                        NSLog(@"找不到节点名为%@的var 该节点为%@的对象",[self checkTheKeyDataSource:dictKey],[self checkTheKeyDataSource:dictKey]);
                    }
                    if(obj!=nil)
                    {
                        
                        if([obj isKindOfClass:[NSString class]])
                        {
                            [self setValue:obj  forKey:key];
                        }
                        else if ([obj isKindOfClass:[NSNull class]])
                        {
                            [self setValue:@"" forKey:key];
                        }
                        else
                        {
                            [self setValue:[obj stringValue]  forKey:key];
                        }
                    }
                    else
                    {
                        if([self getNecessaryNilKey:key])
                        {
                            [self setValue:@""  forKey:key];
                        }
                        
                    }
                }
                else
                {
                    NSString *dictKey = key;
                    id obj = [dict objectForKey:[self checkTheKeyDataSource:dictKey]];
                    if(obj!=nil)
                    {
                        [self setValue:obj forKey:key];
//                        if([classType isEqualToString:@"NSInteger"])
//                        {
//                            [self setValue:[NSNumber numberWithInteger:(NSInteger)obj] forKey:key];
//                        }
//                        else if([classType isEqualToString:@"double"])
//                        {
//                            double doublevalue = (double)obj;
//                            [self setValue:[NSNumber numberWithDouble:(double)obj] forKey:key];
//
//                        }
                    }
                    else
                    {
                        [self setValue:[NSNumber numberWithInt:0] forKey:key];
                    }
                }

                
                
            }];
        }
    }
    
    return ;
    
}

// 获取某个类自身的所有属性
- (NSArray *)getClassPropertys:(Class)classInstance {
    NSMutableArray *classPropertyDics = [[NSMutableArray alloc] init];
    
    u_int count;
    objc_property_t *properties  = class_copyPropertyList(classInstance, &count);
    for (int i = 0; i < count ; i++) {
        const char* propertyName = property_getName(properties[i]);
        const char* propertyAttributes = property_getAttributes(properties[i]);
        NSString *name = [NSString stringWithUTF8String:propertyName];
        NSString *attribute = [NSString stringWithUTF8String:propertyAttributes];
        NSString *attributeType = [self parseAttributeType:attribute];
        
        NSMutableDictionary *propertyDic = [[NSMutableDictionary alloc] init];
        [propertyDic setObject:attributeType forKey:name];
        [classPropertyDics insertObject:propertyDic atIndex:0];
        //        [classPropertyDics insertObject:name atIndex:0];
    }
    free(properties);
    
    return (NSArray *)classPropertyDics;
}
- (NSString *)parseAttributeType:(NSString *)Attributes {
    NSRange leftRange = [Attributes rangeOfString:@"\""];
    if(leftRange.length==1)
    {
        NSString *temp1 = [Attributes substringFromIndex:leftRange.location+1];
        NSRange rightRange = [temp1 rangeOfString:@"\""];
        NSString *temp2 = [temp1 substringToIndex:rightRange.location];
        return temp2;
    }
    return Attributes;
}
@end
