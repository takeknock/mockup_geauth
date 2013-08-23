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
    int input_flag;
    int auth_input_flag;
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
    // exception
    if(point.y<0||point.y>320)
        return;
    
    if(input_flag) {
        [input setOptions:wg :90];
        // initalize path
        [input initPath];
        [input beginPath:point];
        // set point
        [input setStartPoint:point];

        // print to console
        [input touchLogging:point];
        
        [self drawLine:[input nowPath]];
    } else if(auth_input_flag) {
        [self drawLine:[input nowPath]];
    } else {
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.canvas];
    // exception
    if(point.y<0||point.y>320)
        return;

    if(input_flag) {
        // set point
        [input setPoint:point];
        // print to console
        [input touchLogging:point];

        [self drawLine:[input nowPath]];
    } else if(auth_input_flag) {
        [self drawLine:[input nowPath]];
    } else {
        
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.canvas];
    // exception
    if(point.y<0||point.y>320)
        return;

    if(input_flag) {
        // set point
        [input setEndPoint:point];
        // print to console
        [input touchLogging:point];
    
        pDrawImage = [input pathtoImage: [input nowPath]];
        [input saveLayer:pDrawImage];
    
        // next gesture layer
        Boolean res = [input nextPath];
        if(!res) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"GeAuth" message:@"ジェスチャー登録しました" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            // ボタンもオフにする
            input_flag = 0;
            [self.GestureButton setTitle:@"ジェスチャー登録" forState:UIControlStateNormal];
            auth_input_flag = 0;
            return;
        }
    } else if(auth_input_flag) {
        [self drawLine:[input nowPath]];
    } else {
        
    }
    self.canvas.image = nil;
    UIGraphicsEndImageContext();
}

//フォトライブラリ開く
-(IBAction)tapPictureBtn
{
    if(input_flag || auth_input_flag)
        return;
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
    input_flag=(input_flag+1)%2;
    //ボタンのラベルを変更
    if(input_flag){
        [input initGesData];
        [self.GestureButton setTitle:@"登録中..." forState:UIControlStateNormal];
        NSLog(@"%d",input_flag);
    }else{
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"GeAuth" message:@"ジェスチャー登録しました" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [self.GestureButton setTitle:@"ジェスチャー登録" forState:UIControlStateNormal];
        NSLog(@"%d",input_flag);
    }
}

-(IBAction)tapAuthBtn
{
    if(input_flag)
        return;
    NSLog(@"認証開始");
    [input setMode:0];
    if(auth_input_flag) {
        auth_input_flag = 0;
        // check auth
    
//        [self drawLine:[input nowPath]];

        Boolean auth=[input checkAuth];
        pDrawImage = [input testFunc:pDrawImage];
        self.canvas.image = pDrawImage;

        NSString *msg = [NSString alloc];
        if(auth) {
            //次の画面に移動．認証できました！とか表示されてる単純な画面．戻るボタンとかあったらいいね！
            NSLog(@"accept!");
            msg = @"err";
        } else {
            //アラート出力．「認証できませんでした．もう一度ジェスチャーをお願いします．」
            //いろいろリセット．画面再読み込み．
            NSLog(@"denied!");
            msg = @"err";
        }
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"GeAuth" message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    } else {
        [input initInData];
        auth_input_flag=1;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    input = [GeAuthInput alloc];
    
    wg=35;
    input_flag=0;
    auth_input_flag=0;
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
