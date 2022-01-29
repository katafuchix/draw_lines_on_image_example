//
//  DrawSample.h
//  DrawSample
//
//  Created by cano on 2013/12/02.
//  Copyright (c) 2013年 cano. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PublicDatas.h"

@interface DrawSample : UIView
{
    UIImageView *canvas;
    CGPoint touchPoint;
    UIBezierPath *currentPath;
    //NSMutableArray *paths;
    //NSMutableArray *paths2
    
    PublicDatas *pData;
    
    UIColor *drawColor;
}

@property CAShapeLayer *lineShapeBorder;
@property CAShapeLayer *lineShapeFill;

@property (strong, nonatomic) NSMutableArray *paths;
@property (strong, nonatomic) NSMutableArray *paths2;
@property (strong, nonatomic) NSMutableArray *widthArray;

-(void)undoButtonClicked;
//-(void)redoButtonClicked;

@end
