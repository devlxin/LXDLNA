//
//  FindDeviceController.m
//  DLNADemo
//
//  Created by 李鑫 on 2019/11/19.
//  Copyright © 2019 李鑫. All rights reserved.
//

#import "FindDeviceController.h"
#import "LXFindDevice.h"
#import "LXUPnPDevice.h"
#import "ControlDeviceController.h"

@interface FindDeviceController () <LXFindDeviceDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSArray *datas;

@end

@implementation FindDeviceController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setTitle:@"设备列表"];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) style:UITableViewStylePlain];
    [_tableView setDataSource:self];
    [_tableView setDelegate:self];
    [self.view addSubview:_tableView];
    
    [[LXFindDevice sharedInstance] startFindDevice];
    [[LXFindDevice sharedInstance] setDelegate:self];
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _datas.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"deviceCell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"deviceCell"];
    }
    
    LXUPnPDevice *device = _datas[indexPath.row];
    cell.textLabel.text = device.friendlyName;
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    LXUPnPDevice *device = _datas[indexPath.row];
    
    ControlDeviceController *controlDevice = [[ControlDeviceController alloc] init];
    controlDevice.device = device;
    controlDevice.url = @"http://vfx.mtime.cn/Video/2019/03/19/mp4/190319212559089721.mp4";
    [self.navigationController pushViewController:controlDevice animated:YES];
}

#pragma mark - LXFindDeviceDelegate
- (void)lx_UPnPDeviceChanged:(NSArray<LXUPnPDevice *> *)devices {
    _datas = devices;
    [_tableView reloadData];
}

- (void)dealloc {
    [[LXFindDevice sharedInstance] stopFindDevice];
}

@end
