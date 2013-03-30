#import <CoreData/CoreData.h>

@class SUSItem;

@interface SUSDataManager : NSObject
{
    NSManagedObjectContext* _managedObjectContext;
}

// プロパティ
@property (nonatomic, readonly) NSManagedObjectContext* managedObjectContext;
@property (nonatomic, readonly) NSArray* sortedItems;

// 初期化
+ (SUSDataManager*)sharedManager;

// アイテムの操作
- (SUSItem*)insertNewItem;

// 永続化
- (void)save;

@end
