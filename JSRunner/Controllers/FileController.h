//
//  FileController.h
//  JSRunner
//
//  Created by Taras Kalapun on 10/4/14.
//  Copyright (c) 2014 Kalapun. All rights reserved.
//

#import <Foundation/Foundation.h>
//#import <FCFileManager.h>

@interface FileController : NSObject




+ (NSArray *)UTIs;
+ (NSString *)UTI;
+ (NSString *)appGroupId;

+ (void)checkExampleFiles;


+ (NSArray *)itemsAtPath:(NSString *)path;
+ (NSArray *)attributedItemsAtPath:(NSString *)path;
+ (NSDictionary *)attributes:(NSString *)item;

+ (NSArray *)filesWithExtention:(NSString *)ext;

+ (NSString *)pathForFile:(NSString *)fileName;
+ (NSURL *)urlToFile:(NSString *)fileName;

+ (BOOL)fileExists:(NSString *)file;
+ (void)deleteFile:(NSString *)file;
+ (void)saveFileData:(NSData *)data name:(NSString *)name override:(BOOL)override;

+ (void)saveFile:(NSString *)fromPath name:(NSString *)name override:(BOOL)override;
+ (void)renameFile:(NSString *)name newName:(NSString *)newName isDirectory:(BOOL)isDir;
+ (void)renameFile:(NSString *)name newName:(NSString *)newName;

+ (BOOL)saveFileFromInboxUrl:(NSURL *)url;
+ (BOOL)importFileFromUrl:(NSURL *)url;

@end
