//
//  GeAuthInput.h
//  mockup_sample
//
//  Created by mmathew_43 on 13/08/23.
//  Copyright (c) 2013年 geauth. All rights reserved.
//

#import <Foundation/Foundation.h>

#define GESTURE_PTERR 40 // 開始・終着点での許容誤差
#define GESTURE_LNERR 150 // ジェスチャーのずれ誤差
#define GESTURE_MAX 16
#define CANVAS_WIDTH 320
#define CANVAS_HEIGHT 320

@protocol GeAuth <NSObject>
@end

@interface GeAuthInput : NSObject <GeAuth>
//variable
{
    int iLayer;
    double dWeight;
    int iPrecision;
    UIBezierPath *pBezierPath[GESTURE_MAX];
    UIImage *pLayer[GESTURE_MAX];
    UInt8 arLayer[GESTURE_MAX][CANVAS_WIDTH][CANVAS_HEIGHT];
    CGPoint ptStart[GESTURE_MAX], ptEnd[GESTURE_MAX];
    NSInteger tmp_pixels[CANVAS_WIDTH][CANVAS_HEIGHT];

}

//function
-(id)init;
-(void)setOptions:(float)weight :(int)precision;
-(void)initPath;
-(void)beginPath:(CGPoint)point;
-(BOOL)nextPath;
-(UIBezierPath*)nowPath;
-(UIBezierPath*)smoothing:(UIBezierPath*)path;
-(void)setPoint:(CGPoint)point;
-(void)setStartPoint:(CGPoint)point;
-(void)setEndPoint:(CGPoint)point;
-(void)touchLogging:(CGPoint)point;
-(UIImage*)pathtoImage:(UIBezierPath*)path;
-(void)saveLayer:(UIImage*)image;
-(UIImage*)thinning:(UIImage*)img;
-(Boolean)check:(UIImage*)img;

-(UIImage*)testFunc:(UIImage*)img;


@end
