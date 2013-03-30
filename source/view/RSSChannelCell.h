#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface RSSChannelCell : UITableViewCell
{
    // サブビュー
    UILabel*        _titleLabel;
    UILabel*        _feedLabel;
    UIImageView*    _numberBackgroundImageView;
    UILabel*        _numberLabel;
}

// プロパティ
@property (nonatomic, retain) UILabel* titleLabel;
@property (nonatomic, retain) UILabel* feedLabel;
@property (nonatomic) int itemNumber;

@end
