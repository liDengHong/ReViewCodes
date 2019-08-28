//
//  AVC_VP_VideoPlayViewController.m
//  AliyunVideoClient_Entrance
//
//  Created by Zejian Cai on 2018/4/11.
//  Copyright © 2018年 Alibaba. All rights reserved.
//

#import "AVC_VP_VideoPlayViewController.h"
#import "AliyunVodPlayerView.h"
#import "AVCVideoConfig.h"
#import <sys/utsname.h>
#import "AVCLogView.h"
#import "MBProgressHUD+AlivcHelper.h"
#import "AVCDownloadVideo.h"
#import "AVCVideoDownloadTCell.h"
#import "AlivcAppServer.h"
#import "AVCSelectSharpnessView.h"
#import "AlivcVideoPlayManager.h"
#import "AlivcVideoPlayListModel.h"
#import "AlivcPlayListsView.h"
#import "AlivcVideoDataBase.h"
#import "AliyunReachability.h"
#import "AVC_VP_PlaySettingVC.h"
#import "UIImage+AlivcHelper.h"
#import <AliyunVodPlayerSDK/AliyunVodDownLoadManager.h>
#import "AlivcAlertView.h"
#import "MBProgressHUD+AlivcHelper.h"
NS_ASSUME_NONNULL_BEGIN

#define VIEWSAFEAREAINSETS(view) ({UIEdgeInsets i; if(@available(iOS 11.0, *)) {i = view.safeAreaInsets;} else {i = UIEdgeInsetsZero;} i;})

static CGFloat kExchangeHeight = 50; //日志离线视频行的高度
static NSString *kSaveVideoFileName = @"AVCLocalVideo";
static NSInteger alertViewTag_downLoad_continue = 1002; //wifi为4g时下载是否继续的tag
static NSInteger alertViewTag_exit_continue = 1003; //是否继续退出
static NSInteger alertViewTag_delete_video = 1004; //删除本地视频

@interface AVC_VP_VideoPlayViewController ()<AliyunVodPlayerViewDelegate,UITableViewDataSource,UITableViewDelegate,AliyunVodDownLoadDelegate,AVCSelectSharpnessViewDelegate,AlivcPlayListsViewDelegate,UIAlertViewDelegate,AVCVideoDownloadTCellDelegate>

//播放器
@property (nonatomic,strong, nullable)AliyunVodPlayerView *playerView;

//控制锁屏
@property (nonatomic, assign)BOOL isLock;

//是否隐藏navigationbar
@property (nonatomic,assign)BOOL isStatusHidden;

//进入前后台时，对界面旋转控制
@property (nonatomic, assign)BOOL isBecome;

//网络监听
@property (nonatomic, strong) AliyunReachability *reachability;


/**
 切换的容器视图
 */
@property (nonatomic, strong) UIView *exchangeContainView;

/**
 蓝色切换条
 */
@property (nonatomic, strong) UIView *exchangeLineView;


/**
 播放列表
 */
@property (nonatomic, strong) AlivcPlayListsView *listView;

/**
 播放列表按钮
 */
@property (nonatomic, strong) UIButton *listButton;

/**
 日志视图
 */
@property (nonatomic, strong) AVCLogView *logView;

/**
 日志按钮
 */
@property (nonatomic, strong) UIButton *logButton;

/**
 离线视频
 */
@property (nonatomic, strong) UIButton *offLineVideoButton;

/**
 离线视频上的小红点
 */
@property (nonatomic, strong) UIView *redView;

/**
 下载容器视图
 */
@property (nonatomic, strong) UIView *downloadContainView;

/**
 下载容器视图横屏的时候 左边的手势识别视图
 */
@property (nonatomic, strong) UIView *downloadGestureView;

/**
 离线视频下载tableView
 */
@property (nonatomic, strong) UITableView *downloadTableView;

/**
 下载编辑视频的容器视图
 */
@property (nonatomic, strong) UIView *downloadEditContainView;

/**
 是否在编辑下载视频
 */
@property (nonatomic, assign) BOOL isEdit;

/**
 是否全部选中
 */
@property (nonatomic, assign) BOOL isAllSelected;

/**
 是否在展示模态视图
 */
@property (nonatomic, assign) BOOL isPresent;

/**
 选择清晰度
 */
@property (nonatomic, strong) AVCSelectSharpnessView *selectView;

// data define

/**
 正在缓存列表
 */
@property (nonatomic, strong) NSMutableArray <AVCDownloadVideo *>*downloadingVideoArray;

/**
 已缓存列表
 */
@property (nonatomic, strong) NSMutableArray <AVCDownloadVideo *>*doneVideoArray;

/**
 选中的编辑列表
 */
@property (nonatomic, strong) NSMutableArray <AVCDownloadVideo *>*editVideoArray;

/**
 准备下载的视频参数
 */
@property (nonatomic, strong) AliyunDataSource *readyDataSource;

///**
// 准备好的某原视频对应的各清晰度的下载数据
// */
//@property (nonatomic, strong) NSArray <AliyunDownloadMediaInfo *>*prepareMediaInfos;

/**
 记录之前竖屏状态下在哪个界面 0:播放列表 1：日志， 2：离线视频
 */
@property (assign, nonatomic) NSInteger logOrDownload;

/**
 提示框
 */
@property (strong, nonatomic) MBProgressHUD *hud;

/**
 全屏状态下是否点击了查看离线视频
 */
@property (assign, nonatomic) BOOL isLookingVideoWhenFullScreen;


@end

@implementation AVC_VP_VideoPlayViewController

#pragma mark - Lazy init
- (NSMutableArray <AVCDownloadVideo *>*)downloadingVideoArray{
    if (!_downloadingVideoArray) {
        _downloadingVideoArray = [[NSMutableArray alloc]init];
    }
    return _downloadingVideoArray;
}

- (NSMutableArray <AVCDownloadVideo *>*)doneVideoArray{
    if (!_doneVideoArray) {
        _doneVideoArray = [[NSMutableArray alloc]init];
    }
    return _doneVideoArray;
}

- (NSMutableArray <AVCDownloadVideo *>*)editVideoArray{
    if (!_editVideoArray) {
        _editVideoArray = [[NSMutableArray alloc]init];
    }
    return _editVideoArray;
}

/**
 播放视图
 */
- (AliyunVodPlayerView *__nullable)playerView{
    if (!_playerView) {
        CGFloat width = 0;
        CGFloat height = 0;
        CGFloat topHeight = 0;
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
        if (orientation == UIInterfaceOrientationPortrait ) {
            width = ScreenWidth;
            height = ScreenWidth * 9 / 16.0;
            topHeight = 20;
        }else{
            width = ScreenWidth;
            height = ScreenHeight;
            topHeight = 20;
        }
        /****************UI播放器集成内容**********************/
        _playerView = [[AliyunVodPlayerView alloc] initWithFrame:CGRectMake(0,topHeight, width, height) andSkin:AliyunVodPlayerViewSkinRed];
//        _playerView.circlePlay = YES;
        [_playerView setDelegate:self];
        [_playerView setAutoPlay:YES];
        
        [_playerView setPrintLog:YES];
        
        _playerView.isScreenLocked = false;
        _playerView.fixedPortrait = false;
        self.isLock = self.playerView.isScreenLocked||self.playerView.fixedPortrait?YES:NO;
        
        //边下边播缓存沙箱位置
        NSArray *pathArray = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docDir = [pathArray objectAtIndex:0];
        //maxsize:单位 mb    maxDuration:单位秒 ,在prepare之前调用。
        [_playerView setPlayingCache:NO saveDir:docDir maxSize:300 maxDuration:10000];
    }
    return _playerView;
}


- (UIView *)exchangeContainView{
    if (!_exchangeContainView) {
        CGFloat eHeight = kExchangeHeight;
        _exchangeContainView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ScreenWidth, eHeight)];
        CGPoint eCenter = CGPointMake(ScreenWidth / 2, self.playerView.frame.size.height +20+ eHeight / 2);
        
        
        if(IPHONEX){
            eCenter = CGPointMake(eCenter.x, eCenter.y + 16);
        }

        _exchangeContainView.center = eCenter;
        _exchangeContainView.backgroundColor = [UIColor clearColor];
        UILabel *devideLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, _exchangeContainView.frame.size.height - 1, _exchangeContainView.frame.size.width, 1)];
        devideLabel.backgroundColor = [UIColor colorWithRed:216/255.0 green:216/255.0 blue:216/255.0 alpha:0.5];
        [_exchangeContainView addSubview:devideLabel];
        
        [_exchangeContainView addSubview:self.listButton];
        [_exchangeContainView addSubview:self.logButton];
        [_exchangeContainView addSubview:self.offLineVideoButton];
        [_exchangeContainView addSubview:self.exchangeLineView];
    }
    return _exchangeContainView;
}

