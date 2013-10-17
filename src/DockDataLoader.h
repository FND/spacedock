#import <Foundation/Foundation.h>

@interface DockDataLoader : NSObject <NSXMLParserDelegate>
@property (strong, nonatomic) NSMutableDictionary* parsedData;
@property (strong, nonatomic) NSMutableDictionary* currentElement;
@property (strong, nonatomic) NSDictionary* currentAttributes;
@property (strong, nonatomic) NSMutableArray* currentList;
@property (strong, nonatomic) NSMutableArray* elementNameStack;
@property (strong, nonatomic) NSMutableString* currentText;
@property (strong, nonatomic) NSSet* listElementNames;
@property (strong, nonatomic) NSSet* itemElementNames;
@property (readonly, weak, nonatomic) NSManagedObjectContext* managedObjectContext;
-(id)initWithContext:(NSManagedObjectContext*)context;
-(BOOL)loadData:(NSError**)error;
-(NSSet*)validateSpecials;
@end
