//
//  LJPlayMusicViewController.m
//  AudioAndVideo
//
//  Created by LiJie on 2017/5/10.
//  Copyright © 2017年 LiJie. All rights reserved.
//

#import "LJPlayMusicViewController.h"

@interface LJPlayMusicViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) UITableView *musicListTableView;
@property (nonatomic,strong) NSArray *CollectionArray;
@property (nonatomic,strong) MPMusicPlayerController *playViewController;

@end

@implementation LJPlayMusicViewController

- (instancetype)initWithMediaItemCollection:(NSArray *)CollectionArray
{
    self = [super init];
    if (self) {
        _CollectionArray = CollectionArray;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"歌曲列表";
    _musicListTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _musicListTableView.delegate = self;
    _musicListTableView.dataSource = self;
    [self.view addSubview:_musicListTableView];
    [_musicListTableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"musicCell"];
}

- (MPMusicPlayerController *)playViewController {
    if (!_playViewController) {
        _playViewController = [MPMusicPlayerController iPodMusicPlayer];
        [_playViewController setQueueWithItemCollection:(MPMediaItemCollection *)_CollectionArray];
        [_playViewController beginGeneratingPlaybackNotifications];//开启通知，否则监控不到MPMusicPlayerController的通知
        [_playViewController setNowPlayingItem:nil];
        [self addNotification];
    }
    return _playViewController;
}

-(void)addNotification{
    NSNotificationCenter *notificationCenter=[NSNotificationCenter defaultCenter];
    [notificationCenter addObserver:self selector:@selector(playbackStateChange:) name:MPMusicPlayerControllerPlaybackStateDidChangeNotification object:self.playViewController];
}

-(void)playbackStateChange:(NSNotification *)notification{
    switch (self.playViewController.playbackState) {
        case MPMusicPlaybackStatePlaying:
            NSLog(@"正在播放...");
            break;
        case MPMusicPlaybackStatePaused:
            NSLog(@"播放暂停.");
            break;
        case MPMusicPlaybackStateStopped:
            NSLog(@"播放停止.");
            break;
        default:
            break;
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMusicPlayerControllerPlaybackStateDidChangeNotification object:self.playViewController];
}

#pragma mark - UITableViewDelegate,UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _CollectionArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"musicCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"musicCell"];
    }
    MPMediaItem  *musicItem = _CollectionArray[indexPath.row];
    //歌曲名字
    NSString *musicName = [musicItem valueForProperty:MPMediaItemPropertyTitle];
    //专辑名称
    //    NSString *musicAlbumName = [musicItem valueForProperty:MPMediaItemPropertyAlbumTitle];
    //作者
    NSString *ArtistName = [musicItem valueForProperty:MPMediaItemPropertyArtist];
    //专辑图片
    MPMediaItemArtwork *artwork = [musicItem valueForProperty:MPMediaItemPropertyArtwork];
    UIImage *image = [artwork imageWithSize:CGSizeMake(100, 100)];//获取图片
    
    cell.textLabel.text = musicName;
    cell.detailTextLabel.text = ArtistName;
    cell.imageView.image = image;
    if (self.playViewController.nowPlayingItem == _CollectionArray[indexPath.row]) {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    cell.selectionStyle = UITableViewCellAccessoryNone;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [_musicListTableView deselectRowAtIndexPath:indexPath animated:NO];
    //设置播放选中的歌曲
    [self.playViewController setNowPlayingItem:_CollectionArray[indexPath.row]];
    [self.playViewController play];
    
    [_musicListTableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return kScale(66);
}

@end