- (UIView *)exchangeLineView{
    if (!_exchangeLineView) {
        _exchangeLineView = [[UIView alloc]initWithFrame:CGRectMake(0, self.exchangeContainView.frame.size.height - 2, ScreenWidth / 3, 2)];
        _exchangeLineView.backgroundColor = [UIColor colorWithHexString:@"00c1de"];
    }
    return _exchangeLineView;
}

- (UIButton *)listButton{
    if (!_listButton) {
        _listButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_listButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_listButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [_listButton setFrame:CGRectMake(0, 0, self.exchangeContainView.frame.size.width / 3, self.exchangeContainView.frame.size.height)];
        [_listButton setTitle:[@"视频列表" localString] forState:UIControlStateNormal];
        [_listButton setTitle:[@"视频列表" localString] forState:UIControlStateSelected];
        [_listButton setTitleEdgeInsets:UIEdgeInsetsMake(10, 0, 0, 0)];
        [_listButton addTarget:self action:@selector(listButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    }
    return _listButton;
}

- (UIButton *)logButton{
    if (!_logButton) {
        _logButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_logButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_logButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [_logButton setFrame:CGRectMake(self.exchangeContainView.frame.size.width / 3, 0, self.exchangeContainView.frame.size.width / 3, self.exchangeContainView.frame.size.height)];
        [_logButton setTitle:[@"日志" localString] forState:UIControlStateNormal];
        [_logButton setTitle:[@"日志" localString] forState:UIControlStateSelected];
        [_logButton setTitleEdgeInsets:UIEdgeInsetsMake(10, 0, 0, 0)];
        [_logButton addTarget:self action:@selector(logButtonTouched) forControlEvents:UIControlEventTouchUpInside];
    }
    return _logButton;
}

- (UIButton *)offLineVideoButton{
    if (!_offLineVideoButton) {
        _offLineVideoButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_offLineVideoButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_offLineVideoButton setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [_offLineVideoButton setFrame:CGRectMake(self.exchangeContainView.frame.size.width*2 / 3, 0, self.exchangeContainView.frame.size.width / 3, self.exchangeContainView.frame.size.height)];
        [_offLineVideoButton setTitle:[@"离线视频" localString] forState:UIControlStateNormal];
        [_offLineVideoButton setTitle:[@"离线视频" localString] forState:UIControlStateSelected];
        [_offLineVideoButton setTitleEdgeInsets:UIEdgeInsetsMake(10, 0, 0, 0)];
        [_offLineVideoButton addTarget:self action:@selector(offLineVideoButtonTouched) forControlEvents:UIControlEventTouchUpInside];
        CGFloat width = 8;
        self.redView = [[UIView alloc]initWithFrame:CGRectMake(_offLineVideoButton.frame.size.width - 26, 16, width, width)];
        self.redView.layer.cornerRadius = width / 2;
        self.redView.clipsToBounds = true;
        self.redView.hidden = true;
        self.redView.backgroundColor = [UIColor redColor];
        [_offLineVideoButton addSubview:self.redView];
    }
    return _offLineVideoButton;
}

- (AlivcPlayListsView *)listView{
    if (!_listView) {
        CGFloat increat = 0;
        if(IPHONEX){
            increat = 16;
        }
        CGFloat y = self.playerView.frame.size.height + 20 + self.exchangeContainView.frame.size.height + increat;
        _listView = [[AlivcPlayListsView alloc]initWithFrame:CGRectMake(0, y, ScreenWidth, ScreenHeight - y)];
        _listView.delegate = self;
    }
    return _listView;
}


- (AVCLogView *)logView{
    if (!_logView) {
        CGFloat y = self.playerView.frame.size.height + 20 + self.exchangeContainView.frame.size.height;
        if(IPHONEX){
            y += 16;
        }
        _logView = [[AVCLogView alloc]initWithFrame:CGRectMake(0, y, ScreenWidth, ScreenHeight - y)];
        _logView.hidden = YES;
    }
    return _logView;
}

- (UIView *)downloadContainView{
    if (!_downloadContainView) {
        CGFloat y = self.playerView.frame.size.height + 20 + self.exchangeContainView.frame.size.height;
        if(IPHONEX){
            y += 16;
        }
        _downloadContainView = [[UIView alloc]initWithFrame:CGRectMake(0, y, ScreenWidth, ScreenHeight - y)];
        _downloadContainView.backgroundColor = [UIColor clearColor];
        [_downloadContainView addSubview:self.downloadTableView];
        [_downloadContainView addSubview:self.downloadEditContainView];
        _downloadContainView.hidden = YES;
    }
    return _downloadContainView;
}

- (UITableView *)downloadTableView{
    if (!_downloadTableView) {
//        CGFloat y = self.playerView.frame.size.height + self.exchangeContainView.frame.size.height;
        _downloadTableView = [[UITableView alloc]init];
        _downloadTableView.frame = CGRectMake(0, 0, ScreenWidth, _downloadContainView.frame.size.height - 50);
        [_downloadTableView registerNib:[UINib nibWithNibName:@"AVCVideoDownloadTCell" bundle:nil] forCellReuseIdentifier:@"AVCVideoDownloadTCell"];
        _downloadTableView.tableFooterView = [UIView new];
        _downloadTableView.dataSource = self;
        _downloadTableView.delegate = self;
        _downloadTableView.backgroundColor = [AlivcUIConfig shared].kAVCBackgroundColor;
        [_downloadTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
        
    }
    return _downloadTableView;
}

- (UIView *)downloadEditContainView{
    if (!_downloadEditContainView) {
        _downloadEditContainView = [[UIView alloc]initWithFrame:CGRectMake(0, self.downloadTableView.frame.size.height, ScreenWidth, 50)];
        [_downloadContainView setBackgroundColor:[UIColor colorWithHexString:@"373d41"]];
    }
    return _downloadEditContainView;
}

- (UIView *)downloadGestureView{
    if (!_downloadGestureView) {
        _downloadGestureView = [[UIView alloc]init];
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tapDownloadSpace)];
        [_downloadGestureView addGestureRecognizer:gesture];
        [_downloadGestureView setBackgroundColor:[UIColor clearColor]];
    }
    return _downloadGestureView;
}

//- (BOOL)isIphone8PAndIOS12{
//    struct utsname systemInfo;
//    uname(&systemInfo);
//    NSString *platform = [NSString stringWithCString:systemInfo.machine encoding:NSASCIIStringEncoding];
//    CGFloat version = [[[UIDevice currentDevice] systemVersion]floatValue];
//    if (([platform isEqualToString:@"iPhone10,2"] || [platform isEqualToString:@"iPhone10,5"]) && version > 11.9){
//        return YES;
//    }
//    return NO;
//}


#pragma mark - System Method

- (void)viewDidLoad {
    [super viewDidLoad];
    AliyunVodDownLoadManager *downloadManager = [AliyunVodDownLoadManager shareManager];
    [downloadManager setMaxDownloadOperationCount:4];
    [downloadManager downLoadInfoListenerDelegate:self];
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //只调一次
        NSString *encrptyFilePath = [[NSBundle mainBundle]pathForResource:@"encryptedApp" ofType:@"dat"];
        [downloadManager setEncrptyFile:encrptyFilePath];
        NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
        [downloadManager setDownLoadPath:path];
    });
    
    [self configBaseUI];
    [self configBaseDataSuccess:^{
        [self startPlayVideo];
    }];
    [self loadLocalVideo];

    /**************************************/
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(becomeActive)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(resignActive)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];
    //网络状态判定
    _reachability = [AliyunReachability reachabilityForInternetConnection];
    [_reachability startNotifier];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(reachabilityChanged)
                                                 name:AliyunPVReachabilityChangedNotification
                                               object:nil];
    
    NSLog(@"%@",[self.playerView getSDKVersion]);
}


- (void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [self destroyPlayVideo];
//    //保存正在下载的视频信息
//    for(AVCDownloadVideo *video in self.downloadingVideoArray){
//        [[AlivcVideoDataBase shared]addVideo:video];
//    }
}

- (void)returnAction{
    BOOL haveDownloadingVideo = false;
    if (self.downloadingVideoArray.count > 0) {
        for (AVCDownloadVideo *video in self.downloadingVideoArray) {
            if (video.downloadStatus == AVCDownloadStatusDownloading) {
                haveDownloadingVideo = true;
                break;
            }
        }
    }
    if (haveDownloadingVideo) {
        AlivcAlertView *alertView = [[AlivcAlertView alloc]initWithAlivcTitle:nil message:@"当前有视频在下载中,退出界面将暂停下载任务" delegate:self cancelButtonTitle:@"取消"  confirmButtonTitle:@"继续退出"];
        alertView.tag = alertViewTag_exit_continue;
        [alertView show];
    }else{
        [self.navigationController popViewControllerAnimated:true];
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.hidden = true;
    
    NSLog(@"self view y:%f",self.view.frame.origin.y);
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.hidden = false;
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
}

- (void)configChanged{
    [self startPlayVideo];
}

//适配iphone x 界面问题，没有在 viewSafeAreaInsetsDidChange 这里做处理 ，主要 旋转监听在 它之后获取。
-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    NSString *platform =  [self iphoneType];
    CGFloat width = 0;
    CGFloat height = 0;
    CGFloat topHeight = 0;
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationPortrait ) {
        width = ScreenWidth;
        height = ScreenWidth * 9 / 16.0;
        topHeight = 20;
        [self changeDownloadViewFrameWhenFullScreen:false];
        [self refreshUIWhenScreenChanged:false];
    }else{
        width = ScreenWidth;
        height = ScreenHeight;
        topHeight = 0;
        [self changeDownloadViewFrameWhenFullScreen:true];
        [self refreshUIWhenScreenChanged:true];
    }
    CGRect tempFrame = CGRectMake(0,topHeight, width, height);
