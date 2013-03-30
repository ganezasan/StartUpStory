#import "RSSResponseParseOperation.h"

@implementation RSSResponseParseOperation

// Property
@synthesize feedUrlString = _feedUrlString;
@synthesize parsedChannel = _parsedChannel;

//--------------------------------------------------------------//
#pragma mark -- Operation --
//--------------------------------------------------------------//

- (void)start
{
    // Create autorelease pool
    NSAutoreleasePool*  pool;
    pool = [[NSAutoreleasePool alloc] init];
    
    // Create request
    NSURLRequest*   request = nil;
    if (_channel) {
        NSURL*  url;
        url = [NSURL URLWithString:_channel.feedUrlString];
        if (url) {
            request = [NSURLRequest requestWithURL:url];
        }
    }
    
    if (!request) {
        return;
    }
    
    // Create connection
    NSData*         data;
    NSURLResponse*  response;
    NSError*        error = nil;
    data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    if (error) {
        // Notify to delegate
        //[self performSelectorOnMainThread:@selector(_notifyParserDidFailWithError:) 
        //        withObject:error waitUntilDone:YES];
    }
    else {
        // Create XML parser
        NSXMLParser*    parser;
        parser = [[NSXMLParser alloc] initWithData:data];
        [parser setDelegate:self];
        
        // Parse XML
        [parser parse];
        
        // Notify to delegate
        //[self performSelectorOnMainThread:@selector(_notifyParserDidFinishLoading) 
        //        withObject:error waitUntilDone:YES];
    }
    
    // Release autorelease pool
    [pool release], pool = nil;
}

#if 0
- (void)parse
{
}

- (void)cancel
{
}

//-------------------------------------------------------------------------------------//
#pragma mark -- Properties --
//-------------------------------------------------------------------------------------//
@synthesize delegate = _delegate;
@synthesize request = _request;
@synthesize connection = _connection;
@synthesize response = _response;
@synthesize data = _data;
@synthesize dataFilePath = _dataFilePath;
@synthesize downloadedDataLength = _downloadedDataLength;
@synthesize error = _error;

- (NSData*)data
{
	// Get dataFilePath
	NSString *dataFilePath;
	dataFilePath = self.dataFilePath;
	
	// Return data
	if ([dataFilePath length]) {
		return [NSData dataWithContentsOfFile:dataFilePath];
	}
	else {
		return [[_data retain] autorelease];
	}
}

+ (NSInteger)version
{
	return 3;       // 1.0.2
}

- (float)progress
{
	// Get response and data
	NSURLResponse *response;
	response = [self response];
	if (!response) {
		return HMDownloadOperationUnknownProgress;
	}
	
	// Calc progress
	float progress;
	long long expectedLength;
	expectedLength = [response expectedContentLength];
	if (expectedLength <= 0 || expectedLength == NSURLResponseUnknownLength) {
		return HMDownloadOperationUnknownProgress;
	}
	progress = (float)_downloadedDataLength / (float)expectedLength;
	
	return progress;
}

//-------------------------------------------------------------------------------------//
#pragma mark -- Initialize --
//-------------------------------------------------------------------------------------//

+ (BOOL)automaticallyNotifiesObserversForKey:(NSString *)key
{
	if ([key isEqualToString:@"isReady"]
			|| [key isEqualToString:@"isExecuting"]
			|| [key isEqualToString:@"isCancelled"]
			|| [key isEqualToString:@"isFinished"]
			|| [key isEqualToString:@"request"]
			|| [key isEqualToString:@"response"]
			|| [key isEqualToString:@"data"]
			|| [key isEqualToString:@"error"]
	) {
		return YES;
	}
	else if ([key isEqualToString:@"downloadedDataLength"]) {
		return NO;
	}
	
	return [super automaticallyNotifiesObserversForKey:key];
}

+ (id)downloadOperationWithRequest:(NSURLRequest*)request
{
	id downloadOperation;
	downloadOperation = [[[self class] alloc] initWithRequest:request];
	
	return [downloadOperation autorelease];
}

