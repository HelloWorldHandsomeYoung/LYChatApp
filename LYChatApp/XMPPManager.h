//
//  XMPPManager.h
//  LYChatApp
//
//  Created by 吕阳 on 16/2/25.
//  Copyright © 2016年 DeveloperYoung. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPPFramework.h"

@interface XMPPManager : NSObject
/* 通信管道 */
@property (nonatomic, strong)XMPPStream *xmppStream;
/* 好友花名册 */
@property (nonatomic, strong)XMPPRoster *xmppRoster;
/* 花名册数据管理助手 */
@property (nonatomic, strong)XMPPRosterCoreDataStorage  *coreDataStorage;

/* 聊天消息类 */
@property (nonatomic, strong)XMPPMessageArchiving *messageArchiving;
/* 被管理对象上下文 */
@property (nonatomic, strong)NSManagedObjectContext *context;
/**
 *单例
 **/

+ (instancetype)shareInstance;

/**
 *@param 用户名
 *@param 密码
 **/
- (void)registerWithUserName:(NSString *)name
                    passWord:(NSString *)password;

/**
 *@param 用户名
 *@param 密码
 **/
- (void)loginWithUserName:(NSString *)name
                 passWord:(NSString *)password;
@end
