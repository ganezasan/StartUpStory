//
//  SUSplayRadioViewController.h
//  StartUpStory
//
//  Created by 貴之 伊藤 on 12/10/07.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import "AVPlayerView.h"

@class SUSItem;

@interface SUSplayRadioViewController : UIViewController
{
    SUSItem*    _item;
    AVPlayer *player;
    AVPlayerItem *playerItem;
    id          _delegate; // Assign
    AVPlayerLayer *playerLayer;
    AVPlayerView *_playerView;
//    MPMusicPlayerController *player;
    MPMoviePlayerController *moviePlayer;
    IBOutlet UIWebView* _webView;
    UIActivityIndicatorView* indicator;
    NSURLConnection*    _connection;
}

// アクション
- (IBAction)stopAction;
- (IBAction)startAction;

// プロパティ
@property (nonatomic, retain) IBOutlet AVPlayerView* videoPlayerView;  //! 動画表示
@property (nonatomic, retain) SUSItem* item;
@property (nonatomic, assign) id delegate;
@property (nonatomic, retain) AVPlayerView* playerView;


@end
