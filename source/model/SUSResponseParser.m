#import "SUSItem.h"
#import "SUSDataManager.h"
#import "SUSResponseParser.h"

@implementation SUSResponseParser

// プロパティ
@synthesize networkState = _networkState;
@synthesize feedUrlString = _feedUrlString;
@synthesize parsedChannelTitle = _parsedChannelTitle;
@synthesize parsedChannelLink = _parsedChannelLink;
@synthesize items = _items;
@synthesize downloadedData = _downloadedData;
@synthesize error = _error;
@synthesize delegate = _delegate;

//--------------------------------------------------------------//
#pragma mark -- 初期化 --
//--------------------------------------------------------------//

- (id)init
{
    self = [super init];
    if (!self) {
        return nil;
    }
    
    // インスタンス変数を初期化する
    _networkState = SUSNetworkStateNotConnected;
    _items = [[NSMutableArray array] retain];
    
    return self;
}

- (void)dealloc
{
    // インスタンス変数を解放する
    [_feedUrlString release], _feedUrlString = nil;
    [_parsedChannelTitle release], _parsedChannelTitle = nil;
    [_parsedChannelLink release], _parsedChannelLink = nil;
    [_connection release], _connection = nil;
    [_downloadedData release], _downloadedData = nil;
    [_error release], _error = nil;
    [_buffer release], _buffer = nil;
    [_items release], _items = nil;
    _currentItem = nil;
    _delegate = nil;
    
    // 親クラスのdeallocを呼び出す
    [super dealloc];
}

//--------------------------------------------------------------//
#pragma mark -- パース --
//--------------------------------------------------------------//

- (void)parse
{
    // リクエストの作成
    NSURLRequest*   request = nil;
    if (_feedUrlString) {
        NSURL*  url;
        url = [NSURL URLWithString:_feedUrlString];
        if (url) {
            request = [NSURLRequest requestWithURL:url];
        }
    }
    
    if (!request) {
        return;
    }
    
    // データバッファの作成
    [_downloadedData release], _downloadedData = nil;
    _downloadedData = [[NSMutableData data] retain];
    
    // NSURLConnectionオブジェクトの作成
    _connection = [[NSURLConnection connectionWithRequest:request delegate:self] retain];
    
    // ネットワークアクセス状態の設定
    _networkState = SUSNetworkStateInProgress;
}

//--------------------------------------------------------------//
#pragma mark -- キャンセル --
//--------------------------------------------------------------//

- (void)cancel
{
    // ネットワークアクセスのキャンセル
    [_connection cancel];
    
    // ダウンロード済みデータの解放
    [_downloadedData release], _downloadedData = nil;
    
    // ネットワークアクセス状態の設定
    _networkState = SUSNetworkStateCanceled;
    
    // デリゲートに通知
    if ([_delegate respondsToSelector:@selector(parserDidCancel:)]) {
        [_delegate parserDidCancel:self];
    }
    
    // NSURLConnectionオブジェクトを解放
    [_connection release], _connection = nil;
}

//--------------------------------------------------------------//
#pragma mark -- NSURLConnectionDelegate --
//--------------------------------------------------------------//

- (void)connection:(NSURLConnection*)connection didReceiveResponse:(NSURLResponse*)response
{
    // デリゲートに通知
    if ([_delegate respondsToSelector:@selector(parser:didReceiveResponse:)]) {
        [_delegate parser:self didReceiveResponse:response];
    }
}

