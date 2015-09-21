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

static CGFloat CELL_HEIGHT = 80.f;

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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 399;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    ExampleCell *cell = [tableView dequeueReusableCellWithIdentifier:IDENTIFIER];
    [[cell viewWithTag:1] removeFromSuperview];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.currentIndexPath = indexPath;
    __weak typeof(tableView) weakTableView = tableView;
    [[DWURunLoopWorkDistribution sharedRunLoopWorkDistribution] addTask:(id)^(id previousUnitResult){
        if ([[weakTableView visibleCells] indexOfObject:cell] != NSNotFound && cell.currentIndexPath.section == indexPath.section && cell.currentIndexPath.row == indexPath.row) {
            UIView *complicatedView = [ViewController _complicatedView];
            [UIView transitionWithView:cell.contentView duration:0.3 options:UIViewAnimationOptionTransitionCrossDissolve | UIViewAnimationOptionCurveEaseInOut animations:^{
                [cell.contentView addSubview:complicatedView];
            } completion:^(BOOL finished) {
                
            }];
        }
        return nil;
    } withKey:indexPath urgent:NO];
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
