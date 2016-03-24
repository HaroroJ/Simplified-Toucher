//
//  MQDrawViewController.m
//  simplifiedToucher
//
//  Created by yons on 16/3/10.
//  Copyright © 2016年 moreChinese. All rights reserved.
//

#import "MQDrawViewController.h"
#import "MQDrawView.h"

@interface MQDrawViewController ()
@property (strong, nonatomic) MQDrawView *drawView;
@end


@implementation MQDrawViewController

-(void)loadView
{
    
    _drawView = [[MQDrawView alloc]initWithFrame:CGRectZero];
    
    self.view = _drawView;
    
}


-(void)viewDidLoad
{
    
    UIButton *btn = [[UIButton alloc]initWithFrame:CGRectMake(150, 50, 75, 75)];
    
    
    btn.backgroundColor = [UIColor greenColor];
    [btn addTarget:self action:@selector(cleanScreen) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:btn];
    
}


-(void)cleanScreen
{
    
    [_drawView cleanScreen];
    
}

@end
