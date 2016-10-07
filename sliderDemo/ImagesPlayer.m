//
//  ImagesPlayer.m
//  sliderDemo
//
//  Created by yuyun chen on 16/10/7.
//  Copyright © 2016年 yuyun chen. All rights reserved.
//

#import "ImagesPlayer.h"
//#include <ifaddrs.h>
//#include <arpa/inet.h>
//#include <net/if.h>
#import "NSString+stringEncrypt.h"

#define imageCount self.imageArray.count
#define W self.frame.size.width
#define H self.frame.size.height

@interface ImagesPlayer () <UICollectionViewDelegate, UICollectionViewDataSource>

@property (weak, nonatomic) UICollectionView *collectionView;
@property (weak, nonatomic) UICollectionViewFlowLayout *flowLayout;
@property (strong, nonatomic) NSTimer *timer;

@property (weak, nonatomic) UIPageControl *pageControl;       //分页指示器
@property (strong, nonatomic) NSMutableArray *imageArray;     //数据源
@property (assign, nonatomic) CGFloat previousOffsetX;        //图片滚动前偏移量
@property (strong, nonatomic) UIImage *placeHolder;
@property (copy, nonatomic) void (^ block)(NSInteger);

@end


@implementation ImagesPlayer

#pragma mark - Setter/Getter

- (UIPageControl *)pageControl
{
    if (!_pageControl) {
        UIPageControl *pageControl                = [[UIPageControl alloc] init];
        pageControl.currentPageIndicatorTintColor = [UIColor whiteColor];
        pageControl.pageIndicatorTintColor        = [UIColor grayColor];
        [self addSubview:pageControl];
        _pageControl = pageControl;
    }
    return _pageControl;
}

- (NSMutableArray *)imageArray
{
    if (!_imageArray) {
        _imageArray = [NSMutableArray array];
    }
    return _imageArray;
}

- (void)setAutoScroll:(BOOL)autoScroll
{
    _autoScroll = autoScroll;
    if (_autoScroll == NO) {
        [self removeTimer];
    }
}

- (void)setHidePageControl:(BOOL)hidePageControl
{
    _hidePageControl        = hidePageControl;
    self.pageControl.hidden = hidePageControl;
}

- (void)setScrollInterval:(NSTimeInterval)scrollInterval
{
    if (_scrollInterval != scrollInterval) {
        _scrollInterval = scrollInterval;
        [self removeTimer];
        [self addTimer];
    }
}

- (void)setIndicatorPattern:(id<ImagesPlayerIndicatorPattern>)indicatorPattern
{
    _indicatorPattern = indicatorPattern;
    if (indicatorPattern) {
        [self.pageControl removeFromSuperview];
        [self layoutIfNeeded];
        [self addSubview:[self.indicatorPattern indicatorViewInImagesPlayer:self]];
    }
}

#pragma mark - Initail

- (instancetype)init
{
    if (self = [super init]) {
        [self addSubViews];
    }
    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self addSubViews];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.flowLayout.itemSize  = self.frame.size;
    self.collectionView.frame = self.bounds;
    self.pageControl.frame    = CGRectMake(W * 0.5f, H - 15.f, 0.f, 0.f);
}

#pragma mark - Private

- (void)addSubViews
{
    //初始值
    self.autoScroll      = YES;
    self.hidePageControl = NO;
    self.scrollInterval  = 2;
    
    //subViews
    [self addCollectionView];
    [self bringSubviewToFront:self.pageControl];
}

static NSString * const reuseIdentifier = @"ImagesPlayerCell";

- (void)addCollectionView
{
    UICollectionViewFlowLayout *flowLayout        = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.minimumLineSpacing                 = 0.f;
    flowLayout.scrollDirection                    = UICollectionViewScrollDirectionHorizontal;
    self.flowLayout                               = flowLayout;
    UICollectionView *collectionView              = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    collectionView.delegate                       = self;
    collectionView.dataSource                     = self;
    collectionView.pagingEnabled                  = YES;
    collectionView.showsHorizontalScrollIndicator = NO;
    collectionView.backgroundColor                = [UIColor clearColor];
    self.collectionView                           = collectionView;
    [self addSubview:collectionView];
    [collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
}

//添加定时器
- (void)addTimer
{
    if (!self.autoScroll) {
        return;
    }
    
    NSUInteger scrollInterval = self.scrollInterval ? self.scrollInterval : 2;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:scrollInterval target:self selector:@selector(nextImage) userInfo:nil repeats:YES];
}

- (void)nextImage
{
    if ((NSInteger)self.collectionView.contentOffset.x % (NSInteger)W == 0) {
        CGFloat offsetX = self.collectionView.contentOffset.x + W;
        [self.collectionView setContentOffset:CGPointMake(offsetX, 0.f) animated:YES];
    }else {
        NSInteger count = round(self.collectionView.contentOffset.x / W);
        [self.collectionView setContentOffset:CGPointMake(count * W, 0.f) animated:NO];
    }
}

