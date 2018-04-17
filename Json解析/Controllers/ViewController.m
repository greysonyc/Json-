//
//  ViewController.m
//  Json解析
//
//  Created by  Ron on 2017/12/16.
//  Copyright © 2017年  Ron. All rights reserved.
//

#import "ViewController.h"
#import "ContentsInCell.h"
#import "Header.h"
#import "DetailViewController.h"
#import "MyTableViewCell.h"
#import "UIViewExt.h"
#define MARGIN 88
@interface ViewController () <UITableViewDataSource,UITableViewDelegate>
@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic,strong) NSMutableArray * arr;
@property (nonatomic,strong) DetailViewController * nextVC;
@property (nonatomic,weak) MyTableViewCell * cell_first;
//下拉动画：
@property(nonatomic, strong)CAShapeLayer *shapeLayer;//弧线
@property(nonatomic, strong)CAShapeLayer *circleLayer;//太阳
//子table:
//@property (nonatomic,strong) UIView * insertView;
@end
/*注意:!!!!!!
 Xcode7之后，不能直接读http的资源，需要在info.plist里面的App Transport Security Settings中加Allow Arbitrary Loads这一条，并且改为YES
 */
@implementation ViewController
-(CAShapeLayer *)shapeLayer {
    if (!_shapeLayer) {
        _shapeLayer = [CAShapeLayer layer];
        _shapeLayer.fillColor = [UIColor colorWithRed:200/255.0 green:200/255.0 blue:169/255.0 alpha:1].CGColor;
    }
    return _shapeLayer;
}

-(CAShapeLayer *)circleLayer {
    if (!_circleLayer) {
        _circleLayer = [CAShapeLayer layer];
        _circleLayer.fillColor = [UIColor whiteColor].CGColor;
    }
    return _circleLayer;
}
-(NSMutableArray*)arr{
    if (_arr==nil) {
        _arr = [[NSMutableArray alloc]init];
    }
    return _arr;
}
-(void)pullDownRequest{
    NSURL * url = [NSURL URLWithString:@MAIN_URL];
    NSURLSession * session = [NSURLSession sharedSession];
    NSURLSessionDataTask * task = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
    }];
    [task resume];
}
-(void)urlJson{
    //知乎日报：
    self.title = @"知乎";
    NSURL * url = [NSURL URLWithString:@MAIN_URL];
    __block id obj = NULL;
    NSURLSession * session = [NSURLSession sharedSession];
    NSURLSessionDataTask * task = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        obj= [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        if ([obj isKindOfClass:[NSDictionary class]]) {//字典类型
            NSDictionary * dic = (NSDictionary*)obj;
            NSArray * storiesArr = [dic objectForKey:@"stories"];
            for (NSDictionary * eachdic in storiesArr) {
                ContentsInCell * content = [[ContentsInCell alloc]initWithImge:[eachdic objectForKey:@"images"] andTitle:[eachdic objectForKey:@"title"] andIdNum:[NSString stringWithFormat:@"%@",[eachdic objectForKey:@"id"]]];
                [self.arr addObject:content];
            }
        }else if ([obj isKindOfClass:[NSArray class]]) {//数组类型
            self.arr = (NSMutableArray*)obj;
            NSLog(@"Arr");
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            //刷新数据：
            [self.tableView reloadData];
        });
    }];
    [task resume];
}
-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:nil];
    [self.tableView reloadData];
