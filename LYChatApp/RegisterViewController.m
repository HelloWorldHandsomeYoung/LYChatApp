//
//  RegisterViewController.m
//  LYChatApp
//
//  Created by 吕阳 on 16/2/25.
//  Copyright © 2016年 DeveloperYoung. All rights reserved.
//

#import "RegisterViewController.h"
#import "XMPPManager.h"
#import "XMPPFramework.h"
@interface RegisterViewController ()<XMPPStreamDelegate>
//用户名输入框
@property (weak, nonatomic) IBOutlet UITextField *userNameField;
//密码输入框
@property (weak, nonatomic) IBOutlet UITextField *passWordField;

@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //添加代理
    [[XMPPManager shareInstance].xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    // Do any additional setup after loading the view.
}
#pragma mark - 注册成功
- (void)xmppStreamDidRegister:(XMPPStream *)sender
{
    NSString *userName = self.userNameField.text;
    NSString *passWord = self.passWordField.text;
    //注册成功 自动登录
    [[XMPPManager shareInstance]loginWithUserName:userName passWord:passWord];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
//按钮点击事件
- (IBAction)registerAction:(UIButton *)sender {
    NSString *userName = self.userNameField.text;
    NSString *passWord = self.passWordField.text;
    
    [[XMPPManager shareInstance]registerWithUserName:userName passWord:passWord];
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
