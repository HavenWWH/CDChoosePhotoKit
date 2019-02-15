#
# Be sure to run `pod lib lint CDChoosePhotoKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'CDChoosePhotoKit'
  s.version          = '0.1.3'
  s.summary          = '拍照, 单选, 多选图片'
  s.description      = '单选, 多选图片, 支持图片进行裁剪,  裁剪引用第三方框架'
  s.homepage         = 'https://github.com/HavenWWH/CDChoosePhotoKit'
  s.license          = { :type => "MIT", :file => "LICENSE" } 
  s.author           = { 'Haven' => '513433750@qq.com' }
  s.source           = { :git => "https://gitlab.ttsing.com/ios/CDChoosePhotoKit.git"} 
  
  s.ios.deployment_target = '8.0'

  s.source_files  = "CDChoosePhotoKit/Classes/**/*.{h,m}"
  s.resources = 'CDChoosePhotoKit/**/*.{png,xib,nib,bundle}'


  s.public_header_files = 'CDChoosePhotoKit/Classes/**/*.h'
  s.frameworks = 'CoreGraphics', 'Photos', 'AssetsLibrary', 'AddressBook', 'AddressBookUI', 'UIKit', 'Foundation'
  s.dependency 'TOCropViewController', '~> 2.3.8'
end
