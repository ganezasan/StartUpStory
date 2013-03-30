//
//  SUSInfoViewController.h
//  StartUpStory
//
//  Created by 貴之 伊藤 on 12/10/08.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SUSInfoViewController : UIViewController
{
    IBOutlet UIWebView* _webView;
    UIActivityIndicatorView* indicator;
}
@property (nonatomic, retain) UIWebView* webView;

@end