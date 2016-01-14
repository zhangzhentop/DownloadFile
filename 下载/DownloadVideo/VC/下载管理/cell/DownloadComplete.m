//
//  DownloadComplete.m
//  
//
//  Created by csip on 15/10/15.
//
//

#import "DownloadComplete.h"

@implementation DownloadComplete

- (void)awakeFromNib {
    // Initialization code
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-0.5, self.frame.size.width, 0.5)];
    line.backgroundColor = [UIColor grayColor];
    [self addSubview:line];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
