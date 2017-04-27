//
//  NSTimer+Addition.h
//  EDate_V3
//
//  Created by Wcg on 2017/4/22.
//  Copyright © 2017年 吴朝刚. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSTimer (Addition)
//关闭定时器
- (void)pauseTimer;
//启动定时器
- (void)resumeTimer;
//添加一个定时器
- (void)resumeTimerAfterTimeInterval:(NSTimeInterval)interval;
@end
