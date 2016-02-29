//
//  RosterViewController.m
//  LYChatApp
//
//  Created by 吕阳 on 16/2/25.
//  Copyright © 2016年 DeveloperYoung. All rights reserved.
//

#import "RosterViewController.h"
#import "XMPPManager.h"
#import "ChatViewController.h"

@interface RosterViewController ()<XMPPRosterDelegate>
/* 好友列表数组 */
@property (nonatomic, strong)NSMutableArray *friendsArray;
@end

@implementation RosterViewController
- (NSMutableArray *)friendsArray
{
    if (!_friendsArray) {
        _friendsArray = [NSMutableArray array];
    }
    return _friendsArray;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    
    [[XMPPManager shareInstance].xmppRoster addDelegate:self delegateQueue:dispatch_get_main_queue()];
}
- (IBAction)addFriend:(UIBarButtonItem *)sender {
    
    UIAlertController *controller = [UIAlertController alertControllerWithTitle:@"添加好友" message:@"输入好友名称" preferredStyle:UIAlertControllerStyleAlert];
    //输入框
    [controller addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        
    }];
    //按钮
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"添加" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //获取好友名字
        NSString *name = [controller.textFields firstObject].text;
        //设置JID
        XMPPJID *jid = [XMPPJID jidWithUser:name domain:kDomin resource:kResource];
        
//        //判断
        if ([[XMPPManager shareInstance].coreDataStorage userExistsWithJID:jid xmppStream:[XMPPManager shareInstance].xmppStream]) {
            NSLog(@"exists");
            return;
        }
        
        //发送好友请求
        [[XMPPManager shareInstance].xmppRoster subscribePresenceToUser:jid];
    }];
    
    [controller addAction:action];
    [self.navigationController presentViewController:controller animated:YES completion:nil];
}
#pragma mark - XMPPRosterDelegate

#pragma mark 接收到好友请求
- (void)xmppRoster:(XMPPRoster *)sender didReceivePresenceSubscriptionRequest:(XMPPPresence *)presence
{
    
    //接受好友请求
    
    XMPPJID *jid = [presence from];
    
//    //获取好友花名册
    if ([[XMPPManager shareInstance].coreDataStorage userExistsWithJID:jid xmppStream:[XMPPManager shareInstance].xmppStream]) {
        
        NSLog(@"exists");
        
        return;
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"%@想添加你为好友", jid.user] message:@"是否同意" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"同意" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //同意好友请求
        [[XMPPManager shareInstance].xmppRoster acceptPresenceSubscriptionRequestFrom:jid andAddToRoster:YES];
    }];
    
    UIAlertAction *noAction = [UIAlertAction actionWithTitle:@"拒绝" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        //拒绝好友请求
        [[XMPPManager shareInstance].xmppRoster rejectPresenceSubscriptionRequestFrom:jid];
        
        XMPPPresence *presence = [XMPPPresence presenceWithType:@"unsubscribed"];
        [[XMPPManager shareInstance].xmppStream sendElement:presence];
    }];
    
    [alert addAction:okAction];
    [alert addAction:noAction];
    
    [self.navigationController presentViewController:alert animated:YES completion:^{
        
    }];
    
    
    
}
#pragma mark 开始检索
- (void)xmppRosterDidBeginPopulating:(XMPPRoster *)sender
{
    NSLog(@"开始检索");
}
#pragma mark 一次检索出一个好友
- (void)xmppRoster:(XMPPRoster *)sender didReceiveRosterItem:(DDXMLElement *)item
{
    NSString *jidStr = [[item attributeForName:@"jid"] stringValue];
    
    //转换成XMPPJID对象
    XMPPJID *jid = [XMPPJID jidWithString:jidStr];
    //判断是否添加过
    if ([self.friendsArray containsObject:jid]) {
        return;
    }
    [self.friendsArray addObject:jid];
    //刷新UI
    [self.tableView reloadData];
}
#pragma mark 结束检索
- (void)xmppRosterDidEndPopulating:(XMPPRoster *)sender
{
    NSLog(@"结束检索");
}

#pragma mark - Table view data source



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.friendsArray.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"rosterID" forIndexPath:indexPath];
    
    XMPPJID *jid = self.friendsArray[indexPath.row];
    
    cell.textLabel.text = jid.user;
    return cell;
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //获取cell
    UITableViewCell *cell = sender;
    
    //获取NSIndexPath
    NSIndexPath *path = [self.tableView indexPathForCell:cell];
    //获取到JID
    XMPPJID *jid = self.friendsArray[path.row];
    //获取到聊天控制器
//    ChatViewController *chatVC = [[UIStoryboard storyboardWithName:@"Main" bundle:nil]instantiateViewControllerWithIdentifier:@"chatController"];
    ChatViewController *chatVC = segue.destinationViewController;
    chatVC.friendJID = jid;
}

@end
