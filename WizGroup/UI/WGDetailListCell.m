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
    [[WizNotificationCenter defaultCenter] removeObserver:self];
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
            titleFont = [[UIFont boldSystemFontOfSize:15] retain];
            authorFont = [[UIFont systemFontOfSize:11] retain];
            detailFont = [[UIFont systemFontOfSize:11] retain];
            timeFont = [[UIFont systemFontOfSize:11] retain];
        });
        
        titleLabel = [[UILabel alloc] init];
        [titleLabel setFont:titleFont];
        [self.contentView addSubview:titleLabel];
        
        //
        timeLabel = [[UILabel alloc] init];
        [timeLabel setFont:timeFont];
        [self.contentView addSubview:timeLabel];
        timeLabel.textColor = [UIColor lightGrayColor];
        //
        authorLabel = [[UILabel alloc] init];
        [authorLabel setFont:authorFont];
        [self.contentView addSubview:authorLabel];
        authorLabel.textColor = [UIColor lightGrayColor];
        //
        abstractLabel = [[UILabel alloc] init];
        [abstractLabel setFont:detailFont];
        abstractLabel.numberOfLines = 0;
        [self.contentView addSubview:abstractLabel];
        //
        abstractImageView = [[UIImageView alloc] init];
        [self.contentView addSubview:abstractImageView];
        
        [[WizNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadUI:) name:WizNMUIDidGenerateAbstract object:nil];
    }
    return self;
}


- (void) reloadUI:(NSNotification*)nc
{
    NSString* hasAbsDocGuid = [WizNotificationCenter getDocumentGuidFromNc:nc];
    if ([self.documentGuid isEqualToString:hasAbsDocGuid]) {
        [self performSelectorOnMainThread:@selector(doReloadUI) withObject:nil waitUntilDone:NO];
    }
}

- (void) doReloadUI
{
    id<WizMetaDataBaseDelegate> metaDb = [[WizDbManager shareInstance] getMetaDataBaseForAccount:self.accountUserId kbGuid:self.kbGuid];
    WizDocument* doc = [metaDb documentFromGUID:self.documentGuid];

    WizAbstract* abstract = [WGGlobalCache abstractForDoc:self.documentGuid kbguid:self.kbGuid accountUserId:self.accountUserId];
    
    static float startX = 10;
    
    CGSize cellSize = self.contentView.frame.size;
    float endX = cellSize.width - 20;
    //
    float imageWidth = 0;
    float imageHeight = 0;
    float imageStartX = cellSize.width - 10 - cellSize.height;
    if (abstract && abstract.uiImage) {
        imageWidth = cellSize.height - 10;
        imageHeight = cellSize.height - 10;
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
    CGRect titleRect = CGRectMake(startX, 5, titleWidth , titleHeight);

    CGRect detailRect = CGRectMake(startX, titleHeight + 5, detaiWidth, detailHeight);
    
    CGRect timeRect = CGRectMake(startX, titleHeight + detailHeight +5, timeWidth, timeHeight);
    CGRect authorRect = CGRectMake(authorStartx, titleHeight + detailHeight +5, authorWidth, authorHeight);
    
    CGRect imageRect = CGRectMake(imageStartX, 5, imageWidth, imageHeight);
    NSString* authorStr = doc.strOwner;
    if (authorStr) {
        NSInteger indexOf = [authorStr indexOf:@"@"];
        if (indexOf != NSNotFound) {
            authorStr = [authorStr substringToIndex:indexOf];
        }
    }
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
}

- (void) drawRect:(CGRect)rect
{
    [self doReloadUI];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
