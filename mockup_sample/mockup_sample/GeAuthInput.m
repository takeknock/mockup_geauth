//
//  GeAuthInput.m
//  mockup_sample
//
//  Created by mmathew_43 on 13/08/23.
//  Copyright (c) 2013年 geauth. All rights reserved.
//

#import "GeAuthInput.h"

@implementation GeAuthInput

-(id)init {
    self = [super init];
    if(self != nil) {
        iLayer = 0;
        gCnt = 0;
        signupMode = false;
    }
    return self;
}

-(void)setOptions:(float)weight :(int)precision {
    dWeight = weight;
    iPrecision = precision;
}

-(void)initPath {
    pBezierPath[iLayer] = [UIBezierPath bezierPath];
    pBezierPath[iLayer].lineCapStyle = kCGLineCapRound;
    pBezierPath[iLayer].lineWidth = dWeight;
}

-(void)beginPath:(CGPoint)point {
    [pBezierPath[iLayer] moveToPoint:point];
}

-(BOOL)nextPath {
    iLayer++;
    if(iLayer<GESTURE_MAX) {
        return true;
    } else {
        iLayer = 0;
        return false;
    }
}

-(UIBezierPath*)nowPath {
    return pBezierPath[iLayer];
}

-(void)setPoint:(CGPoint)point {
    if(signupMode) {
        [pBezierPath[iLayer] addLineToPoint:point];
    } else
        [pBezierPath[gCnt] addLineToPoint:point];
}

-(void)setStartPoint:(CGPoint)point {
    if(signupMode) {
        ptStart[iLayer] = point;
    } else
        ptGStart[gCnt] = point;
}

-(void)setEndPoint:(CGPoint)point {
    if(signupMode) {
        ptEnd[iLayer] = point;
        [pBezierPath[iLayer] addLineToPoint:point];
    } else {
        ptGEnd[gCnt] = point;
        [pBezierPath[gCnt] addLineToPoint:point];
    }
}

-(UIBezierPath*)smoothing:(UIBezierPath*)path {
    // smoothing algorithm
    /*
     // スプライン補間とか使う
     */
    return path;
}

-(void)touchLogging:(CGPoint)point {
    NSString *str = [NSString stringWithFormat:@"%f,%f",point.x,point.y];
    NSLog(@"%@", str);
}

-(UIImage*)pathtoImage:(UIBezierPath*)path {
    CGFloat width = CANVAS_WIDTH;
    CGFloat height = CANVAS_HEIGHT;
    CGSize size = CGSizeMake(width, height);
    UIGraphicsBeginImageContext(size);
    [[UIColor blackColor] setStroke];
    [path setLineJoinStyle:kCGLineJoinRound];
    [path stroke];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    // pixelデータにするため、一度PNGにする
    NSData *data = [[NSData alloc]initWithData:UIImagePNGRepresentation(viewImage)];
    UIImage* result = [[UIImage alloc] initWithData:data];
    
    return result;
}

-(void)saveLayer:(UIImage*)image {
    pLayer[iLayer]=image;
    CGImageRef imageRef = image.CGImage;
    size_t width  = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    size_t bytesPerRow = CGImageGetBytesPerRow(imageRef);
    CGDataProviderRef dataProvider = CGImageGetDataProvider(imageRef);
    CFDataRef data = CGDataProviderCopyData(dataProvider);
    UInt8* buffer = (UInt8*)CFDataGetBytePtr(data);
    UInt8* tmp;
    
    NSUInteger  x, y;
    for (y = 0; y < height; y++) {
        for (x = 0; x < width; x++) {
            tmp = buffer + y * bytesPerRow + x * 4;
            UInt8 red,green,blue,alpha;
            red = *(tmp + 0);
            green = *(tmp + 1);
            blue = *(tmp + 2);
            alpha = *(tmp + 3);
            arLayer[iLayer][x][y]=255-alpha;
        }
    }
}

