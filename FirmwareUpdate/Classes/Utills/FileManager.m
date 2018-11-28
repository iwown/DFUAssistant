//
//  FileManager.m
//  Rior
//
//  Created by west on 15/11/2.
//  Copyright © 2015年 west. All rights reserved.
//

#import "FileManager.h"

@implementation FileManager


//文件是否存在
+ (BOOL) isFileExist:(NSString *)fileName
{
    NSString *fullPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:fileName];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL result = [fileManager fileExistsAtPath:fullPath];
    return result;
}

//创建文件夹
+ (BOOL)createDirWithPath:(NSString *)path
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:path]) {
        return YES;
    }
    else
    {
        // 创建目录
        BOOL res=[fileManager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
        if (res) {
            NSLog(@"文件夹创建成功");
        }else
            NSLog(@"文件夹创建失败");
        
        return res;
    }
}

//创建文件
+ (BOOL)createFileWithPath:(NSString *)path
{
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:path]) {
        return YES;
    }
    else
    {
        return [self createFile:path];
    }
}

+ (BOOL)createFile:(NSString *)path
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL res=[fileManager createFileAtPath:path contents:nil attributes:nil];
    if (res) {
        NSLog(@"文件创建成功: %@" ,path);
    }else
        NSLog(@"文件创建失败");
    return res;
}

//写文件
+ (BOOL)writeFileHead:(NSString *)str toPath:(NSString *)path
{
    BOOL res=[str writeToFile:path atomically:YES encoding:NSUTF8StringEncoding error:nil];
    if (res) {
        NSLog(@"文件写入成功");
    }else
        NSLog(@"文件写入失败");
    
    return res;
}

//写文件
+ (void)writeFile:(NSString *)str toPath:(NSString *)path
{
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForUpdatingAtPath:path];
    [fileHandle seekToEndOfFile];  // 将节点跳到文件的末尾
    
    NSData* stringData  = [str dataUsingEncoding:NSUTF8StringEncoding];
    
    [fileHandle writeData:stringData]; //追加写入数据
    
    [fileHandle closeFile];
}

//扫描文件夹
+ (NSArray *)scanDirWithPath:(NSString *)path {
    NSError *error;
    NSArray *directoryContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:&error];
    if (error) {
        NSLog(@"%@", error);
        return nil;
    }
    return directoryContents;
}

//单个文件的大小
+ (float) fileSizeAtPath:(NSString*) filePath
{
    
    NSFileManager* manager = [NSFileManager defaultManager];
    
    if ([manager fileExistsAtPath:filePath]){
        
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize]/1024.0;
    }
    return 0;
}

+ (BOOL)moveFileFrom:(NSString *)fileFrom
       toAnotherPath:(NSString *)fileTo {
    NSError *error;
    NSFileManager* manager = [NSFileManager defaultManager];
    BOOL isSuccess = [manager moveItemAtPath:fileFrom toPath:fileTo error:&error];
    NSLog(@"%@",error);
    return isSuccess;
}

+ (NSInteger)addFunction:(NSInteger)a andB:(NSInteger)b {
    return a+b;
}


@end
