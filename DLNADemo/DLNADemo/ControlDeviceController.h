//
//  ControlDeviceController.h
//  DLNADemo
//
//  Created by 李鑫 on 2019/11/19.
//  Copyright © 2019 李鑫. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LXUPnPDevice.h"

NS_ASSUME_NONNULL_BEGIN

@interface ControlDeviceController : UIViewController

@property (nonatomic, strong) LXUPnPDevice *device;
@property (nonatomic, copy) NSString *url;

@end

NS_ASSUME_NONNULL_END
