//
//  FilesViewController.m
//  JSRunner
//
//  Created by Taras Kalapun on 10/4/14.
//  Copyright (c) 2014 Kalapun. All rights reserved.
//

#import "FilesViewController.h"
#import "RunnerViewController.h"
#import "FileController.h"
#import "FileViewController.h"
#import <ionicons/IonIcons.h>
#import <SSZipArchive/SSZipArchive.h>

@interface FilesViewController ()<UIDocumentMenuDelegate, UIDocumentPickerDelegate>
@property (nonatomic, strong) NSArray *items;

@property (nonatomic, strong) UIDocumentInteractionController *documentInteractionController;

@property (nonatomic, strong) UIImage *fileIcon;
@property (nonatomic, strong) UIImage *dirIcon;

@end

@implementation FilesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileImportedNotification:) name:@"fileImported" object:nil];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(refreshAction:) forControlEvents:UIControlEventValueChanged];
    
    
    if (self.pickingLocation) {
        UIBarButtonItem *saveBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveAction:)];
        UIBarButtonItem *cancelBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelAction:)];
        self.navigationItem.leftBarButtonItem = cancelBtn;
        self.navigationItem.rightBarButtonItem = saveBtn;
    } else {
        UIBarButtonItem *addBtn = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addItemAction:)];
        self.navigationItem.rightBarButtonItem = addBtn;
    }
    
    
    
    if (!self.currentPath) {
        self.currentPath = @"";
    }
    
    UIColor *color = self.view.tintColor;
    self.fileIcon = [IonIcons imageWithIcon:icon_document size:30.0f color:color];
    self.dirIcon  = [IonIcons imageWithIcon:icon_ios7_folder_outline size:30.0f color:color];
    
    [self loadFilesWithReload:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (NSString *)relativePathToItem:(NSString *)item {
    return [self.currentPath stringByAppendingPathComponent:item];
}

- (void)loadFilesWithReload:(BOOL)reload {
//    self.items = [FileController filesWithExtention:@"js"];

    self.items = [FileController itemsAtPath:self.currentPath];
    //self.items = [FileController attributedItemsAtPath:self.currentPath];
    
    
    if (reload) {
        [self.tableView reloadData];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    if ([segue.identifier isEqualToString:@"detail"]) {
//        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
//        
//        NSString *file = self.items[indexPath.row];
//        RunnerViewController *destViewController = segue.destinationViewController;
//        destViewController.fileName = file;
//    }
//}

- (void)fileImportedNotification:(NSNotification *)note {
    [self loadFilesWithReload:YES];
}

- (IBAction)addItemAction:(id)sender {
    UIDocumentMenuViewController *importMenu = [[UIDocumentMenuViewController alloc] initWithDocumentTypes:[FileController UTIs] inMode:UIDocumentPickerModeImport];
    importMenu.delegate = self;
    
    [importMenu addOptionWithTitle:@"New Folder" image:self.dirIcon order:UIDocumentMenuOrderFirst handler:^{
        [self renameOrCreateFile:nil isDirectory:YES];
    }];
    [importMenu addOptionWithTitle:@"New File" image:self.fileIcon order:UIDocumentMenuOrderFirst handler:^{
        [self renameOrCreateFile:nil isDirectory:NO];
    }];
    
    [self presentViewController:importMenu animated:YES completion:nil];
}

- (IBAction)refreshAction:(id)sender {
    [self.refreshControl beginRefreshing];
    
    [FileController checkExampleFiles];
    
    [self loadFilesWithReload:YES];
    [self.refreshControl endRefreshing];
}

- (IBAction)saveAction:(id)sender {
    
}

- (IBAction)cancelAction:(id)sender {
    if (self.pickingLocation) {
        // Probably we are modal
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void)documentMenu:(UIDocumentMenuViewController *)documentMenu didPickDocumentPicker:(UIDocumentPickerViewController *)documentPicker

{
    documentPicker.delegate = self;
    [self presentViewController:documentPicker animated:YES completion:nil];
}

- (void)documentPicker:(UIDocumentPickerViewController *)controller didPickDocumentAtURL:(NSURL *)url {
    [FileController importFileFromUrl:url];
}

- (void)documentInteractionWithFile:(NSString *)file {
    
    NSURL *url = [FileController urlToFile:file];
    self.documentInteractionController = [UIDocumentInteractionController interactionControllerWithURL:url];
    //self.documentInteractionController.delegate = self;
    self.documentInteractionController.UTI = [FileController UTI];
    //[self.documentInteractionController presentOptionsMenuFromBarButtonItem:sender animated:YES];
    [self.documentInteractionController presentOptionsMenuFromRect:CGRectZero inView:self.view animated:YES];
}

- (void)actionsWithFile:(NSString *)file {
    
    NSURL *url = [FileController urlToFile:file];
    
    UIActivityViewController *av = [[UIActivityViewController alloc] initWithActivityItems:@[file, url] applicationActivities:nil];
    [self presentViewController:av animated:YES completion:nil];
}

- (void)renameOrCreateFile:(NSString *)file isDirectory:(BOOL)isDir {
    
    BOOL create = (file.length == 0);
    
    NSString *fileName = [file lastPathComponent];
    
    NSString *title = fileName;
    
    if (create) {
        title = (isDir) ? @"New Folder" : @"New File";
    }
    
    NSString *actionTitle = (create) ? @"Create" : @"Rename";
    
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:title message:nil preferredStyle:UIAlertControllerStyleAlert];
    __block UITextField *tf = nil;
    [ac addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.keyboardType = UIKeyboardTypeASCIICapable;
        textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        textField.autocorrectionType = UITextAutocorrectionTypeNo;
        textField.placeholder = @"Name";
        textField.text = fileName;
        tf = textField;
    }];
    [ac addAction:[UIAlertAction actionWithTitle:actionTitle style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        NSString *newPath = [self relativePathToItem:tf.text];
        [FileController renameFile:file newName:newPath isDirectory:isDir];
        [self loadFilesWithReload:YES];
    }]];
    [ac addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:ac animated:YES completion:nil];
}

- (void)moveItem:(NSString *)item {
    // TODO: Implement!!!
}

- (void)zipItem:(NSString *)item {
    NSDictionary *attr = [FileController attributes:item];
    
    NSString *filename = [[item lastPathComponent] stringByAppendingPathExtension:@"zip"];
    NSString *dest = [FileController pathForFile:[self.currentPath stringByAppendingPathComponent:filename]];
    NSString *path = [FileController pathForFile:item];
    
    
    BOOL isDir = (attr[NSFileType] == NSFileTypeDirectory);

    if (isDir) {
        [SSZipArchive createZipFileAtPath:dest withContentsOfDirectory:path];
    } else {
        [SSZipArchive createZipFileAtPath:dest withFilesAtPaths:@[path]];
    }
    
    [self loadFilesWithReload:YES];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.items.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * const CellIdentifier = @"FileCellIdentifier";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    // Configure the cell...
    
    NSString *item = self.items[indexPath.row];
    NSDictionary *attr = [FileController attributes:[self relativePathToItem:item]];

    cell.textLabel.text = item;
    cell.detailTextLabel.text = nil;
    
    if (attr[NSFileType] == NSFileTypeDirectory) {
        cell.imageView.image = self.dirIcon;
        cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
    } else {
        cell.detailTextLabel.text = [attr[NSFileSize] description];
        cell.imageView.image = self.fileIcon;
        cell.accessoryType = UITableViewCellAccessoryDetailButton;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *item = self.items[indexPath.row];
    NSDictionary *attr = [FileController attributes:[self relativePathToItem:item]];
    
    if (attr[NSFileType] == NSFileTypeDirectory) {
        FilesViewController *vc = [FilesViewController new];
        vc.currentPath = [self relativePathToItem:item];
        [self.navigationController pushViewController:vc animated:YES];
    } else {
        
        if (![[item pathExtension] isEqualToString:@"js"]) {
            return;
        }
        
        FileViewController *vc = [FileViewController new];
        vc.fileName = [self relativePathToItem:item];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        NSString *item = self.items[indexPath.row];
        [FileController deleteFile:[self relativePathToItem:item]];
        
        [self loadFilesWithReload:YES];
        
        //[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }
}

- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
    NSString *item = self.items[indexPath.row];
    
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:[item lastPathComponent] message:nil preferredStyle:UIAlertControllerStyleActionSheet];
//    [ac addAction:[UIAlertAction actionWithTitle:@"Actions..." style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
//        [self actionsWithFile:file];
//    }]];
    [ac addAction:[UIAlertAction actionWithTitle:@"Open in..." style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self documentInteractionWithFile:[self relativePathToItem:item]];
    }]];
    [ac addAction:[UIAlertAction actionWithTitle:@"Rename" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self renameOrCreateFile:[self relativePathToItem:item] isDirectory:NO];
    }]];
    [ac addAction:[UIAlertAction actionWithTitle:@"Move" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self moveItem:[self relativePathToItem:item]];
    }]];
    [ac addAction:[UIAlertAction actionWithTitle:@"Zip" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self zipItem:[self relativePathToItem:item]];
    }]];
    [ac addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:ac animated:YES completion:nil];
}



@end
