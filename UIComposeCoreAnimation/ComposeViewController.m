//
//  ComposeViewController.m
//  UIComposeCoreAnimation
//
//  Created by mac on 16/5/27.
//  Copyright © 2016年 mac. All rights reserved.
//

#define BTNTAG 100

#import "ComposeViewController.h"

@interface ItemModel ()
@property (nonatomic,copy) void (^handler)(ItemModel *action);
@end
//模型类
@implementation ItemModel
+ (instancetype)itemWithName:(nullable NSString *)name ImageName:(NSString*)imageName handler:(void (^ __nullable)(ItemModel *action))handler
{
    ItemModel * item = [[self alloc]init];
    item.name = name;
    item.imageName = imageName;
    item.handler = handler;
    return item;
}


@end
//自定义button
@interface ZYButton : UIButton
@property (nonatomic) CGPoint startPoint;
@property (nonatomic) CGPoint endPoint;
@property (nonatomic) CGPoint farPoint;
@property (nonatomic,strong) ItemModel * item;
@end
@implementation ZYButton



@end
@interface ComposeViewController ()
{
    NSMutableArray <ZYButton*>*_mutButtonArray;//放button
    BOOL _isDown;//button的位置装填
    BOOL _isStop;//动画的结束状态
    NSInteger _currentIndex;
    
    int _count;//用来计数 计算延迟时间的
    
    BOOL _isBig;//是否放大
    
    BOOL _isScrollToSecond;//是否横向滑动
    UIImageView *_addImageView;//底部的加号
    UIButton * _returnBtn;//第二个界面的返回按钮
    
}

@end

@implementation ComposeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createButton];
    [self addSwipeGestureToBlurView];
    [self addTapGestureToBlurView];
    [self addBottomView];
}
-(void)addBottomView
{
    UIView *bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.frame)-57, CGRectGetWidth(self.view.frame), 57)];
    bottomView.backgroundColor = [UIColor whiteColor];
    [self.blurView addSubview:bottomView];
    _addImageView= [[ UIImageView alloc]initWithImage:[UIImage imageNamed:@"tabbar_compose_background_icon_add"]];
    _addImageView.center = bottomView.center;
    [self.blurView addSubview:_addImageView];
     _returnBtn = [[UIButton alloc]init];
    _returnBtn.bounds = CGRectMake(0, 0,CGRectGetWidth(self.view.frame), 52);
    _returnBtn.center = CGPointMake(CGRectGetWidth(self.view.frame)/4, bottomView.center.y);
    [_returnBtn setImage:[UIImage imageNamed:@"tabbar_compose_background_icon_return"] forState:UIControlStateNormal];
    _returnBtn.hidden = YES;
    [_returnBtn addTarget:self action:@selector(returnButtonClick) forControlEvents:UIControlEventTouchUpInside];
    [self.blurView addSubview:_returnBtn];
}
-(void)returnButtonClick
{
   
        
            _returnBtn.hidden = YES;
            _isScrollToSecond =NO;
            [self addImageViewTranslate];
            [_mutButtonArray enumerateObjectsUsingBlock:^(ZYButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [self enTranslateWithButton:obj];
            }];
    
  

}
-(void)addTapGestureToBlurView
{
    UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapGesture:)];
    [self.blurView addGestureRecognizer:tap];
}
-(void)tapGesture:(UITapGestureRecognizer*)tap
{
    if (_isStop == YES&&_currentIndex!=5) {
        [self callAnimation];
    }
    
}
-(void)addSwipeGestureToBlurView
{
    UISwipeGestureRecognizer * swipe = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(swipeGesture:)];
    [self.blurView addGestureRecognizer:swipe];
}
-(void)swipeGesture:(UISwipeGestureRecognizer*)swipe
{
    
    if (_isScrollToSecond==YES) {
        
        if (swipe.direction ==UISwipeGestureRecognizerDirectionRight) {
            NSLog(@"是第二个界面,只能向左滑动");
             _returnBtn.hidden = YES;
            _isScrollToSecond =NO;
            [self addImageViewTranslate];
            [_mutButtonArray enumerateObjectsUsingBlock:^(ZYButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [self enTranslateWithButton:obj];
            }];

        }
    }else{
        NSLog(@"在第一个界面不能滑动");
    }
}

