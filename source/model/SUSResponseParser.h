#import <UIKit/UIKit.h>

enum {
    SUSNetworkStateNotConnected = 0, 
    SUSNetworkStateInProgress, 
    SUSNetworkStateFinished, 
    SUSNetworkStateError,
    SUSNetworkStateCanceled, 
};

@class SUSItem;
@class SUSChannel;

@interface SUSResponseParser : NSObject <NSXMLParserDelegate>
{
    int                 _networkState;
    NSString*           _feedUrlString;
    NSString*           _parsedChannelTitle;
    NSString*           _parsedChannelLink;
    
    NSURLConnection*    _connection;
    NSMutableData*      _downloadedData;
    NSError*            _error;
    
    BOOL                _foundRss;
    BOOL                _isRss;
    BOOL                _isChannel;
    BOOL                _isItem;
    NSMutableString*    _buffer;
    NSMutableArray*     _items;
    SUSItem*            _currentItem; // Assign
    
    id                  _delegate; // Assign
}

// プロパティ
@property (nonatomic, readonly) int networkState;
@property (nonatomic, retain) NSString* feedUrlString;
@property (nonatomic, retain) NSString* parsedChannelTitle;
@property (nonatomic, retain) NSString* parsedChannelLink;
@property (nonatomic, readonly) NSArray* items;

@property (nonatomic, readonly) NSData* downloadedData;
@property (nonatomic, readonly) NSError* error;
@property (nonatomic, assign) id delegate;

// パース
- (void)parse;

// キャンセル
- (void)cancel;

@end

// デリゲートメソッド
@interface NSObject (SUSResponseParserDelegate)

- (void)parser:(SUSResponseParser*)parser didReceiveResponse:(NSURLResponse*)response;
- (void)parser:(SUSResponseParser*)parser didReceiveData:(NSData*)data;
- (void)parserDidFinishLoading:(SUSResponseParser*)parser;
- (void)parser:(SUSResponseParser*)parser didFailWithError:(NSError*)error;
- (void)parserDidCancel:(SUSResponseParser*)parser;

@end
