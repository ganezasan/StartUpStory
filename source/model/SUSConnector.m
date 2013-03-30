#import "SUSItem.h"
#import "SUSDataManager.h"
#import "SUSResponseParser.h"
#import "SUSConnector.h"

NSString*   SUSConnectorDidBeginRetriveTitle = @"SUSConnectorDidBeginRetriveTitle";
NSString*   SUSConnectorDidFinishRetriveTitle = @"SUSConnectorDidFinishRetriveTitle";
NSString*   SUSConnectorDidBeginRefreshAllChannels = @"SUSConnectorDidBeginRefreshAllChannels";
NSString*   SUSConnectorInProgressRefreshAllChannels = @"SUSConnectorInProgressRefreshAllChannels";
NSString*   SUSConnectorDidFinishRefreshAllChannels = @"SUSConnectorDidFinishRefreshAllChannels";

@implementation SUSConnector

//--------------------------------------------------------------//
#pragma mark -- 初期化 --
//--------------------------------------------------------------//

static SUSConnector*    _sharedInstance = nil;

+ (SUSConnector*)sharedConnector
{
    // インスタンスを作成する
    if (!_sharedInstance) {
        _sharedInstance = [[SUSConnector alloc] init];
    }
    
    return _sharedInstance;
}

- (id)init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    // インスタンス変数を初期化する
    _retrieveTitleParsers = [[NSMutableArray array] retain];
    _refreshAllChannelParsers = [[NSMutableArray array] retain];
    
    return self;
}

- (void)dealloc
{
    // インスタンス変数の解放
    [_retrieveTitleParsers release], _retrieveTitleParsers = nil;
    [_refreshAllChannelParsers release], _refreshAllChannelParsers = nil;
    
    // 親クラスのdeallocを呼び出す
    [super dealloc];
}

//--------------------------------------------------------------//
#pragma mark -- プロパティ --
//--------------------------------------------------------------//

- (BOOL)isNetworkAccessing
{
    return [_retrieveTitleParsers count] > 0 || 
            [_refreshAllChannelParsers count] > 0;
}

//--------------------------------------------------------------//
#pragma mark -- フィードのタイトル取得 --
//--------------------------------------------------------------//

- (void)retrieveTitleWithUrlString:(NSString*)urlString
{
    // 現在のネットワークアクセス状況を取得
    BOOL    networkAccessing;
    networkAccessing = self.networkAccessing;
    
    // レスポンスパーサの作成
    SUSResponseParser*  parser;
    parser = [[SUSResponseParser alloc] init];
    [parser autorelease];
    parser.feedUrlString = urlString;
    parser.delegate = self;
    
    // パースの開始
    [parser parse];
    
    // パーサの追加
    [_retrieveTitleParsers addObject:parser];
    
    // networkAccessingの値の変更を通知する
    if (networkAccessing != self.networkAccessing) {
        [self willChangeValueForKey:@"networkAccessing"];
        [self didChangeValueForKey:@"networkAccessing"];
    }
    
    // userInfoの作成
    NSMutableDictionary*    userInfo;
    userInfo = [NSMutableDictionary dictionary];
    [userInfo setObject:parser forKey:@"parser"];
    
    // 通知
    [[NSNotificationCenter defaultCenter] 
            postNotificationName:SUSConnectorDidBeginRetriveTitle object:self userInfo:userInfo];
}

- (void)cancelRetrieveTitleWithUrlString:(NSString*)urlString
{
    // 指定されたパーサを検索する
    for (SUSResponseParser* parser in _retrieveTitleParsers) {
        if ([parser.feedUrlString isEqualToString:urlString]) {
            // パーサをキャンセルする
            [parser cancel];
            
            // userInfoの作成
            NSMutableDictionary*    userInfo;
            userInfo = [NSMutableDictionary dictionary];
            [userInfo setObject:parser forKey:@"parser"];
            
            // 通知
            [[NSNotificationCenter defaultCenter] 
                    postNotificationName:SUSConnectorDidFinishRetriveTitle 
                    object:self userInfo:userInfo];
            
            // networkAccessingの値の変更を通知する
            [self willChangeValueForKey:@"networkAccessing"];
            [_retrieveTitleParsers removeObject:parser];
            [self didChangeValueForKey:@"networkAccessing"];
            
            break;
        }
    }
}

//--------------------------------------------------------------//
#pragma mark -- 登録したすべてのチャンネルの更新 --
//--------------------------------------------------------------//

- (BOOL)isRefreshingAllChannels
{
    return [_refreshAllChannelParsers count] > 0;
}

- (void)refreshAllChannels
{
    // 現在の更新状況を確認
    if ([self isRefreshingAllChannels]) {
        return;
    }
    
    // 現在のネットワークアクセス状況を取得
    BOOL    networkAccessing;
    networkAccessing = self.networkAccessing;
    
    // レスポンスパーサの作成
    SUSResponseParser*  parser;
    parser = [[SUSResponseParser alloc] init];
    [parser autorelease];
//        parser.feedUrlString = channel.feedUrlString;
    parser.feedUrlString = @"http://startupstory.biz/feed/podcast";
    parser.delegate = self;
        
    // パースの開始
    [parser parse];
    
    // パーサの追加
    [_refreshAllChannelParsers addObject:parser];
//    }
    
    // networkAccessingの値の変更を通知する
    if (networkAccessing != self.networkAccessing) {
        [self willChangeValueForKey:@"networkAccessing"];
        [self didChangeValueForKey:@"networkAccessing"];
    }
    
    // userInfoの作成
    NSMutableDictionary*    userInfo;
    userInfo = [NSMutableDictionary dictionary];
    [userInfo setObject:_refreshAllChannelParsers forKey:@"parsers"];
    
    // 通知
    [[NSNotificationCenter defaultCenter] 
            postNotificationName:SUSConnectorDidBeginRefreshAllChannels object:self userInfo:userInfo];
}

