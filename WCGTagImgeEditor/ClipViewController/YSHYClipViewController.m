//
//  YSHYClipViewController.m
//  裁剪图片
//
//  Created by wcg on 16/6/6.
//  Copyright © 2016年 wuchaogang. All rights reserved.
//

#import "YSHYClipViewController.h"
#import "SVProgressHUD.h"
#import "WCGTagImageView.h"
#import "YSHYClipContentView.h"

@interface YSHYClipViewController ()<WCGTagImgViewDelegate,UIGestureRecognizerDelegate>

/**最后的缩放比例 */
@property(nonatomic,assign) CGFloat lastPhotoScale;

//**裁剪图层*/
@property (nonatomic, weak) YSHYClipContentView *clipView;

//** 图片ImageView */
@property (nonatomic, weak) UIImageView *imageView;

//**标签的view*/
@property(nonatomic,strong) WCGTagImageView *tagImageView;

//** 图片Data */
@property(nonatomic,strong) UIImage *image;

//**覆盖层 */
@property (nonatomic, weak) UIView *overView;

//**裁剪框的半径*/
@property (nonatomic, assign)CGFloat radius;

//**裁剪框的frame*/
@property (nonatomic, assign)CGRect circularFrame;

//**图片刚加进去时的Frame*/
@property (nonatomic, assign)CGRect OriginalFrame;

//**每次缩放保存当前Frame*/
@property (nonatomic, assign)CGRect currentFrame;

//**给carmera360的图片*/
@property(nonatomic,strong) UIImage *toCarmera360Img;

@end

@implementation YSHYClipViewController

- (instancetype)initWithImage:(UIImage *)image
{
    if(self = [super init])
    {
        _image = [self fixOrientation:image];
        self.lastPhotoScale = 1;
        self.radius = [UIScreen mainScreen].bounds.size.width/2;
        self.scaleRation =  2;
    }
    return  self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //设置颜色
    [SVProgressHUD setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.5]];
    [SVProgressHUD setForegroundColor:[UIColor whiteColor]];
    [SVProgressHUD setRingThickness:6];
    self.view.backgroundColor = [UIColor blackColor];
    [self CreatUI];
    [self addAllGesture];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [UIApplication sharedApplication].statusBarStyle = UIStatusBarStyleLightContent;

    [UIApplication sharedApplication].statusBarHidden = NO;
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self.tagImageView cancelTimers];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [UIApplication sharedApplication].statusBarHidden = YES;
    self.navigationController.navigationBarHidden = YES;
}

