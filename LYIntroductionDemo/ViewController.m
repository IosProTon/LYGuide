//
//  ViewController.m
//  LYIntroductionDemo
//
//  Created by 李尧 on 2016/10/29.
//  Copyright © 2016年 ryanleely. All rights reserved.
//

#import "ViewController.h"
#import "LYGuide.h"
#import "LYGuideConfig.h"

@interface ViewController ()
@property (strong, nonatomic) IBOutlet UIButton *button1;
@property (strong, nonatomic) IBOutlet UIButton *button2;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated{
    /* Set property to customize your introduction tutorial && Each property has default value.So it's OK if don't set any property.
     */
//    [[LYGuide defaultConfig] setBorderColor:[UIColor redColor]];
//    [[LYGuide defaultConfig] setCornerRadius:20.f];
//    [[LYGuide defaultConfig] setBorderScale:1.8f];
//    [[LYGuide defaultConfig] setFont:[UIFont fontWithName:@"GillSans-BoldItalic" size:17]];
//    [[LYGuide defaultConfig] setTextColor:[UIColor redColor]];
    [self registerGuides];
}
- (IBAction)button1Pressed:(UIButton *)sender {
    [self guide];
}

- (IBAction)button2Pressed:(UIButton *)sender {
    [LYGuide showNextFrom:self];
}

- (void)registerGuides {
    LYGuide *g1 = [LYGuide guideWithText:@"Test1" target:self.button2.ly_absolute_frame handler:^(LYGuide *guide, BOOL onHint) {
        if(onHint){
            [guide dismiss];  //Dissmiss the introduction tutorial
            NSLog(@"Tap on hint");
        }else{
            NSLog(@"Not Tap on hint");
        }
        
    }];
    
    LYGuide *g2 = [LYGuide guideWithText:@"Test2" target:self.button2.ly_absolute_frame handler:^(LYGuide *guide, BOOL onHint) {
        if(onHint){
            [guide dismiss];  //Dissmiss the introduction tutorial
            NSLog(@"Tap on hint");
        }else{
            NSLog(@"Not Tap on hint");
        }
        
    }];
    
    LYGuide *g3 = [LYGuide guideWithText:@"Test3:This is an self-adaptaion guide text. Please tap the button \"guides\". This is an self-adaptaion guide text. Please tap the button \"guides\". This is an self-adaptaion guide text. Please tap the button \"guides\"." target:self.button2.ly_absolute_frame handler:^(LYGuide *guide, BOOL onHint) {
        if(onHint){
            [guide dismiss];  //Dissmiss the introduction tutorial
            NSLog(@"Tap on hint");
        }else{
            NSLog(@"Not Tap on hint");
        }
        
    }];
    [LYGuide registerGuides:[NSArray arrayWithObjects:g1,g2,g3,nil] from:self completion:^(BOOL finished){
        NSLog(@"Guides Finished");
    }];
}


- (void)guide {
    [[LYGuide guideWithText:@"Test" target:self.button1.ly_absolute_frame handler:^(LYGuide *guide, BOOL onHint) {
        if(onHint){
            [guide dismiss];  //Dissmiss the introduction tutorial
            NSLog(@"Tap on hint");
        }else{
            NSLog(@"Not Tap on hint");
        }
    }] show];
 
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
