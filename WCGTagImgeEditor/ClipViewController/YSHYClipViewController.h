//
//  YSHYClipViewController.h
//  裁剪图片
//
//  Created by wcg on 16/6/6.
//  Copyright © 2016年 wuchaogang. All rights reserved.
//

#import <UIKit/UIKit.h>
@class YSHYClipViewController;

//代理方法
@protocol ClipViewControllerDelegate <NSObject>

-(void)ClipViewController:(YSHYClipViewController *)clipViewController FinishClipImage:(UIImage *)editImage;

@end


@interface YSHYClipViewController : UIViewController<UIGestureRecognizerDelegate>

@property (nonatomic, assign)CGFloat scaleRation;//图片缩放的最大倍数

@property (nonatomic, weak)id<ClipViewControllerDelegate>delegate;

-(instancetype)initWithImage:(UIImage *)image;

/**图片 */
@property(nonatomic,assign) BOOL isImageSource;

@end
