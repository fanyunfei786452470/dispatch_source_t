//
//  dispatch_source_t_VC.m
//  dispatch_source_t(实例)
//
//  Created by 范云飞 on 2017/8/30.
//  Copyright © 2017年 范云飞. All rights reserved.
//

#import "dispatch_source_t_VC.h"


@interface dispatch_source_t_VC ()

@end

static dispatch_source_t_VC * source_t_VC = nil;
NSInteger timeoutCount = 0;/* 用于超时计数 */
NSInteger timeoutLength = 20;/* 设定20为超时的长度 */
float timeInterval = 0.1;/* 时间间隔 */
BOOL isFinish = NO;/* 结束任务完成的标志 */

@implementation dispatch_source_t_VC

dispatch_queue_t timerQueue;
dispatch_source_t Timer;
dispatch_source_t CreateDispatchTimer(uint64_t interval,
                                      uint64_t leeway,
                                      dispatch_queue_t queue,
                                      dispatch_block_t block)
{
    if (!Timer) {
        Timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER,
                                       0,
                                       0,
                                       queue
                                       );
        if (Timer) {
            dispatch_source_set_timer(Timer,
                                      dispatch_walltime(NULL, 0),
                                      interval,
                                      leeway
                                      );
            dispatch_source_set_event_handler(Timer, block);
            dispatch_resume(Timer);
        }
        
    }
    return Timer;
}

+ (void) MyCreateTimerInterval:(float) timeInterval Block:(dispatch_block_t)block
{
    if (!timerQueue) {
        timerQueue = dispatch_queue_create("timeout queue", DISPATCH_QUEUE_SERIAL);
        dispatch_source_t timer = CreateDispatchTimer(timeInterval * NSEC_PER_SEC,
                                                      1ull * NSEC_PER_SEC,
                                                      timerQueue,
                                                      block
                                                      );
        if (timer) {
            NSLog(@"creating a timeout queue is ok");
        }
    }
}

+ (dispatch_source_t_VC *)shareSource{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        source_t_VC = [[dispatch_source_t_VC alloc]init];
    });
    return source_t_VC;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"dispatch_source_t_VC";
    self.view.backgroundColor = [UIColor whiteColor];
    [self createTimer_DispatchSource];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


/* 创建一个定时器 dispatch source */
- (void)createTimer_DispatchSource{
    dispatch_async(dispatch_queue_create("time_out_control", DISPATCH_QUEUE_SERIAL), ^{
        [dispatch_source_t_VC MyCreateTimerInterval: timeInterval Block:^{
            [self checkTimeOut];
        }];
        [self TimeConsumingTasks];
    });
    
    while (!isFinish) {
        if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
            break;
        }
        else{
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"***********timeoutCount:%ld*********",timeoutCount);
        NSLog(@"***********timeoutCount * timeInterval:%f*********",timeoutCount * timeInterval);
        NSLog(@"***********%@*********",@"到此为止");
    });
    
}

/* 耗时方法 */
- (void)TimeConsumingTasks{
    
    for (int i = 0; i < 1000 ; i++) {
        NSLog(@"***********%@ %d*********",@"执行任务中",i);
        if (timeoutCount * timeInterval >= timeoutLength) {
            break;
        }
    }
    
    /* 此处唤醒 run loop */
    if(isFinish == 0)
    {
        [[dispatch_source_t_VC shareSource] stopTimer];
        [self performSelectorOnMainThread:@selector(endRunLoop) withObject:nil waitUntilDone:NO];
    }
    
}

/* 检查超时的方法 */
- (void)checkTimeOut{
    timeoutCount ++;
    if (timeoutCount * timeInterval >= timeoutLength) {
        NSLog(@"***********%@*********",@"你大爷的已经超时了");
        [[dispatch_source_t_VC shareSource] stopTimer];
        return;
    }
}

/* 注销 Timer */

- (void)stopTimer{
    NSCondition* Condition = [[NSCondition alloc] init];
    [Condition lock];
    {
        if (Timer) {
            dispatch_source_set_cancel_handler(Timer, ^{
            });
            dispatch_source_cancel(Timer);
            Timer = NULL;
            {
                if (timerQueue) {
                    Timer = NULL;
                    timerQueue = NULL;
                }
            }
        }
    }
    [Condition unlock];
    [[dispatch_source_t_VC shareSource] endRunLoop];
}

/* 结束roonloop 的跑圈 */
- (void)endRunLoop{
    isFinish = YES;
}

@end
