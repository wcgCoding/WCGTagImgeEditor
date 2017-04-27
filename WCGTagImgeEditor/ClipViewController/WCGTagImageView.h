//
//  WCGTagImageView.h
//  YXLImageLabelDemo
//
//  Created by Wcg on 2017/4/22.
//  Copyright © 2017年 吴朝刚. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WCGTagView.h"
#import "WCGWaterFlowImageView.h"
@class WCGTagImageView;

typedef NS_ENUM(NSInteger, WCGTagImgViewType) {
    WCGTagImgViewTypeEditor,//编辑类型
    WCGTagImgViewTypeShow,//展示类型
};

//查看的时候
@protocol WCGTagImgViewDataSource <NSObject>

- (NSInteger)numOfLabelImgView:(WCGTagImageView *)tagImageView;

- (WCGTagView *)tagViewForIndex:(NSInteger)index ImgView:(WCGTagImageView *)tagImageView;

@end

//编辑的时候
@protocol WCGTagImgViewDelegate <NSObject>

- (void)didEditTagView:(WCGTagView *)tagView imgView:(WCGTagImageView *)tagImageView;//跳转到编辑

- (void)didDeleteTagView:(WCGTagView *)tagView imgView:(WCGTagImageView *)tagImageView;//做了删除动作

- (void)didTapImgView:(WCGTagImageView *)tagImageView tmpTagView:(WCGTagView *)tagView;//跳转到添加

@end



@interface WCGTagImageView : UIView

/**
 *  初始化并添加一张图片（本地照片）
 *
 *  @param image 作为点选标签的底图
 */
- (id)initWithImage:(UIImage *)image type:(WCGTagImgViewType)type;

/**
 *  初始化并添加一张网络图
 *
 *  @param image 作为点选标签的底图
 */
- (id)initWithNetImageName:(NSString *)imageName type:(WCGTagImgViewType)type;

/**
 *  获取图片中所有的TagModels
 */
- (NSMutableArray *)tagModels;

/**
 *  添加已有的标签
 *
 *  @param text  标签文本
 *  @param point
 *  标签的位置  位置都是以点的起始位置  正向标签X取最小值  反向则取最大值 Y值为标签的Y值
 *  如果是取本demo里面值则不需要修改直接传入,如果是自定义的需要参考一下上面标签位置的逻辑！否则会有点偏移
 *  @param isPositive 标签这个样式是正还是反
 */
- (void)addTagViewText:(NSString *)text Location:(CGPoint )point isPositive:(BOOL)isPositive tagType:(WCGTagType)tagType;

/*
 * 合成图生成
 */
- (UIImage *)compoundImage;

/*
 * 设置图层
 */
- (void)setImage:(UIImage *)image;

/*
 *  类型 编辑与查看
 */
@property(nonatomic,assign) WCGTagImgViewType imgViewType;

/*
 *  标签组的展示与隐藏
 */
@property(nonatomic,assign) BOOL isHiddenTagViews;

- (void)clickimagePreviewsAtPoint:(CGPoint)point;
- (void)cancelTimers;


///////////////////////
///**代理的相关 待完善*///
///////////////////////

/**根据数据源代理刷新 */
- (void)reloadData;

//**数据源*/
@property (nonatomic, weak) id<WCGTagImgViewDataSource> dataSource;

//**代理 */
@property (nonatomic, weak) id<WCGTagImgViewDelegate> delegate;

@end
