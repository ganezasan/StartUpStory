#import "SUSDataManager.h"
#import "SUSConnector.h"
#import "SUSAppController.h"
#import "SUSWebViewController.h"
#import "SUSItemListController.h"
#import "SUSInfoViewController.h"

@interface SUSAppController (private)

// 画面の更新
- (void)_updateNetworkActivity;

@end

@implementation SUSAppController

// プロパティ
@synthesize susWebViewController = _susWebViewController;
@synthesize susItemListController = _susItemListController;
@synthesize susInfoViewController = _susInfoViewController;
@synthesize window = _window;

//--------------------------------------------------------------//
#pragma mark -- 初期化 --
//--------------------------------------------------------------//

static SUSAppController*    _sharaedInstance = nil;

+ (SUSAppController*)sharedController
{
    return _sharaedInstance;
}

- (id)init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
	// 共用インスタンスの設定
	_sharaedInstance = self;
	
    // キー値監視の登録
    [[SUSConnector sharedConnector] 
            addObserver:self forKeyPath:@"networkAccessing" options:0 context:NULL];
    
    
	return self;
}

//--------------------------------------------------------------//
#pragma mark -- 画面の更新 --
//--------------------------------------------------------------//

- (void)_updateNetworkActivity
{
    // ネットワークアクティビティを更新する
    [UIApplication sharedApplication].networkActivityIndicatorVisible = 
            [SUSConnector sharedConnector].networkAccessing;
}

//--------------------------------------------------------------//
#pragma mark -- UIApplicationDelegate --
//--------------------------------------------------------------//

- (void)applicationDidFinishLaunching:(UIApplication*)application
{
    // ルートコントローラを追加する
    CGRect  rect;
    rect = [UIScreen mainScreen].applicationFrame;    
    _rootController = [[UITabBarController alloc] init];
    _rootController.view.frame = rect;
    UINavigationController *navigationController;
    _susItemListController = [[SUSItemListController alloc] init];
    navigationController = [[UINavigationController alloc] initWithRootViewController:_susItemListController];
    navigationController.navigationBar.tintColor = [UIColor colorWithRed:42/255.0 green:42/255.0 blue:42/255.0 alpha:0.8];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleBlackOpaque;

    _susWebViewController = [[SUSWebViewController alloc] init];
    UINavigationController* navigationController2 = [[UINavigationController alloc] initWithRootViewController:_susWebViewController];
    navigationController2.navigationBar.tintColor = [UIColor colorWithRed:42/255.0 green:42/255.0 blue:42/255.0 alpha:0.8];
    
    _susInfoViewController = [[SUSInfoViewController alloc] init];
    UINavigationController* navigationController3 = [[UINavigationController alloc] initWithRootViewController:_susInfoViewController];
    navigationController3.navigationBar.tintColor = [UIColor colorWithRed:42/255.0 green:42/255.0 blue:42/255.0 alpha:0.8];

    NSArray* controllers = [NSArray arrayWithObjects:navigationController,navigationController2,navigationController3,nil];
    [(UITabBarController*)_rootController setViewControllers:controllers animated:NO];
    [_window addSubview:_rootController.view];
    
    // ウィンドウを表示する
    [_window makeKeyAndVisible];
}

- (void)applicationWillTerminate:(UIApplication*)application
{
    // データを保存する
    [[SUSDataManager sharedManager] save];
}

//--------------------------------------------------------------//
#pragma mark -- NSKeyValueObserving protocol --
//--------------------------------------------------------------//

- (void)observeValueForKeyPath:(NSString*)keyPath 
        ofObject:(id)object 
        change:(NSDictionary*)change 
        context:(void*)context
{
    // networkAccessingキーの場合
    if ([keyPath isEqualToString:@"networkAccessing"]) {
        // 画面を更新する
        [self _updateNetworkActivity];
    }
}

@end
