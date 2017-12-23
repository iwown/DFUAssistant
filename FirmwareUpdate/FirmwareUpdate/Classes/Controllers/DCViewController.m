//
//  DCViewController.m
//  ZLYIwown
//
//  Created by 曹凯 on 15/11/16.
//  Copyright © 2015年 Iwown. All rights reserved.
//
typedef enum{
    ScanStateScaning = 0,
    ScanStateScaned ,
    ScanStateNull   ,
    ScanStateStart ,
}ScanState;
#import "IwownBlePeripheral.h"
#import "BLELib3.h"
#import "DCViewController.h"

@interface DCViewController ()<UITableViewDataSource,UITableViewDelegate,BLELib3Delegate,BleDiscoverDelegate,BleConnectDelegate>
{
    UILabel *_scanState;
    UIImageView *_deviceView;
    UIView *_menuBar;
    NSString *_theBleMAC;
    UIButton *_upgradeBtn;
}
@property (nonatomic ,strong) UITableView *tableView;
@property (nonatomic ,strong) NSMutableArray *dataSource;
@property (nonatomic ,strong) UITextView *textView;
@property (nonatomic ,strong) UIButton *rescan;


@end

@implementation DCViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"LightBLE";
    [[BLELib3 shareInstance] setDelegate:self];
    [[BLELib3 shareInstance] setConnectDelegate:self];
    [[BLELib3 shareInstance] setDiscoverDelegate:self];
    [self initParam];
    [self initUI];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)initParam{
    _dataSource = [[NSMutableArray alloc] initWithCapacity:0];
}

- (void)initUI{
    self.view.backgroundColor = [UIColor whiteColor];
    [self drawScanStateView];
    [self drawTableView];
    [self drawRescanButton];
    [self drawUpgradeButton];
}

- (void)drawScanStateView{
    UITapGestureRecognizer *tapTwice = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapTwiceForReScan:)];
    tapTwice.numberOfTapsRequired = 2;
    _scanState = [[UILabel alloc] initWithFrame:CGRectMake(0, FONT(60), SCREEN_WIDTH, FONT(60))];
    [_scanState setTextAlignment:NSTextAlignmentCenter];
    [self.view addSubview:_scanState];
    [_scanState addGestureRecognizer:tapTwice];
    [self setScanState:ScanStateStart];
}

- (void)drawTableView{
    //tableView的初始化
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, FONT(120), SCREEN_WIDTH, SCREEN_HEIGHT-FONT(150)) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.bounces = NO;
    [self.tableView setHidden:YES];
    [self.view addSubview:self.tableView];
}

- (void)drawRescanButton{
    _rescan = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:_rescan];
    [_rescan setTitle:NSLocalizedString(@"重新搜索", nil) forState:UIControlStateNormal];
    [_rescan setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_rescan addTarget:self action:@selector(reScan) forControlEvents:UIControlEventTouchUpInside];
    [_rescan setHidden:YES];
}
    