//    UIDevice *device = [UIDevice currentDevice] ;
    //iphone x
    if (![platform isEqualToString:@"iPhone10,3"] && ![platform isEqualToString:@"iPhone10,6"]) {
        switch (orientation) {
            case UIInterfaceOrientationUnknown:
            case UIInterfaceOrientationPortraitUpsideDown:
            {
                
            }
                break;
            case UIInterfaceOrientationPortrait:
            {
                self.playerView.frame = tempFrame;
            }
                break;
            case UIInterfaceOrientationLandscapeLeft:
            case UIInterfaceOrientationLandscapeRight:
            {
//                self.playerView.frame = CGRectMake(0,0,ScreenWidth,ScreenHeight);
                self.playerView.frame = tempFrame;
            }
                break;
                
            default:
                break;
        }
        [self.selectView layoutSubviews];
//        switch (device.orientation) {//device.orientation
//            case UIDeviceOrientationFaceUp:
//            case UIDeviceOrientationFaceDown:
//            case UIDeviceOrientationUnknown:
//            case UIDeviceOrientationPortraitUpsideDown:
//                break;
//            case UIDeviceOrientationLandscapeLeft:
//            case UIDeviceOrientationLandscapeRight:
//            {
//                self.playerView.frame = CGRectMake(0,0,ScreenWidth,ScreenHeight);
//            }
//                break;
//            case UIDeviceOrientationPortrait:
//            {
//                self.playerView.frame = tempFrame;
//            }
//                break;
//            default:
//
//                break;
//        }
        return;
    }
    
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 110000
    
    switch (orientation) {
        case UIInterfaceOrientationUnknown:
        case UIInterfaceOrientationPortraitUpsideDown:
        {
            if (self.isStatusHidden) {
                CGRect frame = self.playerView.frame;
                frame.origin.x = VIEWSAFEAREAINSETS(self.view).left;
                frame.origin.y = VIEWSAFEAREAINSETS(self.view).top;
                frame.size.width = ScreenWidth-VIEWSAFEAREAINSETS(self.view).left*2;
                frame.size.height = ScreenHeight-VIEWSAFEAREAINSETS(self.view).bottom-VIEWSAFEAREAINSETS(self.view).top;
                self.playerView.frame = frame;
            }else{
                CGRect frame = self.playerView.frame;
                frame.origin.y = VIEWSAFEAREAINSETS(self.view).top;
                //竖屏全屏时 isStatusHidden 来自是否 旋转回调。
                if (self.playerView.fixedPortrait&&self.isStatusHidden) {
                    frame.size.height = ScreenHeight- VIEWSAFEAREAINSETS(self.view).top- VIEWSAFEAREAINSETS(self.view).bottom;
                }
                self.playerView.frame = frame;
            }
        }
            break;
        case UIInterfaceOrientationPortrait:
        {
            width = ScreenWidth;
            height = ScreenWidth * 9 / 16.0;
            topHeight = 20;
            [self changeDownloadViewFrameWhenFullScreen:false];
            [self refreshUIWhenScreenChanged:false];
            
            CGRect frame = CGRectMake(0, topHeight, width, height);
            frame.origin.y = VIEWSAFEAREAINSETS(self.view).top;
            //竖屏全屏时 isStatusHidden 来自是否 旋转回调。
            if (self.playerView.fixedPortrait&&self.isStatusHidden) {
                frame.size.height = ScreenHeight- VIEWSAFEAREAINSETS(self.view).top- VIEWSAFEAREAINSETS(self.view).bottom;
            }
            self.playerView.frame = frame;
        }
            break;
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
        {
            CGRect frame = self.playerView.frame;
            frame.origin.x = VIEWSAFEAREAINSETS(self.view).left;
            frame.origin.y = VIEWSAFEAREAINSETS(self.view).top;
            frame.size.width = ScreenWidth-VIEWSAFEAREAINSETS(self.view).left*2;
            frame.size.height = ScreenHeight-VIEWSAFEAREAINSETS(self.view).bottom;
            self.playerView.frame = frame;
        }
            break;
            
        default:
            break;
    }
    
//    switch (device.orientation) {//device.orientation
//        case UIDeviceOrientationFaceUp:
//        case UIDeviceOrientationFaceDown:
//        case UIDeviceOrientationUnknown:
//        case UIDeviceOrientationPortraitUpsideDown:{
//            if (self.isStatusHidden) {
//                CGRect frame = self.playerView.frame;
//                frame.origin.x = VIEWSAFEAREAINSETS(self.view).left;
//                frame.origin.y = VIEWSAFEAREAINSETS(self.view).top;
//                frame.size.width = ScreenWidth-VIEWSAFEAREAINSETS(self.view).left*2;
//                frame.size.height = ScreenHeight-VIEWSAFEAREAINSETS(self.view).bottom-VIEWSAFEAREAINSETS(self.view).top;
//                self.playerView.frame = frame;
//            }else{
//                CGRect frame = self.playerView.frame;
//                frame.origin.y = VIEWSAFEAREAINSETS(self.view).top;
//                //竖屏全屏时 isStatusHidden 来自是否 旋转回调。
//                if (self.playerView.fixedPortrait&&self.isStatusHidden) {
//                    frame.size.height = ScreenHeight- VIEWSAFEAREAINSETS(self.view).top- VIEWSAFEAREAINSETS(self.view).bottom;
//                }
//                self.playerView.frame = frame;
//            }
//        }
//            break;
//        case UIDeviceOrientationLandscapeLeft:
//        case UIDeviceOrientationLandscapeRight:
//        {
//            //
//            CGRect frame = self.playerView.frame;
//            frame.origin.x = VIEWSAFEAREAINSETS(self.view).left;
//            frame.origin.y = VIEWSAFEAREAINSETS(self.view).top;
//            frame.size.width = ScreenWidth-VIEWSAFEAREAINSETS(self.view).left*2;
//            frame.size.height = ScreenHeight-VIEWSAFEAREAINSETS(self.view).bottom;
//            self.playerView.frame = frame;
//        }
//
//            break;
//        case UIDeviceOrientationPortrait:
//        {
//            //
//            CGRect frame = self.playerView.frame;
//            frame.origin.y = VIEWSAFEAREAINSETS(self.view).top;
//            //竖屏全屏时 isStatusHidden 来自是否 旋转回调。
//            if (self.playerView.fixedPortrait&&self.isStatusHidden) {
//                frame.size.height = ScreenHeight- VIEWSAFEAREAINSETS(self.view).top- VIEWSAFEAREAINSETS(self.view).bottom;
//            }
//            self.playerView.frame = frame;
//        }
//
//            break;
//        default:
//
//            break;
//    }
//
#else
    
#endif
    
}

- (void)configBaseUI{
    [self.view addSubview:self.playerView];
    [self.view addSubview:self.exchangeContainView];
    [self.view addSubview:self.listView];
    [self.view addSubview:self.logView];
    [self.view addSubview:self.downloadContainView];
    self.downloadContainView.hidden = true;
    [self configDownloadEditView:self.isEdit];
}

- (void)configBaseDataSuccess:(void(^)(void))success{
    
    //加载默认的STS数据
    self.config = [[AVCVideoConfig alloc]init];
    self.config.playMethod = AliyunPlayMedthodSTS;
    
    NSString *defaultVidString = @"6e783360c811449d8692b2117acc9212";
    [AlivcAppServer getStsDataWithVid:defaultVidString sucess:^(NSString *accessKeyId, NSString *accessKeySecret, NSString *securityToken) {
        self.config.stsAccessKeyId = accessKeyId;
        self.config.stsAccessSecret = accessKeySecret;
        self.config.stsSecurityToken = securityToken;
        //查询视频列表
        [AlivcVideoPlayManager requestPlayListVodPlayWithAccessKeyId:self.config.stsAccessKeyId accessSecret:self.config.stsAccessSecret securityToken:self.config.stsSecurityToken cateId:@"472183517" pageNo:1 pageCount:10 sucess:^(NSArray *ary, long total) {
            self.listView.dataAry = ary;
            AlivcVideoPlayListModel *model = ary.firstObject;
            self.config.videoId = model.videoId;
            self.config.playMethod = AliyunPlayMedthodSTS;
            //赋值
            for(AlivcVideoPlayListModel *itemModel in ary){
                itemModel.stsAccessKeyId = self.config.stsAccessKeyId;
                itemModel.stsAccessSecret = self.config.stsAccessSecret;
                itemModel.stsSecurityToken = self.config.stsSecurityToken;
            }
            if (success) {
                success();
            }
        } failure:^(NSString *errString) {
            //
        }];
    } failure:^(NSString *errorString) {
        [MBProgressHUD showMessage:errorString inView:self.view];
    }];
}

