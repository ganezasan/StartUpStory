//
//  SUSplayRadioViewController.m
//  StartUpStory
//
//  Created by 貴之 伊藤 on 12/10/07.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SUSItem.h"
#import "SUSDataManager.h"
#import "SUSplayRadioViewController.h"

@implementation SUSplayRadioViewController

// プロパティ
@synthesize item = _item;
@synthesize delegate = _delegate;
@synthesize playerView = _playerView;
@synthesize videoPlayerView;

//--------------------------------------------------------------//
#pragma mark -- 初期化 --
//--------------------------------------------------------------//

- (void)_init
{
    // コントローラの設定
    self.title = NSLocalizedString(@"Play Radio", nil);
}

- (id)init
{
    self = [super initWithNibName:@"SUSplayRadioViewController" bundle:nil];
    if (!self) {
        return nil;
    }
    
    // 共通の初期化メソッド
    [self _init];
    
    return self;
}

- (id)initWithCoder:(NSCoder*)decoder
{
    self = [super initWithCoder:decoder];
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
    [_webView release], _webView = nil;
}

- (void)dealloc
{
    // アウトレットを解放する
    [self _releaseOutlets];
    
    // インスタンス変数を解放する
    [_item release], _item = nil;
    _delegate = nil;
    
    // 親クラスのdeallocを呼び出す
    [super dealloc];
}

//--------------------------------------------------------------//
#pragma mark -- プロパティ --
//--------------------------------------------------------------//

- (void)setItem:(SUSItem*)item
{
    // アイテムを設定する
    if (_item != item) {
        [_item release], _item = nil;
        _item = [item retain];
    }
    
    // アイテムを既読にする
    item.read = [NSNumber numberWithBool:YES];
        
    // 保存を行う
    [[SUSDataManager sharedManager] save];
}

//--------------------------------------------------------------//
#pragma mark -- ビュー --
//--------------------------------------------------------------//

- (void)viewDidLoad
{
    //プレーヤ開始時(フルスクリーン状態になった時)
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(movieIsPlaying:)
                                                 name:@"UIMoviePlayerControllerDidEnterFullscreenNotification"
                                               object:nil];
    
    // プレーヤ停止時
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(movieStopedPlaying:)
                                                 name:@"UIMoviePlayerControllerDidExitFullscreenNotification"
                                               object:nil];

    
    NSURL *url = [NSURL URLWithString:@"http://startupstory.biz/wp-content/uploads/2012/08/Ep05_MerryBiz_01_m.mp3"];
    
    // リクエストの作成
    NSURLRequest*   request = nil;
    if (url) {
        request = [NSURLRequest requestWithURL:url];
    }

    // NSURLConnectionオブジェクトの作成
    _connection = [[NSURLConnection connectionWithRequest:request delegate:self] retain];

    
//    player = [[AVPlayer playerWithURL:url] retain];
    playerItem = [[AVPlayerItem playerItemWithURL:url] retain];
//    self.playerItem = [AVPlayerItem playerItemWithURL:url];
//    [playerItem addObserver:self forKeyPath:@"status" options:0
//                    context:&ItemStatusContext];
    // プレイアイテムより動画プレイヤーを作成
    player = [[AVPlayer playerWithPlayerItem: playerItem] retain];
    playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
    playerLayer = ( AVPlayerLayer* )self.videoPlayerView.layer;
    playerLayer.frame = self.playerView.frame;
    playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    [self.view.layer addSublayer:playerLayer];
    [player play];
        
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:nil];
    
//    //ここがミソ　MPMoviePlayerControllerのframeを変更することで
//    //表示位置、サイズを設定することが出来ます。
//    [moviePlayer.view setFrame:CGRectMake(20.0f, 75.0f, 280, 200)];
//    [super viewDidLoad];
//    [self.view setBackgroundColor:[UIColor blackColor]];
////    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
//    
//    //ムービープレイヤーの生成
//    moviePlayer=[[self makeMoviePlayer:@"sample.m4v"] retain];
//    [moviePlayer.view setFrame:CGRectMake(0,0,320,320)];
//    [moviePlayer setFullscreen:YES animated:YES];
//    
//    [self.view addSubview:moviePlayer.view];
//    
//    //ムービー完了の通知(2)
//    [[NSNotificationCenter defaultCenter] addObserver:self 
//                                             selector:@selector(moviePlayBackDidFinish:) 
//                                                 name:MPMoviePlayerPlaybackDidFinishNotification 
//                                               object:moviePlayer];
//    
//    //ムービーの再生(4)
//    [moviePlayer play];
//    
//    //端末のボリューム操作(5)
//    MPVolumeView* volumeView=[[[MPVolumeView alloc] init] autorelease]; 
//    [volumeView setFrame:CGRectMake(0,320,320,40)];
//	[self.view addSubview:volumeView];

} 

