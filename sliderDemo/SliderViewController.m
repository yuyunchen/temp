//
//  SliderViewController.m
//  sliderDemo
//
//  Created by yuyun chen on 16/10/7.
//  Copyright © 2016年 yuyun chen. All rights reserved.
//

#import "SliderViewController.h"
#import "ImagesPlayer.h"

@interface SliderViewController () <ImagesPlayerIndicatorPattern, ImagesPlayerDelegate>
@property (weak, nonatomic) IBOutlet ImagesPlayer *localImagesView;
@property (weak, nonatomic) IBOutlet ImagesPlayer *networkImagesView;
@property (weak, nonatomic) UILabel *indicatorLabel;
@end

@implementation SliderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSMutableArray *images = [NSMutableArray array];
    
    for (NSInteger index = 1; index < 6; index++) {
        NSString *imageName = [NSString stringWithFormat:@"%zd_launch", index];
        [images addObject:imageName];
    }
    [self.localImagesView addLocalImages:images];
    self.localImagesView.autoScroll = YES;
    
    NSArray *netImages = @[@"http://www.ld12.com/upimg358/allimg/c151129/144WW1420B60-401445_lit.jpg",
                           @"http://img4.duitang.com/uploads/item/201508/11/20150811220329_XyZAv.png",
                           @"http://tx.haiqq.com/uploads/allimg/150326/160R95612-10.jpg",
                           @"http://img5q.duitang.com/uploads/item/201507/22/20150722145119_hJnyP.jpeg",
                           @"http://imgsrc.baidu.com/forum/w=580/sign=dc0e6c8c8101a18bf0eb1247ae2e0761/1cb3c90735fae6cd2c5341c109b30f2440a70fc7.jpg",];
    [self.networkImagesView addNetWorkImages:netImages placeholder:[UIImage imageNamed:@"1_launch"]];
    self.networkImagesView.delegate         = self;
    self.networkImagesView.indicatorPattern = self;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [self.networkImagesView removeTimer];
}

#pragma mark = ImagesPlayerIndicatorPattern

- (UIView *)indicatorViewInImagesPlayer:(ImagesPlayer *)imagesPlayer
{
    CGFloat margin          = 5.f;
    UIView *indicatorView   = [[UIView alloc] init];
    CGFloat w               = 50.f;
    CGFloat h               = 20.f;
    CGFloat x               = CGRectGetWidth(imagesPlayer.frame) - w - margin;
    CGFloat y               = CGRectGetHeight(imagesPlayer.frame) - h - margin;
    indicatorView.frame              = CGRectMake(x, y, w, h);
    indicatorView.backgroundColor    = [UIColor blackColor];
    indicatorView.alpha              = 0.5f;
    indicatorView.clipsToBounds      = YES;
    indicatorView.layer.cornerRadius = 5.f;
    UILabel *lable          = [[UILabel alloc] initWithFrame:indicatorView.bounds];
    lable.textAlignment     = NSTextAlignmentCenter;
    lable.textColor         = [UIColor whiteColor];
    self.indicatorLabel     = lable;
    [indicatorView addSubview:lable];
    return indicatorView;
}

- (void)imagesPlayer:(ImagesPlayer *)imagesPlayer didChangedIndex:(NSInteger)index count:(NSInteger)count
{
    self.indicatorLabel.text = [NSString stringWithFormat:@"%ld/%ld", index, count];
}

#pragma mark - ImagesPlayerDelegae

- (void)imagesPlayer:(ImagesPlayer *)player didSelectImageAtIndex:(NSInteger)index
{
    NSLog(@"点击了：%ld", index);
}

@end