- (void)loadLocalVideo{
    //离线视频
    [self.doneVideoArray removeAllObjects];
    [self.downloadingVideoArray removeAllObjects];
    NSArray *videos = [[AlivcVideoDataBase shared]getAllVideo];
    for (AVCDownloadVideo *video in videos) {
        if ([video.video_status integerValue] == AVCDownloadStatusDone) {
            [self.doneVideoArray addObject:video];
            
        }else{
            video.downloadStatus = AVCDownloadStatusPause;
            [self.downloadingVideoArray addObject:video];
        }
    }
    [self.downloadTableView reloadData];
}


/**
 开始播放视频
 */
- (void)startPlayVideo{
    if (self.config.isLocal) {
        [self.playerView reset];
        [self.playerView setTitle:self.config.videoTitle];
        [self.playerView playViewPrepareWithLocalURL:self.config.videoUrl];
    }else{
        [self.playerView stop];
    
        [self.playerView reset];//不显示最后一帧
        //播放器播放方式
        if (!self.config) {
            self.config = [[AVCVideoConfig alloc] init];
        }
        
        switch (self.config.playMethod) {
            case AliyunPlayMedthodURL:
            {
                [self.playerView playViewPrepareWithURL:self.config.videoUrl];
            }
                break;
            case AliyunPlayMedthodSTS:
            {
                [self.playerView playViewPrepareWithVid:self.config.videoId
                                            accessKeyId:self.config.stsAccessKeyId
                                        accessKeySecret:self.config.stsAccessSecret
                                          securityToken:self.config.stsSecurityToken];
            }
                break;
            default:
                break;
        }
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Custom Method

#pragma mark - UI Refresh
/**
 刷新UI，全屏和非全屏切换的时候

 @param isFullScreen 是否全屏
 */
- (void)refreshUIWhenScreenChanged:(BOOL)isFullScreen{
    if (isFullScreen) {
//        self.selectView.hidden = true;
        self.exchangeContainView.hidden = true;
        self.logView.hidden = true;
        if (!self.isLookingVideoWhenFullScreen) {
            self.downloadContainView.hidden = true;
        }
        
        self.listView.hidden = YES;
    }else{
        self.isLookingVideoWhenFullScreen = false;
//        self.selectView.hidden = false;
        self.exchangeContainView.hidden = false;
        self.downloadContainView.hidden = false;
        self.listView.hidden = NO;
        switch (self.logOrDownload) {
            case 0:
                [self listButtonTouched];
                break;
            case 1:
                 [self logButtonTouched];
                break;
            case 2:
                [self offLineVideoButtonTouched];
                break;
                
            default:
                break;
        }
       
    }
}

/**
 全屏状态下显示视频下载列表视图
 */
- (void)showDownloadTableViewWhenFullScreen{
    if (ScreenWidth > ScreenHeight) {
        self.isLookingVideoWhenFullScreen = true;
        self.downloadContainView.hidden = false;
        [self.view addSubview:self.downloadGestureView];
        [self changeDownloadViewFrameWhenFullScreen:true];
    }
}


/**
 全屏状态下隐藏视频下载列表视图
 */
- (void)dismissDownloadTableViewWhenFullScreen{
    if (ScreenWidth > ScreenHeight) {
        self.isLookingVideoWhenFullScreen = false;
        self.downloadContainView.hidden = true;
        [self.downloadGestureView removeFromSuperview];
    }
}

/**
 调整下载列表视图的frame以及其中子视图的frame
 
 @param isFullScreen 是否全屏
 */
- (void)changeDownloadViewFrameWhenFullScreen:(BOOL)isFullScreen{
    if (!isFullScreen) {
        //竖屏
        CGFloat y = self.playerView.frame.size.height + 20 + self.exchangeContainView.frame.size.height;
        if (IPHONEX) {
            y += 16;
        }
        _downloadContainView.frame = CGRectMake(0, y, ScreenWidth, ScreenHeight - y);
        [self.downloadGestureView removeFromSuperview];
    }else{
        //全屏
        CGRect frame = self.downloadContainView.frame;
        frame.size.height = ScreenHeight;
        frame.origin.x = ScreenWidth - frame.size.width;
        frame.origin.y = 0;
        self.downloadContainView.frame = frame;
        //        self.downloadContainView.backgroundColor = [UIColor redColor];
        self.downloadGestureView.frame = CGRectMake(0, 0, ScreenWidth - frame.size.width, ScreenHeight);
    }
    _downloadTableView.frame = CGRectMake(0, 0, self.downloadContainView.frame.size.width, _downloadContainView.frame.size.height - 50);
    _downloadEditContainView.frame = CGRectMake(0, self.downloadTableView.frame.size.height, self.downloadContainView.frame.size.width, 50);
//    [self configDownloadEditView:self.isEdit]; //防止iPhone 5s下
}


/**
 适配让下载视频列表界面是否进入编辑模式

 @param isEdit 是否是编辑模式
 */
- (void)refreshUIWhenDownloadVideoIsEdit:(BOOL)isEdit{
    [self configDownloadEditView:isEdit];
    [self.downloadTableView reloadData];
}

/**
 适配下载编辑视图

 @param isEdit 是否在编辑
 */
- (void)configDownloadEditView:(BOOL)isEdit{
    self.downloadEditContainView.backgroundColor = [UIColor darkGrayColor];
    for (UIView *view in self.downloadEditContainView.subviews) {
        [view removeFromSuperview];
    }
    if (isEdit) {
        //全选
        UIButton *allButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, 100, self.downloadEditContainView.frame.size.height)];
        [allButton addTarget:self action:@selector(selectAll:) forControlEvents:UIControlEventTouchUpInside];
        [allButton setTitle:@" 全选" forState:UIControlStateNormal];
        [allButton setImage:[UIImage imageNamed:@"avcDownloadNormal"] forState:UIControlStateNormal];
        [allButton setImage:[UIImage imageNamed:@"avcSelected"] forState:UIControlStateSelected];
        [self.downloadEditContainView addSubview:allButton];
        allButton.selected = self.isAllSelected;
        //删除
        UIButton *deleteButton = [[UIButton alloc]initWithFrame:CGRectMake(self.downloadEditContainView.frame.size.width - 120, 0, 50, 50)];
        [deleteButton setImage:[UIImage imageNamed:@"avcDelete"] forState:UIControlStateNormal];
        [deleteButton addTarget:self action:@selector(deleteDownloadVideo) forControlEvents:UIControlEventTouchUpInside];
        [self.downloadEditContainView addSubview:deleteButton];
        //cancel的按钮
        UIButton *cancelButton = [[UIButton alloc]init];
        cancelButton.frame = CGRectMake(CGRectGetMaxX(deleteButton.frame) + 8, 0, 50, self.downloadEditContainView.frame.size.height);
        [cancelButton addTarget:self action:@selector(endEdit) forControlEvents:UIControlEventTouchUpInside];
        [cancelButton setImage:[UIImage imageNamed:@"avcClose"] forState:UIControlStateNormal];
        [self.downloadEditContainView addSubview:cancelButton];
    }else{
        
        UIButton *editButton = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, self.downloadEditContainView.frame.size.width, self.downloadEditContainView.frame.size.height)];
        [editButton setTitle:@"编辑" forState:UIControlStateNormal];
        [editButton addTarget:self action:@selector(editVideo) forControlEvents:UIControlEventTouchUpInside];
        [self.downloadEditContainView addSubview:editButton];
    }
}


- (void)destroyPlayVideo{
    if (_playerView != nil) {
        [_playerView stop];
        [_playerView releasePlayer];
        [_playerView removeFromSuperview];
        _playerView = nil;
    }
}
#pragma mark - Response

- (void)listButtonTouched{
    self.listView.hidden = NO;
    self.logOrDownload = 0;
    
    self.downloadContainView.hidden = true;
    self.logView.hidden = YES;
    
    CGFloat cx = self.exchangeContainView.frame.size.width * 1 / 6;
    CGFloat cy = self.exchangeLineView.center.y;
    [UIView animateWithDuration:0.5 animations:^{
        self.exchangeLineView.center = CGPointMake(cx, cy);
    }];
}

- (void)logButtonTouched{
    self.logView.hidden = false;
    self.logOrDownload = 1;
    
    self.listView.hidden = YES;
    self.downloadContainView.hidden = true;
    
    CGFloat cx = self.exchangeContainView.frame.size.width *1  /2;
    CGFloat cy = self.exchangeLineView.center.y;
    [UIView animateWithDuration:0.5 animations:^{
        self.exchangeLineView.center = CGPointMake(cx, cy);
    }];
}

