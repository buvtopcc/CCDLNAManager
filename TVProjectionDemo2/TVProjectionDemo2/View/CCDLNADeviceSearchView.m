//
//  CCDLNADeviceSearchView.m
//  hustcc
//
//  Created by buvtopcc on 2019/11/21.
//  Copyright © 2019 buvtopcc.inc. All rights reserved.
//

#import "CCDLNADeviceSearchView.h"
//#import "UIView+Toast.h"
#import "CCUPnPDevice.h"
#import "DLNAManager.h"
//#import "YYHttpClient.h"
//#import "NSString+YYAdd.h"
//#import "ChannelCore.h"
//#import "CoreManager.h"
//#import "NSDictionary+Safe.h"
//#import "YYLogger.h"


static CGFloat const kTableViewHeightMin = 88;
static CGFloat const kTableViewHeightMax = 176;
static CGFloat const kTableViewHeightOneCell = 44;

@interface CCDLNADeviceSearchView () < UITableViewDelegate, UITableViewDataSource, DLNAManagerDelegate
                                      /* DZNEmptyDataSetSource, DZNEmptyDataSetDelegate */>

@property (nonatomic, weak) IBOutlet UIView *splitLine1;
@property (nonatomic, weak) IBOutlet UIView *splitLine2;
@property (nonatomic, weak) IBOutlet UIButton *cancelButton;
@property (nonatomic, weak) IBOutlet UIView *containerView;
@property (nonatomic, weak) IBOutlet UIView *bgView;
@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *tableViewHeightConstraint;
@property (nonatomic, strong) NSArray <CCUPnPDevice *> *deviceArray;
@property (nonatomic, assign) BOOL isSearchingStatus;

@end


@implementation CCDLNADeviceSearchView

+ (void)showInSuperView:(UIView *)superView
{
    CCDLNADeviceSearchView *searchView = [[[NSBundle mainBundle] loadNibNamed:@"CCDLNADeviceSearchView"
                                                                        owner:nil options:nil] firstObject];
    if (!superView) {
        superView = [[[UIApplication sharedApplication] windows] firstObject];
    }
    
    [superView addSubview:searchView];
    CGRect rect = superView.bounds;
    rect.origin.y = rect.size.height;
    searchView.frame = rect;
    [UIView animateWithDuration:0.25 animations:^{
        searchView.frame = superView.bounds;
    } completion:^(BOOL finished) {
        [searchView startSearch];
    }];
}

- (void)startSearch
{
    self.isSearchingStatus = YES;
    [[DLNAManager sharedDLNAManager] startSearch];
//    [self.tableView showLoadingToast];
//    [self.tableView reloadEmptyDataSet];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    // 暗黑 TODO
    [self.cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    self.splitLine1.backgroundColor = [UIColor grayColor];
    self.splitLine2.backgroundColor = [UIColor grayColor];
    self.containerView.backgroundColor = [UIColor blackColor];
    self.tableView.backgroundColor = [UIColor whiteColor];
//    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
//    self.tableView.emptyDataSetSource = self;
//    self.tableView.emptyDataSetDelegate = self;
    self.isSearchingStatus = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onCancel:)];
    [self.bgView addGestureRecognizer:tap];
    DLNAManager *mgr = [DLNAManager sharedDLNAManager];
    mgr.delegate = self;
    [mgr setSearchOutTime:30];
}

- (void)dealloc
{
    [[DLNAManager sharedDLNAManager] stopSearch];
}

