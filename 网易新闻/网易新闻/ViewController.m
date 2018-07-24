//
//  ViewController.m
//  网易新闻
//
//  Created by define on 2018/7/24.
//  Copyright © 2018年 刘绍强. All rights reserved.
//

#import "ViewController.h"
#import "FirstNewsViewController.h"
#import "HotNewsViewController.h"
#import "VideoViewController.h"
#import "SocietyViewController.h"
#import "ReadViewController.h"
#import "ScienceViewController.h"

#define SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
static CGFloat const radious = 1.3;
static NSInteger const width = 100;

@interface ViewController ()<UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *upScrollView;

@property (weak, nonatomic) IBOutlet UIScrollView *downScrollView;

@property (nonatomic,strong)UILabel *selectedLabel;

//用来存label
@property (nonatomic,strong)NSMutableArray *labelArray;


@end

@implementation ViewController

/*
 网易新闻实现步骤:
 1、搭建结构(D导航控制器)
     *自定义导航控制器的跟控制器NewsController
     *搭建NewsController界面（上下滚动view）
     *
 
 */

//
- (NSMutableArray *)labelArray{
    
    if (_labelArray == nil) {
        _labelArray = [NSMutableArray array];
        
    }
    return _labelArray;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
//    创建子控制器
    [self setupAllChildVc];
    
//    创建标题
    [self setUpTitleLabel];
    
//    iOS7会给导航控制器下所有UIScrollView顶部添加额外滚动区域
    
//     初始化ScrollView的contentsize
    
    [self setupScrollView];
    
}

// 设置标题居中
- (void)setUpTitleCenter:(UILabel *)centerLabel{
//    计算偏移量
#pragma mark --十分重要
    CGFloat offsetX = centerLabel.center.x - SCREEN_WIDTH * 0.5;
    
    if (offsetX < 0) {
        offsetX = 0;
    }
    
    
//    获取最大滚动范围
    CGFloat maxOffset = self.upScrollView.contentSize.width - SCREEN_WIDTH;
    if (offsetX > maxOffset) {
        offsetX = maxOffset;
    }
    [self.upScrollView setContentOffset:CGPointMake(offsetX, 0) animated:YES];
    
    
    
}

- (void)setupScrollView{
    NSInteger count = self.childViewControllers.count;
    
//    设置标题滚动条
    self.upScrollView.contentSize = CGSizeMake(count * width, 0);
    self.upScrollView.showsHorizontalScrollIndicator = NO;
    
//    设置内容滚动条
    self.downScrollView.contentSize = CGSizeMake(count * SCREEN_WIDTH, 0);
    self.downScrollView.pagingEnabled = YES;
    self.downScrollView.bounces = NO;
    self.downScrollView.showsHorizontalScrollIndicator = NO;
//   设置代理
    self.downScrollView.delegate = self;
    
}
- (void)setUpTitleLabel{
    
    NSInteger count = self.childViewControllers.count;
    CGFloat labelY = 0;
    CGFloat labelHeight = 44;
    CGFloat labelWidth = width;
    
    for (int i = 0; i < count; i++) {
        UIViewController *vc = self.childViewControllers[i];
        UILabel *label = [[UILabel alloc]init];
        label.frame = CGRectMake( i*labelWidth, labelY, labelWidth, labelHeight);
        label.text = vc.title;

        label.tag = i;
        label.highlightedTextColor = [UIColor redColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.userInteractionEnabled = YES;
        UITapGestureRecognizer *tapGes = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(titleClick:)];
        //        默认选中第0个label
        //        设置文字高亮颜色
     
        [label addGestureRecognizer:tapGes];
        [self.labelArray addObject:label];

        if (i == 0) {
            
#pragma mark 这里可能是个bug
            //            label.highlighted = YES;
            //            _selectedLabel = label;
            [self titleClick:tapGes];
        }
        [self.upScrollView addSubview:label];
    }
    
    
}

- (void)titleClick:(UITapGestureRecognizer *)tap{
    
    NSLog(@"%s",__func__);
//    获取选中的label
     UILabel *selLabel = (UILabel *)tap.view;
//   1、标题颜色变成红色、放大
    [self selLabel:selLabel];
//   2、scrollview切换 滚动到对应位置
//       *2.1计算滚动的位置
    NSInteger index = selLabel.tag;
    CGFloat offsetX = index * SCREEN_WIDTH;
//       *2.2拿到scrollview
    [self.downScrollView setContentOffset:CGPointMake(offsetX, 0) animated:YES];
//   3、给对应位置添加view
    [self showVc:index];
//   4、让被点击的按钮居中
    [self setUpTitleCenter:selLabel];
}