- (void)offLineVideoButtonTouched{
    self.redView.hidden = true;
    if (ScreenWidth < ScreenHeight) {
        self.logView.hidden = true;
        self.logOrDownload = 2;
        
        self.listView.hidden = YES;
        self.downloadContainView.hidden = false;
        
        CGFloat cx = self.exchangeContainView.frame.size.width * 5 / 6;
        CGFloat cy = self.exchangeLineView.center.y;
        [UIView animateWithDuration:0.5 animations:^{
            self.exchangeLineView.center = CGPointMake(cx, cy);
        }];
    }
   
}

- (void)becomeActive{
    self.isBecome = NO;
    if (!self.isPresent) {
        NSLog(@"播放器状态:%ld",(long)self.playerView.playerViewState);
        if (self.playerView){
           [self.playerView resume];
        }
    }
   
}

- (void)resignActive{
    if (self.isPresent) {
        self.isBecome = YES;
    }
    if (_playerView){
        [self.playerView pause];
    }
}

- (NSString*)iphoneType {
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString*platform = [NSString stringWithCString: systemInfo.machine encoding:NSASCIIStringEncoding];
    return platform;
}

- (void)editVideo{
    self.isEdit = true;
    self.editVideoArray = [[NSMutableArray alloc]init];
    [self refreshUIWhenDownloadVideoIsEdit:true];
}

- (void)selectAll:(UIButton *__nullable)button{
    button.selected = !button.isSelected;
    self.isAllSelected = button.selected;
    if (button.selected) {
        
        if (self.downloadingVideoArray.count > 0) {
            [self.editVideoArray addObjectsFromArray:self.downloadingVideoArray];
        }
        if (self.doneVideoArray.count > 0) {
            [self.editVideoArray addObjectsFromArray:self.doneVideoArray];
        }
        
    }else{
        [self.editVideoArray removeAllObjects];
    }
    [self.downloadTableView reloadData];
}

- (void)deleteDownloadVideo{
    if (self.editVideoArray.count == 0) {
        [MBProgressHUD showMessage:@"请选择至少一个视频" inView:self.view];
    }else{
        AlivcAlertView *alertView = [[AlivcAlertView alloc]initWithAlivcTitle:nil message:@"确定要删除选中的视频吗？" delegate:self cancelButtonTitle:@"取消" confirmButtonTitle:@"确定"];
        alertView.tag = alertViewTag_delete_video;
        [alertView showInView:self.view];
    }
    
}

- (void)endEdit{
    self.isEdit = false;
    [self refreshUIWhenDownloadVideoIsEdit:false];
}

//横屏下下载列表空白区域点击
- (void)tapDownloadSpace{
    [self dismissDownloadTableViewWhenFullScreen];
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == alertViewTag_downLoad_continue) {
        if (buttonIndex == 1) {
            [self prepareTODownLoadWithVideoId:self.config.videoId];
            return;
        }
    }
 
    if (alertView.tag == alertViewTag_delete_video) {
        if (buttonIndex == 1) {
            for (AVCDownloadVideo *video in self.editVideoArray) {
                if (video.downloadStatus == AVCDownloadStatusDone) {
                    //删除文件
                    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
                    NSString *filePath = [NSString stringWithFormat:@"%@/%@",path,video.video_fileName];
                    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
                        NSError *error = nil;
                        [[NSFileManager defaultManager]removeItemAtPath:filePath error:&error];
                        if (error) {
                            [MBProgressHUD showWarningMessage:[NSString stringWithFormat:@"本地文件删除错误:%@",error.description] inView:self.view];
                        }else{
                            //数据库删除内容
                            BOOL deleteSucess = [[AlivcVideoDataBase shared]deleteVideo:video];
                            if (deleteSucess) {
                                //删除本地的变量中的数据
                                [self.downloadingVideoArray removeObject:video];
                                [self.doneVideoArray removeObject:video];
                                [MBProgressHUD showWarningMessage:@"视频已删除" inView:self.view];
                                if (video.mediaInfo) {
                                   [[AliyunVodDownLoadManager shareManager]clearMedia:video.mediaInfo];
                                }else{
                                    AliyunDownloadMediaInfo *info = [[AliyunDownloadMediaInfo alloc]init];
                                    info.vid = video.video_id;
                                    info.quality = [video.video_quality integerValue];
                                    info.format = video.video_format;
                                    [[AliyunVodDownLoadManager shareManager]clearMedia:info];
                                }
                            }
                        }
                    }else{
                        [MBProgressHUD showWarningMessage:@"找不到删除路径" inView:self.view];
                    }
                    
                }else{
                    //停止下载
                    [[AliyunVodDownLoadManager shareManager]stopDownloadMedia:video.mediaInfo];
                    //数据库删除内容
                    BOOL deleteSucess = [[AlivcVideoDataBase shared]deleteVideo:video];
                    if (deleteSucess) {
                        //删除本地的变量中的数据
                        [self.downloadingVideoArray removeObject:video];
                        [self.doneVideoArray removeObject:video];
                        
                    }
                }
            }
            self.isEdit = false;
            [self refreshUIWhenDownloadVideoIsEdit:self.isEdit];
        }
        return;
    }
    
    if (alertView.tag == alertViewTag_exit_continue) {
        if (buttonIndex == 1) {
            //
            [self.navigationController popViewControllerAnimated:true];
        }
    }
}


#pragma mark - UITableViewDataSource

- (NSInteger )numberOfSectionsInTableView:(UITableView *)tableView{
    NSInteger sections = 0;
    if (self.downloadingVideoArray.count > 0) {
        sections += 1;
    }
    if (self.doneVideoArray.count > 0) {
        sections += 1;
    }
    return sections;
}

- (NSInteger )tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    switch (section) {
        case 0:{
            if (self.downloadingVideoArray.count > 0) {
                return  self.downloadingVideoArray.count;
            }else{
                return self.doneVideoArray.count;
            }
        }
            break;
        case 1:{
            return self.doneVideoArray.count;
        }
            
        default:
            return 0;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    AVCVideoDownloadTCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AVCVideoDownloadTCell"];
    AVCDownloadVideo *video = nil;
    switch (indexPath.section) {
        case 0:
            if (self.downloadingVideoArray.count > 0 && indexPath.row < self.downloadingVideoArray.count) {
                video = self.downloadingVideoArray[indexPath.row];
            }else if(indexPath.row < self.doneVideoArray.count){
                video = self.doneVideoArray[indexPath.row];
            }
            break;
        case 1:
            if (indexPath.row < self.doneVideoArray.count) {
                video = self.doneVideoArray[indexPath.row];
            }
            
            break;
            
        default:
            break;
    }
    cell.delegate = self;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if (video) {
        [cell configWithVideo:video];
        //选中状态根据self.editVideoArray来适配，保证ui和数据的统一
        BOOL haveSelected = false;
        for (AVCDownloadVideo *editVideo in self.editVideoArray) {
            if ([editVideo isSameWithOtherVideo:video]) {
                haveSelected = true;
                break;
            }
        }
        [cell setSelectedCustom:haveSelected];
        
    }
    [cell setTOEditStyle:self.isEdit];
    
    return cell;
}



- (NSString *)titleStringForHeaderInSection:(NSInteger)section{
    switch (section) {
        case 0:
            if (self.downloadingVideoArray.count > 0) {
                return [@"  正在缓存" localString];
            }else{
                return [@"  已缓存" localString];
            }
            break;
        case 1:
            return [@"  已缓存" localString];
            
        default:
            break;
    }
    return @"";
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 100, 30)];
    titleLabel.text = [self titleStringForHeaderInSection:section];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = [UIColor whiteColor];
    [titleLabel sizeToFit];
    return titleLabel;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 30.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100.0f;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
   
    AVCDownloadVideo *video = nil;
    switch (indexPath.section) {
        case 0:{
            if (self.downloadingVideoArray.count > 0) {
                if (indexPath.row < self.downloadingVideoArray.count) {
                    video = self.downloadingVideoArray[indexPath.row];
                }
                
            }else{
                if (indexPath.row < self.doneVideoArray.count) {
                    video = self.doneVideoArray[indexPath.row];
                }
            }
        }
            break;
        case 1:{
            if (indexPath.row < self.doneVideoArray.count) {
                    video = self.doneVideoArray[indexPath.row];
            }
        }
            
        default:
           
            break;
    }
   
    if (video) {
        if (self.isEdit) {
            //切换选中非选中状态
            AVCVideoDownloadTCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            BOOL selected = !cell.customSelected;
            [cell setSelectedCustom:selected];
            if (selected) {
                [self.editVideoArray addObject:video];
            }else{
                [self.editVideoArray removeObject:video];
            }
            
        }else{
            //播放视频
            [self changeToPlayLocalVideo:video];
        }
        
    }
}

