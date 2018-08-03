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
#import <IVBaseKit/IVBaseKit.h>
#import "Toast.h"
#import "FUHandle.h"
#import <BLEMidAutumn/BLEMidAutumn.h>
#import "RequestFirmwareUpdateApi.h"
#import "DCViewController.h"

@interface DCViewController ()<UITableViewDataSource,UITableViewDelegate,FUHandleDelegate,BLEShareInstanceDelegate>
{
    UILabel *_scanState;
    UIImageView *_deviceView;
    UIView *_menuBar;
    NSString *_theBleMAC;
    UIButton *_upgradeBtn;
    
    NSString *_deviceName;
    UILabel *_textLabel;
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
    self.title = @"Fasting Upgrade";
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceDidConnected:) name:@"k_deviceDidConnected" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceInfoDidUpdate:) name:@"kNOTICE_DEVICE_UPDATE" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(batteryInfoDidUpdate:) name:@"kNOTICE_BATTERY_UPDATE" object:nil];


    [self initParam];
    [self initUI];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)initParam {
    _dataSource = [[NSMutableArray alloc] initWithCapacity:0];
    [BLEShareInstance shareInstance].delegate = self;
    [[FUHandle handle] setDelegate:self];
}

- (void)initUI {
    
    [self drawBgView];
    [self drawScanStateView];
    [self drawTextLabel];
    [self drawTableView];
    [self drawRescanButton];
    [self drawUpgradeButton];
}

- (void)drawBgView {
    
    UIImage *bg = [UIImage imageNamed:@"hardware_bg"];
    UIImageView *bgView = [[UIImageView alloc]initWithImage:bg];
    [bgView setFrame:self.view.bounds];
    [self.view addSubview:bgView];
}

- (void)drawTextLabel {
    
    _textLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, FONT(FONT(200)), FONT(200))];
    _textLabel.numberOfLines = 0;
    _textLabel.center = self.view.center;
    [self.view addSubview:_textLabel];
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
    self.tableView = [[UITableView alloc]initWithFrame:CGRectMake(0, FONT(120), SCREEN_WIDTH, SCREEN_HEIGHT-FONT(180)) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.bounces = NO;
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView setHidden:YES];
    [self.view addSubview:self.tableView];
}

- (void)drawRescanButton{
    _rescan = [UIButton buttonWithType:UIButtonTypeCustom];
    [_rescan setFrame:CGRectMake(SCREEN_WIDTH * 0.5 - FONT(60), SCREEN_HEIGHT *0.75, FONT(120), FONT(40))];
    [self.view addSubview:_rescan];
    [_rescan setTitle:NSLocalizedString(@"Rescan", nil) forState:UIControlStateNormal];
    [_rescan setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [_rescan addTarget:self action:@selector(reScan) forControlEvents:UIControlEventTouchUpInside];
    [_rescan setHidden:YES];
}
    
- (void)drawUpgradeButton {
    _upgradeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.view addSubview:_upgradeBtn];
    [_upgradeBtn setFrame:CGRectMake(0.5*(SCREEN_WIDTH-FONT(120)), SCREEN_HEIGHT - FONT(120), FONT(120),FONT(40))];
    [_upgradeBtn setTitle:NSLocalizedString(@"UPGRADE", nil) forState:UIControlStateNormal];
    [_upgradeBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_upgradeBtn setBackgroundColor:[UIColor colorWithRed:65/255.0 green:173/255.0 blue:229/255.0 alpha:0.6]];
    [[_upgradeBtn titleLabel] setFont:[UIFont systemFontOfSize:FONT(16)]];
    [_upgradeBtn addTarget:self action:@selector(upgradeBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_upgradeBtn setHidden:YES];
    _upgradeBtn.layer.cornerRadius = FONT(20);
    _upgradeBtn.layer.masksToBounds = YES;
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
    ZRBlePeripheral *device = _dataSource[indexPath.row];
    cell.textLabel.text = device.deviceName;
    cell.backgroundColor = [UIColor clearColor];
    if ([_theBleMAC isEqualToString:device.uuidString]) {
        cell.detailTextLabel.text = NSLocalizedString(@"connected", nil);
    }else{
        cell.detailTextLabel.text = NSLocalizedString(@"unconnect", nil);
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return FONT(38);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [Toast makeToastActivityWithViwa:@"connecting..."];
    [_tableView deselectRowAtIndexPath:indexPath animated:YES];
    ZRBlePeripheral *device = _dataSource[indexPath.row];
    [[BLEShareInstance shareInstance] connectDevice:device];
}

#pragma -mark Actions
- (void)returnButtonClicked:(UIButton *)button{
    [[BLEShareInstance shareInstance] stopScan];
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
            [_scanState setText:NSLocalizedString(@"Scaning", nil)];
            [self scanAnimation];
            [_rescan setHidden:YES];
            [_textView setHidden:NO];
        }
            break;
        case ScanStateScaned:
        {
            [_scanState setUserInteractionEnabled:YES];
            [_scanState setText:NSLocalizedString(@"Found These, Tap Twice To Rescan", nil)];
            [_textView setHidden:YES];
            [_tableView setHidden:NO];
            [self showTableViewAnimation];
            [_tableView reloadData];
        }
            break;
        case ScanStateNull:
        {
            [_scanState setText:NSLocalizedString(@"Sorry, No Aviable Device", nil)];
            [_textView setHidden:YES];
            [_tableView setHidden:YES];
            [_rescan setHidden:NO];
        }
            break;
        case ScanStateStart:
        {
            [_scanState setUserInteractionEnabled:YES];
            [_scanState setText:NSLocalizedString(@"Tap Twice To Scan", nil)];
            [_textView setHidden:YES];
        }
            break;
        default:
        
            break;
    }
}

