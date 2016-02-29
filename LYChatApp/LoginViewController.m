//
//  LoginViewController.m
//  LYChatApp
//
//  Created by 吕阳 on 16/2/25.
//  Copyright © 2016年 DeveloperYoung. All rights reserved.
//

#import "LoginViewController.h"
#import "RegisterViewController.h"
#import "XMPPManager.h"
#import "XMPPFramework.h"

@interface LoginViewController ()<XMPPStreamDelegate>
@property (weak, nonatomic) IBOutlet UITextField *userNameField;
@property (weak, nonatomic) IBOutlet UITextField *passWordField;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //添加代理
    [[XMPPManager shareInstance].xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    // Do any additional setup after loading the view.
}
#pragma mark - 协议方法 验证成功
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)loginAction:(UIButton *)sender {
    
    NSString *userName = self.userNameField.text;
    NSString *passWord = self.passWordField.text;
    //执行登录
    [[XMPPManager shareInstance]loginWithUserName:userName passWord:passWord];
}
- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    [segue destinationViewController];
}


@end