+ (id)downloadOperationWithRequest:(NSURLRequest*)request dataFilePath:(NSString*)dataFilePath
{
    id downloadOperation;
	 downloadOperation = [[self alloc] initWithRequest:request dataFilePath:dataFilePath];
	 
	 return [downloadOperation autorelease];
}

- (id)initWithRequest:(NSURLRequest*)request
{
	// Super
	if (![super init]) {
		return nil;
	}
	
	// Initialize self
	_request = [request retain];
	_data = [[NSMutableData data] retain];
	_kvcDict = [[NSMutableDictionary dictionary] retain];
	_isExecuting = NO;
	_isFinished = NO;
	
	return self;
}

- (id)initWithRequest:(NSURLRequest*)request dataFilePath:(NSString*)dataFilePath
{
	// Super
	self = [super init];
	if (!self) {
		return nil;
	}
	
	// Initialize self
	_request = [request retain];
	_data = [[NSMutableData data] retain];
	_kvcDict = [[NSMutableDictionary dictionary] retain];
	_isExecuting = NO;
	_isFinished = NO;
	_dataFilePath = [dataFilePath retain];
	if ([_dataFilePath length]) {
		// Create intermediate directories
		NSString *directory;
		directory = [_dataFilePath stringByDeletingLastPathComponent];
		if (![[NSFileManager defaultManager] createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:NULL]) {
			return nil;
		}
		
		// Open _dataFile
		_dataFile = fopen([_dataFilePath UTF8String], "w+");
		if (!_dataFile) {
			return nil;
		}
	}
	
	return self;
}

- (void)dealloc
{
	// Clean up
	_delegate = nil;
	[_request release], _request = nil;
	[_connection cancel], [_connection release], _connection = nil;
	[_response release], _response = nil;
	[_data release], _data = nil;
	[_dataFilePath release], _dataFilePath = nil;
	if (_dataFile) {
		fclose(_dataFile), _dataFile = NULL;
	}
	[_error release], _error = nil;
	[_kvcDict release], _kvcDict = nil;
	
	// Super
	[super dealloc];
}

//-------------------------------------------------------------------------------------//
#pragma mark -- KVC Container --
//-------------------------------------------------------------------------------------//

- (id)valueForUndefinedKey:(NSString *)key
{
	// Return object in _kvcDict
	return [_kvcDict objectForKey:key];
}

- (void)setValue:(id)value forUndefinedKey:(NSString *)key
{
	// Filter
	if (!key) {
		return;
	}
	
	// Update _kvcDict
	if (!value) {
		[_kvcDict removeObjectForKey:key];
	}
	else {
		[_kvcDict setObject:value forKey:key];
	}
}

//-------------------------------------------------------------------------------------//
#pragma mark -- Operating --
//-------------------------------------------------------------------------------------//

- (BOOL)isConcurrent
{
	return NO;
}

- (BOOL)isExecuting
{
	return _isExecuting;
}

- (BOOL)isFinished
{
	return _isFinished;
}

- (void)start
{
    // Create pool
    NSAutoreleasePool *pool;
    pool = [[NSAutoreleasePool alloc] init];
    
    if (![self isCancelled]) {
        if (![NSThread isMainThread]) {
            // Call on main thread
            [self performSelectorOnMainThread:_cmd withObject:nil waitUntilDone:YES];
        }
        else {
            // Start downloading
            NSURLConnection *connection;
            connection = [[NSURLConnection alloc] initWithRequest:[self request] delegate:self startImmediately:NO];
            [connection autorelease];
            self.connection = connection;
            if (![self isExecuting]) {
                [self setValue:[NSNumber numberWithBool:YES] forKey:@"isExecuting"];
            }
            [connection scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:UITrackingRunLoopMode];
            [connection start];
            
            // Run runLoop
            while ([self isExecuting] && [[NSRunLoop currentRunLoop] runMode:UITrackingRunLoopMode beforeDate:[NSDate distantFuture]]);
        }
    }
    
    // Release pool
    [pool release];
}