- (void)connection:(NSURLConnection*)connection didReceiveData:(NSData*)data
{
    // ダウンロード済みデータを追加
    [_downloadedData appendData:data];
    
    // デリゲートに通知
    if ([_delegate respondsToSelector:@selector(parser:didReceiveData:)]) {
        [_delegate parser:self didReceiveData:data];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection*)connection
{
    // フラグの初期化
    _foundRss = NO;
    _isRss = NO;
    _isChannel = NO;
    _isItem = NO;
    _currentItem = nil;
    [_buffer release], _buffer = nil;
    [_items removeAllObjects];
    
    // XMLパーサの作成
    NSXMLParser*    parser;
    parser = [[NSXMLParser alloc] initWithData:_downloadedData];
    [parser setDelegate:self];
    
    // XMLをパース
    [parser parse];
    
    // XMLパーサの解放
    [parser release], parser = nil;
    
    // 成功した場合（RSS要素があった場合成功とみなす）
    if (_foundRss) {
        // ネットワークアクセス状態の設定
        _networkState = SUSNetworkStateFinished;
        
        // デリゲートに通知
        if ([_delegate respondsToSelector:@selector(parserDidFinishLoading:)]) {
            [_delegate parserDidFinishLoading:self];
        }
    }
    // 失敗した場合
    else {
        // ネットワークアクセス状態の設定
        _networkState = SUSNetworkStateError;
        
        // デリゲートに通知
        if ([_delegate respondsToSelector:@selector(parser:didFailWithError:)]) {
            NSError*    error;
            error = [NSError errorWithDomain:@"RSS" code:0 userInfo:nil];
            [_delegate parser:self didFailWithError:nil];
        }
    }
    
    // NSURLConnectionオブジェクトを解放
    [_connection release], _connection = nil;
}

- (void)connection:(NSURLConnection*)connection didFailWithError:(NSError*)error
{
    // エラーオブジェクトの設定
    [_error release], _error = nil;
    _error = [error retain];
    
    // ネットワークアクセス状態の設定
    _networkState = SUSNetworkStateError;
    
    // デリゲートに通知
    if ([_delegate respondsToSelector:@selector(parser:didFailWithError:)]) {
        [_delegate parser:self didFailWithError:error];
    }
    
    // NSURLConnectionオブジェクトを解放
    [_connection release], _connection = nil;
}

//--------------------------------------------------------------//
#pragma mark -- NSXMLParserDelegate --
//--------------------------------------------------------------//

// 要素の開始
- (void)parser:(NSXMLParser*)parser 
        didStartElement:(NSString*)elementName 
        namespaceURI:(NSString*)namespaceURI 
        qualifiedName:(NSString*)qualifiedName 
        attributes:(NSDictionary*)attributeDict
{
    // rssの場合
    if ([elementName isEqualToString:@"rss"]) {
        // フラグの設定
        _foundRss = YES;
        _isRss = YES;
    }
    
    // channelの場合
    else if ([elementName isEqualToString:@"channel"]) {
        // フラグの設定
        _isChannel = YES;
    }
    
    // itemの場合
    else if ([elementName isEqualToString:@"item"]) {
        // フラグの設定
        _isItem = YES;
        
        // アイテムの作成
        SUSItem*    item;
        item = [[SUSDataManager sharedManager] insertNewItem];
        [_items addObject:item];
        
        // パース中のアイテムとして設定
        _currentItem = item;
    }

    // それ以外の要素で、文字列を取得する必要があるもの
    else if ([elementName isEqualToString:@"title"] ||
             [elementName isEqualToString:@"link"] ||
             [elementName isEqualToString:@"description"] ||
             [elementName isEqualToString:@"pubDate"] ||
             [elementName isEqualToString:@"itunes:subtitle"])
    {
        // バッファの作成
        [_buffer release], _buffer = nil;
        _buffer = [[NSMutableString string] retain];
    }
    
    //enclosureの場合
    if ([elementName isEqualToString:@"enclosure"]) {
        if(_isItem){
            NSString *urlValue=[attributeDict valueForKey:@"url"];
            _currentItem.podcastLink = urlValue;
        }
    }
}

// 要素の終了
- (void)parser:(NSXMLParser*)parser 
        didEndElement:(NSString*)elementName 
        namespaceURI:(NSString*)namespaceURI 
        qualifiedName:(NSString*)qualifiedName
{
    // rssの場合
    if ([elementName isEqualToString:@"rss"]) {
        _isRss = NO;
    }
    
    // channelの場合
    else if ([elementName isEqualToString:@"channel"]) {
        _isChannel = NO;
    }
    
    // itemの場合
    else if ([elementName isEqualToString:@"item"]) {
        _isItem = NO;
    }
    
    // titleの場合
    else if ([elementName isEqualToString:@"title"]) {
        // アイテムのtitleの場合
        if (_isItem) {
            _currentItem.title = _buffer;
        }
        
        // チャンネルのtitleの場合
        else if (_isChannel) {
            self.parsedChannelTitle = _buffer;
        }
    }
    
    // linkの場合
    else if ([elementName isEqualToString:@"link"]) {
        // アイテムのlinkの場合
        if (_isItem) {
            _currentItem.link = _buffer;
        }
        
        // チャンネルのlinkの場合
        else if (_isChannel) {
            self.parsedChannelLink = _buffer;
        }
    }
    
    // descriptionの場合
    else if ([elementName isEqualToString:@"description"]) {
        // アイテムのdescriptionの場合
        if (_isItem) {
            _currentItem.itemDescription = _buffer;
        }
    }
    
    // pubDateの場合
    else if ([elementName isEqualToString:@"pubDate"]) {
        // アイテムのpubDateの場合
        if (_isItem) {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"US"]];
            [formatter setDateFormat:@"EEE, dd MMM yyyy HH:mm:ss ZZZZ"];
            NSDate *pubDate = [formatter dateFromString:_buffer];
            [formatter release];
            _currentItem.pubDate = pubDate;
        }
    }
    // itunes:subtitleの場合
    else if ([elementName isEqualToString:@"itunes:subtitle"]) {
        // アイテムのpubDateの場合
        if (_isItem) {
            _currentItem.subTitle = _buffer;
        }
    }
    
    // バッファを解放する
    [_buffer release], _buffer = nil;
}

// 文字列の出現
- (void)parser:(NSXMLParser*)parser foundCharacters:(NSString*)string
{
    // 文字列の追加
    [_buffer appendString:string];
}

- (void)parserDidEndDocument:(NSXMLParser*)parser
{
    NSArray* items = [[SUSDataManager sharedManager] sortedItems];
    for(SUSItem* item in items){
        NSString* link  =nil;
        link= item.link;
        NSString* title = nil;
        title = item.title;
        NSNumber* index = nil;
        index = item.index;
        for(SUSItem* tmpItem in _items){
            //link と titleが同じかつインデックスが大きい場合同じ記事と判断し古い記事を更新
            if([link isEqualToString:tmpItem.link] && [title isEqualToString:tmpItem.title]
               && [index compare:tmpItem.index] < 0){
                tmpItem.itemDescription = _currentItem.itemDescription;
                tmpItem.podcastLink = _currentItem.podcastLink;
                tmpItem.pubDate = _currentItem.pubDate;
                tmpItem.subTitle = _currentItem.subTitle;
                tmpItem.radioFlag = _currentItem.radioFlag;
                [[SUSDataManager sharedManager].managedObjectContext deleteObject:tmpItem];
                break;
            }
        }
    }
}

@end
