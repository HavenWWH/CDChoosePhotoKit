# CDChoosePhotoKit
单选照片  多选照片  还可以选择是否进行裁剪

类说明:

CDAlbumListController  相册列表(根据自己需求可以选择显示哪些相册)

CDPhotoListController   照片列表

CDCustomSheet            底部弹窗, 选择相册或者相机

CDPhotoImageHelper    工具类(照片对象的转换,  获取列表等等)

CDShowBigImage          放大图片


用法:

相机调用系统自带方法

UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];

imagePicker.delegate = self;

imagePicker.allowsEditing = NO;

imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;

[self presentViewController:imagePicker animated:YES completion:nil];

相册调用此方法

CDAlbumListController *vc = [[CDAlbumListController alloc] init];

// 保存已选照片
vc.selctImageArray = self.selectArray;

// 最大可选择几张照片
vc.maxCount = self.maxCount;

// 是否需要剪裁
vc.isCrop = self.isCrop;

// 剪裁框比例
if (self.isCrop) vc.cropScale = self.cropScale;

UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];

__weak CDPhotoBaseViewController *weakSelf = self;

// 选择完照片的回调
vc.okClickComplete = ^(NSArray<ImageModel *> *images){

}