- (void)connection:(NSURLConnection*)connection didReceiveResponse:(NSURLResponse*)response
{
    //レスポンスを受け取った時に呼び出される  
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)connectionDidFinishLoading:(NSURLConnection*)connection
{
    //通信が完了した時に呼び出される
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
}

//
//- (MPMoviePlayerController*)makeMoviePlayer:(NSString*)res {
//    //リソースのURLの生成
//    //    NSString* path=[[NSBundle mainBundle] pathForResource:res ofType:@""];
//    //    NSURL* url=[NSURL fileURLWithPath:path];
//    
//    NSString *path = @"http://startupstory.biz/wp-content/uploads/2012/08/Ep05_MerryBiz_01_m.mp3";
//    NSURL *url = [NSURL URLWithString:path];          
//    //ムービープレイヤーの生成(1)
//    MPMoviePlayerController* player=[[[MPMoviePlayerController alloc] 
//                                      initWithContentURL:url] autorelease];
//    player.scalingMode = MPMovieScalingModeAspectFit;
//    [player setMovieSourceType:MPMovieSourceTypeUnknown];
//    //    player.controlStyle=MPMovieControlStyleEmbedded;
//    player.controlStyle=MPMovieControlStyleDefault;
//    return player;
//}

//ムービー完了時に呼ばれる
- (void) moviePlayBackDidFinish:(NSNotification*)notification {
    //ムービー完了原因の取得(3)
    NSDictionary* userInfo=[notification userInfo];
    int reason=[[userInfo objectForKey:
                 @"MPMoviePlayerPlaybackDidFinishReasonUserInfoKey"] intValue];
    if (reason==MPMovieFinishReasonPlaybackEnded) {
        NSLog(@"再生終了");
    } else if (reason==MPMovieFinishReasonPlaybackError) {
        NSLog(@"エラー");
    } else if (reason==MPMovieFinishReasonUserExited) {
        NSLog(@"フルスクリーン用UIのDoneボタンで終了");
    }
}

