//
//  DrawSample.m
//  DrawSample
//
//  Created by cano on 2013/12/02.
//  Copyright (c) 2013年 cano. All rights reserved.
//

#import "DrawSample.h"

@implementation DrawSample

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _paths = [NSMutableArray array];
        _paths2 = [NSMutableArray array];
        _widthArray = [NSMutableArray array];
        
        pData = [PublicDatas instance];
        
        drawColor = [pData getDataForKey:@"color"];
        if(!drawColor) drawColor = [UIColor blackColor];
        [drawColor set];
    }
    return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    currentPath = [UIBezierPath bezierPath];
    currentPath.lineWidth = 3.0;
    UITouch *touch = [touches anyObject];
    [currentPath moveToPoint:[touch locationInView:self]];
    
    //NSLog(@"[begin _paths count] %lu",(unsigned long)[_paths count]);
    
    if([_paths count]==0){
        drawColor = [pData getDataForKey:@"color"];
        if(!drawColor) drawColor = [UIColor blackColor];
        [drawColor set];
    }
    
    [_paths addObject:currentPath];
    [_paths2 addObject:currentPath];
    
    NSString *val = [pData getDataForKey:@"width"];
    if(val!=nil){
    }else{
        val = @"10.0";
    }
    [_widthArray addObject:val];
    
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    //NSLog(@"touchs : %@", touches);
    UITouch *touch = [touches anyObject];
    [currentPath addLineToPoint:[touch locationInView:self]];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    //[[UIColor redColor] set];
    //UIColor *color = [pData getDataForKey:@"color"];
    //if(!color) color = [UIColor blackColor];
    //[color set];
    
    [drawColor set];
    
    //NSLog(@"[draw _paths count] %lu",(unsigned long)[_paths count]);
    int i = 0;
    for (UIBezierPath *path in _paths) {
        //NSLog(@"path : %@", path);
        float val = [[_widthArray objectAtIndex:i] floatValue];
        
        path.lineWidth = val;
        path.miterLimit=-10;
        path.lineCapStyle = kCGLineCapRound;
        path.lineJoinStyle = kCGLineJoinRound;
        [path stroke];
        i++;
    }
    /*
    [[UIColor blueColor] set];
    for (UIBezierPath *path in _paths2) {
        //NSLog(@"path : %@", path);
        path.lineWidth = 5;
        path.miterLimit=-10;
        [path stroke];
    }
     */
}


-(void)undoButtonClicked
{
    //NSLog(@"[_paths count] %lu",(unsigned long)[_paths count]);
    if([_paths count]>0){
        //UIBezierPath *_path=[_paths lastObject];
        //[bufferArray addObject:_path];
        [_paths removeLastObject];
        [self setNeedsDisplay];
    }
    //NSLog(@"[_paths count] %lu",(unsigned long)[_paths count]);
}

/*
-(void)redoButtonClicked
{
    if([bufferArray count]>0){
        UIBezierPath *_path=[bufferArray lastObject];
        [pathArray addObject:_path];
        [bufferArray removeLastObject];
        
        UIColor *_color = [bufferColorArray lastObject];
        [colorArray addObject:_color];
        [bufferColorArray removeLastObject];
        
        [self setNeedsDisplay];
    }
}
 */


/*
- (void)drawRect:(CGRect)rect {
    NSLog(@"drawrect");
    
    [[UIColor redColor] set];
    for (UIBezierPath *path in paths) {
        //NSLog(@"path : %@", path);
        [path stroke];
        path.usesEvenOddFillRule = NO;
        
        self.lineShapeBorder = [[CAShapeLayer alloc] init];
        //self.lineShapeBorder.zPosition = 0.0f;
        self.lineShapeBorder.strokeColor = [UIColor blueColor].CGColor;
        self.lineShapeBorder.lineWidth = 10;
        self.lineShapeBorder.lineCap = kCALineCapRound;
        self.lineShapeBorder.lineJoin = kCALineJoinRound;
        
        
        self.lineShapeFill = [[CAShapeLayer alloc] init];
        [self.lineShapeBorder addSublayer:self.lineShapeFill];
        self.lineShapeFill.zPosition = 0.0f;
        self.lineShapeFill.strokeColor = [UIColor greenColor].CGColor;
        self.lineShapeFill.lineWidth = 5.0f;
        self.lineShapeFill.lineCap = kCALineCapRound;
        self.lineShapeFill.lineJoin = kCALineJoinRound;
        
        // ...
        
        //UIBezierPath *_path = [UIBezierPath bezierPath];
        //[_path moveToPoint:CGPointMake(100, 100)];
        //[_path addLineToPoint:CGPointMake(200, 200)];
        self.lineShapeBorder.path = self.lineShapeFill.path = path.CGPath;
        
        //[path strokeWithBlendMode:kCGBlendModeMultiply alpha:1.0];
        
        [[self layer] addSublayer:self.lineShapeBorder];
        //[[self layer] addSublayer:self.lineShapeFill];
        
        
    }
}
*/

/*
 self.lineShapeBorder = [[CAShapeLayer alloc] init];
 self.lineShapeBorder.zPosition = 0.0f;
 self.lineShapeBorder.strokeColor = [UIColor blueColor].CGColor;
 self.lineShapeBorder.lineWidth = 25;
 self.lineShapeBorder.lineCap = kCALineCapRound;
 self.lineShapeBorder.lineJoin = kCALineJoinRound;
 
 self.lineShapeFill = [[CAShapeLayer alloc] init];
 [self.lineShapeBorder addSublayer:self.lineShapeFill];
 self.lineShapeFill.zPosition = 0.0f;
 self.lineShapeFill.strokeColor = [UIColor greenColor].CGColor;
 self.lineShapeFill.lineWidth = 20.0f;
 self.lineShapeFill.lineCap = kCALineCapRound;
 self.lineShapeFill.lineJoin = kCALineJoinRound;
 
 // ...
 
 UIBezierPath *_path = [UIBezierPath bezierPath];
 [_path moveToPoint:CGPointMake(100, 100)];
 [_path addLineToPoint:CGPointMake(200, 200)];
 self.lineShapeBorder.path = self.lineShapeFill.path = _path.CGPath;
 
 [[self.view layer] addSublayer:self.lineShapeBorder];
 [[self.view layer] addSublayer:self.lineShapeBorder];
 */

/*
- (void)drawRect:(CGRect)rect
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint: CGPointMake(63.5, 10.5)];
    [path addLineToPoint: CGPointMake(4.72, 119.5)];
    [path addLineToPoint: CGPointMake(122.28, 119.5)];
    [path addLineToPoint: CGPointMake(63.5, 10.5)];
    [path closePath];
    path.miterLimit = 7;
 
    path.lineCapStyle = kCGLineCapRound;
 
    path.lineJoinStyle = kCGLineJoinRound;
    path.lineWidth = 20;
 
 
    UIColor *whiteAlph5 = [UIColor colorWithWhite:0.6 alpha:0.5];
 
    [whiteAlph5 setFill];
    [whiteAlph5 setStroke];
 
 
    [path fill];
    [path stroke];
}
*/

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