//给对应位置添加view
- (void)showVc:(NSInteger)index{
    CGFloat offsetX = index * SCREEN_WIDTH;
    UIViewController *vc = self.childViewControllers[index];
//    添加过了就不需要再添加了 如果已经加载过了 就不需要加载了
#pragma mark ----很重要
    if (vc.isViewLoaded) {
        return;
    }
    vc.view.frame = CGRectMake(offsetX, 0, self.downScrollView.bounds.size.width, self.downScrollView.bounds.size.height);
    [self.downScrollView addSubview:vc.view];
}
     

     
- (void)selLabel:(UILabel *)label{
    /*
     互斥三部曲
     1、让上一个选中按钮取消选中状态
     2、让当前按钮成为选中状态
     3、把当前的按钮复制给上一个按钮
     */
    
    // 取消高亮
    _selectedLabel.highlighted = NO;
    // 取消形变
    _selectedLabel.transform = CGAffineTransformIdentity;
//    颜色恢复
    _selectedLabel.textColor = [UIColor blackColor];
    
    // 高亮
    label.highlighted = YES;
    // 高大
    label.transform = CGAffineTransformMakeScale(radious, radious);
    
    _selectedLabel = label;
    
//    _selectedLabel.highlighted = NO;
//    _selectedLabel.transform = CGAffineTransformIdentity;
////    _selectedLabel.transform = CGAffineTransformIdentity;
////    选中的label放大加上高亮
//    label.highlighted = YES;
//    label.transform = CGAffineTransformMakeScale(radious, radious);
//
//    _selectedLabel = label;
}



- (void)setupAllChildVc{
    
//    头条
    FirstNewsViewController *firstNews = [[FirstNewsViewController alloc]init];
    firstNews.title = @"头条";
    [self addChildViewController:firstNews];
//    热点
    HotNewsViewController *hotNews = [[HotNewsViewController alloc]init];
    hotNews.title = @"热点";
    [self addChildViewController:hotNews];
//    视频
    VideoViewController *videoNews = [[VideoViewController alloc]init];
    videoNews.title = @"视频";
    [self addChildViewController:videoNews];
//    社会
    SocietyViewController *societyNews = [[SocietyViewController alloc]init];
    societyNews.title = @"社会";
    [self addChildViewController:societyNews];
//    订阅
    ReadViewController *readNews = [[ReadViewController alloc]init];
    readNews.title = @"订阅";
    [self addChildViewController:readNews];
//    科学
    ScienceViewController *science = [[ScienceViewController alloc]init];
    science.title = @"科学";
    [self addChildViewController:science];
    
}

//监听scrollView的滚动完成
#pragma mark --scrollView
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
//    计算滚动到哪一页
    CGFloat offsetX = scrollView.contentOffset.x;
    NSInteger index = offsetX / SCREEN_WIDTH;
//   1、 获取对应子控制器 并 添加子控制器view
    [self showVc:index];
    
//    2、把对应的标题选中
    UILabel *selLabel = self.labelArray[index];
    [self selLabel:selLabel];
    
//    3、让选中的标题居中
    [self setUpTitleCenter:selLabel];
    
    
}
//监听scrollView滚动
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    
    CGFloat curPage = scrollView.contentOffset.x / SCREEN_WIDTH;
//    左边label的角标
    NSInteger leftIndex = curPage;
//    右边Label的角标
    NSInteger rightIndex = leftIndex + 1;
    
//    获取左边的label
    UILabel *leftLabel = self.labelArray[leftIndex];
//    获取右边的label
    UILabel *rightLabel;
    if (rightIndex < self.labelArray.count - 1) {
        rightLabel = self.labelArray[rightIndex];
    }
//    计算缩放比例
//    0~1
//    1~2
    CGFloat rightScale = curPage - leftIndex ;
//    左边缩小，右边增大
    CGFloat leftScale = 1 - rightScale;
    
//    缩放
    leftLabel.transform = CGAffineTransformMakeScale(leftScale * 0.3 + 1, leftScale *0.3 + 1);
    
    rightLabel.transform = CGAffineTransformMakeScale(rightScale * 0.3 + 1, rightScale* 0.3 + 1);
    
    /*
     设置文字渐变 (黑色是最纯洁的)
     R G B
     黑色 :0 0 0
     
     红色 :1 0 0
     */
    
//    左边由红色边为黑色
    leftLabel.textColor = [UIColor colorWithRed:leftScale green:0 blue:0 alpha:1];
//    右边由黑变红
    rightLabel.textColor = [UIColor colorWithRed:rightScale green:0 blue:0 alpha:1];
    
    
    
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
