//
//  ViewController.m
//  RunLoop
//
//  Created by 李朝 on 16/1/10.
//  Copyright © 2016年 ammar. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
/** 自己的线程 */
@property (strong, nonatomic) NSThread *thread;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 需求:搞一个线程一直不死，一直在后台做一些操作 比如监听某个状态， 比如监听是否联网。
    // 需要在线程中开启一个RunLoop 一个线程对应一个RunLoop 所以获得当前RunLoop就会自己创建RunLoop
//    NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(run2) object:nil];
//    self.thread = thread;
//    [thread start];
    
    NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(excute) object:nil];
    self.thread = thread;
    [thread start];
  
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self performSelector:@selector(run) onThread:self.thread withObject:nil waitUntilDone:NO];
}

- (void)excute
{
    @autoreleasepool {
        NSTimer *timer = [NSTimer timerWithTimeInterval:2.0 target:self selector:@selector(text) userInfo:nil repeats:YES];
        
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
        
        [[NSRunLoop currentRunLoop] run];
        
    }
}

- (void)run2
{
    @autoreleasepool {
        NSLog(@"----------");
        /*
         * 创建RunLoop，如果RunLoop内部没有添加任何Source Timer Observer，
         * 会直接退出循环，因此需要自己添加一些source才能保持RunLoop运转
         */
        [[NSRunLoop currentRunLoop] addPort:[NSPort port] forMode:NSDefaultRunLoopMode];
        // [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        [[NSRunLoop currentRunLoop] run];
        
        
        
        NSLog(@"-----------22222222");
    }
}

// 加载比较大的图片时，
//- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
//{
//    // inModes 传入一个数组，这句话的意思是，只有在 NSDefaultRunLoopMode 模式下才会执行 seletor 的方法
//    [self.imageView performSelector:@selector(setImage:) withObject:[UIImage imageNamed:@"avater"] afterDelay:3.0 inModes:@[NSDefaultRunLoopMode]];
//}

- (void)observer
{
    // CFRunLoopObserverRef
    // 1.创建观察者 监听 RunLoop
    // 参1: 有个默认值 CFAllocatorRef :CFAllocatorGetDefault()
    // 参2: CFOptionFlags activities 监听RunLoop的活动 枚举 见上面
    // 参3: 重复监听 Boolean repeats YES
    // 参4: CFIndex order 传0
    CFRunLoopObserverRef observer = CFRunLoopObserverCreateWithHandler(CFAllocatorGetDefault(), kCFRunLoopAllActivities, YES, 0, ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {
        // 该方法可以在添加timer之前做一些事情，  在添加source之前做一些事情
        NSLog(@"%zd", activity);
    });
    
    // 2.添加观察者，监听当前的RunLoop对象
    CFRunLoopAddObserver(CFRunLoopGetCurrent(), observer, kCFRunLoopDefaultMode);
    
    // CF层面的东西 凡是带有create、copy、retain等字眼的函数在CF中要进行内存管理
    CFRelease(observer);
}

- (void)timer
{
    // CFRunLoopTimerRef
    NSTimer *timer = [NSTimer timerWithTimeInterval:2.0 target:self selector:@selector(run) userInfo:nil repeats:YES];
    
    // 在默认模式下添加的 timer 当我们拖拽 textView 的时候，不会运行 run 方法
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
    
    // 在 UI 跟踪模式下添加 timer 当我们拖拽 textView 的时候，run 方法才会运行
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:UITrackingRunLoopMode];
    
    // timer 可以运行在两种模式下，相当于上面两句代码写在一起
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}


- (void)run
{
    NSLog(@"--------run");
}

/** 监听按钮的点击 */
- (IBAction)buttonClick:(id)sender {
    NSLog(@"-----------buttonClick");
}

- (void)text
{
    NSLog(@"text--------");
}

@end