- (void)viewDidUnload
{
    // アウトレットを解放する
    [self _releaseOutlets];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

/**********************再生関連*************************/

///**
// * 再生時間の更新ハンドラを削除します。
// */
//- (void)removePlayerTimeObserver
//{
//    if( self.playTimeObserver == nil ) { return; }
//    
//    [self.videoPlayer removeTimeObserver:self.playTimeObserver];
//    self.playTimeObserver = nil;
//}
//
///**
// * 再生時間スライダーの操作によって値が更新された時に発生します。
// *
// * @param slider スライダー。
// */
//- (void)seekBarValueChanged:(UISlider *)slider
//{
//	[self.videoPlayer seekToTime:CMTimeMakeWithSeconds( slider.value, NSEC_PER_SEC )];
//}
//
///**
// * シークバーを初期化します。
// */
//- (void)setupSeekBar
//{
//	self.seekBar.minimumValue = 0;
//	self.seekBar.maximumValue = CMTimeGetSeconds( self.playerItem.duration );
//	self.seekBar.value        = 0;
//	[self.seekBar addTarget:self action:@selector(seekBarValueChanged:) forControlEvents:UIControlEventValueChanged];
//    
//	// 再生時間とシークバー位置を連動させるためのタイマー
//	const double interval = ( 0.5f * self.seekBar.maximumValue ) / self.seekBar.bounds.size.width;
//	const CMTime time     = CMTimeMakeWithSeconds( interval, NSEC_PER_SEC );
//	self.playTimeObserver = [self.videoPlayer addPeriodicTimeObserverForInterval:time
//                                                                           queue:NULL
//                                                                      usingBlock:^( CMTime time ) { [self syncSeekBar]; }];
//    
//    self.durationLabel.text = [self timeToString:self.seekBar.maximumValue];
//}

/**
 * エラー通知をおこないます。
 *
 * @param error エラー情報。
 */
//- (void)showError:(NSError *)error
//{
//    [self removePlayerTimeObserver];
//    [self syncSeekBar];
//    self.playButton.enabled = NO;
//    self.seekBar.enabled    = NO;
//    
//    if( error != nil )
//    {
//        UIAlertView* alertView = [[[UIAlertView alloc] initWithTitle:[error localizedDescription]
//                                                             message:[error localizedFailureReason]
//                                                            delegate:nil
//                                                   cancelButtonTitle:@"OK"
//                                                   otherButtonTitles:nil] autorelease];
//        [alertView show];
//    }
//}
//
///**
// * 再生位置スライダーを同期します。
// */
//- (void)syncSeekBar
//{
//	const double duration = CMTimeGetSeconds( [self.videoPlayer.currentItem duration] );
//	const double time     = CMTimeGetSeconds([self.videoPlayer currentTime]);
//	const float  value    = ( self.seekBar.maximumValue - self.seekBar.minimumValue ) * time / duration + self.seekBar.minimumValue;
//    
//	[self.seekBar setValue:value];
//    self.currentTimeLabel.text = [self timeToString:self.seekBar.value];
//}
//
///**
// * 再生・一時停止ボタンの状態を同期します。
// */
//- (void)syncPlayButton
//{
//    if( self.isPlaying )
//    {
//        [self.playButton setImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
//    }
//    else
//    {
//        [self.playButton setImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
//    }
//}
//
///**
// * View がシングル タップされた時に発生します。
// *
// * @param sender イベント送信元。
// */
//- (void)tapSingle:(UITapGestureRecognizer *)sender
//{
//    const BOOL isHidden = !self.navigationController.navigationBar.hidden;
//    
//	[[UIApplication sharedApplication] setStatusBarHidden:isHidden withAnimation:NO];
//	[self.navigationController setNavigationBarHidden:isHidden animated:YES];
//    [self.playerToolView setHidden:isHidden];
//}

/**
 * View がダブル タップされた時に発生します。
 *
 * @param sender イベント送信元。
 */
- (void)tapDouble:(UITapGestureRecognizer *)sender
{
    AVPlayerLayer* layer = ( AVPlayerLayer* )self.videoPlayerView.layer;
    layer.videoGravity = ( layer.videoGravity == AVLayerVideoGravityResizeAspect ? AVLayerVideoGravityResizeAspectFill : AVLayerVideoGravityResizeAspect );
}

/**
 * 時間を文字列化します。
 *
 * @param value 時間。
 *
 * @return 文字列。
 */
- (NSString* )timeToString:(float)value
{
    const NSInteger time = value;
    return [NSString stringWithFormat:@"%d:%02d", ( int )( time / 60 ), ( int )( time % 60 )];
}

//--------------------------------------------------------------//
#pragma mark -- 画面の更新 --
//--------------------------------------------------------------//

//- (void)_updateHTMLContent
//{
//    // webViewを確認する
//    if (!_webView) {
//        return;
//    }
//    
//    // HTMLを作成する
//    NSMutableString*    html;
//    html = [NSMutableString string];
//    
//    // ヘッダを追加する
//    [html appendString:@"<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\">"];
//    [html appendString:@"<html>"];
//    [html appendString:@"<meta http-equiv=\"Content-Type\" content=\"text/html; charset=utf-8\">"];
//    [html appendString:@"<meta http-equiv=\"Content-Style-Type\" content=\"text/css\">"];
//    [html appendString:@"<meta http-equiv=\"Content-Script-Type\" content=\"text/javascript\">"];
//    [html appendString:@"<meta name=\"viewport\" content=\"minimum-scale=1.0, width=device-width, maximum-scale=1.0, user-scalable=no\" />"];
//    [html appendString:@"</head>"];
//    
//    // bodyを追加する
//    [html appendString:@"<body>"];
//    
//    // アイテムを追加する
//    if (_item) {
//        // titleを追加する
//        NSString*   title;
//        title = _item.title;
//        if (!title) {
//            title = NSLocalizedString(@"Untitled", nil);
//        }
//        [html appendString:@"<h2>"];
//        [html appendString:title];
//        [html appendString:@"</h2>"];
//        
//        // linkを追加する
//        NSString*   link;
//        link = _item.link;
//        if (link) {
//            [html appendString:@"<h4>"];
//            [html appendString:_item.link];
//            [html appendString:@"</h4>"];
//        }
//        
//        // pubDateを追加する
//        NSString*   pubDate;
//        pubDate = _item.pubDate;
//        if (pubDate) {
//            [html appendString:@"<h4>"];
//            [html appendString:_item.pubDate];
//            [html appendString:@"</h4>"];
//        }
//        
//        // itemDescriptionを追加する
//        NSString*   itemDescription;
//        itemDescription = _item.itemDescription;
//        if (!itemDescription) {
//            itemDescription = @"(No Description)";
//        }
//        [html appendString:@"<p>"];
//        [html appendString:itemDescription];
//        [html appendString:@"</p>"];
//    }
//    
//    // bodyの終わり
//    [html appendString:@"</body>"];
//    
//    // HTMLの終わり
//    [html appendString:@"</html>"];
//    
//    // HTMLを読み込む
//    [_webView loadHTMLString:html baseURL:nil];
//}


-(void)startAction {
    [player play];
}

-(void)stopAction {
    [player pause];
}

@end

