//
//  NewTaskVC.m
//  
//
//  Created by csip on 15/10/15.
//
//

#import "NewTaskVC.h"
#import "DownLoadOperationManager.h"
#import "AFHTTPSessionManager.h"
@interface NewTaskVC ()<UITextFieldDelegate,UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *textField;

@end

@implementation NewTaskVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
/**
 *  测试网络链接
 */
-(void)testNetworkLink{
    AFHTTPSessionManager *sharedClient = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:@"http://weibo.com/"]];
    sharedClient.securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
    [sharedClient.reachabilityManager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status){
        if (status == AFNetworkReachabilityStatusReachableViaWWAN) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"当前网络是2G/3G/4G,是否确认下载" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:@"取消", nil];
            alert.delegate = self;
            alert.tag = 101;
            [alert show];
            //数据网路
        }else if (status == AFNetworkReachabilityStatusUnknown || status == AFNetworkReachabilityStatusNotReachable) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"无法连接到互联网" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
            [alert show];
            return;
        }else{
            [self toBack];
        }
    }];
    [sharedClient.reachabilityManager startMonitoring];
}
- (IBAction)download:(id)sender {
    if (_textField.text.length>0) {
        //测试网络
        [self testNetworkLink];
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:@"请输入网址" delegate:self cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }
    
}

/**
 *  返回上一页
 */
-(void)toBack{
    NSString *l = _textField.text;
//    NSString *l = @"https://dl.google.com/dl/android/aosp/hammerhead-lmy48i-factory-a38c3441.tgz";
    DownLoadOperationManager *df = [[DownLoadOperationManager sharedFiles]initWithUrl:l];
    NSLog(@"%@",df);
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark AlertViewdelegate
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == 0 && alertView.tag == 101) {
        [self toBack];
    }else{
        
    }
}
#pragma mark textFieldDelegate
-(void)textFieldDidBeginEditing:(UITextField *)textField{
    CGRect frame = textField.frame;
    int offset = frame.origin.y + 32 - (self.view.frame.size.height - 216.0);//iPhone键盘高度216，iPad的为352
    
    [UIView beginAnimations:@"ResizeForKeyboard" context:nil];
    [UIView setAnimationDuration:0.3f];
    
    //将视图的Y坐标向上移动offset个单位，以使下面腾出地方用于软键盘的显示
    if(offset > 0)
        self.view.frame = CGRectMake(0.0f, -offset, self.view.frame.size.width, self.view.frame.size.height);
    [UIView commitAnimations];
}

-(void)textFieldDidEndEditing:(UITextField *)textField{
    self.view.frame =CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [textField resignFirstResponder];
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

@end
