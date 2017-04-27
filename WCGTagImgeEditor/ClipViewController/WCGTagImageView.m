//
//  WCGTagImageView.m
//  YXLImageLabelDemo
//
//  Created by Wcg on 2017/4/22.
//  Copyright © 2017年 吴朝刚. All rights reserved.
//

#import "WCGTagImageView.h"
#import "WCGWaterFlowImageView.h"
//#import "UIImageView+EDateImageView.h"

@interface WCGTagImageView()<UIGestureRecognizerDelegate>{
    NSMutableArray *arrayTagS;
    WCGTagView *viewTag;
    CGFloat imageScale;
    CGFloat viewTagLeft;
}

//**前景图 */
@property (nonatomic ,strong) UIImageView *imagePreviews;

//**菜单 */
@property(nonatomic,strong) UIMenuController *popMenu;

/**菜单是否显示 */
@property(nonatomic,assign) BOOL isMenuShow;

@end

@implementation WCGTagImageView

#pragma mark - life circle

- (id)init{
    self =[super init];
    if (self) {
        if (arrayTagS==nil) {
            arrayTagS =[NSMutableArray array];
        }
        
        [self addSubview:self.imagePreviews];
    }
    return self;
}

- (id)initWithImage:(UIImage *)image type:(WCGTagImgViewType)type{
    self =[super init];
    if (self) {
        _imgViewType = type;
        arrayTagS = [NSMutableArray array];
        self.imagePreviews.userInteractionEnabled=YES;
        [self addSubview:self.imagePreviews];
        
        [self.imagePreviews mas_makeConstraints:^(MASConstraintMaker *make) {
            
            make.edges.mas_equalTo(self).insets(UIEdgeInsetsZero);
        }];
        
        if (image==nil) {
            return self;
        }
        _imagePreviews.image =image;
    }
    return self;
}

- (id)initWithNetImageName:(NSString *)imageName type:(WCGTagImgViewType)type{
    
    //回调中调用
    self = [self initWithImage:nil type:type];
    
    if (self) {
        //调用SDWeb获取图片
//        [self.imagePreviews edate_setBigImageWithURLName:imageName placeholder:nil duration:0.25 completedWithArgument:^(UIImage *image, NSError *error, SDImageCacheType cacheType) {
//            
//        }];
    }
    
    return self;
}

#pragma -mark 添加已知标签

- (void)addTagViewText:(NSString *)text Location:(CGPoint )point isPositive:(BOOL)isPositive tagType:(WCGTagType)tagType{
    
    [self addtagViewimageClickinit:point isAddTagView:YES];
    if(text.length!=0)
        viewTag.text=text;
    //根据tagType不同设置不同的小点
    //位置 或者 圆心
}

#pragma mark - action
#pragma -mark GestureRecognizer

/**
 *  点击创建标签
 */
- (void)addtagViewimageClickinit:(CGPoint)point isAddTagView:(BOOL)isAdd{
    if (self.imgViewType == WCGTagImgViewTypeShow && !isAdd) {
        return;
    }
    
    if (self.isMenuShow) {
        self.isMenuShow = NO;
        return;
    }
    
    WCGTagView *viewTagNew =[[WCGTagView alloc]init];
    
    UIPanGestureRecognizer *panTagView =[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panTagView:)];
    panTagView.minimumNumberOfTouches=1;
    panTagView.maximumNumberOfTouches=1;
    panTagView.delegate=self;
    [viewTagNew addGestureRecognizer:panTagView];
    
    UITapGestureRecognizer* tapTagView = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapTagView:)];
    tapTagView.numberOfTapsRequired=1;
    tapTagView.numberOfTouchesRequired=1;
    tapTagView.delegate = self;
    [viewTagNew addGestureRecognizer:tapTagView];
    
    UILongPressGestureRecognizer *longTagView =[[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longTagView:)];
    longTagView.minimumPressDuration=0.5;
    longTagView.delegate=self;
    [viewTagNew addGestureRecognizer:longTagView];
    [_imagePreviews addSubview:viewTagNew];
    
    [viewTagNew mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(point.x));
        make.top.equalTo(@(point.y-viewTagNew.imageLabelH/2));
        make.width.greaterThanOrEqualTo(@(viewTagNew.imageLabelW + 8));
        make.height.equalTo(@(viewTagNew.imageLabelH));
    }];
    
    [arrayTagS addObject:viewTagNew];
    
    if (self.isHiddenTagViews) {
        
        viewTagNew.hidden = YES;
    }
    
    viewTag = viewTagNew;
    if (!isAdd) {
        
        //跳转去选择text
        if (self.delegate && [self.delegate respondsToSelector:@selector(didTapImgView:tmpTagView:)]) {
            
            [self.delegate didTapImgView:self tmpTagView:viewTag];
        }
    }else{
        
        viewTagNew.shouldImageLabelShow=YES;
    }
}

/**
 *  标签移动
 */
