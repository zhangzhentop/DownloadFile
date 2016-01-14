//
//  DownloadComplete.h
//  
//
//  Created by csip on 15/10/15.
//
//

#import <UIKit/UIKit.h>

@interface DownloadComplete : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *fileIcon;
@property (weak, nonatomic) IBOutlet UILabel *fileName;
@property (weak, nonatomic) IBOutlet UILabel *fileSize;

@end