-(void)createButton
{
    _currentIndex = 200;
    _mutButtonArray = [[NSMutableArray alloc]init];
    float btnW = CGRectGetWidth([UIScreen mainScreen].bounds)/3;
    float btnH = btnW;
    __block CGFloat ButnX = 0;
//    NSLog(@"===%@",self.items);
    if (self.items) {
        [self.items enumerateObjectsUsingBlock:^(ItemModel * _Nonnull obj, NSUInteger i, BOOL * _Nonnull stop) {
            ButnX =  CGRectGetWidth([UIScreen mainScreen].bounds)*(i/6);
            ZYButton *btn = [[ZYButton alloc]init];
            btn.frame = CGRectMake(btnW*(i%3)+ButnX, CGRectGetHeight([UIScreen mainScreen].bounds)+btnH*(i/3)-btnH*2*(i/6), btnW, btnH);
            btn.startPoint = btn.center;
            btn.endPoint = CGPointMake(btn.startPoint.x, btn.startPoint.y-CGRectGetHeight([UIScreen mainScreen].bounds)/2);
            btn.farPoint =CGPointMake(btn.startPoint.x, btn.endPoint.y-50);
            btn.tag = i+BTNTAG;
            [btn addTarget:self  action:@selector(buttonClick:) forControlEvents:UIControlEventTouchUpInside];
            [self.blurView addSubview:btn];
            [btn setImage:[UIImage imageNamed:obj.imageName] forState:UIControlStateNormal];
            [btn setTitle:obj.name forState:UIControlStateNormal];
            btn.item= obj;
//            btn.backgroundColor = [UIColor colorWithRed:arc4random()%255/255.0 green:arc4random()%255/255.0  blue:arc4random()%255/255.0  alpha:1];
            btn.imageEdgeInsets = UIEdgeInsetsMake(0,30, 10, 0);
            btn.titleEdgeInsets = UIEdgeInsetsMake(80,-80,-10,0);
            [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [_mutButtonArray addObject:btn];
        }];
    }
}

-(void)viewDidAppear:(BOOL)animated
{
    
    [super viewDidAppear:animated];
    [self callAnimation];
    
}
#pragma mark -- coreAnimation动画的上下移动
-(void)upCoreAnimationWithButton:(ZYButton*)btn
{
    
    CAKeyframeAnimation *positionAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    positionAnimation.fillMode = kCAFillModeForwards;
    positionAnimation.removedOnCompletion = NO;
    positionAnimation.duration = 0.2f;
    //延迟的秒数
    positionAnimation.beginTime = CACurrentMediaTime() + (_count++)*0.05;
    CGMutablePathRef path= CGPathCreateMutable();
    if (_isDown==YES) {
        CGPathMoveToPoint(path, NULL, btn.startPoint.x,  btn.startPoint.y);
        CGPathAddLineToPoint(path, NULL, btn.farPoint.x, btn.farPoint.y);
        CGPathAddLineToPoint(path, NULL, btn.endPoint.x,  btn.endPoint.y);
        
    }else{
        
        CGPathMoveToPoint(path, NULL, btn.endPoint.x,  btn.endPoint.y);
        CGPathAddLineToPoint(path, NULL, btn.startPoint.x,  btn.startPoint.y);

    }
    positionAnimation.delegate = self;
    positionAnimation.path = path;
    CGPathRelease(path);
    [btn.layer addAnimation:positionAnimation forKey:@"positionAnimation"];

}
//TODO:底部加号的旋转
-(void)addImageViewRotateAnimation
{
    
    CABasicAnimation * rotateAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    rotateAnimation.duration = 0.3;
    if (_isDown==1) {
        rotateAnimation.fromValue =[NSValue valueWithCATransform3D:CATransform3DMakeRotation(0, 0, 0, 1)];
        rotateAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(M_PI_4, 0, 0, 1)];
    }else{
        rotateAnimation.fromValue =[NSValue valueWithCATransform3D:CATransform3DMakeRotation(M_PI_4, 0, 0, 1)];
        rotateAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(0, 0, 0, 1)];
    }
    rotateAnimation.fillMode = kCAFillModeForwards;
    rotateAnimation.removedOnCompletion = NO;
    [_addImageView.layer addAnimation:rotateAnimation forKey:@"rotateAnimation"];
}
//TODO:底部加号的平移
-(void)addImageViewTranslate
{
    CAKeyframeAnimation *translate = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    
    translate.duration = 0.2f;
    translate.fillMode = kCAFillModeForwards;
    translate.removedOnCompletion = NO;
    CGMutablePathRef  path= CGPathCreateMutable();
    if (_isScrollToSecond== YES) {
        CGPathMoveToPoint(path, NULL,_addImageView.center.x, _addImageView.center.y);
        CGPathAddLineToPoint(path, NULL,_addImageView.center.x+(CGRectGetWidth(self.view.frame)/4), _addImageView.center.y);
    }else{
        
       CGPathMoveToPoint(path, NULL,_addImageView.center.x, _addImageView.center.y);
        CGPathAddLineToPoint(path, NULL,self.view.center.x, _addImageView.center.y);
    }
    translate.path = path;
    CGPathRelease(path);
//    
    [_addImageView.layer addAnimation:translate forKey:@"translate123"];
      _addImageView.center = CGPointMake( self.view.center.x+(_isScrollToSecond)*(CGRectGetWidth(self.view.frame)/4), _addImageView.center.y);
    
}
#pragma mark ==动画的放大和缩小
-(void)enScaleAnimationWithButton:(ZYButton*)button
{
    CABasicAnimation *basicAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    basicAnimation.toValue =  (button.tag == _currentIndex+BTNTAG) ? [NSValue valueWithCATransform3D:CATransform3DMakeScale(3, 3, 1)]:[NSValue valueWithCATransform3D:CATransform3DMakeScale(0, 0, 1)] ;
    CABasicAnimation * opacity = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacity.toValue = @(0);
    CAAnimationGroup * group = [CAAnimationGroup animation];
    group.removedOnCompletion = NO;
    group.fillMode = kCAFillModeForwards;
    group.animations =@[basicAnimation,opacity];
    group.duration = 0.3;
    group.delegate = self;
    [button.layer addAnimation:group forKey:@"group"];
}

