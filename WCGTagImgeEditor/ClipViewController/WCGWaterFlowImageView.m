//
//  WCGWaterFlowImageView.m
//  YXLImageLabelDemo
//
//  Created by Wcg on 2017/4/22.
//  Copyright © 2017年 吴朝刚. All rights reserved.
//

#import "WCGWaterFlowImageView.h"

@implementation WCGWaterFlowImageView

- (void)dealloc{
    
    [self.label removeObserver:self forKeyPath:@"text"];
}

- (id)initWithFrame:(CGRect)frame{
    self =[super initWithFrame:frame];
    if (self) {
        self.layer.masksToBounds=YES;        
        _label = [[UILabel alloc]init];
        _label.font = WCGTagFont;
        _label.textColor = [UIColor whiteColor];
        _label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:_label];
        [_label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self).insets(UIEdgeInsetsMake(0, 15, 0, 5));
        }];
        
        [self.label addObserver:self forKeyPath:@"text" options:NSKeyValueObservingOptionNew context:nil];
    }
    return self;
}

#pragma -mark KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([object isEqual:_label] && [keyPath isEqualToString:@"text"]) {
        
        NSString *text = [_label valueForKey:@"text"];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(textDidChangeWaterFlowImageView:text:)]) {
            [self.delegate textDidChangeWaterFlowImageView:self text:text];
        }
    }
}


@end
