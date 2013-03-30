//
//  SUSWebViewController.m
//  StartUpStory
//
//  Created by 貴之 伊藤 on 12/09/30.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "SUSWebViewController.h"
#import "MyToolbar.h"

@interface SUSWebViewController ()

@end

@implementation SUSWebViewController

@synthesize webView = _webView;

-(id)_init{
    if((self = [super init])){
        //tabBar設定用
        self.title = @"Home";
        UIImage* icon = [UIImage imageNamed:@"home.png"];
        self.tabBarItem = [[[UITabBarItem alloc]initWithTitle:@"Home" image:icon tag:0] autorelease];

        UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRewind target:self action:@selector(back)];
        backButton.style = UIBarButtonItemStyleBordered;
        backButton.tintColor=[UIColor blackColor];
        
        UIBarButtonItem *forwardButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFastForward target:self action:@selector(forward)];
        forwardButton.style = UIBarButtonItemStyleBordered;
        forwardButton.tintColor=[UIColor blackColor];
        
        UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        
        UIToolbar *toolbar = [[MyToolbar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 100.0f, 44.0f)];
        toolbar.backgroundColor = [UIColor clearColor];
        toolbar.autoresizingMask = UIViewAutoresizingFlexibleHeight;
        UIBarButtonItem *toolbarBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:toolbar];
        [toolbar release];
        
        toolbar.items = [NSArray arrayWithObjects: backButton, space,forwardButton, nil];
        [space release];
        [backButton release];
        [forwardButton release];
        
        UIBarButtonItem *refreshButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(refresh)];
        refreshButtonItem.style = UIBarButtonItemStyleBordered;
        refreshButtonItem.tintColor=[UIColor blackColor];
        
        self.navigationItem.leftBarButtonItem = toolbarBarButtonItem;
        self.navigationItem.rightBarButtonItem = refreshButtonItem;
        [toolbarBarButtonItem release];
    }
    return self;
}

-(UIBarButtonItem*)barButtonSystemItem:(UIBarButtonSystemItem)systemItem selector:(SEL)selector{
    
    UIBarButtonItem* button = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:systemItem target:nil action:nil] autorelease];
    
    return button;
}

-(void)back
{
    [_webView goBack];
}

-(void)forward
{
    [_webView goForward];
}

-(void)refresh
{
    [_webView reload];
}

- (id)init
{
    // nibファイル名を指定して、初期化メソッドを呼び出す
    self = [super initWithNibName:@"SUSWebViewController" bundle:nil];
    if (!self) {
        return nil;
    }
    
    // 共通の初期化メソッド
    [self _init];
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    indicator = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] autorelease];
    indicator.frame = CGRectMake(0, 0, 50, 50);
    indicator.center = self.view.center;
    [self.view addSubview:indicator];
    NSURLRequest* request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://startupstory.biz"]];
    [_webView loadRequest:request];
}

- (void)webViewDidStartLoad:(UIWebView *)webView{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    [indicator startAnimating];
}

//コンテンツ読み込み完了時に呼ばれる
-(void)webViewDidFinishLoad:(UIWebView*)webView{
    [indicator stopAnimating];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}


-(void)viewDidAppear:(BOOL)animated{
    //WebViewの作成
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