- (void)changeToPlayLocalVideo:(AVCDownloadVideo *)video{
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
    NSString *str = [NSString stringWithFormat:@"%@/%@",path,video.video_fileName];
    self.config.playMethod = AliyunPlayMedthodURL;
    self.config.isLocal = true;
    self.config.videoUrl = [NSURL URLWithString:str];
    self.config.video_quality = video.video_quality;
    self.config.video_format = video.video_format;
    self.config.videoId = video.video_id;
    self.config.videoTitle = video.video_title;
    [self startPlayVideo];
}


#pragma mark -  AVCVideoDownloadTCellDelegate
- (void)videoDownTCell:(AVCVideoDownloadTCell *)cell video:(AVCDownloadVideo *)video selected:(BOOL)selected{
    if (selected) {
        [self.editVideoArray addObject:video];
    }else{
        [self.editVideoArray removeObject:video];
    }
}

- (void)videoDownTCell:(AVCVideoDownloadTCell *)cell actionButtonTouchedWithVideo:(AVCDownloadVideo *)video{
    switch (video.downloadStatus) {
        case AVCDownloadStatusPause:{
            //重新开始下载 - stsData得重新获取
            [self startDownloadWithVid:video.video_id quality:[video.video_quality integerValue] format:video.video_format success:^{
                video.downloadStatus = AVCDownloadStatusDownloading;
                [self.downloadTableView reloadData];
            } failure:^(NSString * _Nonnull errDes) {
                [MBProgressHUD showMessage:errDes inView:self.view];
            }];
            
           
            }
            break;
        case AVCDownloadStatusFailure:{
            //重新开始下载 - stsData得重新获取
            [self startDownloadWithVid:video.video_id quality:[video.video_quality integerValue] format:video.video_format success:^{
                video.downloadStatus = AVCDownloadStatusDownloading;
                [self.downloadTableView reloadData];
            } failure:^(NSString * _Nonnull errDes) {
                [MBProgressHUD showMessage:errDes inView:self.view];
            }];
        }
            break;
            
        case AVCDownloadStatusDownloading:{
            //暂停下载
            AliyunDownloadMediaInfo *mediaInfo = nil;
            if (!video.mediaInfo) {
                //从数据库加载的下载视频media为空
                mediaInfo = [[AliyunDownloadMediaInfo alloc]init];
                mediaInfo.vid = video.video_id;
                mediaInfo.format = video.video_format;
                mediaInfo.quality = [video.video_quality integerValue];
            }else{
                mediaInfo = video.mediaInfo;
            }
            [[AliyunVodDownLoadManager shareManager]stopDownloadMedia:mediaInfo];
            video.downloadStatus = AVCDownloadStatusPause;
            [self.downloadTableView reloadData];
        }
            
            
        default:
            break;
    }
}
#pragma mark - Download

/**
 根据AliyunDownloadMediaInfo寻找当前列表的自定义的视频信息
 
 @param media 回调的下载媒体信息
 @return 拥有这个媒体信息的下载模块
 */
- (AVCDownloadVideo *__nullable)downVideoWithMediaInfo:(AliyunDownloadMediaInfo *)media{
    for (AVCDownloadVideo *downloadVideo in self.downloadingVideoArray) {
        if ([downloadVideo isSameWithOtherMedia:media]) {
            return downloadVideo;
        }
    }
    return nil;
}

- (void)showAlertViewWithString:(NSString *)string{
    AlivcAlertView *alertView = [[AlivcAlertView alloc]initWithAlivcTitle:nil message:string delegate:self cancelButtonTitle:nil confirmButtonTitle:@"确定"];
    [alertView showInView:self.view];
}

- (void)prepareTODownLoadWithVideoId:(NSString *)vid{
    //准备下载
    AliyunVodDownLoadManager *downloadManager = [AliyunVodDownLoadManager shareManager];

    __block AVC_VP_VideoPlayViewController *wealSelf = self;
    [self getDataSourceWithVid:vid format:nil qualitity:AliyunVodPlayerVideoHD sucess:^(AliyunDataSource * _Nonnull dataSource) {
        wealSelf.readyDataSource = dataSource;
        [downloadManager prepareDownloadMedia:dataSource];
        
    } failure:^(NSString * _Nonnull errDes) {
        [MBProgressHUD showMessage:errDes inView:self.view];
    }];
}

- (void)getDataSourceWithVid:(NSString *)vid format:(NSString *__nullable)formatString qualitity:(AliyunVodPlayerVideoQuality )quality sucess:(void(^)(AliyunDataSource *dataSource))sucess failure:(void(^)(NSString *errDes))failure{
    [AlivcAppServer getStsDataWithVid:vid sucess:^(NSString * _Nonnull accessKeyId, NSString * _Nonnull accessKeySecret, NSString * _Nonnull securityToken) {
        //AliyunDataSource
        AliyunDataSource *dataSource = [[AliyunDataSource alloc]init];
        dataSource.requestMethod = AliyunVodRequestMethodStsToken;
        dataSource.vid = vid;
        if (formatString) {
            dataSource.format = formatString;
        }
        dataSource.quality = quality;
        AliyunStsData *stsData = [[AliyunStsData alloc]init];
        stsData.accessKeyId = accessKeyId;
        stsData.accessKeySecret = accessKeySecret;
        stsData.securityToken = securityToken;
        dataSource.stsData = stsData;
        sucess(dataSource);
    } failure:^(NSString * _Nonnull errorString) {
        failure(errorString);
    }];
}

- (void)startDownloadWithVid:(NSString *)vid quality:(AliyunVodPlayerVideoQuality )quality format:(NSString *)format success:(void(^)(void))success failure:(void(^)(NSString *errDes))failure{
    [self getDataSourceWithVid:vid format:format qualitity:quality sucess:^(AliyunDataSource * _Nonnull dataSource) {
        [[AliyunVodDownLoadManager shareManager]startDownloadMedia:dataSource];
        success();
    } failure:^(NSString * _Nonnull errDes) {
        failure(errDes);
    }];
}


#pragma mark - AliyunVodDownLoadDelegate
/*
 功能：未完成回调，异常中断导致下载未完成，下次启动后会接收到此回调。
 回调数据：AliyunDownloadMediaInfo数组
 */
-(void) onUnFinished:(NSArray<AliyunDataSource*>*)mediaInfos{
    for (AliyunDataSource *source in mediaInfos) {
     
    }
}


/*
  功能：开始下载后收到回调，更新最新的playAuth。主要场景是开始多个下载时，等待下载的任务自动开始下载后，playAuth有可能已经过期了，需通过此回调更新
 参数：返回当前数据
 返回：使用代理方法，设置playauth来更新数据。
  */
-(NSString*)onGetPlayAuth:(NSString*)vid format:(NSString*)format quality:(AliyunVodPlayerVideoQuality)quality{
    NSLog(@"更新最新的playAuth");
    return @"";
    
}


/*
  功能：开始下载后收到回调，更新最新的stsData。主要场景是开始多个下载时，等待下载的任务自动开始下载后，stsData有可能已经过期了，需通过此回调更新
 参数：返回当前数据
 返回：使用代理方法，设置AliyunStsData来更新数据。
 */
- (AliyunStsData*)onGetAliyunStsData:(NSString *)videoID
                              format:(NSString*)format
                             quality:(AliyunVodPlayerVideoQuality)quality{
    NSLog(@"更新最新的stsData");
    
    AliyunStsData *stsData = [[AliyunStsData alloc]init];
    NSString *urlString = [NSString stringWithFormat:@"https://demo-vod.cn-shanghai.aliyuncs.com/voddemo/CreateSecurityToken?BusinessType=vodai&TerminalType=pc&DeviceModel=iPhone9,2&UUID=59ECA-4193-4695-94DD-7E1247288&AppVersion=1.0.0&VideoId=%@",videoID];
    NSURLRequest *requst = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    NSURLResponse *response;
    NSError *error;
    NSData *resultData = [NSURLConnection sendSynchronousRequest:requst returningResponse:&response error:&error];
    if (!error && resultData) {
        NSDictionary *responseDic = [NSJSONSerialization JSONObjectWithData:resultData options:NSJSONReadingMutableLeaves error:&error];
        NSDictionary *resultDic = responseDic[@"SecurityTokenInfo"];
        NSLog(@"%@",resultDic);
        //AccessKeyId
        NSString *keyIDString = resultDic[@"AccessKeyId"];
        //AccessKeySecret
        NSString *accessKeySecret = resultDic[@"AccessKeySecret"];
        //SecurityToken
        NSString *securityToken = resultDic[@"SecurityToken"];
        
        if (keyIDString && accessKeySecret && securityToken) {
            stsData.accessKeyId = keyIDString;
            stsData.accessKeySecret = accessKeySecret;
            stsData.securityToken = securityToken;
            NSLog(@"成功返回");
            return stsData;
        }
    }
    return nil;
}


/*
  功能：开始下载后收到回调，更新最新的MtsData。主要场景是开始多个下载时，等待下载的任务自动开始下载后，MtsData有可能已经过期了，需通过此回调更新
 参数：返回当前数据
 返回：使用代理方法，设置AliyunMtsData来更新数据。
 */
