//
//  ViewController.m
//  07-RunLoop
//
//  Created by Ammar on 15/7/11.
//  Copyright (c) 2015年 小码哥. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

/** GCD定时器 */
@property (strong, nonatomic) dispatch_source_t timer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

}

- (void)time
{
    NSLog(@"----");
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
//    // 需求:搞一个线程一直不死，一直在后台做一些操作 比如监听某个状态， 比如监听是否联网。
//    // 需要在线程中开启一个RunLoop 一个线程对应一个RunLoop 所以获得当前RunLoop就会自己创建RunLoop
//    NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(run) object:nil];
//    [thread start];
    
    static int count = 0;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 这句话的意思现在很好懂了
    });
    
    // GCD定时器
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    // 1.创建一个定时器源
    
    // 参1:类型定时器，参2:句柄 参3:mask传0 参4:队列  (注意:dispatch_source_t本质是OC对象，表示源)
    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    
    // 2.设置定时器的各种属性
        // 严谨起见，时间间隔需要用单位int64_t，做乘法以后单位就变了
    int64_t interval = (int64_t)(2.0 * NSEC_PER_SEC); // 回调函数时间间隔是多少
        // 如何设置开始时间 CGD给我们了一个设置时间的方法  参1:dispatch_time_t when 传一个时间， delta是增量
        // 注意:GCD中 时间的单位是:int64_t
    dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)); // 从现在3秒后开始
    
    // 参1:timer 参2:开始时间 参3:时间间隔 参4:传0 不需要   DISPATCH_TIME_NOW 表示现在 GCD时间用NS表示
    dispatch_source_set_timer(self.timer, start, interval, 0);
    
    
    // 3.设置回调(即每次间隔要做什么事情)
    dispatch_source_set_event_handler(self.timer, ^{
        NSLog(@"----------------%@", [NSThread currentThread]);
        
        // 如果希望做5次就停掉
        count++;
        if (count == 5) {
            dispatch_cancel(self.timer);
            self.timer = nil;
        }
    });
    
    // 4.启动定时器  (恢复)
    dispatch_resume(self.timer);
    
    
    
    
}

- (void)run
{
    NSLog(@"----------");
    // 创建RunLoop，如果RunLoop内部没有添加任何Source Timer Observer，会直接退出循环，因此需要自己添加一些source才能保持RunLoop运转
    [[NSRunLoop currentRunLoop] addPort:[NSPort port] forMode:NSDefaultRunLoopMode];
    [[NSRunLoop currentRunLoop] run];
    
    NSLog(@"-----------22222222");
}

- (void)gcdtimer
{
    static int count = 0;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        // 这句话的意思现在很好懂了
    });
    
    // GCD定时器
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    
    // 1.创建一个定时器源
    
    // 参1:类型定时器，参2:句柄 参3:mask传0 参4:队列  (注意:dispatch_source_t本质是OC对象，表示源)
    self.timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    
    // 2.设置定时器的各种属性
    // 严谨起见，时间间隔需要用单位int64_t，做乘法以后单位就变了
    int64_t interval = (int64_t)(2.0 * NSEC_PER_SEC); // 回调函数时间间隔是多少
    // 如何设置开始时间 CGD给我们了一个设置时间的方法  参1:dispatch_time_t when 传一个时间， delta是增量
    // 注意:GCD中 时间的单位是:int64_t
    dispatch_time_t start = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)); // 从现在3秒后开始
    
    // 参1:timer 参2:开始时间 参3:时间间隔 参4:传0 不需要   DISPATCH_TIME_NOW 表示现在 GCD时间用NS表示
    dispatch_source_set_timer(self.timer, start, interval, 0);
    
    
    // 3.设置回调(即每次间隔要做什么事情)
    dispatch_source_set_event_handler(self.timer, ^{
        NSLog(@"----------------%@", [NSThread currentThread]);
        
        // 如果希望做5次就停掉
        count++;
        if (count == 5) {
            dispatch_cancel(self.timer);
            self.timer = nil;
        }
    });
    
    // 4.启动定时器  (恢复)
    dispatch_resume(self.timer);
    
}

