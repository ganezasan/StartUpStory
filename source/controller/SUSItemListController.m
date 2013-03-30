#import "SUSItem.h"
#import "SUSDataManager.h"
#import "SUSItemListController.h"
#import "SUSConnector.h"
#import "AVPlayerViewController.h"

@interface SUSItemListController (private)

// 画面の更新
- (void)_updateNavigationItemAnimated:(BOOL)animated;
//- (void)_updateToolbarItemsAnimated:(BOOL)animated;
- (void)_updateCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath;

@end

@implementation SUSItemListController

// プロパティ
@synthesize tableView = _tableView;
@synthesize item = _item;
@synthesize items = _items;
@synthesize delegate = _delegate;

//--------------------------------------------------------------//
#pragma mark -- Initialize --
//--------------------------------------------------------------//

- (void)_init
{
    // コントローラの設定
    self.title = NSLocalizedString(@"StartUpStory", nil);
    UIImage* icon = [UIImage imageNamed:@"microphone@2x.png"];
    self.tabBarItem = [[[UITabBarItem alloc]initWithTitle:@"Interview" image:icon tag:0] autorelease];
    // チャンネルを取得する
    _items = [[SUSDataManager sharedManager] sortedItems];
}

- (id)init
{
    // nibファイル名を指定して、初期化メソッドを呼び出す
    self = [super initWithNibName:@"ItemList" bundle:nil];
    if (!self) {
        return nil;
    }
    
    // 共通の初期化メソッド
    [self _init];
    
    return self;
}

- (void)_releaseOutlets
{
    // アウトレットを解放する
    [_tableView release], _tableView = nil;
    [_refreshItem release], _refreshItem = nil;
}

- (void)dealloc
{
    // アウトレットを解放する
    [self _releaseOutlets];
    
    // インスタンス変数を解放する
    [_item release], _item = nil;
    [_items release], _items= nil;
    _delegate = nil;
    
    // 親クラスのdeallocを呼び出す
    [_tableView release];
    [super dealloc];
}

//--------------------------------------------------------------//
#pragma mark -- ビュー --
//--------------------------------------------------------------//

- (void)viewDidLoad{
    _items = [[SUSDataManager sharedManager] sortedItems];
    
    self.tableView.rowHeight = 93.0;
    _tableView.backgroundColor = [UIColor darkGrayColor];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _tableView.separatorColor = [UIColor blackColor];
    _tableView.backgroundView.hidden = YES;

    // 通知の登録
    NSNotificationCenter*   center;
    center = [NSNotificationCenter defaultCenter];
    [center addObserver:self selector:@selector(connectorDidBeginRefreshAllChannels:) 
                   name:SUSConnectorDidBeginRefreshAllChannels object:nil];
    [center addObserver:self selector:@selector(connectorInProgressRefreshAllChannels:) 
                   name:SUSConnectorInProgressRefreshAllChannels object:nil];
    [center addObserver:self selector:@selector(connectorDidFinishRefreshAllChannels:) 
                   name:SUSConnectorDidFinishRefreshAllChannels object:nil];
    
    [self refreshAction];
}

