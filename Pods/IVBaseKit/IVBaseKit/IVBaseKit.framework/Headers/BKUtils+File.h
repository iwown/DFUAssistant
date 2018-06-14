//
//  BKUtils+File.h
//  linyi
//
//  Created by caike on 16/12/20.
//  Copyright © 2016年 com.kunekt.healthy. All rights reserved.
//

#import "BKUtils.h"

@interface BKUtils (File)

//创建文件夹
+ (BOOL)createDirWithPath:(NSString *)path Name:(NSString *)name;
//创建文件
+ (BOOL)createFileWithPath:(NSString *)path;
+ (BOOL)createFileWithPath:(NSString *)path andFileHeader:(NSString *)fileHeader;
//删除文件
+ (void)deleteFileByPath:(NSString *)path;
//写文件头
+ (BOOL)writeFileHead:(NSString *)str toPath:(NSString *)path;
//写文件
+ (void)writeFile:(NSString *)str toPath:(NSString *)path;

+ (NSArray *)selectAllFileInDir:(NSString *)dirPath;

/**
 *  检查文件是否存在
 *
 *  @param fileName 文件名称
 *
 *  @return 如果存在则返回yes
 */
+ (BOOL) isFileExist:(NSString *)fileName;
+ (BOOL)isFileExistAtPath:(NSString *)filePath;

+ (void)checkFlieProtection:(NSString *)path ;

+ (NSString*) FilePaths:(NSString*)fileName;

+ (NSString*)getFileMD5WithPath:(NSString*)path;
@end