- (void)CreatUI
{
    //图片生成层
    //设置绘制的View
    CGPoint center = self.view.center;
    YSHYClipContentView *clipView = [[YSHYClipContentView alloc] init];

    clipView.frame = CGRectMake(center.x - self.radius, center.y - self.radius, self.radius * 2, self.radius * 2);
    clipView.backgroundColor = [UIColor darkGrayColor];
    self.clipView = clipView;
    self.clipView.userInteractionEnabled = YES;
    [self.view addSubview:self.clipView];
    
    //验证 裁剪半径是否有效
    self.radius= self.radius > self.view.frame.size.width/2?self.view.frame.size.width/2:self.radius;
    
    CGFloat width  = self.radius * 2;
    CGFloat height = (_image.size.height / _image.size.width) * width;
    
    UIImageView *imageView = [[UIImageView alloc] initWithImage:_image];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [imageView setFrame:CGRectMake(0, 0, width, height)];
    CGPoint centerP = CGPointMake(self.clipView.bounds.size.width * 0.5,self.clipView.bounds.size.height * 0.5);
    [imageView setCenter:centerP];
    self.OriginalFrame = imageView.frame;
    self.currentFrame = imageView.frame;
    self.imageView = imageView;
    [self.clipView addSubview:imageView];
    
    //标签的view
    WCGTagImageView *tagImageView = [[WCGTagImageView alloc] initWithImage:nil type:WCGTagImgViewTypeEditor];
    tagImageView.delegate = self;
    tagImageView.frame = CGRectMake(0, 0, self.radius * 2, self.radius * 2);
    self.tagImageView = tagImageView;
    self.tagImageView.backgroundColor = [UIColor clearColor];
    [self.clipView addSubview:self.tagImageView];
    
    //覆盖层
    UIView *overView = [[UIView alloc]init];
    [overView setBackgroundColor:[UIColor clearColor]];
    overView.opaque = NO;
    overView.userInteractionEnabled = NO;
    [overView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    self.overView = overView;
    [self.view addSubview:overView];
    
    //标题文字
    UILabel *title = [[UILabel alloc] init];
    [title setText:@"移动和缩放"];
    [title setTextColor:[UIColor whiteColor]];
    [title sizeToFit];
    [title setCenter:CGPointMake(self.view.bounds.size.width * 0.5, self.clipView.frame.origin.y - 20)];
    [self.view addSubview:title];
    
    
    UIButton * clipBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [clipBtn setTitle:@"选取" forState:UIControlStateNormal];
    [clipBtn setTintColor:[UIColor whiteColor]];
    [clipBtn addTarget:self action:@selector(clipBtnSelected:) forControlEvents:UIControlEventTouchUpInside];
    [clipBtn setFrame:CGRectMake(self.view.frame.size.width - 70, self.view.frame.size.height-60, 60, 60)];
    [self.view addSubview:clipBtn];
    
    UIButton * cancelBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [cancelBtn setTitle:@"取消" forState:UIControlStateNormal];
    [cancelBtn setTintColor:[UIColor whiteColor]];
    [cancelBtn addTarget:self action:@selector(cancelBtnSelected:) forControlEvents:UIControlEventTouchUpInside];
    [cancelBtn setFrame:CGRectMake(10, self.view.frame.size.height-60, 60, 60)];
    [self.view addSubview:cancelBtn];
    
//    UIButton * beautifyBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
//    [beautifyBtn setTitle:@"美化" forState:UIControlStateNormal];
//    [beautifyBtn setTintColor:[UIColor whiteColor]];
//    [beautifyBtn addTarget:self action:@selector(beautifyBtnBtnSelected:) forControlEvents:UIControlEventTouchUpInside];
//    [beautifyBtn setFrame:CGRectMake(self.view.frame.size.width * 0.5 - 30, self.view.frame.size.height - 60, 60, 60)];
//    [self.view addSubview:beautifyBtn];
    
    [self drawClipPath];
    [self MakeImageViewFrameAdaptClipFrame];
}

//绘制裁剪框
- (void)drawClipPath
{
    CGFloat ScreenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat ScreenHeight = [UIScreen mainScreen].bounds.size.height;
    CGPoint center = self.view.center;
    //裁剪框的Frame
    self.circularFrame = CGRectMake(center.x - self.radius, center.y - self.radius, self.radius * 2, self.radius * 2);
    UIBezierPath * path= [UIBezierPath bezierPathWithRect:CGRectMake(0, 0, ScreenWidth, ScreenHeight)];
    CAShapeLayer *layer = [CAShapeLayer layer];
    
    //绘制矩形框
    [path appendPath:[UIBezierPath bezierPathWithRect:CGRectMake(center.x - self.radius, center.y - self.radius, self.radius * 2, self.radius * 2)]];
    
    [path setUsesEvenOddFillRule:YES];
    layer.path = path.CGPath;
    layer.fillRule = kCAFillRuleEvenOdd;
    layer.fillColor = [[UIColor blackColor] CGColor];
    layer.opacity = 0.5;
    [_overView.layer addSublayer:layer];
}

//让图片自己适应裁剪框的大小
- (void)MakeImageViewFrameAdaptClipFrame
{
    CGFloat width = _imageView.frame.size.width ;
    CGFloat height = _imageView.frame.size.height;
    
    //如果图片高度小于裁剪框的高度，按照裁剪框高度算
    if(height < self.circularFrame.size.height && height > width)
    {
        width = (width / height) * self.circularFrame.size.height;
        height = self.circularFrame.size.height;
        CGRect frame = CGRectMake(0, 0, width, height);
        [_imageView setFrame:frame];
        [_imageView setCenter:self.view.center];
    }
    
    //如果图片宽度小于裁剪框的宽度，按照裁剪框宽度算
    if(width < self.circularFrame.size.width && width >= height)
    {
        height = (height / width) * self.circularFrame.size.width;
        width = self.circularFrame.size.width;
        CGRect frame = CGRectMake(0, 0, width, height);
        [_imageView setFrame:frame];
        [_imageView setCenter:self.view.center];
    }
}

//添加手势
- (void)addAllGesture
{
    //捏合手势
    UIPinchGestureRecognizer * pinGesture = [[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(handlePinGesture:)];
    pinGesture.delegate = self;
    [self.clipView addGestureRecognizer:pinGesture];
    //拖动手势
    UIPanGestureRecognizer * panGesture = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePanGesture:)];
    panGesture.delegate = self;
    [self.clipView addGestureRecognizer:panGesture];
    //双击手势
    UITapGestureRecognizer *singleTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleSingleTap:)];
    singleTapGesture.numberOfTapsRequired = 1;
    singleTapGesture.numberOfTouchesRequired  = 1;
    singleTapGesture.delegate = self;
    [self.clipView addGestureRecognizer:singleTapGesture];
    //单击手势
    UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleDoubleTap:)];
    doubleTapGesture.numberOfTapsRequired = 2;
    doubleTapGesture.numberOfTouchesRequired = 1;
    doubleTapGesture.delegate = self;
    [self.clipView addGestureRecognizer:doubleTapGesture];
    
    [singleTapGesture requireGestureRecognizerToFail:doubleTapGesture];
}
#pragma mark ---------------
#pragma mark 手势代理
//捏合手势
- (void)handlePinGesture:(UIPinchGestureRecognizer *)pinGesture
{
    UIView * view = _imageView;
    CGFloat width = self.OriginalFrame.size.width;//图片的宽度
    CGFloat height = self.OriginalFrame.size.height;//图片的高度
    
    if([pinGesture state] == UIGestureRecognizerStateBegan) {
        // Reset the last scale, necessary if there are multiple objects with different scales
        self.lastPhotoScale = [pinGesture scale];
    }
    if ([pinGesture state] == UIGestureRecognizerStateBegan ||
        [pinGesture state] == UIGestureRecognizerStateChanged) {
        
        CGFloat currentScale = [[view.layer valueForKeyPath:@"transform.scale"] floatValue];
        
        // Constants to adjust the max/min values of zoom
        const CGFloat kMaxScale = self.scaleRation;
        CGFloat kMinScale = 1.0;
        
        if(width > height){
            kMinScale = _circularFrame.size.width / width;
        }else{
            kMinScale = _circularFrame.size.height / height;
        }
        
        CGFloat newScale = 1 -  (self.lastPhotoScale - [pinGesture scale]);
        newScale = MIN(newScale, kMaxScale / currentScale);
        newScale = MAX(newScale, kMinScale / currentScale);
        CGAffineTransform transform = CGAffineTransformScale([view transform], newScale, newScale);
        view.transform = transform;
        
        self.lastPhotoScale = [pinGesture scale];  // Store the previous scale factor for the next pinch gesture call
    }
    if(pinGesture.state == UIGestureRecognizerStateEnded)
    {
        //最大倍率控制
        CGFloat ration =  view.frame.size.width /self.OriginalFrame.size.width;
        CGRect currentFrame = view.frame;
        
        if(ration>_scaleRation)
        {
            CGRect newFrame =CGRectMake(0, 0, self.OriginalFrame.size.width * _scaleRation, self.OriginalFrame.size.height * _scaleRation);
            currentFrame = newFrame;
        }
        
        //图片的高教长，并且宽度已经小于屏幕宽
        if (view.frame.size.width < self.circularFrame.size.width && self.OriginalFrame.size.width <= self.OriginalFrame.size.height && view.frame.size.height < self.circularFrame.size.height)
        {
            CGFloat rat =  self.OriginalFrame.size.width / self.OriginalFrame.size.height;
            CGRect newFrame =CGRectMake(0, 0, self.circularFrame.size.width * rat , self.circularFrame.size.height);
            currentFrame = newFrame;
        }
        //图片宽教长，并且高度已经小于屏幕高
        else if(view.frame.size.height< self.circularFrame.size.height && self.OriginalFrame.size.height <= self.OriginalFrame.size.width && view.frame.size.width < self.circularFrame.size.width)
        {
            CGFloat rat = self.OriginalFrame.size.height / self.OriginalFrame.size.width;
            CGRect newFrame =CGRectMake(0, 0, self.circularFrame.size.width, self.circularFrame.size.height * rat);
            currentFrame = newFrame;
        }
        
        CGPoint center = CGPointMake(self.clipView.bounds.size.width * 0.5, self.clipView.bounds.size.height * 0.5);
        
        currentFrame = CGRectMake(center.x - currentFrame.size.width * 0.5, center.y - currentFrame.size.height * 0.5, currentFrame.size.width, currentFrame.size.height);
        
        self.currentFrame = currentFrame;
        
        [UIView animateWithDuration:0.45 animations:^{
            [view setFrame:currentFrame];
        }];
    }
}
//拖拽手势
- (void)handlePanGesture:(UIPanGestureRecognizer *)panGesture
{
    UIView * view = _imageView;
    
    if(panGesture.state == UIGestureRecognizerStateBegan || panGesture.state == UIGestureRecognizerStateChanged)
    {
        CGPoint translation = [panGesture translationInView:view.superview];
        [view setCenter:CGPointMake(view.center.x + translation.x, view.center.y + translation.y)];
        
        [panGesture setTranslation:CGPointZero inView:view.superview];
    }
    else if (panGesture.state == UIGestureRecognizerStateEnded)
    {
        CGRect currentFrame = view.frame;
        //向右滑动 并且超出裁剪范围后
        if(currentFrame.origin.x >= self.circularFrame.origin.x)
        {
            currentFrame.origin.x =self.circularFrame.origin.x;
        }
        //向下滑动 并且超出裁剪范围后()
        if(currentFrame.origin.y >= 0)
        {
            currentFrame.origin.y = 0;
        }
        //向左滑动 并且超出裁剪范围后
        if(currentFrame.size.width + currentFrame.origin.x < self.circularFrame.origin.x + self.circularFrame.size.width)
        {
            CGFloat movedLeftX =fabs(currentFrame.size.width + currentFrame.origin.x -(self.circularFrame.origin.x + self.circularFrame.size.width));
            currentFrame.origin.x += movedLeftX;
        }
        //向上滑动 并且超出裁剪范围后
        if(currentFrame.size.height+currentFrame.origin.y < self.circularFrame.size.height)
        {
            CGFloat moveUpY =fabs(currentFrame.size.height + currentFrame.origin.y -(self.circularFrame.size.height));
            currentFrame.origin.y += moveUpY;
        }
        
        //如果已经是最小的尺寸，就要居中
        if (self.currentFrame.size.width < self.circularFrame.size.width || self.currentFrame.size.height < self.circularFrame.size.height) {
            //Y轴居中
            if (self.currentFrame.size.width > self.currentFrame.size.height) {
                CGFloat y = 0 + (self.circularFrame.size.height - self.currentFrame.size.height) / 2;
                currentFrame.origin.y = y;
            }else{
                //X轴居中
                CGFloat x = (self.circularFrame.size.width - self.currentFrame.size.width) / 2;
                currentFrame.origin.x = x;
            }
        }
        
        self.currentFrame  = currentFrame;
        
        [UIView animateWithDuration:0.45 animations:^{
            [view setFrame:currentFrame];
        }];
    }
}
//双击手势
- (void)handleDoubleTap:(UITapGestureRecognizer *)tapGesture
{
    if (tapGesture.state == UIGestureRecognizerStateEnded) {
        [UIView animateWithDuration:0.45 animations:^{
            self.imageView.transform = CGAffineTransformIdentity;
            self.imageView.frame = self.OriginalFrame;
            self.currentFrame = self.OriginalFrame;
            self.lastPhotoScale  = 1;
        } completion:nil];
    }
}
//单击手势
- (void)handleSingleTap:(UITapGestureRecognizer *)tapGesture
{
    CGPoint point = [tapGesture locationInView:tapGesture.view];
    
    [self.tagImageView clickimagePreviewsAtPoint:point];
}

