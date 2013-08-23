//
//  ViewController.m
//  mockup_sample
//
//  Created by mmathew_43 on 13/08/23.
//  Copyright (c) 2013年 geauth. All rights reserved.
//

#import "ViewController.h"
#import "GeAuthInput.h"
#import "AuthedViewController.h"

@interface ViewController (){
    UIBezierPath *pBezierPath;
    UIImage *pDrawImage;
    id input;
    int wg;
}
@end

@implementation ViewController

- (void)drawLine:(UIBezierPath*)path
{
    // draw to canvas
    pDrawImage = [input pathtoImage: [input nowPath]];
    self.canvas.image = [input thinning: pDrawImage];
    UIGraphicsEndImageContext();
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.canvas];
    
    [input setOptions:wg :90];
    
    // initalize path
    [input initPath];
    [input beginPath:point];
    // set point
    [input setStartPoint:point];
    // print to console
    [input touchLogging:point];
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.canvas];
    // set point
    [input setPoint:point];
    // print to console
    [input touchLogging:point];
    
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.canvas];
    // set point
    [input setEndPoint:point];
    // print to console
    [input touchLogging:point];
    
    pDrawImage = [input pathtoImage: [input nowPath]];
    [input saveLayer:pDrawImage];
    
    
    
    // next gesture layer
    [input nextPath];
    
    if(wg==1)
        wg=50;
}

//フォトライブラリ開く
-(IBAction)tapPictureBtn
{
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
    {
        UIImagePickerController* imagePicker = [UIImagePickerController new];
        
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.delegate = self;
        
        [self presentViewController:imagePicker animated:YES completion:^{
            NSLog(@"フォトライブラリ開いた");
        }];
    }
}

//サムネイル選択後
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage* selectedImage = (UIImage *)[info objectForKey:UIImagePickerControllerOriginalImage];
    self.back_image.image = selectedImage;
    [self dismissViewControllerAnimated:YES completion:^{
    }];
}

-(IBAction)tapGestureBtn
{
   

}

-(IBAction)tapAuthBtn
{
    NSLog(@"認証開始");
    // check auth
    
    [self drawLine:[input nowPath]];
    Boolean auth=[input check:pDrawImage];
    pDrawImage = [input testFunc:pDrawImage];
    self.canvas.image = pDrawImage;
    
    if(auth)
        //        self.msg.text = @"OK";
        //次の画面に移動．認証できました！とか表示されてる単純な画面．戻るボタンとかあったらいいね！
    
        else
            //アラート出力．「認証できませんでした．もう一度ジェスチャーをお願いします．」
            
            //いろいろリセット．画面再読み込み．
            //        self.msg.text = @"NG";
            AuthedViewController *second = [[AuthedViewController alloc] initWithNibName:@"AuthedViewController" bundle:nil];
    [self presentViewController:second animated:NO completion:nil];
            UIGraphicsEndImageContext();
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    input = [GeAuthInput alloc];
    
    wg=1;
    [input setOptions:wg :90];
    UIImage *image = [UIImage imageNamed:@"test.jpg"];
    self.back_image.image = [input thinning: image];
    UIGraphicsEndImageContext();
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
