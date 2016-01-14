//
//  NewTaskVC.h
//  
//
//  Created by csip on 15/10/15.
//
//

#import <UIKit/UIKit.h>
typedef void(^downFileUrl)(NSString *url);
@interface NewTaskVC : UIViewController
@property (nonatomic,copy)downFileUrl url;
@end