- (void)reScan{
    [[FUHandle handle] setDeviceInfo:nil];
    [self.dataSource removeAllObjects];
    [self.tableView reloadData];
    [self reset];
    [self scanDevice];
    [self setScanState:ScanStateScaning];
}
    
- (void)reset {
    
    _textLabel.hidden = YES;
    self.tableView.hidden = NO;
    _upgradeBtn.hidden = YES;
    _theBleMAC = nil;
}

#pragma mark -animation
- (void)showTableViewAnimation {
    CGFloat width = _tableView.bounds.size.width;
    CGFloat height = _tableView.bounds.size.height;
    
    [_tableView setFrame:CGRectMake(0, SCREEN_HEIGHT, width, height)];
    [UIView animateWithDuration:0.5 animations:^{
        [_tableView setFrame:CGRectMake(0, FONT(120), width, height)];
    }];
}

- (void)scanAnimation {
    __block int timeNum=0;
    __block UILabel *__safe_scan = _scanState;
    __block DCViewController *__safe_self = self;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0,queue);
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),0.5*NSEC_PER_SEC, 0);
    dispatch_source_set_event_handler(_timer, ^{
        if (timeNum >4) {
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
                [__safe_scan setText:[NSLocalizedString(@"Seraching Device", nil) stringByAppendingString:str]];
            });
        }
    });
    dispatch_resume(_timer);
}
#pragma mark -delegate

- (void)deviceDidConnected:(NSNotification *)obj {
    
    [_scanState setText:NSLocalizedString(@"Connected，Reading device info", nil)];
    [Toast hideToastActivity];
    ZRBlePeripheral *device = (ZRBlePeripheral *)obj.object;
    _deviceName = device.deviceName;
    _theBleMAC = device.uuidString;
    _tableView.hidden = YES;
}

- (void)tapLabTwice {
    [[BLEShareInstance shareInstance] getDeviceInfo];
}

- (void)deviceInfoDidUpdate:(NSNotification *)notice {
    ZRDeviceInfo *deviceInfo = (ZRDeviceInfo *)notice.object;
    [self updateDeviceInfo:deviceInfo];
    [_upgradeBtn setHidden:NO];
}

- (void)batteryInfoDidUpdate:(NSNotification *)notice {
    ZRDeviceInfo *deviceInfo = (ZRDeviceInfo *)notice.object;
    [self updateDeviceInfo:deviceInfo];
}

- (void)updateDeviceInfo:(ZRDeviceInfo *)deviceInfo {
    [[FUHandle handle] setDeviceInfo:deviceInfo];
    dispatch_async(dispatch_get_main_queue(), ^{
        _textLabel.hidden = NO;
        [_textLabel setText:[NSString stringWithFormat:@"NAME:%@\n\nMODEL:%@\n\nVERSION:%@\n\nPOWER:%lu%%",_deviceName,[FUHandle handle].deviceInfo.model,[FUHandle handle].deviceInfo.version,(long)[FUHandle handle].deviceInfo.batLevel]];
    });
}

#pragma mark -BLEaction
- (void)scanDevice{
    [_dataSource removeAllObjects];
    [[BLEShareInstance shareInstance] scanDevice];
}

- (void)scanStop {
    
    [[BLEShareInstance shareInstance] stopScan];
    [_dataSource addObjectsFromArray:[[BLEShareInstance shareInstance] getDevices]];
    if (_dataSource.count != 0) {
        [self setScanState:ScanStateScaned];
    }else{
        [self setScanState:ScanStateNull];
    }
}

- (void)upgradeBtnClick:(UIButton *)btn {
    
    [self requestForCheckDFU];
}

- (void)requestForCheckDFU {
    //Checking Required Params
    ZRDeviceInfo *_dInfo = [BLEShareInstance shareInstance].deviceInfo;
    NSInteger platform = [_dInfo platformForDfu];
    //UI
    [Toast makeToastActivityWithViwa:@"Checking Upgrade..."];
    NSString *deviceVersion = [_dInfo version];
    __weak typeof(self) weakself = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        [[FUHandle handle] fwUpdateRequestWithPlatform:platform andNeedFW:1 andDeviceVersion:deviceVersion completion:^(RequestFirmwareUpdateApi *responce, NSError *error) {
            NSInteger retCode = [responce.responseJSONObject[@"retCode"] integerValue];
            if (retCode == 0) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [Toast hideToastActivity];
                    NSDictionary *fwInfo = responce.firmware;
                    if (fwInfo) {
                        NSMutableDictionary *mDict = [NSMutableDictionary dictionaryWithDictionary:fwInfo];
                        [mDict setObject:_dInfo.bleAddr forKey:@"mac_address"];
                        [mDict setObject:_dInfo.model forKey:@"model"];
                        [weakself checkFWUpdate:mDict];
                    }else {
                        [weakself checkFWUpdate:nil];
                    }
                });
            }else {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [Toast hideToastActivity];
                    [weakself checkFWUpdate:nil];
                });
            }
        }];
    });
}

- (void)checkFWUpdate:(NSDictionary *)mContent {
   
    UIViewController *fuVC = [[FUHandle handle] getFUVC:mContent];
    if (fuVC) {
        [self.navigationController presentViewController:fuVC animated:YES completion:nil];
    }
}

@end