- (void)viewWillAppear:(BOOL)animated
{
    // 親クラスのメソッドを呼び出す
    [super viewWillAppear:animated];
    
    // 画面を更新する
    [self _updateNavigationItemAnimated:animated];
//    [self _updateToolbarItemsAnimated:animated];
    
    // 選択されているセルを解除する
    NSIndexPath*    indexPath;
    indexPath = [_tableView indexPathForSelectedRow];
    if (indexPath) {
        [_tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    
    // セルの表示更新を行う
    for (UITableViewCell* cell in [_tableView visibleCells]) {
        [self _updateCell:cell atIndexPath:[_tableView indexPathForCell:cell]];
    }
}

- (void)viewDidUnload
{
    [self setTableView:nil];
    // アウトレットを解放する
    [self _releaseOutlets];
}

//--------------------------------------------------------------//
#pragma mark -- 画面の更新 --
//--------------------------------------------------------------//

- (void)_updateNavigationItemAnimated:(BOOL)animated
{
    // ナビゲーションアイテムの設定を行う
    // ここでは特にやることなし
    [self.navigationItem setRightBarButtonItem:_refreshItem animated:animated];
}

//- (void)_updateToolbarItemsAnimated:(BOOL)animated
//{
//}

- (void)_updateCell:(UITableViewCell*)cell atIndexPath:(NSIndexPath*)indexPath
{
    // 指定された行のアイテムの取得
    NSArray*    items;
    SUSItem*    item = nil;
    items = [[SUSDataManager sharedManager] sortedItems];
    if (indexPath.row < [items count]) {
        item = [items objectAtIndex:indexPath.row];
    }
    
    // タイトルの設定SUSDataManager
    cell.textLabel.font = [UIFont boldSystemFontOfSize:14.0f];
    cell.textLabel.text = item.title;
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.textLabel.numberOfLines = 0;
    
    // フィードURLの設定
    cell.detailTextLabel.font = [UIFont boldSystemFontOfSize:12.0f];
    cell.detailTextLabel.text = item.subTitle;
    cell.detailTextLabel.textColor = [UIColor colorWithRed:183/255.0 green:212/255.0 blue:242/255.0 alpha:1];
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];

    // 未読マークの設定
    UIImage*    image;
    image = item.read ? [UIImage imageNamed:@"read.png"] : [UIImage imageNamed:@"unread3.png"];
    cell.imageView.image = image;
    
    // アクセサリの設定
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
}

//--------------------------------------------------------------//
#pragma mark -- アクション --
//--------------------------------------------------------------//
- (IBAction)refreshAction
{
    // 登録してあるすべてのチャンネルを更新する
    [[SUSConnector sharedConnector] refreshAllChannels];

}

//--------------------------------------------------------------//
#pragma mark -- UITableViewDataSource --
//--------------------------------------------------------------//

- (NSInteger)tableView:(UITableView*)tableView 
        numberOfRowsInSection:(NSInteger)section
{
    // 配列の数を返す
    return [[SUSDataManager sharedManager].sortedItems count];
}

- (UITableViewCell*)tableView:(UITableView*)tableView 
        cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // セルを取得する
    UITableViewCell*    cell;
    cell = [_tableView dequeueReusableCellWithIdentifier:@"UITableViewCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] 
                initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"UITableViewCell"];
        [cell autorelease];
    }
    
    // セルの値を更新する
    [self _updateCell:cell atIndexPath:indexPath];
    
    return cell;
}

//--------------------------------------------------------------//
#pragma mark -- UITableViewDelegate --
//--------------------------------------------------------------//

- (void)tableView:(UITableView*)tableView 
        didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
    // アイテムを取得する
    NSArray*    items;
    SUSItem*    item = nil;
    items = [[SUSDataManager sharedManager] sortedItems];
    if (indexPath.row < [items count]) {
        item = [items objectAtIndex:indexPath.row];
    }

    if (!item) {
        return;
    }
    
    AVPlayerViewController* controller;
    controller = [[AVPlayerViewController alloc] init];
    controller.item = item;
    controller.delegate = self;
    // 自動解放する
    [controller autorelease];
    // ナビゲーションコントローラに追加する
    [self.navigationController pushViewController:controller animated:YES];
}

//--------------------------------------------------------------//
#pragma mark -- SUSConnector notification --
//--------------------------------------------------------------//

- (void)connectorDidBeginRefreshAllChannels:(NSNotification*)notification
{
    // アクションシートを表示する
    _refreshAllChannelsSheet = [[UIActionSheet alloc] 
                                initWithTitle:@"Refreshing all channels…" 
                                delegate:self 
                                cancelButtonTitle:@"Cancel" 
                                destructiveButtonTitle:nil 
                                otherButtonTitles:nil];
    [_refreshAllChannelsSheet showFromToolbar:self.navigationController.toolbar];
}

- (void)connectorInProgressRefreshAllChannels:(NSNotification*)notification
{
    // 進捗を取得する
    float   progress;
    progress = [[SUSConnector sharedConnector] progressOfRefreshAllChannels];
    
    // アクションシートのタイトルを更新する
    _refreshAllChannelsSheet.title = 
    [NSString stringWithFormat:@"Refreshing all channels… %d", (int)(progress * 100)];
}

- (void)connectorDidFinishRefreshAllChannels:(NSNotification*)notification
{
    // アクションシートを隠す
    [_refreshAllChannelsSheet dismissWithClickedButtonIndex:0 animated:YES];
    [_refreshAllChannelsSheet release], _refreshAllChannelsSheet = nil;
    
    // セルの表示更新を行う
    for (UITableViewCell* cell in [_tableView visibleCells]) {
        [self _updateCell:cell atIndexPath:[_tableView indexPathForCell:cell]];
    }
    
    // 保存を行う
    [[SUSDataManager sharedManager] save];
    [_tableView reloadData];
}

@end
