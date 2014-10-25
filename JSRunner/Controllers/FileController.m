//
//  FileController.m
//  JSRunner
//
//  Created by Taras Kalapun on 10/4/14.
//  Copyright (c) 2014 Kalapun. All rights reserved.
//

#import "FileController.h"

@implementation FileController

static NSFileManager *_fm = nil;
static NSURL *_rootUrl = nil;
static NSString *_rootPath = nil;

+ (void)load {
    
    _fm = [NSFileManager defaultManager];
    
    NSString *appGroupId = @"group.JSRunner";
    NSURL *appGroupDirectoryPath = [[NSFileManager defaultManager] containerURLForSecurityApplicationGroupIdentifier:appGroupId];
    _rootUrl = [appGroupDirectoryPath URLByAppendingPathComponent:@"files"];
    _rootPath = _rootUrl.path;
    
    //    [FCFileManager setDefaultDirectory:appGroupDirectoryPath.path];
}

+ (NSString *)absolutePath:(NSString *)item {
    return [_rootPath stringByAppendingPathComponent:item];
}

+ (NSURL *)absoluteUrl:(NSString *)item {
    if (!item) {
        return _rootUrl;
    }
    return [_rootUrl URLByAppendingPathComponent:item];
}

+ (NSArray *)itemsAtPath:(NSString *)path {
    NSArray *a = [_fm contentsOfDirectoryAtPath:[self absolutePath:path] error:nil];
    return a;
}

+ (NSArray *)attributedItemsAtPath:(NSString *)path {
    NSArray *a = [_fm contentsOfDirectoryAtURL:[self absoluteUrl:path]
                    includingPropertiesForKeys:@[NSURLNameKey, NSURLIsDirectoryKey]
                                       options:NSDirectoryEnumerationSkipsHiddenFiles
                                         error:nil];
    return a;
}

+ (NSDictionary *)attributes:(NSString *)item {
    return [_fm attributesOfItemAtPath:[self absolutePath:item] error:nil];
}

+ (NSArray *)UTIs {
    return @[[self UTI]];
}

+ (NSString *)UTI {
    return @"public.source-code";
}

+ (NSString *)appGroupId {
    return @"group.JSRunner";
}

+ (void)checkAndCreateDirectory:(NSString *)path {
    BOOL isDir = NO;
    [_fm fileExistsAtPath:path isDirectory:&isDir];
    if (!isDir) {
        [_fm createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
}

+ (void)checkExampleFiles {
    
    
    [self checkAndCreateDirectory:_rootPath];
    
    NSString *examplesFolder = [_rootPath stringByAppendingPathComponent:@"examples"];
    [self checkAndCreateDirectory:examplesFolder];
    
    
    NSArray *files = [[NSBundle mainBundle] pathsForResourcesOfType:@"js" inDirectory:@"js"];
    //NSLog(@"files: %@", files);
    
    for (NSString *file in files) {
        NSString *path = [examplesFolder stringByAppendingPathComponent:[file lastPathComponent]];
        if (![_fm fileExistsAtPath:path]) {
            [_fm copyItemAtPath:file toPath:path error:nil];
        }
    }
    
}


+ (NSString *)pathForFile:(NSString *)fileName {
    NSString *s = [_rootPath stringByAppendingPathComponent:fileName];
    return s;
}

+ (NSURL *)urlToFile:(NSString *)fileName {
    return [NSURL fileURLWithPath:[self pathForFile:fileName]];
}

+ (NSArray *)filesWithExtention:(NSString *)ext {
    NSError *error = nil;
    
    NSArray *dirFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:_rootPath error:&error];
    
    if (error) NSLog(@"Error: %@", error);
    
    NSString *extPred = [NSString stringWithFormat:@".%@", ext];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self ENDSWITH %@", extPred];
    NSArray *files = [dirFiles filteredArrayUsingPredicate:predicate];
    return files;
}

+ (NSURL *)applicationDocumentsDirectory {
    
    NSString *documentsDirectory = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    if ([paths count] > 0) {
        documentsDirectory = paths[0];
    }
    return [NSURL fileURLWithPath:documentsDirectory];
}

+ (BOOL)fileExists:(NSString *)file {
    NSString *path = [self pathForFile:file];
    return [[NSFileManager defaultManager] fileExistsAtPath:path];
}

+ (void)deleteFile:(NSString *)file {
    NSError *error = nil;
    
    NSString *path = [self pathForFile:file];
    [[NSFileManager defaultManager] removeItemAtPath:path error:&error];
    
    if (error) NSLog(@"Error: %@", error);
}

+ (void)saveFileData:(NSData *)data name:(NSString *)name override:(BOOL)override {
    NSString *path = [self pathForFile:name];
    
    if ([self fileExists:name]) {
        if (override) {
            [self deleteFile:name];
        } else {
            return;
        }
    }
    
    [data writeToFile:path atomically:YES];
    
}

+ (void)renameFile:(NSString *)name newName:(NSString *)newName {
    [self renameFile:name newName:newName isDirectory:NO];
}

+ (void)renameFile:(NSString *)name newName:(NSString *)newName isDirectory:(BOOL)isDir {
    NSError *error = nil;
    
    NSString *newPath = [self pathForFile:newName];
    
    if (name.length == 0) {
        if (isDir) {
            [_fm createDirectoryAtPath:newPath withIntermediateDirectories:YES attributes:nil error:&error];
        } else {
            [_fm createFileAtPath:newPath contents:nil attributes:nil];
        }
        return;
    }
    
    NSString *path = [self pathForFile:name];
    
    
    [[NSFileManager defaultManager] moveItemAtPath:path toPath:newPath error:&error];
    
    if (error) NSLog(@"Error: %@", error);
}

+ (void)saveFile:(NSString *)fromPath name:(NSString *)name override:(BOOL)override {
    NSError *error = nil;
    
    if (!name) name = [fromPath lastPathComponent];
    NSString *path = [self pathForFile:name];
    
    if ([self fileExists:name]) {
        if (override) {
            [self deleteFile:name];
        } else {
            return;
        }
    }
    
    [[NSFileManager defaultManager] copyItemAtPath:fromPath toPath:path error:&error];
    
    if (error) NSLog(@"Error: %@", error);
}

+ (BOOL)saveFileFromInboxUrl:(NSURL *)url {
    NSError *error = nil;
    NSURL *copyToURL =  [self applicationDocumentsDirectory];
    
    NSString *fileName = [url lastPathComponent];
    
    
    if ([self fileExists:fileName]) {
        [self deleteFile:fileName];
    }
    
    // Add requested file name to path
    copyToURL = [copyToURL URLByAppendingPathComponent:fileName isDirectory:NO];
    
    BOOL ok = [[NSFileManager defaultManager] moveItemAtURL:url toURL:copyToURL error:&error];
    
    // Feed back any errors
    if (error) {
        NSLog(@"%@",[error localizedDescription]);
    }
    
    return ok;
}

+ (BOOL)importFileFromUrl:(NSURL *)url {
    NSError *error = nil;
    NSURL *copyToURL =  [self applicationDocumentsDirectory];
    
    NSString *fileName = [url lastPathComponent];
    
    
    if ([self fileExists:fileName]) {
        [self deleteFile:fileName];
    }
    
    // Add requested file name to path
    copyToURL = [copyToURL URLByAppendingPathComponent:fileName isDirectory:NO];
    
    BOOL ok = [[NSFileManager defaultManager] copyItemAtURL:url toURL:copyToURL error:&error];
    
    // Feed back any errors
    if (error) {
        NSLog(@"%@",[error localizedDescription]);
    }
    
    return ok;
}

@end