-(UIImage*)thinning:(UIImage*)anImage {
    // 細線化アルゴリズム関数
    /*
     CGImageRef imageRef = anImage.CGImage;
     size_t width  = CGImageGetWidth(imageRef);
     size_t height = CGImageGetHeight(imageRef);
     size_t bitsPerComponent = CGImageGetBitsPerComponent(imageRef);
     size_t bitsPerPixel = CGImageGetBitsPerPixel(imageRef);
     size_t bytesPerRow = CGImageGetBytesPerRow(imageRef);
     CGColorSpaceRef colorSpace = CGImageGetColorSpace(imageRef);
     CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
     bool shouldInterpolate = CGImageGetShouldInterpolate(imageRef);
     CGColorRenderingIntent intent = CGImageGetRenderingIntent(imageRef);
     CGDataProviderRef dataProvider = CGImageGetDataProvider(imageRef);
     CFDataRef data = CGDataProviderCopyData(dataProvider);
     UInt8* buffer = (UInt8*)CFDataGetBytePtr(data);
     UInt8* tmp;
     
     UInt8 array[CANVAS_WIDTH][CANVAS_HEIGHT];
     UInt8 array2[CANVAS_WIDTH][CANVAS_HEIGHT];
     NSUInteger  x, y;
     for (y = 0; y < height; y++) {
     for (x = 0; x < width; x++) {
     tmp = buffer + y * bytesPerRow + x * 4;
     UInt8 red,green,blue,alpha;
     red = *(tmp + 0);
     green = *(tmp + 1);
     blue = *(tmp + 2);
     alpha = *(tmp + 3);
     array[x][y]=(255-alpha)/255;
     array2[x][y]=255-alpha;
     }
     }
     
     // Zhang Suen Thinning Algorithm（ちゃんと動作していない気がする）
     for(int iter=0;iter<2;iter++) {
     for(int i=1; i < height-1; i++) {
     for(int j=1; j < width-1; j++) {
     NSInteger p2 = array[i-1][j];
     NSInteger p3 = array[i-1][j+1];
     NSInteger p4 = array[i][j+1];
     NSInteger p5 = array[i+1][j+1];
     NSInteger p6 = array[i+1][j];
     NSInteger p7 = array[i+1][j-1];
     NSInteger p8 = array[i][j-1];
     NSInteger p9 = array[i-1][j-1];
     
     int A  = (p2 == 0 && p3 == 1) + (p3 == 0 && p4 == 1) +
     (p4 == 0 && p5 == 1) + (p5 == 0 && p6 == 1) +
     (p6 == 0 && p7 == 1) + (p7 == 0 && p8 == 1) +
     (p8 == 0 && p9 == 1) + (p9 == 0 && p2 == 1);
     int B  = p2 + p3 + p4 + p5 + p6 + p7 + p8 + p9;
     int m1 = iter == 0 ? (p2 * p4 * p6) : (p2 * p4 * p8);
     int m2 = iter == 0 ? (p4 * p6 * p8) : (p2 * p6 * p8);
     
     if (A == 1 && (B >= 2 && B <= 6) && m1 == 0 && m2 == 0)
     array[i][j] = 1;
     }
     }
     }
     
     for (y = 0; y < height; y++) {
     for (x = 0; x < width; x++) {
     tmp = buffer + y * bytesPerRow + x * 4;
     UInt8 col = array[x][y]*255;
     *(tmp + 0) = col;
     *(tmp + 1) = col;
     *(tmp + 2) = array2[x][y];
     *(tmp + 3) = 255;
     }
     }
     
     CFDataRef effectedData;
     effectedData = CFDataCreate(NULL, buffer, CFDataGetLength(data));
     CGDataProviderRef effectedDataProvider;
     effectedDataProvider = CGDataProviderCreateWithCFData(effectedData);
     CGImageRef effectedCgImage;
     UIImage* effectedImage;
     effectedCgImage = CGImageCreate(
     width, height,
     bitsPerComponent, bitsPerPixel, bytesPerRow,
     colorSpace, bitmapInfo, effectedDataProvider,
     NULL, shouldInterpolate, intent);
     effectedImage = [[UIImage alloc] initWithCGImage:effectedCgImage];
     
     // release
     CGImageRelease(effectedCgImage);
     CFRelease(effectedDataProvider);
     CFRelease(effectedData);
     CFRelease(data);
     
     return effectedImage;
     */
    return anImage;
}

-(UIImage*)testFunc:(UIImage*)anImage {
    CGImageRef imageRef = anImage.CGImage;
    size_t width  = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    size_t bitsPerComponent = CGImageGetBitsPerComponent(imageRef);
    size_t bitsPerPixel = CGImageGetBitsPerPixel(imageRef);
    size_t bytesPerRow = CGImageGetBytesPerRow(imageRef);
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(imageRef);
    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
    bool shouldInterpolate = CGImageGetShouldInterpolate(imageRef);
    CGColorRenderingIntent intent = CGImageGetRenderingIntent(imageRef);
    CGDataProviderRef dataProvider = CGImageGetDataProvider(imageRef);
    CFDataRef data = CGDataProviderCopyData(dataProvider);
    UInt8* buffer = (UInt8*)CFDataGetBytePtr(data);
    UInt8* tmp;
    
    NSUInteger  x, y;
    for (y = 0; y < height; y++) {
        for (x = 0; x < width; x++) {
            tmp = buffer + y * bytesPerRow + x * 4;
            UInt8 red,green,blue,alpha;
            red = *(tmp + 0);
            green = *(tmp + 1);
            blue = *(tmp + 2);
            alpha = *(tmp + 3);
            *(tmp + 0) = 0;
            *(tmp + 1) = 0;
            *(tmp + 2) = alpha;
            *(tmp + 3) = 100;
        }
    }
    
    CFDataRef effectedData;
    effectedData = CFDataCreate(NULL, buffer, CFDataGetLength(data));
    CGDataProviderRef effectedDataProvider;
    effectedDataProvider = CGDataProviderCreateWithCFData(effectedData);
    CGImageRef effectedCgImage;
    UIImage* effectedImage;
    effectedCgImage = CGImageCreate(
                                    width, height,
                                    bitsPerComponent, bitsPerPixel, bytesPerRow,
                                    colorSpace, bitmapInfo, effectedDataProvider,
                                    NULL, shouldInterpolate, intent);
    effectedImage = [[UIImage alloc] initWithCGImage:effectedCgImage];
    
    // release
    CGImageRelease(effectedCgImage);
    CFRelease(effectedDataProvider);
    CFRelease(effectedData);
    CFRelease(data);
    return effectedImage;
    return anImage;
}

