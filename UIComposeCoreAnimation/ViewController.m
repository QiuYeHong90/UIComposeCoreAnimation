//
//  ViewController.m
//  UIComposeCoreAnimation
//
//  Created by mac on 16/5/27.
//  Copyright © 2016年 mac. All rights reserved.
//
#import "ComposeViewController.h"
#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    
    NSArray * itemArray = @[
  @{@"name":@"文字",@"picture":@"tabbar_compose_idea"},
  @{@"name":@"相册",@"picture":@"tabbar_compose_photo"},
  @{@"name":@"拍摄",@"picture":@"tabbar_compose_camera"},
  @{@"name":@"签到",@"picture":@"tabbar_compose_lbs"},
  @{@"name":@"点评",@"picture":@"tabbar_compose_review"},
  @{@"name":@"更多",@"picture":@"tabbar_compose_more"},
  @{@"name":@"好友圈",@"picture":@"tabbar_compose_friend"},
  @{@"name":@"秒拍",@"picture":@"tabbar_compose_shooting"},
  @{@"name":@"音乐",@"picture":@"tabbar_compose_music"},
  @{@"name":@"商品",@"picture":@"tabbar_compose_productrelease"},];
    
    NSMutableArray * mutArray = [[NSMutableArray alloc]init];
   [itemArray enumerateObjectsUsingBlock:^(NSDictionary*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
       ItemModel * item = [ItemModel itemWithName:obj[@"name"] ImageName:obj[@"picture"] handler:^(ItemModel *action) {
           NSLog(@"----%ld====%@",action.index,action.name);
       }];
       item.index= idx;
       [mutArray addObject:item];
   }];
    
    [ComposeViewController creatingComposeViewControllerWithController:self items:mutArray completion:^(int index) {
        NSLog(@"===%d",index);
    }];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
