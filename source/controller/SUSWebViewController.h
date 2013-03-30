//
//  SUSWebViewController.h
//  StartUpStory
//
//  Created by 貴之 伊藤 on 12/09/30.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SUSWebViewController : UIViewController
{
    IBOutlet UIWebView* _webView;
    UIActivityIndicatorView* indicator;
}
@property (nonatomic, retain) UIWebView* webView;

@end
