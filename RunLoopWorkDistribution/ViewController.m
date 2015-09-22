//
//  ViewController.m
//  RunLoopWorkDistribution
//
//  Created by Di Wu on 9/19/15.
//  Copyright © 2015 Di Wu. All rights reserved.
//

#import "ViewController.h"
#import "ExampleCell.h"
#import "DWURunLoopWorkDistribution.h"

static NSString *IDENTIFIER = @"IDENTIFIER";

static NSInteger NUM_OF_IMAGE_VIEW_PER_CELL = 1;

static CGFloat CELL_HEIGHT = 150.f;

@interface ViewController () <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *exampleTableView;

@end

@implementation ViewController

+ (CGRect)_frameForImageViewWithIndex:(NSInteger)index {
    static CGFloat width = 0;
    if (width == 0) {
        width = CGRectGetWidth([UIScreen mainScreen].bounds) / (CGFloat)NUM_OF_IMAGE_VIEW_PER_CELL;
    }
    return CGRectMake(index * width, 0, width, CELL_HEIGHT);
}

+ (CGRect)_frameForComplicatedView {
    static CGFloat width = 0;
    if (width == 0) {
        width = CGRectGetWidth([UIScreen mainScreen].bounds);
    }
    return CGRectMake(0, 0, width, CELL_HEIGHT);
}

+ (UIView *)_complicatedView {
    UIView *view = [UIView new];
    view.tag = 1;
    view.frame = [ViewController _frameForComplicatedView];
    for (NSInteger i = 0; i < NUM_OF_IMAGE_VIEW_PER_CELL; i++) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"spaceship" ofType:@"jpg"];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:path]];
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.tag = 1;
        imageView.frame = [ViewController _frameForImageViewWithIndex:i];
        [view addSubview:imageView];
    }
    return view;
}

+ (void)task_4:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    for (NSInteger i = 1; i <= 5; i++) {
        [[cell.contentView viewWithTag:i] removeFromSuperview];
    }
}

+ (void)task_1:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    [[cell.contentView viewWithTag:1] removeFromSuperview];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(5, 5, 300, 25)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor blackColor];
    label.text = [NSString stringWithFormat:@"%zd - Drawing index is top priority", indexPath.row];
    label.font = [UIFont systemFontOfSize:13];
    label.tag = 1;
    [cell.contentView addSubview:label];
}

+ (void)task_2:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath  {
    [[cell.contentView viewWithTag:2] removeFromSuperview];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(5, 30, 300, 25)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor blackColor];
    label.text = [NSString stringWithFormat:@"%zd - Drawing small image is medium priority", indexPath.row];
    label.font = [UIFont systemFontOfSize:13];
    label.tag = 2;
    [cell.contentView addSubview:label];
    
    [[cell.contentView viewWithTag:3] removeFromSuperview];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(5, 55, 40, 40)];
    imageView.tag = 3;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"small_apple_logo" ofType:@"jpg"];
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.image = image;
    [cell.contentView addSubview:imageView];
}

+ (void)task_3:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath  {
    [[cell.contentView viewWithTag:4] removeFromSuperview];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(5, 95, 300, 25)];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor blackColor];
    label.text = [NSString stringWithFormat:@"%zd - Drawing large image is low priority", indexPath.row];
    label.font = [UIFont systemFontOfSize:13];
    label.tag = 4;
    [cell.contentView addSubview:label];
    
    [[cell.contentView viewWithTag:5] removeFromSuperview];
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(100, 55, 40, 40)];
    imageView.tag = 5;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"spaceship" ofType:@"jpg"];
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.image = image;
    [cell.contentView addSubview:imageView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 399;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ExampleCell *cell = [tableView dequeueReusableCellWithIdentifier:IDENTIFIER];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.currentIndexPath = indexPath;
    [ViewController task_4:cell indexPath:indexPath];
    [ViewController task_1:cell indexPath:indexPath];
    [[DWURunLoopWorkDistribution sharedRunLoopWorkDistribution] addTask:^BOOL(void) {
        if (![cell.currentIndexPath isEqual:indexPath]) {
            return NO;
        }
        [ViewController task_2:cell indexPath:indexPath];
        return YES;
    } withKey:indexPath urgent:YES];
    [[DWURunLoopWorkDistribution sharedRunLoopWorkDistribution] addTask:^BOOL(void) {
        if (![cell.currentIndexPath isEqual:indexPath]) {
            return NO;
        }
        [ViewController task_3:cell indexPath:indexPath];
        return YES;
    } withKey:indexPath urgent:NO];
//    NSLog(@"common:  cell  CA, random number    is %zd\n", [DWURunLoopWorkDistribution sharedRunLoopWorkDistribution].randomNumber);
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return CELL_HEIGHT;
}


- (void)loadView {
    self.view = [UIView new];
    self.exampleTableView = [UITableView new];
    self.exampleTableView.delegate = self;
    self.exampleTableView.dataSource = self;
    [self.view addSubview:self.exampleTableView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.exampleTableView.frame = self.view.bounds;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self.exampleTableView registerClass:[ExampleCell class] forCellReuseIdentifier:IDENTIFIER];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
