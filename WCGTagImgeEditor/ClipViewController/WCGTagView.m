//
//  WCGTagView.m
//  YXLImageLabelDemo
//
//  Created by Wcg on 2017/4/22.
//  Copyright © 2017年 吴朝刚. All rights reserved.
//

#import "WCGTagView.h"
#import "WCGWaterFlowImageView.h"
#import "NSTimer+Addition.h"

@interface WCGTagView()<WCGWaterFlowImageViewDelegate>

//**标签图片+文本 */
@property (nonatomic ,strong) WCGWaterFlowImageView *imageLabel;

//**黑色伸展动画的View */
@property(nonatomic,strong) UIView *spreadView;;

//**中间白色的View (可以是地理位置或者圆点)*/
@property(nonatomic,strong) UIImageView *tapDotView;

//**定时器 */
@property (nonatomic, weak) NSTimer *timerAnimation;

@end

@implementation WCGTagView

static const CGFloat flickerPointWH = 8;


#pragma mark - life circle
- (void)dealloc{
    
    [self cancelTimer];
}

- (void)cancelTimer{
    if (_timerAnimation) {
        [_timerAnimation invalidate];
        _timerAnimation = nil;
    }
}

- (instancetype)init{
    self = [super init];
    if (self) {
        _timerAnimation = [NSTimer scheduledTimerWithTimeInterval:3
                                                         target:self
                                                       selector:@selector(animationTimerDidFired)
                                                       userInfo:nil
                                                        repeats:YES];
        [self initUI];
    }
    return self;
}

- (void)initUI{
    
    self.imageLabel.hidden = YES;
    [self.imageLabel sizeToFit];
    
    _imageLabelH = self.imageLabel.image.size.height;
    _imageLabelW = self.imageLabel.image.size.width;
    
    self.imageLabel.delegate = self;
    
    [self addSubview:self.imageLabel];
    [self.imageLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(10));
        make.centerY.equalTo(self);
        make.width.greaterThanOrEqualTo(@(CGWidth(_imageLabel.frame)));
        make.height.equalTo(@(CGHeight(_imageLabel.frame)));
    }];
    
    self.spreadView.layer.cornerRadius=flickerPointWH/2;
    [self addSubview:self.spreadView];
    [self.spreadView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.left.equalTo(@0);
        make.size.mas_equalTo(CGSizeMake(flickerPointWH, flickerPointWH));
    }];
    
    self.tapDotView.layer.cornerRadius=flickerPointWH/2;
    [self addSubview:self.tapDotView];
    [self.tapDotView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.left.equalTo(@0);
        make.size.mas_equalTo(CGSizeMake(flickerPointWH, flickerPointWH));
    }];
    
    [self.timerAnimation resumeTimer];
}


#pragma mark - private

/**
 *  播放动画
 */
- (void)animationTimerDidFired{
    [UIView animateWithDuration:1 animations:^{
        
        self.tapDotView.transform = CGAffineTransformMakeScale(1.3,1.3);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:1 animations:^{
            
            self.tapDotView.transform = CGAffineTransformIdentity;
        }completion:^(BOOL finished) {
            
            self.spreadView.alpha=1;
            [UIView animateWithDuration:1 animations:^{
                
                self.spreadView.alpha=0;
                self.spreadView.transform = CGAffineTransformMakeScale(5,5);
            }completion:^(BOOL finished) {
                
                self.spreadView.transform = CGAffineTransformIdentity;
            }];
        }];
        
    }];
}

/**
 * 自动布局子控件
 */
- (void)correctSubview{
    UIImage *image = _isPositive? [[UIImage imageNamed:@"textTagAnti"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 5, 5, 12)]:[[UIImage imageNamed:@"textTag"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 12, 5, 5)];
    self.imageLabel.image = image;
    
    __weak typeof(self) weakSelf = self;
    
    CGSize size =[weakSelf.imageLabel.label.text sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:WCGTagFont,NSFontAttributeName, nil]];
    CGFloat W;
    if (weakSelf.imageLabelW - 20 > size.width) {
        W=0;
    }else{
        W=size.width-(weakSelf.imageLabelW - 20);
    }
    [weakSelf mas_updateConstraints:^(MASConstraintMaker *make) {
        make.width.greaterThanOrEqualTo(@(weakSelf.imageLabelW+ 10 + W + flickerPointWH));
        if(_isPositive){
            [weakSelf.imageLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(@0);
            }];
            [weakSelf.imageLabel.label mas_updateConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(_imageLabel).insets(UIEdgeInsetsMake(0, 5, 0, 15));
            }];
            [weakSelf.spreadView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(@(self.imageLabelW+W+0.5));
            }];
            [weakSelf.tapDotView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(@(self.imageLabelW+W+0.5));
            }];
        }else{
            [weakSelf.imageLabel mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(@10);
            }];
            [weakSelf.imageLabel.label mas_updateConstraints:^(MASConstraintMaker *make) {
                make.edges.equalTo(_imageLabel).insets(UIEdgeInsetsMake(0, 15, 0, 5));
            }];
            [weakSelf.spreadView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(@0);
            }];
            [weakSelf.tapDotView mas_updateConstraints:^(MASConstraintMaker *make) {
                make.left.equalTo(@0);
            }];
        }
        
    }];
}