- (AliyunMtsData*)onGetAliyunMtsData:(NSString *)videoID
                              format:(NSString*)format
                             quality:(NSString *)quality{
    NSLog(@"更新最新的MtsData");
    return nil;
}



/*
 功能：准备下载回调。
 回调数据：AliyunDownloadMediaInfo数组
 */
-(void) onPrepare:(NSArray<AliyunDownloadMediaInfo*>*)mediaInfos{
    NSLog(@"准备下载 ---- \n ");
    if (![self.hud isHidden]) {
        [self.hud hideAnimated:true];
    }
        //排序
    NSArray *newArray = [mediaInfos sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        AliyunDownloadMediaInfo *info1 = (AliyunDownloadMediaInfo *)obj1;
        AliyunDownloadMediaInfo *info2 = (AliyunDownloadMediaInfo *)obj2;
        if (info1 && info2) {
            return info1.quality < info2.quality;
        }
        return false;
    }];
    //动态生成选择清晰度的视图
    //    self.prepareMediaInfos = mediaInfos;
    [self.selectView removeFromSuperview];
    self.selectView = [[AVCSelectSharpnessView alloc]initWithMedias:newArray];
    [self.selectView showInView:self.view];
    self.selectView.delegate = self;
    //    self.selectView.backgroundColor = [UIColor blueColor];
    //默认当前的清晰度 - 找不到就第一个
    AliyunDownloadMediaInfo *firstInfo = newArray.firstObject;
    for (AliyunDownloadMediaInfo *info in mediaInfos) {
        if (info.quality == self.playerView.quality) {
            firstInfo = info;
            break;
        }
    }
    [self.selectView setSelectedMedia:firstInfo];
    self.readyDataSource.format = firstInfo.format;
    self.readyDataSource.quality = firstInfo.quality;
    self.readyDataSource.videoDefinition = firstInfo.videoDefinition;

}

/*
 功能：下载开始回调。
 回调数据：AliyunDownloadMediaInfo
 */
-(void) onStart:(AliyunDownloadMediaInfo*)mediaInfo{
    NSLog(@"下载已经开始:%@",mediaInfo.vid);
    //显示小红点
    if (self.logOrDownload != 2) {
        self.redView.hidden = false;
    }
    //防止重复添加
    BOOL find = false;
    for (AVCDownloadVideo *video in self.downloadingVideoArray) {
        if ([video isSameWithOtherMedia:mediaInfo]) {
            find = true;
            [self.downloadTableView reloadData];
            return;
        }
    }
    if (!find) {
        AVCDownloadVideo *video = [[AVCDownloadVideo alloc]initWithMedia:mediaInfo];
        video.downloadStatus = AVCDownloadStatusDownloading;
        [self.downloadingVideoArray addObject:video];
        [self.downloadTableView reloadData];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSURL *url = [NSURL URLWithString:video.coverImageurlString];
            if (url) {
                NSData *imageData = [NSData dataWithContentsOfURL:url];
                if (imageData) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        video.video_imageData = imageData;
                        [[AlivcVideoDataBase shared]addVideo:video];
                    });
                }
            }
        });
    }
    
}

/*
  功能：下载进度回调。可通过mediaInfo.downloadProgress获取进度。
  回调数据：AliyunDownloadMediaInfo
  */
-(void) onProgress:(AliyunDownloadMediaInfo*)mediaInfo{
    AVCDownloadVideo *video = nil;
    for (AVCDownloadVideo *downloadVideo in self.downloadingVideoArray) {
        BOOL success = [downloadVideo refreshStatusWithMedia:mediaInfo];
        if (success) {
            video = downloadVideo;
            break;
        }
    }
    //找到对应的cell
    if (video) {
        NSInteger index = [self.downloadingVideoArray indexOfObject:video];
        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
        UITableViewCell *cell = [self.downloadTableView cellForRowAtIndexPath:indexPath];
        AVCVideoDownloadTCell *downloadCell = (AVCVideoDownloadTCell *)cell;
        if (downloadCell) {
            [downloadCell configWithVideo:video];
        }
        
    }
    
    
}

/*
  功能：调用stop结束下载时回调。
  回调数据：AliyunDownloadMediaInfo
  */
-(void) onStop:(AliyunDownloadMediaInfo*)mediaInfo{
    NSLog(@"结束下载");
    for (AVCDownloadVideo *downloadVideo in self.downloadingVideoArray) {
        BOOL find = [downloadVideo refreshStatusWithMedia:mediaInfo];
        if (find) {
            break;
        }
    }
    [self.downloadTableView reloadData];
}

/*
  功能：下载完成回调。
  回调数据：AliyunDownloadMediaInfo
  */
-(void) onCompletion:(AliyunDownloadMediaInfo*)mediaInfo{
    AVCDownloadVideo *doneVideo = [self downVideoWithMediaInfo:mediaInfo];
    if (doneVideo) {
        [doneVideo refreshStatusWithMedia:mediaInfo];
        doneVideo.downloadStatus = AVCDownloadStatusDone;
        [self.downloadingVideoArray removeObject:doneVideo];
        [self.doneVideoArray addObject:doneVideo];
        [self.downloadTableView reloadData];
        
        //添加或者更新进本地数据库
        [[AlivcVideoDataBase shared]deleteVideo:doneVideo];
        [[AlivcVideoDataBase shared]addVideo:doneVideo];
        
        //
        NSString *showString = [NSString stringWithFormat:@"%@ 下载成功",doneVideo.video_title];
        [MBProgressHUD showSucessMessage:showString inView:self.view];
    }
    
}

/*
  功能：改变加密文件（调用changeEncryptFile时回调）。
  回调数据：重新加密之前视频文件进度
  */
-(void) onChangeEncryptFileProgress:(int)progress{
    NSLog(@"改变加密文件");
}


/*
  功能：改变加密文件后老的加密视频重新加密完成时回调。加密完成后注意删除老的加密文件。
  */
-(void) onChangeEncryptFileComplete{
    NSLog(@"加密完成");
}

/*
  功能：错误回调。错误码与错误信息详见文档。
  回调数据：AliyunDownloadMediaInfo， code：错误码 msg：错误信息
  */
-(void)onError:(AliyunDownloadMediaInfo*)mediaInfo code:(int)code msg:(NSString *)msg{
    NSLog(@"下载错误:%@",msg);
    for (AVCDownloadVideo *downloadVideo in self.downloadingVideoArray) {
        BOOL isfind = [downloadVideo refreshStatusWithMedia:mediaInfo];
        if (isfind) {
            downloadVideo.downloadStatus = AVCDownloadStatusFailure;
            break;
        }
    }
    [self.downloadTableView reloadData];
    //更新界面
}


#pragma mark - AliyunVodPlayerViewDelegate
- (void)onDownloadButtonClickWithAliyunVodPlayerView:(AliyunVodPlayerView *)playerView{
    
    //判断视频类型
    if (self.config.playMethod == AliyunPlayMedthodURL) {
        [self showAlertViewWithString:@"此类型的视频不支持下载"];
        return;
    }
    //判断网络
    _reachability = [AliyunReachability reachabilityForInternetConnection];
    [_reachability startNotifier];
    switch ([self.reachability currentReachabilityStatus]) {
        case AliyunPVNetworkStatusNotReachable://由播放器底层判断是否有网络
            break;
        case AliyunPVNetworkStatusReachableViaWiFi:
            break;
        case AliyunPVNetworkStatusReachableViaWWAN:
        {
            AlivcAlertView *alertView = [[AlivcAlertView alloc]initWithAlivcTitle:nil message:@"当前网络环境为4G,继续下载将耗费流量" delegate:self cancelButtonTitle:@"取消" confirmButtonTitle:@"确定"];
            alertView.tag = alertViewTag_downLoad_continue;
            [alertView show];
            return;
        }
            break;
        default:
            break;
    }
   
    [self prepareTODownLoadWithVideoId:self.config.videoId];
    
    self.hud = [MBProgressHUD showMessage:@"请求资源中..." alwaysInView:self.view];
    //    //10秒超时
    [self.hud hideAnimated:true afterDelay:10];
}

- (void)onBackViewClickWithAliyunVodPlayerView:(AliyunVodPlayerView *)playerView{
    [self returnAction];
}

- (void)aliyunVodPlayerView:(AliyunVodPlayerView *)playerView happen:(AliyunVodPlayerEvent)event{
    AVCLogModel *model = [[AVCLogModel alloc]initWithEvent:event];
    [self.logView haveReceivedNewEvent:model];
}

- (void)aliyunVodPlayerView:(AliyunVodPlayerView*)playerView onPause:(NSTimeInterval)currentPlayTime{
    NSLog(@"onPause");
}

- (void)aliyunVodPlayerView:(AliyunVodPlayerView*)playerView onResume:(NSTimeInterval)currentPlayTime{
    NSLog(@"onResume");
}

- (void)aliyunVodPlayerView:(AliyunVodPlayerView*)playerView onStop:(NSTimeInterval)currentPlayTime{
    NSLog(@"onStop");
}

