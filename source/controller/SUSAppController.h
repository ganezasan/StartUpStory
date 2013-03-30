#import <UIKit/UIKit.h>

@class SUSWebViewController;
@class SUSItemListController;
@class SUSInfoViewController;

@interface SUSAppController : NSObject
{
    SUSItemListController*     _susItemListController;
    SUSWebViewController* _susWebViewController;
    SUSInfoViewController* _susInfoViewController;
    UIViewController* _rootController;
    IBOutlet UIWindow*                  _window;
}

// プロパティ
@property (nonatomic, readonly) SUSItemListController* susItemListController;
@property (nonatomic, readonly) SUSWebViewController* susWebViewController;
@property (nonatomic, readonly) SUSInfoViewController* susInfoViewController;
@property (nonatomic, readonly) UIWindow* window;

@end