- (void)drawUpgradeButton {
    _upgradeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:_upgradeBtn];
    [_upgradeBtn setFrame:CGRectMake(0, SCREEN_HEIGHT -FONT(50), SCREEN_WIDTH,FONT(50))];
    [_upgradeBtn setTitle:NSLocalizedString(@"进入DFU", nil) forState:UIControlStateNormal];
    [_upgradeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_upgradeBtn setBackgroundColor:[UIColor colorWithRed:65/255.0 green:173/255.0 blue:229/255.0 alpha:1]];
    [[_upgradeBtn titleLabel] setFont:[UIFont systemFontOfSize:FONT(26)]];
    [_upgradeBtn addTarget:self action:@selector(upgradeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_upgradeBtn setHidden:YES];
    [self.view bringSubviewToFront:_upgradeBtn];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return _dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
       cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    IwownBlePeripheral *device = _dataSource[indexPath.row];
    cell.textLabel.text = device.deviceName;
    if ([_theBleMAC isEqualToString:device.uuidString]) {
        cell.detailTextLabel.text = NSLocalizedString(@"已连接", nil);
    }else{
        cell.detailTextLabel.text = NSLocalizedString(@"未绑定", nil);
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return FONT(38);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [_tableView deselectRowAtIndexPath:indexPath animated:YES];
    IwownBlePeripheral *device = _dataSource[indexPath.row];
    [[BLELib3 shareInstance] connectDevice:device];
}

#pragma -mark Actions
- (void)returnButtonClicked:(UIButton *)button{
    [[BLELib3 shareInstance] stopScan];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -private
- (void)tapTwiceForReScan:(id)gesture{
    [self reScan];
}

- (void)setScanState:(ScanState)state{
    [_scanState setUserInteractionEnabled:NO];
    switch (state) {
        case ScanStateScaning:
        {
            [_scanState setText:NSLocalizedString(@"正在查找您的设备", nil)];
            [self scanAnimation];
            [_rescan setHidden:YES];
            [_textView setHidden:NO];
        }
            break;
        case ScanStateScaned:
        {
            [_scanState setUserInteractionEnabled:YES];
            [_scanState setText:NSLocalizedString(@"已帮您找到这些设备,双击我重新搜索", nil)];
            [_textView setHidden:YES];
            [_tableView setHidden:NO];
            [self showTableViewAnimation];
            [_tableView reloadData];

        }
            break;
        case ScanStateNull:
        {
            [_scanState setText:NSLocalizedString(@"对不起，并未找到可用设备", nil)];
            [_textView setHidden:YES];
            [_tableView setHidden:YES];
            [_rescan setHidden:NO];
        }
            break;
        case ScanStateStart:
        {
            [_scanState setUserInteractionEnabled:YES];
            [_scanState setText:NSLocalizedString(@"双击开始搜索", nil)];
            [_textView setHidden:YES];
        }
            break;
        default:
        
            break;
    }
}

- (void)reScan{
    [self reset];
    [self scanDevice];
    [self setScanState:ScanStateScaning];
}
    
- (void)reset {
    _upgradeBtn.hidden = YES;
    _theBleMAC = nil;
}

#pragma mark -animation
- (void)showTableViewAnimation{
    CGFloat width = _tableView.bounds.size.width;
    CGFloat height = _tableView.bounds.size.height;
    
    [_tableView setFrame:CGRectMake(0, SCREEN_HEIGHT, width, height)];
    [UIView animateWithDuration:0.5 animations:^{
        [_tableView setFrame:CGRectMake(0, FONT(120), width, height)];
    }];
}

- (void)scanAnimation{
    __block int timeNum=0;
    __block UILabel *__safe_scan = _scanState;
    __block DCViewController *__safe_self = self;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),0.5*NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(_timer, ^{
        if (timeNum >10) {
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                [__safe_self scanStop];
            });
        }else{
            NSString *str = @"・";
            for (int i = 0; i < timeNum%3; i ++) {
                str = [str stringByAppendingString:@"・"];
            }
            timeNum ++;
            dispatch_async(dispatch_get_main_queue(), ^{
                [__safe_scan setText:[NSLocalizedString(@"正在查找您的设备", nil) stringByAppendingString:str]];
            });
        }
    });
    dispatch_resume(_timer);
}

#pragma mark -delegate
- (void)IWBLEDidDiscoverDeviceWithMAC:(IwownBlePeripheral *)iwDevice {
    if ([iwDevice.deviceName containsString:@"Bracel13-"]) { //i6HR
        return;
    }else if ([iwDevice.deviceName containsString:@"Bracel15-"]){ //i6
        return;
    }
    [_dataSource addObject:iwDevice];
}

- (void)IWBLEDidConnectDevice:(IwownBlePeripheral *)device {
    _theBleMAC = device.uuidString;
    [self.tableView reloadData];
    [_upgradeBtn setHidden:NO];
}

- (void)setBLEParameterAfterConnect {
    [[BLELib3 shareInstance] syscTimeAtOnce];
}

- (void)dealloc {
    [BLELib3 shareInstance].delegate = nil;
    [BLELib3 shareInstance].connectDelegate = nil;
    [BLELib3 shareInstance].discoverDelegate = nil;
}
#pragma mark -BLEaction
- (void)scanDevice{
    [_dataSource removeAllObjects];
    [[BLELib3 shareInstance] scanDevice];
}

- (void)scanStop{
 
    if (_dataSource.count != 0) {
        [self setScanState:ScanStateScaned];
    }else{
        [self setScanState:ScanStateNull];
    }
}

- (void)upgradeBtnClick:(UIButton *)btn {
    [[BLELib3 shareInstance] deviceUpdate];
    [[BLELib3 shareInstance] unConnectDevice];
    [self reset];
    [self.tableView reloadData];
}
  

@end
