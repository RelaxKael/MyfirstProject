# MyfirstProject
first public repository
hello ,this's my first time to show my code in github ,i'll glad to receive your suggestions (my english is very poor<D).

/////BaseModel.h///////
this class is a auto-parser tool that use in request was  finished, you only need to define property if necessary in subclass. there are some tips that needs catch your attention when you use it.
1.At the moment, property is only supported NSString,NSIntger,NSArray,ClassName(SubClassName);
2.I only exampled a circumstance that parser a jsonDict , you can do some edit if you used in parsar xml;
3.when you used this class in your project and initial a project, You have to implement the method who marked 'Warnning' in BaseModel.h when you propertied a NSArray-Type property. your project will receive a crash if you didn't implement .
4.you should name you property with you element's name in datasource as well as your possiable ,otherwise, you can use this method 'checkTheKeyDataSource' to convert your different key . for example, you can property a key named 'ID' Even if the key matched ’id‘ in datasource.
