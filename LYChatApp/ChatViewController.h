//
//  ChatViewController.h
//  LYChatApp
//
//  Created by 吕阳 on 16/2/26.
//  Copyright © 2016年 DeveloperYoung. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMPPManager.h"

@interface ChatViewController : UIViewController
/* JID */
@property (nonatomic, strong)XMPPJID *friendJID;
@end
