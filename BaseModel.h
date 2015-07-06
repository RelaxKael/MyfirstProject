#import <Foundation/Foundation.h>

#define defaultArrayIvalKey @"goalArray"


#define ziz_EnityIntergerProperty(a)  @property (nonatomic , assign)NSInteger a
#define ziz_EnityStringProperty(a)  @property (nonatomic , strong)NSString *a
#define ziz_EnityArrayProperty(a)  @property (nonatomic , strong)NSArray *a
#define ziz_EnityAttributeProperty(a,b) @property (nonatomic , strong) a *b
@interface BaseModel : NSObject
ziz_EnityIntergerProperty(success);
ziz_EnityIntergerProperty(statusCode);
ziz_EnityStringProperty(msg);
ziz_EnityIntergerProperty(lagoutFlag);

- (id)initWithDictionary:(NSDictionary *)dic;

- (void)ConfigureWithDictionary:(NSDictionary *)dict;
#warning 在子类中实现此工厂方法
- (Class)getSetEntityClassWithKey:(NSString *)key;

@end
