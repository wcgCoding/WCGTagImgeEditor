//
//  WCGTagView.h
//  YXLImageLabelDemo
//
//  Created by Wcg on 2017/4/22.
//  Copyright © 2017年 吴朝刚. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WCGWaterFlowImageView;

typedef NS_ENUM(NSInteger, WCGTagType) {
    WCGTagTypePosition,
    WCGTagTypeLabel,
};

@interface WCGTagView : UIView

//**方向,是否正向 */
@property(nonatomic,assign) BOOL isPositive;//YES:文字在右

//**标签类型 (普通标签、地理位置) */
@property(nonatomic,assign) WCGTagType tagType;

//**标签名称*/
@property (nonatomic, copy) NSString *text;

/**第一次点击出现时，是否显示标签 */
@property(nonatomic,assign) BOOL shouldImageLabelShow;

/**imageLabel的宽度 */
@property(nonatomic,assign) CGFloat imageLabelW;
@property(nonatomic,assign) CGFloat imageLabelH;

- (void)cancelTimer;
@end
