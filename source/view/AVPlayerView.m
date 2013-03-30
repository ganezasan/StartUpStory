//
//  AVPlayerView.m
//  StartUpStory
//
//  Created by 貴之 伊藤 on 12/10/21.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "AVPlayerView.h"
#import <AVFoundation/AVFoundation.h>

@implementation AVPlayerView

/**
 * レイヤーのクラス情報を取得します。
 *
 * @return レイヤー。
 */
+ (Class)layerClass
{
    return [AVPlayerLayer class];
}

@end
