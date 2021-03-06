//
//  LYGuideManager.h
//  LYIntroductionDemo
//
//  Created by 李尧 on 2016/11/3.
//  Copyright © 2016年 ryanleely. All rights reserved.
//

#import <Foundation/Foundation.h>
@class LYGuide;
typedef void (^LYGuidesCompletionBlock)(BOOL isCanceled);

@interface LYGuideManager : NSObject
+ (LYGuideManager *)shared;
- (BOOL)showNextFrom:(id)obj;
- (void)registerGuides:(NSArray<LYGuide *>*)guides
                  target:(Class)cls
            completion:(LYGuidesCompletionBlock)block;
@end
