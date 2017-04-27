//
//  YSHYClipContentView.m
//  EDate_V3
//
//  Created by Wcg on 2017/4/25.
//  Copyright © 2017年 XuDehui. All rights reserved.
//

#import "YSHYClipContentView.h"
#import "WCGTagImageView.h"

@implementation YSHYClipContentView

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    
    // 1.判断下窗口能否接收事件
    if (self.userInteractionEnabled == NO || self.hidden == YES ||  self.alpha <= 0.01) return nil;
    // 2.判断下点在不在窗口上
    // 不在窗口上
    if ([self pointInside:point withEvent:event] == NO) return nil;
    // 3.从后往前遍历子控件数组
    
    for (UIView *childView in self.subviews) {
        // 坐标系的转换,把窗口上的点转换为子控件上的点
        // 把自己控件上的点转换成子控件上的点
        CGPoint childP = [self convertPoint:point toView:childView];
        UIView *fitView = [childView hitTest:childP withEvent:event];
        
        NSLog(@"fitView --- %@",[fitView class]);
        if (fitView && [fitView isKindOfClass:[WCGWaterFlowImageView class]]) {
            // 如果能找到最合适的view
            return fitView.superview;
        }
        
        if (fitView && [fitView isKindOfClass:[WCGTagView class]]) {
            // 如果能找到最合适的view
            return fitView;
        }
    }
    // 4.没有找到更合适的view，也就是没有比自己更合适的view
    return self;
}

@end
