//
//  IVRootViewController.m
//  FirmwareUpdate
//
//  Created by 曹凯 on 2016/11/7.
//  Copyright © 2016年 west. All rights reserved.
//
#import "ViewController.h"
#import "IVRootViewController.h"
#import "DUViewController.h"
#import "DCViewController.h"
#import "ZGViewController.h"
#import "EPOViewController.h"
#import "PBViewController.h"
#import "LightBlueViewController.h"
#import "Toast.h"

@interface IVRootViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic ,strong) UITableView *tableView;
@property (nonatomic ,strong) NSMutableArray *dataSource;

@end

@implementation IVRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    [self initUI];
}

- (void)initData {
    self.title = @"More Upgrade";
    _dataSource = [[NSMutableArray alloc] initWithCapacity:0];
    NSArray *arr = @[
  @{@"btnTitle":@"ENTRY DFU", @"btnSelectorMethod":@"lightBlueBtnClick", @"btnDetail":@"let device(nodric platform) entry dfu status", @"color" : [UIColor cyanColor]},
  @{@"btnTitle":@"DFU Protobuf", @"btnSelectorMethod":@"pbDfuBtnClick", @"btnDetail":@"dfu way for I7E(use protobuf protocol)", @"color" : [UIColor greenColor]},
  @{@"btnTitle":@"DFU-L Protobuf", @"btnSelectorMethod":@"pbLoopDfuBtnClick", @"btnDetail":@"autocycle dfu way for I7E(use protobuf protocol)", @"color" : [UIColor greenColor]},
  @{@"btnTitle":@"DFU-L-A Protobuf", @"btnSelectorMethod":@"pbLoopAutoDfuBtnClick", @"btnDetail":@"autocycle dfu way for I7E(entry DFU & use protobuf protocol)", @"color" : [UIColor cyanColor]},
  @{@"btnTitle":@"DFU Colorful", @"btnSelectorMethod":@"dfuCBtnClick", @"btnDetail":@"dfu way for I6HC(colorful screen)", @"color" : [UIColor redColor]},
  @{@"btnTitle":@"DFU-L Colorful", @"btnSelectorMethod":@"dfuLoopCBtnClick", @"btnDetail":@"autocycle dfu way for I6HC(colorful screen)", @"color" : [UIColor redColor]},
  @{@"btnTitle":@"SOUTA", @"btnSelectorMethod":@"soutaBtnClick", @"btnDetail":@"upgrade way for I6HR(black & white screen)", @"color" : [UIColor darkGrayColor]},
  @{@"btnTitle":@"FOTA", @"btnSelectorMethod":@"fotaBtnClick", @"btnDetail":@"upgrade way for P1 sport watch(MTK platform)" , @"color" : [UIColor blueColor]},
  @{@"btnTitle":@"EPO", @"btnSelectorMethod":@"epoBtnClick", @"btnDetail":@"epo upgrade for P1 Sport Watch", @"color" : [UIColor blueColor]},
  @{@"btnTitle":@"DFU", @"btnSelectorMethod":@"dfuBtnClick", @"btnDetail":@"dfu way for i5Plus", @"color" : [UIColor blackColor]}];
    [_dataSource addObjectsFromArray:arr];
}

- (void)initUI {
    self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[Toast imageWithText:@"Firmware Upgrade"]];
    [self drawTableView];
}

- (void)drawTableView {
    _tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_dataSource count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 79;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *Id = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:Id];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:Id];
    }
    
    NSDictionary *dict = _dataSource[indexPath.row];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.textLabel.text = [NSString stringWithFormat:@"%@",dict[@"btnTitle"]];
    cell.textLabel.font = [UIFont boldSystemFontOfSize:22];
    cell.textLabel.textColor = dict[@"color"];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@",dict[@"btnDetail"]];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:15];
    [cell.detailTextLabel setNumberOfLines:0];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *dict = _dataSource[indexPath.row];
    SEL selector = NSSelectorFromString(dict[@"btnSelectorMethod"]);
    [self performSelectorOnMainThread:selector withObject:nil waitUntilDone:YES];
}

- (void)lightBlueBtnClick {
    [self.navigationController pushViewController:[LightBlueViewController new] animated:YES];
}

- (void)dfuCBtnClick {
    [self.navigationController pushViewController:[ZGViewController new] animated:YES];
}

- (void)dfuBtnClick {
    [self.navigationController pushViewController:[ViewController new] animated:YES];
}

- (void)dfuLoopCBtnClick {
    ZGViewController *zgVC = [ZGViewController new];
    zgVC.autoUpgrading = YES;
    [self.navigationController pushViewController:zgVC animated:YES];
}

- (void)soutaBtnClick {
    [self.navigationController pushViewController:[[DUViewController alloc] init] animated:YES];
}

- (void)fotaBtnClick {
    [self.navigationController pushViewController:[[DCViewController alloc] init] animated:YES];
}

- (void)epoBtnClick {
    [self.navigationController pushViewController:[[EPOViewController alloc] init] animated:YES];
}

- (void)pbLoopDfuBtnClick {
    PBViewController *pbVc = [[PBViewController alloc] init];
    pbVc.autoUpgrading = YES;
    [self.navigationController pushViewController:pbVc animated:YES];
}

- (void)pbLoopAutoDfuBtnClick {
    PBViewController *pbVc = [[PBViewController alloc] init];
    pbVc.autoUpgrading = YES;
    pbVc.autoEntryDfu = YES;
    [self.navigationController pushViewController:pbVc animated:YES];
}

- (void)pbDfuBtnClick {
    [self.navigationController pushViewController:[[PBViewController alloc] init] animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
