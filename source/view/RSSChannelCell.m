#import "RSSChannelCell.h"

@implementation RSSChannelCell

// プロパティ
@synthesize titleLabel = _titleLabel;
@synthesize feedLabel = _feedLabel;

//--------------------------------------------------------------//
#pragma mark -- 初期化 --
//--------------------------------------------------------------//

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)reuseIdentifier
{
    // 親クラスの初期化メソッドを呼び出す
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (!self) {
        return nil;
    }
    
    // titleラベルの作成
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _titleLabel.font = [UIFont boldSystemFontOfSize:16.0f];
    _titleLabel.textColor = [UIColor blackColor];
    _titleLabel.highlightedTextColor = [UIColor whiteColor];
    [self.contentView addSubview:_titleLabel];
    
    // feedラベルの作成
    _feedLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _feedLabel.font = [UIFont systemFontOfSize:12.0f];
    _feedLabel.textColor = [UIColor grayColor];
    _feedLabel.highlightedTextColor = [UIColor whiteColor];
    [self.contentView addSubview:_feedLabel];
    
    // UIImageViewの作成
    UIImage*    image;
    image = [UIImage imageNamed:@"numberBackground.png"];
    _numberBackgroundImageView = [[UIImageView alloc] initWithImage:image];
    [self.contentView addSubview:_numberBackgroundImageView];
    
    // 数字のためのラベルの作成
    _numberLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _numberLabel.font = [UIFont boldSystemFontOfSize:17.0f];
    _numberLabel.textColor = [UIColor whiteColor];
    _numberLabel.backgroundColor = [UIColor clearColor];
    _numberLabel.textAlignment = UITextAlignmentCenter;
    [self.contentView addSubview:_numberLabel];
    
    return self;
}

//--------------------------------------------------------------//
#pragma mark -- プロパティ --
//--------------------------------------------------------------//

- (int)itemNumber
{
    // ラベルから数値を取得する
    return [_numberLabel.text intValue];
}

- (void)setItemNumber:(int)itemNumber
{
    // ラベルにテキストを設定する
    _numberLabel.text = [NSString stringWithFormat:@"%d", itemNumber];
    
    // セルの再レイアウトを行う
    [self setNeedsLayout];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    // 親クラスのメソッドを呼び出す
    [super setHighlighted:highlighted animated:animated];
    
    // ラベルのハイライトを設定する
    _titleLabel.highlighted = highlighted;
    _feedLabel.highlighted = highlighted;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    // 親クラスのメソッドを呼び出す
    [super setSelected:selected animated:animated];
    
    // ラベルのハイライトを設定する
    _titleLabel.highlighted = selected;
    _feedLabel.highlighted = selected;
}

//--------------------------------------------------------------//
#pragma mark -- レイアウト --
//--------------------------------------------------------------//

- (void)layoutSubviews
{
    CGRect  rect;
    
    // 親クラスのメソッドを呼び出す
    [super layoutSubviews];
    
    // contentViewの大きさを取得する
    CGRect  bounds;
    bounds = self.contentView.bounds;
    
    // numberBackgroundImageViewのレイアウト
    rect.origin = CGPointZero;
    rect.size = _numberBackgroundImageView.frame.size;
    _numberBackgroundImageView.frame = rect;
    
    // numberLabelのレイアウト
    rect = _numberBackgroundImageView.frame;
    _numberLabel.frame = rect;
    
    // titleLabelのレイアウト
    rect.origin.x = CGRectGetMaxX(_numberBackgroundImageView.frame) + 4.0f;
    rect.origin.y = CGRectGetMinY(bounds) + 4.0f;
    rect.size.width = CGRectGetWidth(bounds) - CGRectGetMinX(rect);
    rect.size.height = 22.0f;
    _titleLabel.frame = rect;
    
    // feedLabelのレイアウト
    rect.origin.x = CGRectGetMinX(_titleLabel.frame);
    rect.origin.y = CGRectGetMaxY(_titleLabel.frame);
    rect.size.width = CGRectGetWidth(_titleLabel.frame);
    rect.size.height = 14.0f;
    _feedLabel.frame = rect;
}

@end