#pragma mark ---------------
#pragma mark 按钮点击事件
- (void)clipBtnSelected:(UIButton *)btn
{
    UIImage *image = [self getSmallImage];
    
    //合成出标签图
    [self.tagImageView setImage:image];
    image = [self.tagImageView compoundImage];
    
    if (image != nil) {
        if ([self.delegate respondsToSelector:@selector(ClipViewController:FinishClipImage:)]) {
            //回调代理将大图返回出去
            [self.delegate ClipViewController:self FinishClipImage:image];
        }
    }
    
    [self.tagImageView cancelTimers];
}

- (void)cancelBtnSelected:(UIButton *)btn
{
    
    if (_isImageSource) {
        
        [self.navigationController popViewControllerAnimated:YES];
    }else{
        
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
    
    [self.tagImageView cancelTimers];
}

- (void)beautifyBtnBtnSelected:(UIButton *)btn
{
    _toCarmera360Img = [self getSmallImage];
    
    if (_toCarmera360Img != nil) {
        //将当前的截图获取到之后进入Cramera360的图片编辑
#if TARGET_IPHONE_SIMULATOR//模拟器
        if ([self.delegate respondsToSelector:@selector(ClipViewController:FinishClipImage:)]) {
            [self.delegate ClipViewController:self FinishClipImage:_toCarmera360Img];
        }
#elif TARGET_OS_IPHONE//真机
        [self planB:_toCarmera360Img];
        
#endif
        
    }
}

//原始图片调整
- (UIImage *)fixOrientation:(UIImage *)image
{
    if (image.imageOrientation == UIImageOrientationUp)
        return image;
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (image.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, image.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, image.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (image.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, image.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    CGContextRef ctx = CGBitmapContextCreate(NULL, image.size.width, image.size.height,
                                             CGImageGetBitsPerComponent(image.CGImage), 0,
                                             CGImageGetColorSpace(image.CGImage),
                                             CGImageGetBitmapInfo(image.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (image.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.height,image.size.width), image.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0,0,image.size.width,image.size.height), image.CGImage);
            break;
    }
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

//方形裁剪
- (UIImage *)getSmallImage
{
    if (self.currentFrame.size.width >= self.circularFrame.size.width && self.currentFrame.size.height >= self.
        circularFrame.size.height) {
        //放大至填充
        CGFloat width= self.currentFrame.size.width;
        CGFloat rationScale = (width /_image.size.width);
        
        CGFloat origX = (self.circularFrame.origin.x - (_imageView.frame.origin.x + self.clipView.frame.origin.x)) / rationScale;
        CGFloat origY = (self.circularFrame.origin.y - (_imageView.frame.origin.y + self.clipView.frame.origin.y)) / rationScale;
        CGFloat oriWidth = self.circularFrame.size.width / rationScale;
        CGFloat oriHeight = self.circularFrame.size.height / rationScale;
        
        CGRect myRect = CGRectMake(origX, origY, oriWidth, oriHeight);
        CGImageRef  imageRef = CGImageCreateWithImageInRect(_image.CGImage, myRect);
        UIGraphicsBeginImageContext(myRect.size);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextDrawImage(context, myRect, imageRef);
        UIImage * clipImage = [UIImage imageWithCGImage:imageRef];
        CGImageRelease(imageRef);
        UIGraphicsEndImageContext();
        return clipImage;
    }else{
        //缩放至最小
        CGImageRef imageRef = nil;
        CGRect myRect = CGRectZero;
        CGFloat imageW = _image.size.width;
        CGFloat imageH = _image.size.height;
        if (self.currentFrame.size.width<=self.circularFrame.size.width&&self.currentFrame.size.height<=self.circularFrame.size.height) {
            
            if (imageW > imageH) {
                myRect = CGRectMake(0,0, imageW, imageW);
            }else{
                myRect = CGRectMake(0,0, imageH, imageH);
            }
            
            imageRef = CGImageCreateWithImageInRect(_image.CGImage, CGRectMake(0, 0, imageW, imageH));
            UIGraphicsBeginImageContext(myRect.size);
            CGContextRef context = UIGraphicsGetCurrentContext();
            //将图片画到画布
            if (imageW>imageH) {
                drawImage(context,imageRef,CGRectMake(0, (imageW - imageH) * 0.5, imageW, imageH));
            }else{
                drawImage(context,imageRef,CGRectMake((imageH - imageW) * 0.5, 0 , imageW, imageH));
            }
            //画灰条
            CGContextSetRGBFillColor(context,240/255.0,240/255.0,242/255.0,1);
            
            if (imageW>imageH) {
                CGContextFillRect(context,CGRectMake(0, 0, imageW, (imageW - imageH)*0.5));
                CGContextFillRect(context,CGRectMake(0, (imageW - imageH)*0.5+imageH, imageW, (imageW - imageH)*0.5));
            }else{
                CGContextFillRect(context,CGRectMake(0, 0, (imageH - imageW)*0.5, imageH));
                CGContextFillRect(context,CGRectMake((imageH - imageW)*0.5+imageW, 0, (imageH - imageW)*0.5, imageH));
            }
            UIImage *clipImage = UIGraphicsGetImageFromCurrentImageContext();
            CGImageRelease(imageRef);
            UIGraphicsEndImageContext();
            return clipImage;
        }else{
            //部分包括(高度超出)
            if (self.circularFrame.size.height<self.currentFrame.size.height) {
                CGFloat width= self.currentFrame.size.width;
                CGFloat rationScale = (width /_image.size.width);
                
                CGFloat origX = (self.circularFrame.origin.x - (_imageView.frame.origin.x + self.clipView.frame.origin.x)) / rationScale;
                if (origX<0) {
                    origX=0;
                }
                CGFloat origY = (self.circularFrame.origin.y - (_imageView.frame.origin.y + self.clipView.frame.origin.y)) / rationScale;
                CGFloat oriWidth = self.circularFrame.size.width / rationScale;
                if (oriWidth>imageW) {
                    oriWidth=imageW;
                }
                CGFloat oriHeight = self.circularFrame.size.height / rationScale;
                CGRect myRect = CGRectMake(origX, origY, oriWidth, oriHeight);
                imageRef = CGImageCreateWithImageInRect(_image.CGImage, myRect);
                //将宽度拉长
                CGSize contentSize = CGSizeMake(myRect.size.height, myRect.size.height);
                UIGraphicsBeginImageContext(contentSize);
                CGContextRef context = UIGraphicsGetCurrentContext();
                
                drawImage(context,imageRef,CGRectMake((myRect.size.height - myRect.size.width) * 0.5, 0 , myRect.size.width, contentSize.height));
                
                //画灰条
                CGContextSetRGBFillColor(context,240/255.0,240/255.0,242/255.0,1);
                
                CGContextFillRect(context,CGRectMake(0, 0, (contentSize.height - myRect.size.width)*0.5, contentSize.height));
                CGContextFillRect(context,CGRectMake((contentSize.height - myRect.size.width)*0.5+myRect.size.width, 0, (contentSize.height - myRect.size.width)*0.5, contentSize.height));
                
                UIImage * clipImage = UIGraphicsGetImageFromCurrentImageContext();
                CGImageRelease(imageRef);
                UIGraphicsEndImageContext();
                return clipImage;
            }else {
                //部分包括(宽度超出)
                CGFloat width= self.currentFrame.size.width;
                CGFloat rationScale = (width /_image.size.width);
                CGFloat origX = (self.circularFrame.origin.x - (_imageView.frame.origin.x + self.clipView.frame.origin.x)) / rationScale;
                CGFloat origY = (self.circularFrame.origin.y - (_imageView.frame.origin.y + self.clipView.frame.origin.y)) / rationScale;
                if (origY<0) {
                    origY=0;
                }
                CGFloat oriWidth = self.circularFrame.size.width / rationScale;
                CGFloat oriHeight = self.circularFrame.size.height / rationScale;
                if (oriHeight>imageH) {
                    oriHeight=imageH;
                }
                CGRect myRect = CGRectMake(origX, origY, oriWidth, oriHeight);
                imageRef = CGImageCreateWithImageInRect(_image.CGImage, myRect);
                //将高度拉高
                CGSize contentSize = CGSizeMake(myRect.size.width, myRect.size.width);
                UIGraphicsBeginImageContext(contentSize);
                CGContextRef context = UIGraphicsGetCurrentContext();
                drawImage(context,imageRef,CGRectMake(0, (myRect.size.width-myRect.size.height)*0.5, myRect.size.width, myRect.size.height));
                
                //画灰条
                CGContextSetRGBFillColor(context,240/255.0,240/255.0,242/255.0,1);
                
                CGContextFillRect(context,CGRectMake(0, 0, contentSize.width, (contentSize.width - myRect.size.height)*0.5));
                CGContextFillRect(context,CGRectMake(0, (contentSize.width - myRect.size.height)*0.5+myRect.size.height, contentSize.width, (contentSize.width - myRect.size.height)*0.5));
                
                UIImage * clipImage = UIGraphicsGetImageFromCurrentImageContext();
                CGImageRelease(imageRef);
                UIGraphicsEndImageContext();
                return clipImage;
            }
        }
    }
}

//控制画图方向
void drawImage(CGContextRef context, CGImageRef image , CGRect rect){
    CGContextSaveGState(context);
    
    CGContextTranslateCTM(context, rect.origin.x, rect.origin.y);
    CGContextTranslateCTM(context, 0, rect.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextTranslateCTM(context, -rect.origin.x, -rect.origin.y);
    CGContextDrawImage(context, rect, image);
    
    CGContextRestoreGState(context);
}

- (BOOL)prefersStatusBarHidden{
    return YES;
}

#pragma mark ---------------
#pragma mark 私有方法
- (void)planB:(UIImage *)image{
    
}

#pragma mark - WCGTagImgViewDelegate、UIGestureRecognizerDelegate

- (void)didTapImgView:(WCGTagImageView *)tagImageView tmpTagView:(WCGTagView *)tagView{
    if (tagView) {
        tagView.tagType = WCGTagTypePosition;
        tagView.text = @"新增的标签";
    }
}

- (void)didEditTagView:(WCGTagView *)tagView imgView:(WCGTagImageView *)tagImageView{
    if (tagView) {
        tagView.tagType = WCGTagTypeLabel;
        tagView.text = @"编辑后的标签ajsdhajkdhakshdka是打开AKLjdlkajsd";
    }
}

- (void)didDeleteTagView:(WCGTagView *)tagView imgView:(WCGTagImageView *)tagImageView{
    
}

@end
