//
//  ViewController.h
//  mockup_sample
//
//  Created by mmathew_43 on 13/08/23.
//  Copyright (c) 2013年 geauth. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController<UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *canvas;
@property (weak, nonatomic) IBOutlet UIImageView *back_image;
@property IBOutlet UIImageView* imageView;

-(IBAction)tapPictureBtn;
-(IBAction)tapGestureBtn;
-(IBAction)tapAuthBtn;

@end