#pragma  mark -- 平移
-(void)enTranslateWithButton:(ZYButton*)button
{
    CAKeyframeAnimation *positionHorizon = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    positionHorizon.fillMode = kCAFillModeForwards;
    positionHorizon.removedOnCompletion = NO;
    positionHorizon.duration = 0.2f;
    CGMutablePathRef path= CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, button.endPoint.x,  button                                                                                             .endPoint.y);
    CGPathAddLineToPoint(path, NULL, button.endPoint.x+(1-2*_isScrollToSecond)*CGRectGetWidth(self.view.frame),  button.endPoint.y);
    
    positionHorizon.path = path;
    CGPathRelease(path);
       [button.layer addAnimation:positionHorizon forKey:@"positionHorizon"];
     CGPoint point  = button.center;
    point.x = point.x+(1-2*_isScrollToSecond)*CGRectGetWidth(self.view.frame);
    button.center = point;
    button.endPoint = button.center;
    
    button.startPoint = CGPointMake( button.startPoint.x+(1-2*_isScrollToSecond)*CGRectGetWidth(self.view.frame), button.startPoint.y);
    _currentIndex= 200;//把_currentIndex恢复初始值
}


#pragma mark ===动画的代理
- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    
    
    ZYButton * btn;
    if (_isBig ==YES) {
         //放大的代理++++++++++
        
        btn = _mutButtonArray[_currentIndex];//被点击的那个button
        CAAnimation * animation = [btn.layer animationForKey:@"group"];
        if (animation == anim) {
            _isBig =NO;
            _isStop = YES;
            [self dismissViewControllerAnimated:NO completion:^{
                
                if (_currentIndex!=200) {
                    self.completion((int)_currentIndex);
                }
                
            }];
        }
        
    }else{
        //位移动画代理++++++++++++
        if (_isDown == NO) {
            btn =_mutButtonArray[0];
            CAAnimation * btnAnimation = [btn.layer animationForKey:@"positionAnimation"];
            if (btnAnimation == anim) {
                [self dismissViewControllerAnimated:NO completion:^{
                    _isStop = YES;
                    if (_currentIndex!=200) {
                        self.completion((int)_currentIndex);
                    }
                    
                }];
            }
        }else{
            if (_currentIndex != 5) {
                btn = _mutButtonArray[_mutButtonArray.count-1];
                CAAnimation * btnAnimation = [btn.layer animationForKey:@"positionAnimation"];
                if (btnAnimation == anim) {
                    _isStop = YES;
                    [_mutButtonArray enumerateObjectsUsingBlock:^(ZYButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                        obj.center = obj.endPoint;
                    }];
                }

            }
            
        }

    }
    
   
}


