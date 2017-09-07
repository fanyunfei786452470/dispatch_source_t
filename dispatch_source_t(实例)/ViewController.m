//
//  ViewController.m
//  dispatch_source_t(实例)
//
//  Created by 范云飞 on 2017/8/30.
//  Copyright © 2017年 范云飞. All rights reserved.
//

#import "ViewController.h"

#import "dispatch_source_t_VC.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton * button = [[UIButton alloc]init];
    button.frame = CGRectMake(100, 100, 100, 30);
    button.backgroundColor = [UIColor blackColor];
    [self.view addSubview:button];
    
    [button addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];

}

- (void)click:(UIButton *)button{
    dispatch_source_t_VC * source_t_VC = [[dispatch_source_t_VC alloc]init];
    [self.navigationController pushViewController:source_t_VC animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
