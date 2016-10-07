//
//  ImagesPlayer.h
//  sliderDemo
//
//  Created by yuyun chen on 16/10/7.
//  Copyright © 2016年 yuyun chen. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ImagesPlayerDelegate, ImagesPlayerIndicatorPattern;

@interface ImagesPlayer : UIView

@property (assign, nonatomic) BOOL autoScroll;                                 //是否自动滚动 默认YES
@property (assign, nonatomic) NSTimeInterval scrollInterval;                   //滚动间隔时间 默认2秒

@property (assign, nonatomic) BOOL hidePageControl;                            //是否隐藏分页指示器 默认NO
@property (weak, nonatomic) id<ImagesPlayerDelegate> delegate;
@property (weak, nonatomic) id<ImagesPlayerIndicatorPattern> indicatorPattern;

@property (strong, nonatomic, readonly) NSArray *images;                       //当前展示的图片数组

/**
 *  添加本地图片数组
 */
- (void)addLocalImages:(NSArray *)images;
/**
 *  添加网络图片数组
 */
- (void)addNetWorkImages:(NSArray *)images placeholder:(UIImage *)placeholder;
/**
 *  点击事件回调
 */
- (void)imageTapAction:(void (^)(NSInteger index))block;
/**
 *  移除定时器
 */
- (void)removeTimer;
/**
 *  计算缓存图片总大小（MB）
 */
- (CGFloat)calculateCacheImagesMemory;
/**
 *  清除图片缓存
 */
- (void)removeCacheMemory;
@end

/**
 *  代理
 */
@protocol ImagesPlayerDelegate <NSObject>

@optional
/**
 *  图片点击回调
 */
- (void)imagesPlayer:(ImagesPlayer *)player didSelectImageAtIndex:(NSInteger)index;
@end

/**
 *  指示器样式
 */
@protocol ImagesPlayerIndicatorPattern <NSObject, UITableViewDelegate>

@required
/**
 *  设置分页指示器的样式
 */
- (UIView *)indicatorViewInImagesPlayer:(ImagesPlayer *)imagesPlayer;

@optional
/**
 *  图片交换完成时调用
 */
- (void)imagesPlayer:(ImagesPlayer *)imagesPlayer didChangedIndex:(NSInteger)index count:(NSInteger)count;
@end

@interface UIImageView (WebCache)

- (void)setImageWithURL:(NSString *)url placeholderImage:(UIImage *)placeholder;

@end