- (void)runLooptimer
{
    @autoreleasepool {
        // 需求 让定时器 在其他线程开启
        NSBlockOperation *block = [NSBlockOperation blockOperationWithBlock:^{
            
            // 这种方式创建的timer 必须手动添加到Runloop中去才会被调用
            NSTimer *timer = [NSTimer timerWithTimeInterval:2.0 target:self selector:@selector(time) userInfo:nil repeats:YES];
            [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
            // 同时让RunLoop跑起来
            [[NSRunLoop currentRunLoop] run];
        }];
        
        [[[NSOperationQueue alloc] init] addOperation:block];
    }
}

- (void)showImageView
{
    // 需求有时候，用户拖拽scrollView的时候，mode:UITrackingRunLoopMode，显示图片，如果图片很大，会渲染比较耗时，造成不好的体验，因此，设置当用户停止拖拽的时候再显示图片，进行延迟操作
    // 方法1：设置scrollView的delegate  当停止拖拽的时候做一些事情
    // 方法2：使用performSelector 设置模式为default模式 ，则显示图片这段代码只能在RunLoop切换模式之后执行
    [self.imageView performSelector:@selector(setImage:) withObject:[UIImage imageNamed:@"6478"] afterDelay:3.0 inModes:@[NSDefaultRunLoopMode]];
}


- (void)RunLoop
{
    // 获取当前的线程的RunLoop对象，注意RunLoop是懒加载，currentRunLoop时会自动创建对象
    
    [NSRunLoop currentRunLoop].currentMode; // 获取当前运行模式
    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    // 获取主线程的RunLoop对象
    [NSRunLoop mainRunLoop];
    
    NSTimer *timer = [[NSTimer alloc] init];
    
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    
    NSTimer *timer2 = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(run) userInfo:nil repeats:YES];
    
    [[NSRunLoop currentRunLoop] addTimer:timer2 forMode:UITrackingRunLoopMode];
    
    [self performSelectorOnMainThread:@selector(run) withObject:nil waitUntilDone:YES modes:@[UITrackingRunLoopMode]];
    
    [self performSelectorOnMainThread:@selector(run) withObject:nil waitUntilDone:YES modes:@[NSRunLoopCommonModes]];
    
    
    CADisplayLink *display = [CADisplayLink displayLinkWithTarget:self selector:@selector(run)];
    [display addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
}

- (void)observer
{
    /* Run Loop Observer Activities */
    typedef CF_OPTIONS(CFOptionFlags, CFRunLoopActivity) {
        kCFRunLoopEntry = (1UL << 0), // 1
        kCFRunLoopBeforeTimers = (1UL << 1), // 2
        kCFRunLoopBeforeSources = (1UL << 2), // 4
        kCFRunLoopBeforeWaiting = (1UL << 5), // 32
        kCFRunLoopAfterWaiting = (1UL << 6), // 64
        kCFRunLoopExit = (1UL << 7), // 128
        kCFRunLoopAllActivities = 0x0FFFFFFFU // 监听所有事件
    };
    
    // 创建观察者 监听RunLoop
    // 参1:有个默认值 CFAllocatorRef allocator:CFAllocatorGetDefault()
    // 参2:CFOptionFlags activities 监听RunLoop的活动 枚举 见上面
    // 参3:重复监听 Boolean repeats YES
    // 参4:CFIndex order 传0
    
    CFRunLoopObserverRef observer = CFRunLoopObserverCreateWithHandler(CFAllocatorGetDefault(), kCFRunLoopAllActivities, YES, 0, ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {
        // 该方法可以在添加timer之前做一些事情，  在添加source之前做一些事情
        NSLog(@"%zd", activity);
    });
    
    // 添加观察者，监听当前的RunLoop对象
    CFRunLoopAddObserver(CFRunLoopGetCurrent(), observer, kCFRunLoopDefaultMode);
    
    CFRetain(observer);
    CFRelease(observer);
    // CF层面的东西 凡是带有create、copy、retain等字眼的函数在CF中要进行内存管理
    CFRelease(observer);
}
@end






















