//    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
//    self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:nil];
    self.cell_first.selected = NO;
}
-(void)viewDidLoad{
    [super viewDidLoad];
//    self.view.backgroundColor = [UIColor redColor];
    NSLog(@"%s",__func__);
//    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.view addSubview:self.tableView];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = [UIColor clearColor];
    [self.view.layer insertSublayer:self.shapeLayer atIndex:0];
    [self.shapeLayer addSublayer:self.circleLayer];
    [self p_initCircle];
    
    [self urlJson];
    [self.tableView setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    [self.tableView setContentOffset:CGPointMake(0, 0)];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self.arr[indexPath.row] cellHeight_returns];
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.arr.count;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
//    NSLog(@"cellForRowAtIndexPath");
    NSString * Id = @"Video";
//    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:Id];
//    MyTableViewCell * cell = [[MyTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Id];
    
    MyTableViewCell * cell = [[MyTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Id];
    self.cell_first = cell;
    cell.contentsInCell_mine = self.arr[indexPath.row];
//    NSLog(@"indexpath is %ld,content address is %@,arr address is %@",indexPath.row,cell.contentsInCell_mine,self.arr[indexPath.row]);
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    //use单例模式节省内存：
    self.nextVC = [DetailViewController shareViewController:[self.arr[indexPath.row] idNum]];
    [self.navigationController pushViewController:self.nextVC animated:YES];
}

#pragma mark - private method
-(void)p_initCircle {
    self.circleLayer.frame = CGRectMake(0, MARGIN, self.view.width, 100);
    self.circleLayer.fillColor = nil;
    self.circleLayer.strokeColor = [UIColor whiteColor].CGColor;
    self.circleLayer.lineWidth = 2.0;

    CGPoint center = CGPointMake(self.view.center.x, 50);

    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(self.view.center.x, 35)];
    [path addArcWithCenter:center radius:15 startAngle:-M_PI_2 endAngle:M_PI * 1.5 clockwise:YES];
    CGFloat r1 = 17.0;
    CGFloat r2 = 22.0;
    for (int i = 0; i < 8 ; i++) {
        CGPoint pointStart = CGPointMake(center.x + sin((M_PI * 2.0 / 8 * i)) * r1, center.y - cos((M_PI * 2.0 / 8 * i)) * r1);
        CGPoint pointEnd = CGPointMake(center.x + sin((M_PI * 2.0 / 8 * i)) * r2, center.y - cos((M_PI * 2.0 / 8 * i)) * r2);
        [path moveToPoint:pointStart];
        [path addLineToPoint:pointEnd];
    }

    self.circleLayer.path = path.CGPath;
}

-(void)p_rise {
//    self.tableView.scrollEnabled = NO;
    CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    anim.duration = 0.15;
    anim.toValue = @(M_PI / 4.0);
    anim.repeatCount = MAXFLOAT;
    [self.circleLayer addAnimation:anim forKey:nil];

}

-(void)p_stop {
//    self.tableView.scrollEnabled = YES;
//    [self.tableView setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    [UIView animateWithDuration:0.2 animations:^{
        [self.tableView setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    }];
    [self.circleLayer removeAllAnimations];
}

#pragma mark - UIScrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat height = -(scrollView.contentOffset.y);
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(0, 0)];
    [path addLineToPoint:CGPointMake(self.view.width, 0)];
//    NSLog(@"%f",height);
//    NSLog(@"%f",scrollView.contentInset.top);
    if (height <= MARGIN) {
        [path addLineToPoint:CGPointMake(self.view.width, height+MARGIN)];
        [path addLineToPoint:CGPointMake(0, height+MARGIN)];
        self.circleLayer.strokeEnd = height / (float)MARGIN;
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        self.circleLayer.affineTransform = CGAffineTransformIdentity;
        [CATransaction commit];
    }else{
        self.circleLayer.strokeEnd = 1.0;
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        self.circleLayer.affineTransform = CGAffineTransformMakeRotation(-(M_PI / 720 * (height - MARGIN)));
        [CATransaction commit];
        [path addLineToPoint:CGPointMake(self.view.width, MARGIN*2)];
        [path addQuadCurveToPoint:CGPointMake(0, MARGIN*2) controlPoint:CGPointMake(self.view.center.x, height+MARGIN)];
    }

    [path closePath];
    self.shapeLayer.path = path.CGPath;

}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
//    NSLog(@"@@@ %f",scrollView.contentOffset.y);
//    NSLog(@"table %@ scroll%@",self.tableView,scrollView);
    if (scrollView.contentOffset.y < -MARGIN) {
        [scrollView setContentOffset:CGPointMake(0, -MARGIN) animated:YES];
        [scrollView setContentInset:UIEdgeInsetsMake(MARGIN, 0, 0, 0)];
    }else if(scrollView.contentOffset.y > -MARGIN && scrollView.contentOffset.y <0) {
        [scrollView setContentOffset:CGPointMake(0, 0) animated:YES];
//        [scrollView setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    }else{

    }
}

-(void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
//    NSLog(@"$$$ %f",scrollView.contentOffset.y);
    if (scrollView.contentOffset.y < -(MARGIN-1) && scrollView.contentOffset.y > -(MARGIN+1)) {
        self.circleLayer.affineTransform = CGAffineTransformIdentity;
        [self p_rise];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self p_stop];
        });
    }
}
@end