- (void)panTagView:(UIPanGestureRecognizer *)sender{
    if (self.imgViewType == WCGTagImgViewTypeShow) {
        return;
    }
    viewTag =(WCGTagView *)sender.view;
    
    CGPoint point = [sender locationInView:_imagePreviews];
    if (sender.state ==UIGestureRecognizerStateBegan) {
        viewTagLeft =point.x-CGOriginX(viewTag.frame);
    }
    [self panTagViewPoint:point];
}

/**
 *  点击标签翻转
 */
- (void)tapTagView:(UITapGestureRecognizer *)sender{
    if (self.imgViewType == WCGTagImgViewTypeShow) {
        return;
    }
    
    viewTag =(WCGTagView *)sender.view;
    
    viewTag.isPositive = !viewTag.isPositive;
}

/**
 *  长按手势
 */
- (void)longTagView:(UILongPressGestureRecognizer *)sender{
    if (self.imgViewType == WCGTagImgViewTypeShow) {
        return;
    }
    
    viewTag =(WCGTagView *)sender.view;
    if (sender.state ==UIGestureRecognizerStateBegan) {
        [sender.view becomeFirstResponder];
        [self.popMenu setTargetRect:sender.view.frame inView:_imagePreviews];
        [self.popMenu setMenuVisible:YES animated:YES];
        self.isMenuShow = YES;
    }
}

/**
 *  点击图片
 */
- (void)clickimagePreviews:(UITapGestureRecognizer *)sender{
    if (self.imgViewType == WCGTagImgViewTypeShow) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didTapImgView:tmpTagView:)]) {
            [self.delegate didTapImgView:self tmpTagView:nil];
        }
        return;
    }
    
    CGPoint point = [sender locationInView:sender.view];
    [self addtagViewimageClickinit:point isAddTagView:NO];
}

/**
 *  pan手势 执行移动
 */
- (void)panTagViewPoint:(CGPoint )point{
    
    [viewTag mas_updateConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@(point.x-viewTagLeft));
        make.top.equalTo(@(point.y-viewTag.imageLabelH/2));
        if((point.x-viewTagLeft)<=0){
            make.left.equalTo(@0);
        }
        if (point.y+viewTag.imageLabelH/2 >=CGRectGetHeight(_imagePreviews.frame)) {
            make.top.equalTo(@(CGRectGetHeight(_imagePreviews.frame)-viewTag.imageLabelH));
        }
        if (point.y-viewTag.imageLabelH/2 <= 0) {
            make.top.equalTo(@(0));
        }
        if (point.x+(CGWidth(viewTag.frame)-viewTagLeft) >= kScreenWidth) {
            make.left.equalTo(@(kScreenWidth-(CGWidth(viewTag.frame))));
        }
    }];
}

#pragma -mark 菜单
/**
 *  编辑
 */
- (void)menuItem1Pressed{
    
    //跳转到编辑去
    if (self.delegate && [self.delegate respondsToSelector:@selector(didEditTagView:imgView:)]) {
        
        [self.delegate didEditTagView:viewTag imgView:self];
    }
    self.isMenuShow = NO;
    
//    NSString *updateText = @"";
//    
//    viewTag.text = updateText;
//    [viewTag mas_updateConstraints:^(MASConstraintMaker *make) {
//        CGSize size =[updateText sizeWithAttributes:[NSDictionary dictionaryWithObjectsAndKeys:Font(11),NSFontAttributeName, nil]];
//        CGFloat W;
//        if (viewTag.imageLabelW-15 > size.width) {
//            W=0;
//        }else{
//            W=size.width-(viewTag.imageLabelW-15);
//        }
//        if(viewTag.isPositive){
//            
//            if (CGRectGetMaxX(viewTag.frame)-(viewTag.imageLabelW+8+W)<=0) {
//                make.left.equalTo(@0);
//            }
//        }else{
//            
//            if (CGRectGetMaxX(viewTag.frame) >=kWindowWidth) {
//                make.left.equalTo(@(kWindowWidth-(viewTag.imageLabelW+8+W)));
//            }
//        }
//    }];
}
/**
 *  删除
 */
- (void)menuItem2Pressed{
    
    for (WCGTagView *tag in arrayTagS) {
        if ([tag isEqual: viewTag]) {
            [arrayTagS removeObject:tag];
            [tag removeFromSuperview];
            break;
        }
    }
    
    self.isMenuShow = NO;
}

#pragma mark - getter setter
- (UIImageView *)imagePreviews{
    if (!_imagePreviews) {
        UIImageView *image =[UIImageView new];
        image.contentMode = UIViewContentModeScaleAspectFit;
        _imagePreviews = image;
        
        _imagePreviews.userInteractionEnabled = YES;
        UITapGestureRecognizer* tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickimagePreviews:)];
        tap.numberOfTapsRequired=1;
        tap.numberOfTouchesRequired=1;
        [_imagePreviews addGestureRecognizer:tap];
    }
    
    return _imagePreviews;
}

