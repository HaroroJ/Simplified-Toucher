//
//  MQDrawView.m
//  simplifiedToucher
//
//  Created by yons on 16/3/10.
//  Copyright © 2016年 moreChinese. All rights reserved.
//

#import "MQDrawView.h"
#import "MQBaseLine.h"

@interface MQDrawView ()<UIGestureRecognizerDelegate>

@property (strong, nonatomic) NSMutableArray *doneLines;
//@property (strong, nonatomic) MQBaseLine *line;
@property (strong, nonatomic) NSMutableDictionary *currentLines;
@property (strong, nonatomic) UIPanGestureRecognizer *moveRecognizer;

@property (strong, nonatomic) NSMutableArray *donePoints;

@property (weak, nonatomic) MQBaseLine *selectedLine;

@end


@implementation MQDrawView


-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        self.backgroundColor = [UIColor colorWithRed:255/255.0 green:200/255.0 blue:255/255.0 alpha:0.2];
        self.doneLines = [NSMutableArray array];
        self.currentLines = [NSMutableDictionary dictionary];
        
        self.multipleTouchEnabled = YES;
        
        //双击手势,清除所有线条
        UITapGestureRecognizer *doubleTapRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(cleanScreen)];
        doubleTapRecognizer.numberOfTapsRequired = 2;
        
        [self addGestureRecognizer:doubleTapRecognizer];
        
        //单机选中手势，选中画线
        UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tap:)];
        
        tapRecognizer.delaysTouchesBegan = YES;
        [tapRecognizer requireGestureRecognizerToFail:doubleTapRecognizer];
        
        [self addGestureRecognizer:tapRecognizer];
        
        //长按手势选中线条
        UILongPressGestureRecognizer *pressRrecgnizer = [[UILongPressGestureRecognizer alloc]initWithTarget:self action:@selector(longPress:)];
        
        [self addGestureRecognizer:pressRrecgnizer];
        
        self.moveRecognizer = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(moveLine:)];
        self.moveRecognizer.delegate = self;
        self.moveRecognizer.cancelsTouchesInView = NO;
        [self addGestureRecognizer:self.moveRecognizer];
        
    }
    
    return self;
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(nonnull UIGestureRecognizer *)otherGestureRecognizer
{
    if (gestureRecognizer == self.moveRecognizer) {
        return YES;
    }
    
    return NO;
}

-(void)moveLine:(UIPanGestureRecognizer *)gr{
    if (!self.selectedLine) {
        return ;
    }
    if (gr.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [gr translationInView:self];
        
        CGPoint begin = self.selectedLine.begin;
        CGPoint end = self.selectedLine.end;
        begin.x += translation.x;
        begin.y += translation.y;
        end.x += translation.x;
        end.y += translation.y;
        
        self.selectedLine.begin = begin;
        self.selectedLine.end = end;
        
//        MQBaseLine *line = (MQBaseLine *)[UIBezierPath bezierPathWithCGPath:self.selectedLine.CGPath];
//        [self.selectedLine moveToPoint:point];
//        [self.selectedLine addLineToPoint:end];
        
//        [gr setTranslation:CGPointZero inView:self];
    }
    
    [self setNeedsDisplay];
    
    [gr setTranslation:CGPointZero inView:self];
}

-(void)longPress:(UIGestureRecognizer *)gr
{
    if (gr.state == UIGestureRecognizerStateBegan) {
        CGPoint point = [gr locationInView:self];
        self.selectedLine = [self lineAtPoint:point];
        
        if (self.selectedLine) {
            [self.currentLines removeAllObjects];
        }
    }else if (gr.state == UIGestureRecognizerStateEnded){
        
        self.selectedLine = nil;
        
    }
    [self setNeedsDisplay];
}

-(void)cleanScreen
{
    [self.doneLines removeAllObjects];
    
    [self setNeedsDisplay];
}

