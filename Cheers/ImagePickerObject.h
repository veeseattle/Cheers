//
//  ImagePickerObject.h
//  Cheers
//
//  Created by Vania Kurniawati on 4/9/15.
//  Copyright (c) 2015 Vania Kurniawati. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ImagePickerDelegate;

@interface ImagePickerObject : NSObject

@property (nonatomic, weak) id<ImagePickerDelegate> delegate;
- (void)presentFromRect:(CGRect)rect inView:(UIView *)view;
- (void)presentWithViewController:(UIViewController *)viewController;

@end

@protocol ImagePickerDelegate

- (void)imagePicker:(ImagePickerObject *)imagePicker didSelectImage:(UIImage *)image;
- (void)imagePickerDidCancel:(ImagePickerObject *)imagePicker;


@end
