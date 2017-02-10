//
//  ReacordVideoController.h
//  RecordVideo
//
//  Created by Johnhao on 2017/2/9.
//  Copyright © 2017年 Johnhao. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^VideoPathBlock)(NSURL *videoPath);
@interface ReacordVideoController : UIViewController
/** block */
@property (nonatomic,strong) VideoPathBlock block;
@end