- (NSMutableArray *)tagModels{
    
    NSMutableArray *array =[NSMutableArray array];
    NSString *positive;
    NSString *point;
    NSString *tagType;
    for (WCGTagView *tag in arrayTagS) {
        positive =@"0";
        point =[NSString stringWithFormat:@"%f,%f",CGOriginX(tag.frame)/imageScale,CGOriginY(tag.frame)/imageScale];
        if(tag.isPositive ==YES){
            positive =@"1";
            point =[NSString stringWithFormat:@"%f,%f",CGRectGetMaxX(tag.frame)/imageScale,CGOriginY(tag.frame)/imageScale];
        }
        if (tag.tagType == WCGTagTypePosition) {
            tagType = @"1";
        }else{
            tagType = @"0";
        }
        
        NSDictionary *dic=@{@"positive":positive,@"tagType":tagType,@"point":point,@"text":tag.text};
        [array addObject:dic];
    }
    return array;
}

- (UIMenuController *)popMenu{
    if (!_popMenu) {
        UIMenuController *popMenu = [UIMenuController sharedMenuController];
        UIMenuItem *item1 = [[UIMenuItem alloc] initWithTitle:@"编辑" action:@selector(menuItem1Pressed)];
        UIMenuItem *item2 = [[UIMenuItem alloc] initWithTitle:@"删除" action:@selector(menuItem2Pressed)];
        NSArray *menuItems = [NSArray arrayWithObjects:item1,item2,nil];
        [popMenu setMenuItems:menuItems];
        [popMenu setArrowDirection:UIMenuControllerArrowDown];
        _popMenu = popMenu;
    }
    
    return _popMenu;
}

//- (void)scaledFrame{    
//    CGRect noScale = CGRectMake(0.0, 0.0, _imagePreviews.image.size.width , _imagePreviews.image.size.height );
//    if (CGWidth(noScale) <= kWindowWidth && CGHeight(noScale) <= self.frame.size.height) {
//        imageScale = 1.0;
//        _imagePreviews.frame= (CGRect){{kWindowWidth/2 -noScale.size.width/2,(kWindowHeight-64) /2 -noScale.size.height/2} ,noScale.size};
//        return ;
//    }
//    CGRect scaled;
//    imageScale= (kWindowHeight-64) / _imagePreviews.image.size.height;
//    scaled=CGRectMake(0.0, 0.0, _imagePreviews.image.size.width * imageScale , _imagePreviews.image.size.height * imageScale );
//    if (CGWidth(scaled) <= kWindowWidth && CGHeight(scaled) <= (kWindowHeight-64)) {
//        _imagePreviews.frame= (CGRect){{kWindowWidth/2 -scaled.size.width/2,(self.frame.size.height-64) /2 -scaled.size.height/2} ,scaled.size};
//        return ;
//    }
//    imageScale = kWindowWidth / _imagePreviews.image.size.width;
//    scaled = CGRectMake(0.0, 0.0, _imagePreviews.image.size.width * imageScale, _imagePreviews.image.size.height * imageScale);
//    _imagePreviews.frame=(CGRect){{kWindowWidth/2 -scaled.size.width/2,(kWindowHeight-64) /2 -scaled.size.height/2} ,scaled.size};
//}

- (void)setIsHiddenTagViews:(BOOL)isHiddenTagViews{
    
    [arrayTagS enumerateObjectsUsingBlock:^(WCGTagView *tagView, NSUInteger idx, BOOL * _Nonnull stop) {
        
        tagView.hidden = isHiddenTagViews;
    }];
}

#pragma mark - public

- (UIImage *)compoundImage{
    
    CGFloat width = floor(self.imagePreviews.bounds.size.width);
    CGFloat height = floor(self.imagePreviews.bounds.size.height);
    
    //水印图
    UIImage *mask = [UIImage imageNamed:@"CodingStudy"];
    CGRect rect = CGRectMake(width - 28, 8, 20, 20);
    
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(width, height), YES, 0.0);

    [self.imagePreviews.layer renderInContext:UIGraphicsGetCurrentContext()];
    [mask drawInRect:rect];
    UIImage *image=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (void)cancelTimers{
    [arrayTagS enumerateObjectsUsingBlock:^(WCGTagView *tagView, NSUInteger idx, BOOL * _Nonnull stop) {
        [tagView cancelTimer];
    }];
}

- (void)setImage:(UIImage *)image{
    self.imagePreviews.image = image;
}

- (void)clickimagePreviewsAtPoint:(CGPoint)point{
    
    if (self.imgViewType == WCGTagImgViewTypeShow) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(didTapImgView:tmpTagView:)]) {
            [self.delegate didTapImgView:self tmpTagView:nil];
        }
        return;
    }
    
    [self addtagViewimageClickinit:point isAddTagView:NO];
}

#pragma mark - reload Data
- (void)reloadData{
    //清空所有标签
    [arrayTagS removeAllObjects];
    viewTag = nil;
    
    //循环标签重新添加
    if (self.dataSource && [self.dataSource respondsToSelector:@selector(numOfLabelImgView:)]) {
        for (int i= 0 ; i< [self.dataSource numOfLabelImgView:self]; i++) {
            
            if ([self.dataSource respondsToSelector:@selector(tagViewForIndex:ImgView:)]) {
                
                //**待完善*/                
                
            }
        }
    }
    
}


@end
