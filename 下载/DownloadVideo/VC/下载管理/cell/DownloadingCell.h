//
//  DownloadCell.h
//  
//
//  Created by csip on 15/10/15.
//
//

#import <UIKit/UIKit.h>
#import "CircularProgressButton.h"
#import "FileModel.h"
#import "DownLoadOperationManager.h"
#import "CustomLabel.h"
#import "TCBlobDownloader.h"
#import "TCBlobDownloadManager.h"
@interface DownloadingCell : UITableViewCell
@property(nonatomic, strong) FileModel *fileInfo;
@property (nonatomic,strong) TCBlobDownloader *tcbDownload;
@property (weak, nonatomic) IBOutlet UILabel *state;

@property (weak, nonatomic) IBOutlet CustomLabel *fileName;
@property (nonatomic, strong) CircularProgressButton *progressButton;
@property (weak, nonatomic) IBOutlet UILabel *speedOfProgress;
@property(nonatomic,weak) id parentVC;

-(void)setPercent:(float)per;
-(void)initBtn;
@end