- (void)aliyunVodPlayerView:(AliyunVodPlayerView*)playerView onSeekDone:(NSTimeInterval)seekDoneTime{
    NSLog(@"onSeekDone");
}

-(void)onFinishWithAliyunVodPlayerView:(AliyunVodPlayerView *)playerView{
    NSLog(@"onFinish");
    if (self.config.isLocal && self.doneVideoArray.count > 0) {
//        //本地播放
//        AVCDownloadVideo *nextLocalVideo = nil;
//        for (AVCDownloadVideo *video in self.doneVideoArray) {
//            if ([self.config.videoId isEqualToString:video.video_id] && [self.config.video_format isEqualToString:video.video_format] && self.config.video_quality == video.video_quality) {
//                NSInteger index = [self.doneVideoArray indexOfObject:video];
//                NSInteger nextIndex = index + 1;
//                if (nextIndex < self.doneVideoArray.count) {
//                    nextLocalVideo = self.doneVideoArray[nextIndex];
//                }else{
//                    nextLocalVideo = self.doneVideoArray.firstObject;
//                }
//            }
//        }
//        if (nextLocalVideo) {
//            [self changeToPlayLocalVideo:nextLocalVideo];
//            return;
//        }
        [self.playerView setUIStatusToReplay];
        return;
    }
    //vid列表播放
    [self.listView playNextMediaVideo];
    
}

- (void)aliyunVodPlayerView:(AliyunVodPlayerView *)playerView lockScreen:(BOOL)isLockScreen{
    self.isLock = isLockScreen;
}


- (void)aliyunVodPlayerView:(AliyunVodPlayerView*)playerView onVideoQualityChanged:(AliyunVodPlayerVideoQuality)quality{
    
}

- (void)aliyunVodPlayerView:(AliyunVodPlayerView *)playerView fullScreen:(BOOL)isFullScreen{
    NSLog(@"isfullScreen --%d",isFullScreen);
    
    self.isStatusHidden = isFullScreen  ;
    [self refreshUIWhenScreenChanged:isFullScreen];
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)aliyunVodPlayerView:(AliyunVodPlayerView *)playerView onVideoDefinitionChanged:(NSString *)videoDefinition {
    
}

- (void)onCircleStartWithVodPlayerView:(AliyunVodPlayerView *)playerView {
    
}


- (void)onClickedAirPlayButtonWithVodPlayerView:(AliyunVodPlayerView *)playerView{
    [MBProgressHUD showSucessMessage:@"功能正在开发中" inView:self.view];
}

- (void)onClickedBarrageBtnWithVodPlayerView:(AliyunVodPlayerView *)playerView{
    [MBProgressHUD showSucessMessage:@"功能正在开发中" inView:self.view];
}



#pragma mark - AVCSelectSharpnessViewDelegate
- (void)selectSharpnessView:(AVCSelectSharpnessView *)view haveSelectedMediaInfo:(AliyunDownloadMediaInfo *)medioInfo{
    self.readyDataSource.videoDefinition = medioInfo.videoDefinition;
    self.readyDataSource.format = medioInfo.format;
    self.readyDataSource.quality = medioInfo.quality;
}


- (void)selectSharpnessView:(AVCSelectSharpnessView *)view okButtonTouched:(UIButton *)button{
    for (AVCDownloadVideo *video in self.downloadingVideoArray){
        if ([video.video_id isEqualToString:self.readyDataSource.vid] && self.readyDataSource.quality == [video.video_quality integerValue] && [self.readyDataSource.format isEqualToString:video.video_format]) {
            [MBProgressHUD showMessage:@"该视频已在下载,请耐心等待" inView:self.view];
            return;
        }
    }
    for (AVCDownloadVideo *video in self.doneVideoArray){
        if ([video.video_id isEqualToString:self.readyDataSource.vid] && self.readyDataSource.quality == [video.video_quality integerValue] && [self.readyDataSource.format isEqualToString:video.video_format]) {
            [MBProgressHUD showMessage:@"该视频已下载完成" inView:self.view];
            return;
        }
    }
    [[AliyunVodDownLoadManager shareManager]startDownloadMedia:self.readyDataSource];
    [view dismiss];
    if (ScreenWidth > ScreenHeight) {
        [self showDownloadTableViewWhenFullScreen];
    }
}

- (void)selectSharpnessView:(AVCSelectSharpnessView *)view cancelButtonTouched:(UIButton *)button{
    [view dismiss];
}

- (void)selectSharpnessView:(AVCSelectSharpnessView *)view lookVideoButtonTouched:(UIButton *)button{
    //横屏状态下才有这个按钮 1.隐藏选择视图， 2.展示视频列表视图
    if (ScreenWidth > ScreenHeight) {
        [view dismiss];
        [self showDownloadTableViewWhenFullScreen];
    }
}


#pragma mark - AlivcPlayListsViewDelegate
- (void)alivcPlayListsView:(AlivcPlayListsView *)playListsView didSelectModel:(AlivcVideoPlayListModel *)listModel{
    
    
    self.playerView.coverUrl = [NSURL URLWithString:listModel.coverURL];
    [self.playerView setTitle:listModel.title];
    self.config.isLocal = false;
    if (listModel.videoUrl) {
        self.config.playMethod = AliyunPlayMedthodURL;
        self.config.videoUrl = [NSURL URLWithString:listModel.videoUrl];
        [self startPlayVideo];
        
    }else if (listModel.videoId  && !listModel.videoUrl){
        self.config.playMethod = AliyunPlayMedthodSTS;
        self.config.videoId = listModel.videoId;
        self.config.stsAccessKeyId = listModel.stsAccessKeyId;
        self.config.stsAccessSecret = listModel.stsAccessSecret;
        self.config.stsSecurityToken = listModel.stsSecurityToken;
        [self startPlayVideo];
    }
//    [self.playerView start];
}

- (void)alivcPlayListsView:(AlivcPlayListsView *)playListsView playSettingButtonTouched:(UIButton *)buton{
    [self.playerView pause];
    AVC_VP_PlaySettingVC *targetVC = [[AVC_VP_PlaySettingVC alloc]init];
//    targetVC.originVC = self;
    __weak typeof(self) weakself = self;
    targetVC.setBlock = ^(AVCVideoConfig *config) {
//        [weakself configChanged]
        weakself.config = config;
        weakself.isPresent = NO;
        [weakself.playerView reset];
        switch (config.playMethod) {
            case AliyunPlayMedthodURL:
            {
                [weakself.playerView playViewPrepareWithURL:config.videoUrl];
            }
                break;
            case AliyunPlayMedthodSTS:
            {
                [weakself.playerView playViewPrepareWithVid:config.videoId
                                            accessKeyId:config.stsAccessKeyId
                                        accessKeySecret:config.stsAccessSecret
                                          securityToken:config.stsSecurityToken];
            }
                break;
            default:
                break;
        }
        
    };
    
    targetVC.backBlock = ^{
        weakself.isPresent = NO;
    };
    
    UINavigationController *nav = [[UINavigationController alloc]initWithRootViewController:targetVC];
    self.isPresent = YES;
    [self presentViewController:nav animated:true completion:nil];
}



#pragma mark - 锁屏功能
/**
 * 说明：播放器父类是UIView。
 屏幕锁屏方案需要用户根据实际情况，进行开发工作；
 如果viewcontroller在navigationcontroller中，需要添加子类重写navigationgController中的 以下方法，根据实际情况做判定 。
 */
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    
    //    return toInterfaceOrientation = UIInterfaceOrientationLandscapeLeft|UIInterfaceOrientationPortrait;
    
    if (self.isBecome) {
        return toInterfaceOrientation = UIInterfaceOrientationLandscapeLeft;
    }
    
    if (self.isLock) {
        return toInterfaceOrientation = UIInterfaceOrientationPortrait;
    }else{
        return YES;
    }
    return (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}

- (BOOL)shouldAutorotate{
    return !self.isLock;
}

-(UIInterfaceOrientationMask)supportedInterfaceOrientations{
    
    if (self.isBecome && !self.isPresent) {
        return UIInterfaceOrientationMaskLandscapeLeft|UIInterfaceOrientationMaskLandscapeRight;
    }
    
    if (self.isLock) {
        return UIInterfaceOrientationMaskPortrait;
    }else{
        return UIInterfaceOrientationMaskPortrait|UIInterfaceOrientationMaskLandscapeLeft|UIInterfaceOrientationMaskLandscapeRight;
    }
}

-(BOOL)prefersStatusBarHidden
{
    return self.isStatusHidden;
    
}

#pragma mark - 网络变化
//网络状态判定
- (void)reachabilityChanged{
    AliyunPVNetworkStatus status = [self.reachability currentReachabilityStatus];
    if (status != AliyunPVNetworkStatusNotReachable) {
        [self configBaseDataSuccess:^{
            //
        }];
        
    }
}

@end

NS_ASSUME_NONNULL_END