/**
 * 重新规划在父控件的位置
 */
- (void)correctInSuperview{
    
    if (_isPositive) {
        
        [self mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@(CGOriginX(self.frame)-CGWidth(self.frame)+10));
            if (CGOriginX(self.frame)-CGWidth(self.frame) + 10<=0) {
                make.left.equalTo(@0);
            }
        }];
    }else{
        
        NSLog(@"self.viewWidth:%f",CGRectGetMaxX(self.frame)+CGWidth(self.frame)-10);
        NSLog(@"kScreenWidth:%f",kScreenWidth);
        [self mas_updateConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@(CGOriginX(self.frame)+CGWidth(self.frame)-10));
            if (CGRectGetMaxX(self.frame)+CGWidth(self.frame)-10 >=kScreenWidth) {
                make.left.equalTo(@(kScreenWidth-CGWidth(self.frame)));
            }
        }];
    }
}



#pragma mark - getter setter

- (WCGWaterFlowImageView *)imageLabel{
    
    if (!_imageLabel) {
        
        WCGWaterFlowImageView *imageV =[WCGWaterFlowImageView new];
        
        imageV.image = [[UIImage imageNamed:@"textTag"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 12, 5, 5)];
        
        imageV.userInteractionEnabled=YES;
        
        _imageLabel = imageV;
    }
    return _imageLabel;
}

- (UIView *)spreadView{
    
    if (!_spreadView) {
        _spreadView = [[UIImageView alloc] init];
        _spreadView.backgroundColor=LDColorRGBA(0, 0, 0, 0.7);
        _spreadView.userInteractionEnabled=NO;
    }
    return _spreadView;
}

- (UIView *)tapDotView{
    
    if (!_tapDotView) {
        _tapDotView = [[UIImageView alloc] init];
//        _tapDotView.backgroundColor = [UIColor whiteColor];
        _tapDotView.userInteractionEnabled = NO;
    }
    return _tapDotView;
}

- (void)setShouldImageLabelShow:(BOOL)shouldImageLabelShow{
    
    _shouldImageLabelShow = shouldImageLabelShow;
    if (shouldImageLabelShow) {
        _imageLabel.hidden = NO;
    }else{
        _imageLabel.hidden = YES;
    }
}

- (void)setIsPositive:(BOOL)isPositive{
    
    if (_isPositive != isPositive) {
        
        _isPositive = isPositive;
        
        //重新布局子控件
        [self correctSubview];
    }
}

- (void)setTagType:(WCGTagType)tagType{
    NSString *imageName = nil;
    
    switch (tagType) {
        case WCGTagTypePosition:
            
            imageName = @"tagMapIcon";
            break;
        case WCGTagTypeLabel:
            imageName = @"tagTapIcon";
            break;
    }
    self.tapDotView.image = [UIImage imageNamed:imageName];
}

- (void)setText:(NSString *)text{
    
    _text = text;
    
    self.imageLabel.label.text = text;
    self.shouldImageLabelShow = YES;
}

- (BOOL)canBecomeFirstResponder{
    
    return YES;
};

#pragma mark - WCGWaterFlowImageViewDelegate

- (void)textDidChangeWaterFlowImageView:(WCGWaterFlowImageView *)wfImgV text:(NSString *)text{
    //自动布局子控件
    [self correctSubview];
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
    if (CGRectGetMaxX(self.frame) - 8 >= kScreenWidth){
        NSLog(@"layouSubViews ------ %@",NSStringFromCGRect(self.frame));
        [self correctInSuperview];
    }
}

@end