-(Boolean)setMode:(Boolean)mode {
    signupMode = mode;
    return signupMode;
}

-(void)initInData {
    iLayer = 0;
}

-(void)initGesData {
    gCnt = 0;
}

-(Boolean)checkAuth {
/*    if(iLayer!=gCnt)
        return false;
*/
    int err=0;
    for(int i=0;i<1;i++) {
        // ジェスチャーなぞれてるか判定
//        err+=[self check: pLayer[i]:pGLayer[i]];
        // 開始・終着点の誤差距離算出
        // 値が20程度の誤差まで許容すべき
	    float sx = ptStart[i].x - ptGStart[i].x;
        float sy = ptStart[i].y - ptGStart[i].y;
        float ex = ptEnd[i].x - ptGEnd[i].x;
        float ey = ptEnd[i].y - ptGEnd[i].y;
        float fLng = (sqrt(sx*sx+sy*sy)+sqrt(ex*ex+ey*ey)) /2;
        if(fLng>GESTURE_PTERR) {
            err++;
            NSLog(@"開始とかがずれた");
        }
    }
    // 判定
    if(err!=0) {
        NSLog(@"開始とかがずれた-%d",err);
        return false;
    }
    else
        return true;
}

-(Boolean)check:(UIImage*)anImage :(UIImage*)anImage2 {
    CGImageRef imageRef = anImage.CGImage;
    CGImageRef imageRef2 = anImage2.CGImage;

    size_t width  = CGImageGetWidth(imageRef);
    size_t height = CGImageGetHeight(imageRef);
    size_t bytesPerRow = CGImageGetBytesPerRow(imageRef);
    CGDataProviderRef dataProvider = CGImageGetDataProvider(imageRef);
    CGDataProviderRef dataProvider2 = CGImageGetDataProvider(imageRef2);
    CFDataRef data = CGDataProviderCopyData(dataProvider);
    CFDataRef data2 = CGDataProviderCopyData(dataProvider2);
    UInt8* buffer = (UInt8*)CFDataGetBytePtr(data);
    UInt8* buffer2 = (UInt8*)CFDataGetBytePtr(data2);
    UInt8* tmp;
    
    UInt8 array[CANVAS_WIDTH][CANVAS_HEIGHT];
    UInt8 array2[CANVAS_WIDTH][CANVAS_HEIGHT];
    UInt8 array3[CANVAS_WIDTH][CANVAS_HEIGHT];
    NSUInteger  x, y;
    
    // 現在の線分データを配列に格納
    for (y = 0; y < height; y++) {
        for (x = 0; x < width; x++) {
            tmp = buffer + y * bytesPerRow + x * 4;
            UInt8 red,green,blue,alpha;
            red = *(tmp + 0);
            green = *(tmp + 1);
            blue = *(tmp + 2);
            alpha = *(tmp + 3);
            array[x][y]=255-alpha;
        }
    }
    // 現在の線分データを配列に格納
    for (y = 0; y < height; y++) {
        for (x = 0; x < width; x++) {
            tmp = buffer2 + y * bytesPerRow + x * 4;
            UInt8 red,green,blue,alpha;
            red = *(tmp + 0);
            green = *(tmp + 1);
            blue = *(tmp + 2);
            alpha = *(tmp + 3);
            array2[x][y]=255-alpha;
        }
    }
    
    // 線分データ照合
    int cnt=0;
    for (y = 0; y < height; y++) {
        for (x = 0; x < width; x++) {
            // 二値化
            if(array[x][y]!=255) array[x][y]=0;
            array3[x][y]=(array[x][y]+array2[x][y])/2;
            // 念のためにもう一度二値化
            if(array3[x][y]!=255) array3[x][y]=0;
            // pixelが異なる場合は誤差カウンタをインクリメント
            if(array3[x][y]!=array[x][y]) cnt++;
        }
    }
    // release
    CFRelease(data);

    // 判定
    if(cnt>GESTURE_LNERR) {
        return false;
    } else {
        return true;
    }
    
    return false;
}

@end