- (void)cancel
{
    // Filter
    if ([self isFinished] || [self isCancelled]) {
        return;
    }
    
	// Close _dataFile
	if (_dataFile) {
		fclose(_dataFile), _dataFile = NULL;
	}
	
	// Cancel operation
	[_connection cancel];
	[super cancel];
    if (![self isFinished]) {
        [self setValue:[NSNumber numberWithBool:YES] forKey:@"isFinished"];
    }
    if ([self isExecuting]) {
        [self setValue:[NSNumber numberWithBool:NO] forKey:@"isExecuting"];
    }
}

//-------------------------------------------------------------------------------------//
#pragma mark -- NSURLConnection Delegate --
//-------------------------------------------------------------------------------------//

//- (void)connection:(NSURLConnection *)connection
//		didCancelAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge

- (void)connection:(NSURLConnection *)connection
		didFailWithError:(NSError *)error
{
	// Close _dataFile
	if (_dataFile) {
		fclose(_dataFile), _dataFile = NULL;
	}
	
	// Set error
	[self setValue:error forKey:@"error"];
	
	// Down _isExecuting flag
    if ([self isExecuting]) {
        [self setValue:[NSNumber numberWithBool:NO] forKey:@"isExecuting"];
    }
}

- (void)connection:(NSURLConnection *)connection
		didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
	// Inform delegate
	id delegate;
	delegate = [self delegate];
	if (delegate && [delegate respondsToSelector:@selector(downloadOperation:didReceiveAuthenticationChallenge:)]) {
		[delegate downloadOperation:self didReceiveAuthenticationChallenge:challenge];
	}
}

- (void)connection:(NSURLConnection *)connection
		didReceiveData:(NSData *)data
{
	// Update data
	@synchronized(self) {
		if ([data length]) {
			[self willChangeValueForKey:@"data"];
			[self willChangeValueForKey:@"downloadedDataLength"];
			if (_dataFile) {
				// Write data
				if (!fwrite([data bytes], [data length], 1, _dataFile)) {
					// Failed
					[_connection cancel];
                    if ([self isExecuting]) {
                        [self setValue:[NSNumber numberWithBool:NO] forKey:@"isExecuting"];
                    }
					return;
				}
			}
			else {
				// Append data to _data
				[_data appendData:data];
			}
			_downloadedDataLength += [data length];
			[self didChangeValueForKey:@"data"];
			[self didChangeValueForKey:@"downloadedDataLength"];
		}
	}
}

- (void)connection:(NSURLConnection *)connection
		didReceiveResponse:(NSURLResponse *)response
{
	// Set response
	[self setValue:response forKey:@"response"];
}

//- (NSCachedURLResponse *)connection:(NSURLConnection *)connection
//		willCacheResponse:(NSCachedURLResponse *)cachedResponse

- (NSURLRequest *)connection:(NSURLConnection *)connection
		willSendRequest:(NSURLRequest *)request
		redirectResponse:(NSURLResponse *)redirectResponse
{
	NSURLRequest *newRequest;
	newRequest = request;
	
	// Ask delegate
	id delegate;
	delegate = [self delegate];
	if (delegate && [delegate respondsToSelector:@selector(downloadOperation: willSendRequest: redirectResponse:)]) {
		newRequest = [delegate downloadOperation:self willSendRequest:request redirectResponse:redirectResponse];
	}
	
	// Update _request and _response
	[self setValue:newRequest forKey:@"request"];
	[self setValue:redirectResponse forKey:@"response"];
	
	return newRequest;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	// Close _dataFile
	if (_dataFile) {
		fclose(_dataFile), _dataFile = NULL;
	}
	
	// Finish operation
    if (![self isFinished]) {
        [self setValue:[NSNumber numberWithBool:YES] forKey:@"isFinished"];
    }
    if ([self isExecuting]) {
        [self setValue:[NSNumber numberWithBool:NO] forKey:@"isExecuting"];
    }
}
#endif

@end
