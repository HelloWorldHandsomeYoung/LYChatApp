//
//  XMPPManager.m
//  LYChatApp
//
//  Created by 吕阳 on 16/2/25.
//  Copyright © 2016年 DeveloperYoung. All rights reserved.
//

#import "XMPPManager.h"

typedef enum : NSUInteger {
    connectPurposeRegister,
    connectPurposeLogin,
} connectPurpose;

@interface XMPPManager ()<XMPPStreamDelegate, XMPPRosterDelegate, XMPPMessageArchivingStorage>
/* 注册密码 */
@property (nonatomic, copy)NSString *registerPassWord;
/* 登录密码 */
@property (nonatomic, copy)NSString *loginPassWord;

//枚举器
@property (nonatomic)connectPurpose connectPurpose;

@end

static XMPPManager *manager = nil;
@implementation XMPPManager
+ (instancetype)shareInstance
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[XMPPManager alloc]init];
    });
    return manager;
}
#pragma mark - 初始化相关属性
- (instancetype)init
{
    self = [super init];
    if (self) {
        //通信管道 初始化
        
        self.xmppStream = [[XMPPStream alloc]init];
        
        //设置相关参数
        
        _xmppStream.hostName = kHostName;
        
        _xmppStream.hostPort = kHostPort;
        
        //添加代理  可以添加多个代理，比较特殊
        [_xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
        
        //初始化花名册 并进行相关设置
        
        //花名册数据管理助手
        self.coreDataStorage = [XMPPRosterCoreDataStorage sharedInstance];
        
        _xmppRoster = [[XMPPRoster alloc]initWithRosterStorage:self.coreDataStorage  dispatchQueue:dispatch_get_main_queue()];
        
        //激活通信管道
        [_xmppRoster activate:_xmppStream];
        
        //给roster添加代理
        [self.xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
        
        //初始化聊天信息类设置相关参数
        XMPPMessageArchivingCoreDataStorage *messageCoreDataStorage = [XMPPMessageArchivingCoreDataStorage sharedInstance];
        self.messageArchiving = [[XMPPMessageArchiving alloc]initWithMessageArchivingStorage:messageCoreDataStorage dispatchQueue:dispatch_get_main_queue()];
        //激活通道
        [self.messageArchiving activate:self.xmppStream];
        //添加代理
        [self.messageArchiving addDelegate:self delegateQueue:dispatch_get_main_queue()];
        
        self.context = messageCoreDataStorage.mainThreadManagedObjectContext;
        
    }
    return self;
}
#pragma mark - 连接服务器
- (void)connectToServer
{
    if ([self.xmppStream isConnected]) {
//        XMPPPresence *presense = [XMPPPresence presenceWithType:@"unavailable"];
//        [self.xmppStream sendElement:presense];
//        
//        NSLog(@"myJID:%@", self.xmppStream.myJID);
        //如果当前已经有链接 先断开
        [self.xmppStream disconnect];
    }
    NSError *error = nil;
    BOOL result = [self.xmppStream connectWithTimeout:20 error:&error];
    if (!result) {
        //链接有错误
        NSLog(@"错误信息:%@", error);
    }
}

#pragma mark - 注册
- (void)registerWithUserName:(NSString *)name passWord:(NSString *)password
{
    self.connectPurpose = connectPurposeRegister;
    //创建了一个账号
    XMPPJID *jid = [XMPPJID jidWithUser:name domain:kDomin resource:kResource];
    NSLog(@"%@", jid);
    //设置myJID
    self.xmppStream.myJID = jid;
    //保存注册密码
    self.registerPassWord = password;
    //像服务器发起链接请求
    [self connectToServer];
}
#pragma mark - 登录
- (void)loginWithUserName:(NSString *)name passWord:(NSString *)password
{
    self.connectPurpose = connectPurposeLogin;
    //创建JID
    XMPPJID *jid = [XMPPJID jidWithUser:name domain:kDomin resource:kResource];
    //设置JID
    self.xmppStream.myJID = jid;
    //保存登录密码
    self.loginPassWord = password;
    //链接服务器
    [self connectToServer];
}
#pragma mark - -XMPPStreamDelegate

#pragma mark 链接成功
- (void)xmppStreamDidConnect:(XMPPStream *)sender
{
    NSLog(@"链接成功");
    
    //判断是注册还是登录
    switch (self.connectPurpose) {
        case connectPurposeRegister:
        {
            NSError *error = nil;
            [self.xmppStream registerWithPassword:self.registerPassWord error:&error];
            if (error) {
                NSLog(@"注册error:%@", error);
            }
            break;
        }
        case connectPurposeLogin:
        {
            NSError *error = nil;
            [self.xmppStream authenticateWithPassword:self.loginPassWord error:&error];
            if (error) {
                NSLog(@"登录error:%@", error);
            }
            break;
        }
           
        default:
        {
            break;
        }
    }
}
#pragma mark 连接超时
- (void)xmppStreamConnectDidTimeout:(XMPPStream *)sender
{
    NSLog(@"链接超时");
}
#pragma mark 断开链接
- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error
{
    NSLog(@"断开链接");
}
#pragma mark 注册成功
- (void)xmppStreamDidRegister:(XMPPStream *)sender
{
    NSLog(@"注册成功");
}
#pragma mark 验证成功
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender
{
    NSLog(@"验证成功");
    
    //设置用户当前状态为上线（上线 available 下线 unavailable）
    XMPPPresence *presence = [XMPPPresence presenceWithType:@"available"];
    [sender sendElement:presence];
    
//    NSLog(@"sender.myJID : %@", sender.myJID);
}
#pragma mark 注册失败
- (void)xmppStream:(XMPPStream *)sender didNotRegister:(DDXMLElement *)error
{
    NSLog(@"注册失败");
}
#pragma mark 验证失败
- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error
{
    NSLog(@"验证失败");
}

#pragma mark - XMPPRosterDelegate
- (void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence
{
    NSLog(@"接收到好友请求");
}
@end
