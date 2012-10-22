//
//  WGDetailListCell.m
//  WizGroup
//
//  Created by wiz on 12-10-22.
//  Copyright (c) 2012年 cn.wiz. All rights reserved.
//

#import "WGDetailListCell.h"
#import "WizDbManager.h"
#import "WGGlobalCache.h"

@interface WGDetailListCell ()
{
    UILabel* titleLabel;
    UILabel* timeLabel;
    UILabel* authorLabel;
    UILabel* abstractLabel;
    UIImageView* abstractImageView;
}
@end

@implementation WGDetailListCell
@synthesize documentGuid;
@synthesize kbGuid;
@synthesize accountUserId;

static UIFont* titleFont = nil;
static UIFont* authorFont = nil;
static UIFont* detailFont = nil;
static UIFont* timeFont = nil;


- (void) dealloc
{
    [titleLabel release];
    [timeLabel release];
    [authorLabel release];
    [abstractImageView release];
    [abstractLabel release];
    
    [super dealloc];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            titleFont = [[UIFont systemFontOfSize:16] retain];
            authorFont = [[UIFont systemFontOfSize:12] retain];
            detailFont = [[UIFont systemFontOfSize:14] retain];
            timeFont = [[UIFont systemFontOfSize:12] retain];
        });
        
        titleLabel = [[UILabel alloc] init];
        [titleLabel setFont:titleFont];
        [self.contentView addSubview:titleLabel];
        //
        timeLabel = [[UILabel alloc] init];
        [timeLabel setFont:timeFont];
        [self.contentView addSubview:timeLabel];
        //
        authorLabel = [[UILabel alloc] init];
        [authorLabel setFont:authorFont];
        [self.contentView addSubview:authorLabel];
        //
        abstractLabel = [[UILabel alloc] init];
        [abstractLabel setFont:detailFont];
        abstractLabel.numberOfLines = 0;
        abstractLabel.textColor = [UIColor lightGrayColor];
        [self.contentView addSubview:abstractLabel];
        //
        abstractImageView = [[UIImageView alloc] init];
        [self.contentView addSubview:abstractImageView];
    }
    return self;
}

- (void) drawRect:(CGRect)rect
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        id<WizMetaDataBaseDelegate> metaDb = [[WizDbManager shareInstance] getMetaDataBaseForAccount:self.accountUserId kbGuid:self.kbGuid];
        WizDocument* doc = [metaDb documentFromGUID:self.documentGuid];
        
        WGGlobalCache* shareCache = [WGGlobalCache shareInstance];
        WizAbstract* abstract = [shareCache abstractForGuid:self.documentGuid];
        if (abstract == nil && doc.bServerChanged == NO) {
            if ([shareCache generateAbstractForDocument:self.documentGuid accountUserId:self.accountUserId]) {
                abstract = [shareCache abstractForGuid:self.documentGuid];
            }
        }

        static float startX = 10;
        
        CGSize cellSize = self.contentView.frame.size;
        float endX = cellSize.width - 20;
        //
        float imageWidth = 0;
        float imageHeight = 0;
        float imageStartX = cellSize.width - 10 - cellSize.height;
        if (abstract && abstract.uiImage) {
             imageWidth = cellSize.height;
             imageHeight = cellSize.height;
             endX = cellSize.width - 10 - imageWidth;
            imageStartX = endX;
        }
        //
        float titleWidth = endX - startX;
        float titleHeight = 20;
        //
        float timeWidth = 80 - startX;
        float timeHeight = 15;
        //

        float authorWidth = 80;
        float authorStartx = endX - authorWidth;
        float authorHeight = 15;
        //
        float detaiWidth = titleWidth;
        float detailHeight = 50;
        //
        CGRect titleRect = CGRectMake(startX, 0.0, titleWidth , titleHeight);
        CGRect timeRect = CGRectMake(startX, titleHeight, timeWidth, timeHeight);
        CGRect authorRect = CGRectMake(authorStartx, titleHeight, authorWidth, authorHeight);
        CGRect detailRect = CGRectMake(startX, titleHeight + timeHeight, detaiWidth, detailHeight);
        CGRect imageRect = CGRectMake(imageStartX, 0, imageWidth, imageHeight);
        NSString* authorStr = doc.strOwner;
        if (authorStr) {
            NSInteger indexOf = [authorStr indexOf:@"@"];
            if (indexOf != NSNotFound) {
                authorStr = [authorStr substringToIndex:indexOf];
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            titleLabel.frame = titleRect;
            titleLabel.text = doc.strTitle;
            //
            timeLabel.frame = timeRect;
            timeLabel.text = [doc.dateModified stringLocal];
            //
            abstractLabel.frame = detailRect;
            abstractLabel.text = abstract.strText;
            //
            authorLabel.frame = authorRect;
            authorLabel.text = authorStr;
            //
            abstractImageView.frame = imageRect;
            abstractImageView.image = abstract.uiImage;
        });
    });

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
