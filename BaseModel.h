//
//  BaseModel.h
//  EaseTogether
//
//  Created by Kane.Zhu on 15/10/19.
//  Copyright © 2015年 Kane.Zhu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BaseModel : NSObject
#define defaultArrayIvalKey @"goalArray"


#define EnityIntergerProperty(a)  @property (nonatomic , assign)NSInteger a
#define EnityStringProperty(a)  @property (nonatomic , strong)NSString *a
#define EnityArrayProperty(a)  @property (nonatomic , strong)NSArray *a
#define EnityNumberProperty(a)  @property (nonatomic , strong)NSNumber *a
#define EnityAttributeProperty(a,b) @property (nonatomic , strong) a *b
EnityIntergerProperty(code);
EnityStringProperty(message);

- (id)initWithDictionary:(NSDictionary *)dic;

- (void)ConfigureWithDictionary:(NSDictionary *)dict;
#warning 在子类中实现此工厂方法
- (Class)getSetEntityClassWithKey:(NSString *)key;
- (NSDictionary *)returnConfigureDict;
@end
