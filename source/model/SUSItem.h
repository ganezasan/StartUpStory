#import <CoreData/CoreData.h>

@interface SUSItem : NSManagedObject  
{
}

// プロパティ
@property (nonatomic, retain) NSString* title;
@property (nonatomic, retain) NSString* subTitle;
@property (nonatomic, retain) NSNumber* read;
@property (nonatomic, retain) NSString* identifier;
@property (nonatomic, retain) NSString* link;
@property (nonatomic, retain) NSString* itemDescription;
@property (nonatomic, retain) NSDate* pubDate;
@property (nonatomic, retain) NSString* podcastLink;
@property (nonatomic, retain) NSNumber* radioFlag;
@property (nonatomic, retain) NSNumber* index;


@end



