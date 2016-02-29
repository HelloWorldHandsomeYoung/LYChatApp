//
//  ChatViewController.m
//  LYChatApp
//
//  Created by 吕阳 on 16/2/26.
//  Copyright © 2016年 DeveloperYoung. All rights reserved.
//

#import "ChatViewController.h"
#import "XMPPManager.h"

@interface ChatViewController ()<UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, XMPPStreamDelegate>
@property (weak, nonatomic) IBOutlet UITextField *chatField;
@property (weak, nonatomic) IBOutlet UITableView *chatView;


/* 聊天记录数组 */
@property (nonatomic, strong)NSMutableArray *messageArray;
@end

@implementation ChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //设置通知
    [self getNotification];
    
    //添加代理
    [[XMPPManager shareInstance].xmppStream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    self.chatField.delegate = self;
    
    //查询聊天记录
    [self searchMessage];
}
- (NSMutableArray *)messageArray
{
    if (!_messageArray) {
        _messageArray = [NSMutableArray array];
    }
    return _messageArray;
}

#pragma mark - 获取聊天信息
- (void)searchMessage
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPMessageArchiving_Message_CoreDataObject" inManagedObjectContext:[XMPPManager shareInstance].context];
    [fetchRequest setEntity:entity];
    // Specify criteria for filtering which objects to fetch
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"streamBareJidStr == %@ AND bareJidStr == %@", [XMPPManager shareInstance].xmppStream.myJID.bare, self.friendJID.bare];
    [fetchRequest setPredicate:predicate];
    // Specify how the fetched objects should be sorted
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"timestamp"ascending:YES];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObjects:sortDescriptor, nil]];
    
    NSError *error = nil;
    NSArray *fetchedObjects = [[XMPPManager shareInstance].context executeFetchRequest:fetchRequest error:&error];
    if (fetchedObjects == nil) {
        NSLog(@"查询失败：%@", error);
    }
    [self.messageArray removeAllObjects];
    [self.messageArray addObjectsFromArray:fetchedObjects];
    
    [self.chatView reloadData];
//    NSLog(@"%@", self.messageArray);
    NSIndexPath *path = [NSIndexPath indexPathForRow:self.messageArray.count - 1 inSection:0];
    //自动滑动到最后一行
    [self.chatView scrollToRowAtIndexPath:path atScrollPosition:UITableViewScrollPositionBottom animated:YES];
    [self.chatView reloadData];
}
#pragma mark - 创建通知
- (void)getNotification
{
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillAppear:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillDisappear:) name:UIKeyboardWillHideNotification object:nil];
}
#pragma mark - 计算键盘高度
- (CGFloat)keyboardEnditingFrameHeight:(NSDictionary *)info
{
    CGRect keyboardEnditingUncorrectedFrame = [[info objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    CGRect keyboardEnditingFrame = [self.view convertRect:keyboardEnditingUncorrectedFrame fromView:nil];
    return keyboardEnditingFrame.size.height;
}
#pragma mark - 通知消息

- (void)keyboardWillAppear:(NSNotification *)notification
{
    CGRect currentFrame = self.view.frame;
    CGFloat change = [self keyboardEnditingFrameHeight:[notification userInfo]];
    currentFrame.origin.y = currentFrame.origin.y - change ;
    [UIView animateWithDuration:0.5 animations:^{
        self.view.frame = currentFrame;
    }];
}

- (void)keyboardWillDisappear:(NSNotification *)notification
{
    CGRect currentFrame = self.view.frame;
    CGFloat change = [self keyboardEnditingFrameHeight:[notification userInfo]];
    currentFrame.origin.y = currentFrame.origin.y + change ;
    [UIView animateWithDuration:0.5 animations:^{
        self.view.frame = currentFrame;
    }];
}
#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.chatField resignFirstResponder];
    return YES;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.messageArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"chatCell" forIndexPath:indexPath];
    if (cell) {
        XMPPMessageArchiving_Message_CoreDataObject *message = self.messageArray[indexPath.row];
        if (message.isOutgoing) {
            //发出的消息
            cell.textLabel.text = message.body;
            cell.textLabel.textColor = [UIColor greenColor];
            cell.textLabel.textAlignment = NSTextAlignmentRight;
        }else
        {
            //接收到的消息
//            cell.detailTextLabel.text = message.body;
//            cell.detailTextLabel.textAlignment = NSTextAlignmentRight;
            
            cell.textLabel.text = message.body;
            cell.textLabel.textAlignment = NSTextAlignmentLeft;
        }
    }
    return cell;
}

- (IBAction)sendMessage:(UIButton *)sender {
    //创建消息对象
    XMPPMessage *message = [XMPPMessage messageWithType:@"chat" to:self.friendJID];
    //设置消息内容
    NSLog(@"%@", self.chatField.text);
    if ([self.chatField.text isEqualToString:@""]) {
        
        return;
    }
    [message addBody:self.chatField.text];
    //发送消息
    [[XMPPManager shareInstance].xmppStream sendElement:message];
}

#pragma mark - XMPPStreamDelegate
#pragma mark --接收到消息
- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message
{
    NSLog(@"接收消息成功");
    [self searchMessage];
}
#pragma mark --消息发送失败
- (void)xmppStream:(XMPPStream *)sender didFailToSendMessage:(XMPPMessage *)message error:(NSError *)error
{
    NSLog(@"消息发送失败");
}
#pragma mark --消息发送成功
- (void)xmppStream:(XMPPStream *)sender didSendMessage:(XMPPMessage *)message
{
    [self searchMessage];
    NSLog(@"消息发送成功");
}

@end
