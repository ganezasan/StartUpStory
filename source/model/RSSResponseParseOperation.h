#import <Foundation/Foundation.h>

@interface RSSResponseParseOperation : NSOperation
{
    NSString*   _feedUrlString;
    RSSChannel* _parsedChannel;
    
#if 0
	id _delegate;
	NSURLRequest *_request;
	NSURLConnection *_connection;
	NSURLResponse *_response;
	NSMutableData *_data;
	NSString *_dataFilePath;
	FILE *_dataFile;
	NSUInteger _downloadedDataLength;
	NSError *_error;
	NSMutableDictionary *_kvcDict;
	BOOL _isExecuting;
	BOOL _isFinished;
#endif
}

// Property
@property (nonatomic, retain) NSString* feedUrlString;
@property (retain) RSSChannel* parsedChannel;
@property (nonatomic, assign) id delegate;

// Parse
- (void)parse;
- (void)cancel;

@end

@interface NSObject (RSSResponseParseOperationDelegate)
@end
