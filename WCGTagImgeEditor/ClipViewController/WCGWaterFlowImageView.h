//
//  WCGWaterFlowImageView.h
//  YXLImageLabelDemo
//
//  Created by Wcg on 2017/4/22.
//  Copyright © 2017年 吴朝刚. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Masonry.h"
#define WCGTagFont [UIFont boldSystemFontOfSize:12.0f]
@class WCGWaterFlowImageView;

@protocol WCGWaterFlowImageViewDelegate <NSObject>

- (void)textDidChangeWaterFlowImageView:(WCGWaterFlowImageView *)wfImgV text:(NSString *)text;

@end

@interface WCGWaterFlowImageView : UIImageView

@property (nonatomic ,strong) UILabel *label;

//**代理*/
@property (nonatomic, weak) id<WCGWaterFlowImageViewDelegate> delegate;

@end
