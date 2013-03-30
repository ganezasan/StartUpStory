#import "SUSItem.h"
#import "SUSDataManager.h"

@implementation SUSDataManager

//--------------------------------------------------------------//
#pragma mark -- 初期化 --
//--------------------------------------------------------------//

static SUSDataManager*  _sharedInstance = nil;

+ (SUSDataManager*)sharedManager
{
    // インスタンスを作成する
    if (!_sharedInstance) {
        _sharedInstance = [[SUSDataManager alloc] init];
    }
    
    return _sharedInstance;
}

- (void)dealloc
{
    // インスタンス変数を解放する
    [_managedObjectContext release], _managedObjectContext = nil;
    
    // 親クラスのdeallocを呼び出す
    [super dealloc];
}

//--------------------------------------------------------------//
#pragma mark -- プロパティ --
//--------------------------------------------------------------//

- (NSManagedObjectContext*)managedObjectContext
{
    NSError*    error;
    
    // インスタンス変数のチェック
    if (_managedObjectContext) {
        return _managedObjectContext;
    }
    
    // 管理対象オブジェクトモデルの作成
    NSManagedObjectModel*   managedObjectModel;
    managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
    
    // 永続ストアコーディネータの作成
    NSPersistentStoreCoordinator*   persistentStoreCoordinator;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] 
            initWithManagedObjectModel:managedObjectModel];
    [persistentStoreCoordinator autorelease];
    
    // 保存ファイルの決定
    NSArray*    paths;
    NSString*   path = nil;
    paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    if ([paths count] > 0) {
        path = [paths objectAtIndex:0];
        path = [path stringByAppendingPathComponent:@".sus"];
        path = [path stringByAppendingPathComponent:@"sus.db"];
    }
    
    if (!path) {
        return nil;
    }
    
    // ディレクトリの作成
    NSString*       dirPath;
    NSFileManager*  fileMgr;
    dirPath = [path stringByDeletingLastPathComponent];
    fileMgr = [NSFileManager defaultManager];
    if (![fileMgr fileExistsAtPath:dirPath]) {
        if (![fileMgr createDirectoryAtPath:dirPath 
                withIntermediateDirectories:YES attributes:nil error:&error])
        {
            NSLog(@"Failed to create directory at path %@, erro %@", 
                    dirPath, [error localizedDescription]);
        }
    }
    
    // ストアURLの作成
    NSURL*  url = nil;
    url = [NSURL fileURLWithPath:path];
    
    // 永続ストアの追加
    NSPersistentStore*  persistentStore;
    persistentStore = [persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType 
            configuration:nil URL:url options:nil error:&error];
    if (!persistentStore && error) {
        NSLog(@"Failed to create add persitent store, %@", [error localizedDescription]);
    }
    
    // 管理対象オブジェクトコンテキストの作成
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    
    // 永続ストアコーディネータの設定
    [_managedObjectContext setPersistentStoreCoordinator:persistentStoreCoordinator];
    
    return _managedObjectContext;
}

- (NSArray*)sortedItems
{
    // 管理対象オブジェクトコンテキストを取得する
    NSManagedObjectContext* context;
    context = self.managedObjectContext;
    
    // 取得要求を作成する
    NSFetchRequest*         request;
    NSEntityDescription*    entity;
    NSSortDescriptor*       sortDescriptor;
    request = [[NSFetchRequest alloc] init];
    [request autorelease];
    entity = [NSEntityDescription entityForName:@"Item" inManagedObjectContext:context];
    [request setEntity:entity];
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"pubDate" ascending:NO];
    [sortDescriptor autorelease];
    [request setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    
    // 取得要求を実行する
    NSArray*    result;
    NSError*    error = nil;
    result = [context executeFetchRequest:request error:&error];
    if (!result) {
        // エラー
        NSLog(@"executeFetchRequest: failed, %@", [error localizedDescription]);
        
        return nil;
    }
    return result;
}


//--------------------------------------------------------------//
#pragma mark -- アイテムの操作 --
//--------------------------------------------------------------//

- (SUSItem*)insertNewItem
{
    // 管理対象オブジェクトコンテキストを取得する
    NSManagedObjectContext* context;
    context = self.managedObjectContext;
    
    // アイテムを作成する
    SUSItem*    item;
    item = [NSEntityDescription insertNewObjectForEntityForName:@"Item" 
            inManagedObjectContext:context];
    
    // 識別子を作成する
    CFUUIDRef   uuid;
    NSString*   identifier;
    uuid = CFUUIDCreate(NULL);
    identifier = (NSString*)CFUUIDCreateString(NULL, uuid);
    CFRelease(uuid);
    [identifier autorelease];
    item.identifier = identifier;
    
    // インデックスを設定する
    NSArray*    sortedItems;
    sortedItems = self.sortedItems;
    if ([sortedItems count] > 0) {
        // 最後のチャンネルのインデックスの、次のインデックスを設定する
        item.index = [NSNumber numberWithInt:[sortedItems count] + 1];
    }
    
    return item;
}

//--------------------------------------------------------------//
#pragma mark -- 永続化 --
//--------------------------------------------------------------//

- (void)save
{
    // 保存
    NSError*    error;
    if (![self.managedObjectContext save:&error]) {
        // エラー
        NSLog(@"Error, %@", error);
    }
}

@end