- (IBAction)onCancel:(id)sender
{
    [UIView animateWithDuration:0.25 animations:^{
        CGRect rect = self.superview.bounds;
        rect.origin.y = rect.size.height;
        self.frame = rect;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

#pragma mark - DLNAManagerDelegate
- (void)dlnaManagerDeviceSearchResult:(NSArray<CCUPnPDevice *> *)devicesArray
{
//    [YYLogger info:@"DLNA" message:@"search result:%@", @(devicesArray.count)];
    self.deviceArray = [devicesArray copy];
    NSUInteger count = self.deviceArray.count;
    CGFloat height = kTableViewHeightOneCell * count;
    if (height > kTableViewHeightMax) {
        height = kTableViewHeightMax;
    }
    if (height < kTableViewHeightMin) {
        height = kTableViewHeightMin;
    }
    self.tableViewHeightConstraint.constant = height;
    [self setNeedsLayout];
    [self layoutIfNeeded];
    [self.tableView reloadData];
//    [self.tableView hideToastView];
}

- (void)dlnaManagerSearchOutTime
{
    self.isSearchingStatus = NO;
    [[DLNAManager sharedDLNAManager] stopSearch];
//    [self.tableView reloadEmptyDataSet];
//    [self.tableView hideToastView];
}

- (void)dlnaManagerResponseStartPlay
{
//    [YYLogger info:@"DLNA" message:@"rsp:play"];
}

- (void)dlnaManagerResponsePause
{
//    [YYLogger info:@"DLNA" message:@"rsp:pause"];
}

- (void)dlnaManagerResponseNext
{
//    [YYLogger info:@"DLNA" message:@"rsp:next"];
}

#pragma mark - UITableViewDelegate & UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] init];
    cell.textLabel.text = self.deviceArray[indexPath.row].friendlyName;
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.deviceArray count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CCUPnPDevice *device = [self.deviceArray objectAtIndex:indexPath.row];
    // HTTP接口获取推流地址
    [self pullVideoSteamUrlAndStartPlay:device];
}

- (void)pullVideoSteamUrlAndStartPlay:(CCUPnPDevice *)device
{
//    ChannelDetailInfo *info =[GetCore(ChannelCore) currentChannelInfo];
//    NSString *source = @"yy_ios";
//    NSNumber *sid = @(info.topSid);
//    NSNumber *ssid = @(info.sid);
//    NSNumber *rate = @(2000);
//    NSNumber *gear = @([GetCoreI(ISMMediaCore) currentRouteAndQuality].quality); // 优先使用gear档位匹配，未匹配则用rate规则
//    NSDictionary *properties = @{@"key1":gear.stringValue?:@""};
//    NSString *signString = [[NSString stringWithFormat:@"hls_%@_%@_%@_%@", sid, ssid, rate, source] yyk_md5String];
//    NSString *url = [NSString stringWithFormat:
//                     @"https://interface.yy.com/hls/get/client/%@/0/%@/%@/%@?sign=%@&type=flv&gear=%@", source, sid,
//                     ssid, rate, signString, gear];
//    __weak typeof(self)weakSelf = self;
//    [[YYHttpClient sharedClient] GET:url parameters:nil success:^(NSURLSessionDataTask *task,
//                                                                NSDictionary *responseObject) {
//      if (![responseObject isKindOfClass:NSDictionary.class]) {
//          return;
//      }
//      NSNumber *code = [responseObject numberForKey:@"code"];
//      if (code && code.intValue == 0) {
//          NSString *videoSteamUrl = [responseObject stringForKey:@"hls"];
//          [YYLogger info:@"DLNA" message:@"rate:%@ play:%@", rate, videoSteamUrl];
//          [DLNAManager sharedDLNAManager].playUrl  = videoSteamUrl;
//          [DLNAManager sharedDLNAManager].device = device;
//          [[DLNAManager sharedDLNAManager] startDLNAPlay];
//          [weakSelf onCancel:nil];
//      }
//    } failure:^(NSURLSessionDataTask *task, NSError *error) {
//      [UIView showToast:@"投屏失败，请检查当前网络~"];
//    }];
}

#pragma mark - DZNEmptyDataDelegate
- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView
{
    NSString *text = @"当前没有搜索到可用设备";
    NSDictionary *attributes = @{
        NSFontAttributeName : [UIFont boldSystemFontOfSize:14.0f],
        NSForegroundColorAttributeName : [UIColor grayColor],
    };
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView
{
    NSString *text = @"点击重新搜索";
    NSDictionary *attributes = @{
        NSFontAttributeName : [UIFont boldSystemFontOfSize:12.0f],
        NSForegroundColorAttributeName : [UIColor grayColor],
    };
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (void)emptyDataSet:(UIScrollView *)scrollView didTapView:(UIView *)view
{
    [self startSearch];
}

- (BOOL)emptyDataSetShouldDisplay:(UIScrollView *)scrollView
{
    return !self.isSearchingStatus;
}

@end
