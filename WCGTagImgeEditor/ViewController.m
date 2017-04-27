//
//  ViewController.m
//  WCGTagImgeEditor
//
//  Created by Wcg on 2017/4/27.
//  Copyright © 2017年 吴朝刚. All rights reserved.
//

#import "ViewController.h"
#import "YSHYClipViewController.h"

@interface ViewController ()<UINavigationControllerDelegate,UIImagePickerControllerDelegate,ClipViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (IBAction)choseImgBtnClick:(id)sender {
    
    UIAlertController *alertVc = [UIAlertController alertControllerWithTitle:@"选择方式" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction *action1 = [UIAlertAction actionWithTitle:@"打开相机" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [self takePhotoAction];
    }];
    
    UIAlertAction *action2 = [UIAlertAction actionWithTitle:@"打开相册" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [self localPhotoAction];
    }];
    
    
    UIAlertAction *action3 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
    }];
    
    [alertVc addAction:action1];
    [alertVc addAction:action2];
    [alertVc addAction:action3];
    
    [self presentViewController:alertVc animated:YES completion:nil];
}


#pragma mark 相片操作
//开始拍照
- (void)takePhotoAction{
    
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        
        [self presentViewController:picker animated:YES completion:^{
            [picker.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor],NSForegroundColorAttributeName,nil]];
        }];
        
        
    }else{
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"易悦" message:@"相机暂不可使用" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
        [alert show];
    }
}

//打开本地相册
- (void)localPhotoAction{
    
    UIImagePickerController *pickerImage = [[UIImagePickerController alloc] init];
    pickerImage.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    pickerImage.delegate = self;
    
    [self presentViewController:pickerImage animated:YES completion:^{
        [pickerImage.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor blackColor],NSForegroundColorAttributeName,nil]];
    }];
    
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    
    UIImage *image =  [info objectForKey:UIImagePickerControllerOriginalImage];
    
    YSHYClipViewController * clipView = [[YSHYClipViewController alloc]initWithImage:image];
    clipView.delegate = self;
    if (picker.sourceType == UIImagePickerControllerSourceTypePhotoLibrary) {
        clipView.isImageSource = YES;
    }
    
    [picker pushViewController:clipView animated:YES];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker{
    
    [picker dismissViewControllerAnimated:YES completion:^{
        
        
    }];
}

- (void)ClipViewController:(YSHYClipViewController *)clipViewController FinishClipImage:(UIImage *)editImage{
    self.imageView.image = editImage;
    
    [clipViewController dismissViewControllerAnimated:YES completion:^{
        
        
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
