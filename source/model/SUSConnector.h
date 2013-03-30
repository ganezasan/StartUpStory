#import <UIKit/UIKit.h>

extern NSString*    SUSConnectorDidBeginRetriveTitle;
extern NSString*    SUSConnectorDidFinishRetriveTitle;
extern NSString*    SUSConnectorDidBeginRefreshAllChannels;
extern NSString*    SUSConnectorInProgressRefreshAllChannels;
extern NSString*    SUSConnectorDidFinishRefreshAllChannels;

@interface SUSConnector : NSObject
{
    NSMutableArray* _retrieveTitleParsers;
    NSMutableArray* _refreshAllChannelParsers;
}

// プロパティ
@property (nonatomic, readonly, getter=isNetworkAccessing) BOOL networkAccessing;

// 初期化
+ (SUSConnector*)sharedConnector;

// フィードのタイトル取得
- (void)retrieveTitleWithUrlString:(NSString*)urlString;
- (void)cancelRetrieveTitleWithUrlString:(NSString*)urlString;

// 登録したすべてのチャンネルの更新
- (BOOL)isRefreshingAllChannels;
- (void)refreshAllChannels;
- (float)progressOfRefreshAllChannels;
- (void)cancelRefreshAllChannels;

@end
