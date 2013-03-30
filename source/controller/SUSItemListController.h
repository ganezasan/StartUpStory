#import <UIKit/UIKit.h>

@class SUSItem;

@interface SUSItemListController : UIViewController <UIActionSheetDelegate>
{
    UIActionSheet*  _refreshAllChannelsSheet;
    SUSItem* _item;
    NSArray* _items;
    id          _delegate; // Assign
    
    IBOutlet UITableView*       _tableView;
    IBOutlet UIBarButtonItem*   _refreshItem;
}

// プロパティ

@property (retain, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, retain) SUSItem* item;
@property (nonatomic, retain) NSArray* items;
@property (nonatomic, assign) id delegate;

// アクション
- (IBAction)refreshAction;

@end
