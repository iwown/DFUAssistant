//
//  SPC_LogUtils.h
//  MTKBleManager
//
//  Created by user on 2017/2/17.
//  Copyright © 2017年 ___MTK___. All rights reserved.
//

#ifndef __LOG_UTILS_H__
#define __LOG_UTILS_H__


// Define debug log
#ifdef DEBUG
#define LOG_D(tag, fmt, ...)        NSLog(@"[D][BtNotify][%@][%d] - %@", tag, __LINE__, [NSString stringWithFormat:fmt, __VA_ARGS__])
#else
#define LOG_D(tag, fmt, ...)
#endif   //DEBUG

// Define information log
//#ifdef INFO
#define LOG_I(tag, fmt, ...)        NSLog(@"[I][BtNotify][%@][%d] - %@", tag, __LINE__, [NSString stringWithFormat:fmt, __VA_ARGS__])
//#else
//#define LOG_I(tag, fmt, ...)
//#endif  // INFO

// Define error log
#define LOG_E(tag, fmt, ...)        NSLog(@"[E][BtNotify][%@][%d] - %@", tag, __LINE__, [NSString stringWithFormat:fmt, __VA_ARGS__])


#endif
