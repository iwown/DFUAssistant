//
//  FileManager.h
//  Rior
//
//  Created by west on 15/11/2.
//  Copyright © 2015年 west. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileManager : NSObject


//创建文件夹
+ (BOOL)createDirWithPath:(NSString *)path;
//创建文件
+ (BOOL)createFileWithPath:(NSString *)path;
//写文件头
+ (BOOL)writeFileHead:(NSString *)str toPath:(NSString *)path;
//写文件
+ (void)writeFile:(NSString *)str toPath:(NSString *)path;
//文件是否存在
+ (BOOL)isFileExist:(NSString *)fileName;
//扫描文件夹
+ (NSArray *)scanDirWithPath:(NSString *)path;
//单个文件的大小
+ (float)fileSizeAtPath:(NSString*) filePath;

+ (BOOL)moveFileFrom:(NSString *)fileFrom toAnotherPath:(NSString *)fileTo;

+ (NSInteger)addFunction:(NSInteger)a andB:(NSInteger)b;

@end
