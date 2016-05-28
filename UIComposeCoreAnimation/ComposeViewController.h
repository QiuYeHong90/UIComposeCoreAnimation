//
//  ComposeViewController.h
//  UIComposeCoreAnimation
//
//  Created by mac on 16/5/27.
//  Copyright © 2016年 mac. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ItemModel : NSObject
+ (instancetype)itemWithName:(NSString *)name ImageName:(NSString*)imageName handler:(void (^)(ItemModel *action))handler;
@property (nonatomic,copy) NSString *name;
@property (nonatomic,copy) NSString *imageName;
@property (nonatomic, getter=isEnabled) BOOL enabled;
@property (nonatomic) NSInteger index;
@end
//UIAlertController

@interface ComposeViewController : UIViewController
@property (nonatomic,copy) void (^completion)(int);
@property (nonatomic,strong)NSArray  <ItemModel*>* items;
@property (nonatomic,strong)ItemModel *item;
@property (nonatomic,strong)UIView * blurView ;
//接口 进入的接口

+(void)creatingComposeViewControllerWithController:(UIViewController*)viewController items:(NSArray <ItemModel*>*)items completion:(void(^)(int index)) completion;


@end