#pragma mark -- 调用动画
-(void)callAnimation
{
    _isDown =!_isDown;
    NSLog(@"_isDown---%d",_isDown);
    [self addImageViewRotateAnimation];
    _isStop = NO;
    _count = 0;
    NSEnumerationOptions Options = _isDown == YES ? NSEnumerationConcurrent:NSEnumerationReverse;
    [_mutButtonArray enumerateObjectsWithOptions:(Options) usingBlock:^(ZYButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        if (_currentIndex !=200) {
            [self enScaleAnimationWithButton:obj];
        }else{
            [self upCoreAnimationWithButton:obj];
        }
    }];
}
-(void)buttonClick:(ZYButton*)button
{
    //这是把方法传出去
    _currentIndex = button.tag - BTNTAG;
    if (_isDown == YES&&_isStop == YES&&_isBig ==NO&&button.tag!=(5+BTNTAG)) {
        _isBig = YES;
        //变大
         [self callAnimation];
        button.item.handler(button.item);
    }else{
        //5是更多 并不退出 要做平动画
        if (_mutButtonArray.count>6) {
            //翻页 平移
            _returnBtn.hidden = NO;
            _isScrollToSecond =YES;
            [self addImageViewTranslate];
            [_mutButtonArray enumerateObjectsUsingBlock:^(ZYButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [self enTranslateWithButton:obj];
            }];
        }else{
            //只有六个不能翻页了
        }
    }
   
    
    
}

+(void)creatingComposeViewControllerWithController:(UIViewController*)viewController items:(NSArray*)items completion:(void(^)(int index)) completion
{
    ComposeViewController * composeViewController = [[self alloc]init];
    double version = [[UIDevice currentDevice].systemVersion doubleValue];
    
    
    //版本的检测与对应的开发 并添加毛玻璃效果
    if (version>=8.0f) {
        composeViewController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
        composeViewController.blurView = [[UIVisualEffectView alloc]initWithEffect:blurEffect];
        composeViewController.blurView.frame = [UIScreen mainScreen].bounds;
        
    }else{
         composeViewController.modalPresentationStyle = UIModalPresentationCurrentContext;
        if (version>=7.0f){
            composeViewController.blurView = [[UIToolbar alloc]initWithFrame:[UIScreen mainScreen].bounds];
            ((UIToolbar*)composeViewController.blurView).barStyle = UIBarStyleDefault;
            
        }else{
            composeViewController.blurView =[[UIView alloc]initWithFrame:[UIScreen mainScreen].bounds];
            composeViewController.blurView.backgroundColor = [UIColor colorWithRed:1 green:1 blue:1 alpha:0.9f];
        }

    }
    //把所需要的项目传过来
    composeViewController.items = items;
    //完成调用block
    composeViewController.completion = completion;
    [composeViewController.view addSubview:composeViewController.blurView];
    [viewController presentViewController:composeViewController animated:NO completion:^{
        
    }];
    
  
   
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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