-(void)tap:(UIGestureRecognizer *)tapRecognizer
{
    
    CGPoint point = [tapRecognizer locationInView:self];
    
    self.selectedLine = [self lineAtPoint:point];
    
    if (self.selectedLine) {
        [self becomeFirstResponder];
        
        UIMenuController *menuController = [UIMenuController sharedMenuController];
        
        UIMenuItem *deleteItem = [[UIMenuItem alloc] initWithTitle:@"delete" action:@selector(deleteLine)];
        
        menuController.menuItems = @[deleteItem];
        
        [menuController setTargetRect:CGRectMake(point.x, point.y, 2, 2) inView:self];
        [menuController setMenuVisible:YES animated:YES];
    }else{
        [[UIMenuController sharedMenuController] setMenuVisible:NO animated:YES];
    }
    
    [self setNeedsDisplay];
}

-(void)deleteLine{
    
    [self.doneLines removeObject:self.selectedLine];
    
    [self setNeedsDisplay];
}

-(void)drawRect:(CGRect)rect
{
    
    [[UIColor blackColor] set];
    
    for (MQBaseLine *line in self.doneLines) {
        [self strokeLine:line];
//        [line stroke];
        }
    
    for (NSValue *key in self.currentLines) {
        [[UIColor redColor] set];
        [self strokeLine:self.currentLines[key]];
        
    }
        
    
    
    if (self.selectedLine) {
        [[UIColor greenColor] set];
       
        [self strokeLine:self.selectedLine];
        
    }
    
}

-(void)strokeLine:(MQBaseLine *)line
{
    UIBezierPath *bp = [UIBezierPath bezierPath];
    
    bp.lineWidth = 10;
    bp.lineCapStyle = kCGLineCapRound;
    
    [bp moveToPoint:line.begin];
    [bp addLineToPoint:line.end];
    
    [bp stroke];
}

-(BOOL)canBecomeFirstResponder
{
    return YES;
}


-(MQBaseLine *)lineAtPoint:(CGPoint)p
{
    for (MQBaseLine *line in self.doneLines) {
        CGPoint start =line.begin;
        CGPoint end = line.end;
        for (float t = 0.0; t<=1.0; t += 0.05) {
            float x = start.x + t*(end.x - start.x);
            float y = start.y + t*(end.y - start.y);
            
            if (hypot(x - p.x, y - p.y)<10) {
                return line;
            }
        }
        
        
        
        
//        if ([line containsPoint:P]) {
//            
//            NSLog(@"111111333");
//            
//            return line;
//            
//        }
    }
    return nil;
}




-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    if (!self.selectedLine) {
    
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInView:self];
        
//        MQBaseLine *line = [MQBaseLine baseLineWithPoint:location];
//        line.lineWidth = 15;
//        line.lineCapStyle = kCGLineCapRound;
        MQBaseLine *line = [[MQBaseLine alloc]init];
        
        line.begin = location;
        line.end = location;
        
//        [line moveToPoint:location];
        
        NSValue *key = [NSValue valueWithNonretainedObject:touch];
        self.currentLines[key] = line;
        
    }
    
//    UITouch *touch = [touches anyObject];
    
    [self setNeedsDisplay];
    }
}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    
//    UITouch *touch = [touches anyObject];
    NSLog(@"%@",NSStringFromSelector(_cmd));
    if (!self.selectedLine) {
        for (UITouch *touch in touches) {
            NSValue *key = [NSValue valueWithNonretainedObject:touch];
            MQBaseLine *line = self.currentLines[key];
            
            CGPoint location = [touch locationInView:self];
            line.end = location;
            //        [line addLineToPoint:location];
        }
        
        //    CGPoint location = [touch locationInView:self];
        //    [self.line addLineToPoint:location];
        
        [self setNeedsDisplay];
    }
    
    
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    
    if (!self.selectedLine) {
    for (UITouch *touch in touches) {
        NSValue *key = [NSValue valueWithNonretainedObject:touch];
        
        MQBaseLine *line  = self.currentLines[key];
        
        [self.doneLines addObject:line];
        [self.currentLines removeObjectForKey:key];
        
    }
    
//    [self.doneLines addObject:self.line];
//    self.line = nil;
    
    [self setNeedsDisplay];
    }
}


@end