- (float)progressOfRefreshAllChannels
{
    // パーサが無い場合
    if ([_refreshAllChannelParsers count] == 0) {
        return 1.0f;
    }
    
    // 進捗の計算
    int doneCount = 0;
    for (SUSResponseParser* parser in _refreshAllChannelParsers) {
        // ネットワークアクセス状態の確認
        int networkState;
        networkState = parser.networkState;
        if (networkState == SUSNetworkStateFinished || 
            networkState == SUSNetworkStateError || 
            networkState == SUSNetworkStateCanceled)
        {
            doneCount++;
        }
    }
    
    return (float)doneCount / [_refreshAllChannelParsers count];;
}

- (void)cancelRefreshAllChannels
{
    // すべてのパーサをキャンセルする
    for (SUSResponseParser* parser in _refreshAllChannelParsers) {
        [parser cancel];
    }
    
    // userInfoの作成
    NSMutableDictionary*    userInfo;
    userInfo = [NSMutableDictionary dictionary];
    [userInfo setObject:_refreshAllChannelParsers forKey:@"parsers"];
    
    // 通知
    [[NSNotificationCenter defaultCenter] 
            postNotificationName:SUSConnectorDidFinishRefreshAllChannels 
            object:self userInfo:userInfo];
    
    // networkAccessingの値の変更を通知する
    [self willChangeValueForKey:@"networkAccessing"];
    [_refreshAllChannelParsers removeAllObjects];
    [self didChangeValueForKey:@"networkAccessing"];
}

//--------------------------------------------------------------//
#pragma mark -- SUSResponseParserDelegate --
//--------------------------------------------------------------//

- (void)_notifyRetriveTitleStatusWithParser:(SUSResponseParser*)parser
{
    // userInfoの作成
    NSMutableDictionary*    userInfo;
    userInfo = [NSMutableDictionary dictionary];
    [userInfo setObject:parser forKey:@"parser"];
    
    // 通知する
    [[NSNotificationCenter defaultCenter] 
            postNotificationName:SUSConnectorDidFinishRetriveTitle object:self userInfo:userInfo];
    
    // networkAccessingの値の変更を通知する
    [self willChangeValueForKey:@"networkAccessing"];
    [_retrieveTitleParsers removeObject:parser];
    [self didChangeValueForKey:@"networkAccessing"];
}

- (void)_notifyRefreshAllChannelStatus
{
    // userInfoの作成
    NSMutableDictionary*    userInfo;
    userInfo = [NSMutableDictionary dictionary];
    [userInfo setObject:_refreshAllChannelParsers forKey:@"parsers"];
    
    // 進捗の取得
    float   progress;
    progress = [self progressOfRefreshAllChannels];
    
    // 通知
    NSString*   name;
    if (progress < 1.0f) {
        name = SUSConnectorInProgressRefreshAllChannels;
    }
    else {
        name = SUSConnectorDidFinishRefreshAllChannels;
    }
    [[NSNotificationCenter defaultCenter] 
            postNotificationName:name object:self userInfo:userInfo];
    
    // For did finish
    if (progress == 1.0f) {
        // networkAccessingの値の変更を通知する
        [self willChangeValueForKey:@"networkAccessing"];
        [_refreshAllChannelParsers removeAllObjects];
        [self didChangeValueForKey:@"networkAccessing"];
    }
}

- (void)parser:(SUSResponseParser*)parser didReceiveResponse:(NSURLResponse*)response
{
    // ここでは特に何もしない
}

- (void)parser:(SUSResponseParser*)parser didReceiveData:(NSData*)data
{
    // ここでは特に何もしない
}

- (void)parserDidFinishLoading:(SUSResponseParser*)parser
{
    // フィードのタイトル取得の場合
    if ([_retrieveTitleParsers containsObject:parser]) {
        // 通知
        [self _notifyRetriveTitleStatusWithParser:parser];
    }
    // 登録したすべてのチャンネルの更新の場合
    else if ([_refreshAllChannelParsers containsObject:parser]) {
        // 通知
        [self _notifyRefreshAllChannelStatus];
    }
}

- (void)parser:(SUSResponseParser*)parser didFailWithError:(NSError*)error
{
    // フィードのタイトル取得の場合
    if ([_retrieveTitleParsers containsObject:parser]) {
        // 通知
        [self _notifyRetriveTitleStatusWithParser:parser];
    }
    // 登録したすべてのチャンネルの更新の場合
    else if ([_refreshAllChannelParsers containsObject:parser]) {
        // 通知
        [self _notifyRefreshAllChannelStatus];
    }
}

- (void)parserDidCancel:(SUSResponseParser*)parser
{
    // フィードのタイトル取得の場合
    if ([_retrieveTitleParsers containsObject:parser]) {
        // 通知
        [self _notifyRetriveTitleStatusWithParser:parser];
    }
    // 登録したすべてのチャンネルの更新の場合
    else if ([_refreshAllChannelParsers containsObject:parser]) {
        // 通知
        [self _notifyRefreshAllChannelStatus];
    }
}

@end