#pragma mark - Public

- (void)addLocalImages:(NSArray *)images
{
    [self.imageArray removeAllObjects];
    [self.imageArray addObjectsFromArray:images];
    _images = [NSArray arrayWithArray:self.imageArray];
    
    //刷新pageControl
    self.pageControl.numberOfPages = images.count;
    [self.pageControl updateCurrentPageDisplay];
    
    //在Updates里执行完更新操作后再执行completion回调
    [self.collectionView performBatchUpdates:^{
        [self.collectionView reloadData];
    } completion:^(BOOL finished) {
        //刷新完成让collectionView滚动到中间位置
        NSInteger center = ceilf([self.collectionView numberOfItemsInSection:0] * 0.5f);
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:center inSection:0];
        [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
        self.previousOffsetX = self.collectionView.contentOffset.x;

        [self removeTimer];
        [self addTimer];
    }];
}

- (void)addNetWorkImages:(NSArray *)images placeholder:(UIImage *)placeholder
{
    [self addLocalImages:images];
    self.placeHolder = placeholder;
}

- (void)imageTapAction:(void (^)(NSInteger))block
{
    self.block = block;
}

- (void)removeTimer
{
    [self.timer invalidate];
    self.timer = nil;
}

- (CGFloat)calculateCacheImagesMemory
{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *fileDir = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"imagesCache"];
    NSDictionary *fileAttr = [manager attributesOfItemAtPath:fileDir error:nil];
    NSUInteger filesSize = [fileAttr fileSize];
    return filesSize / (1000 * 1000);
}

- (void)removeCacheMemory
{
    NSFileManager *manager = [NSFileManager defaultManager];
    NSString *fileDir = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"imagesCache"];
    for (NSString *subPath in [manager subpathsOfDirectoryAtPath:fileDir error:nil]) {
        [manager removeItemAtPath:subPath error:nil];
    }
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return imageCount;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell       = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    UIImageView *imageView           = [[UIImageView alloc] init];
    imageView.userInteractionEnabled = YES;
    NSString *imageName              = self.imageArray[indexPath.item % imageCount];
    UIImage *image                   = [UIImage imageNamed:imageName];
    if (image) {//本地图片
        imageView.image              = image;
    }else {//网络图片
        [imageView setImageWithURL:imageName placeholderImage:self.placeHolder];
    }
    cell.backgroundView              = imageView;
    return cell;
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger number = [collectionView numberOfItemsInSection:0];
    
    if (number == indexPath.item + 1) {
        NSInteger adjust = self.previousOffsetX - collectionView.contentOffset.x;
        if (adjust < 0) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
            [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
        }
    } else if (0 == indexPath.item) {
        NSInteger adjust = self.previousOffsetX - collectionView.contentOffset.x;
        if (adjust > 0) {
            NSIndexPath *indexPath = [NSIndexPath indexPathForRow:number -1 inSection:0];
            [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
        }
    }
    
    self.previousOffsetX         = collectionView.contentOffset.x;
    self.pageControl.currentPage = indexPath.item % imageCount;
    
    if ([self.indicatorPattern respondsToSelector:@selector(imagesPlayer:didChangedIndex:count:)]) {
        [self.indicatorPattern imagesPlayer:self didChangedIndex:indexPath.item % imageCount + 1 count:imageCount];
    }
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.block) {
        self.block(indexPath.item % imageCount);
    }
    if ([self.delegate respondsToSelector:@selector(imagesPlayer:didSelectImageAtIndex:)]) {
        [self.delegate imagesPlayer:self didSelectImageAtIndex:(indexPath.item % imageCount)];
    }
    
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self removeTimer];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self addTimer];
}

@end

@implementation UIImageView (WebCache)

- (void)setImageWithURL:(NSString *)url placeholderImage:(UIImage *)placeholder
{
    NSString *fileDir  = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:@"imagesCache"];
    NSFileManager *fm  = [NSFileManager defaultManager];
    [fm createDirectoryAtPath:fileDir withIntermediateDirectories:YES attributes:nil error:nil];
    NSString *fileName = [fileDir stringByAppendingPathComponent:[url md5]];//MD5加密图片名全路径
    UIImage *image     = [UIImage imageWithContentsOfFile:fileName];
    if (image) {
        self.image = image;
    }else {
        self.image = placeholder;
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSURL *path = [NSURL URLWithString:url];
            NSData *data = [NSData dataWithContentsOfURL:path];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.image = [UIImage imageWithData:data];
            });
            [data writeToFile:fileName atomically:YES];
        });
    }
}
@end
