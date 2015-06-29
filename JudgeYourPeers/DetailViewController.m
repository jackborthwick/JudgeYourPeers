//
//  ViewController.m
//  JudgeYourPeers
//
//  Created by Jack Borthwick on 6/29/15.
//  Copyright (c) 2015 Jack Borthwick. All rights reserved.
//

#import "DetailViewController.h"
#import "AppDelegate.h"
#import <CoreData/CoreData.h>
#import "Peers.h"
#import "Settings.h"
@interface DetailViewController ()

@property (nonatomic, strong) AppDelegate               *appDelegate;
@property (nonatomic, strong) NSManagedObjectContext    *managedObjectContext;
@property (nonatomic, strong) IBOutlet UITextField      *peerNameTextField;
@property (nonatomic, strong) IBOutlet UITextField      *peerRatingTextField;
@property (nonatomic, strong) IBOutlet UITextView       *peerDescriptionTextView;
@property (nonatomic, strong) NSArray                   *peerArray;
@property (nonatomic, weak) IBOutlet UIImageView        *selectedImageView;
@property (nonatomic, strong) Settings                  *fileNameCounter;

@end

@implementation DetailViewController

#pragma mark - interactivity

-(void)galleryButtonTapped:(id)sender {
    NSLog(@"gallery");
    UIImagePickerController *ipc = [[UIImagePickerController alloc]init];
    ipc.delegate = self;
    ipc.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
    [self presentViewController:ipc animated:true completion:nil];
}

-(void)cameraButtonTapped:(id)sender {
    NSLog(@"camera");
    UIImagePickerController *ipc = [[UIImagePickerController alloc]init];
    ipc.delegate = self;
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        ipc.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:ipc animated:true completion:nil];
    }
    else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"no camera" message:@"you got no camera" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }
}

-(void)saveButtonPressed: (id)sender {
    NSLog(@"save");

    NSString *imageFilename = [NSString stringWithFormat:@"%@",[_fileNameCounter filenameCounter]];
    if (imageFilename) {
        NSString *newImagePath = [self getDocumentPathForFile:[NSString stringWithFormat:@"%@.png",imageFilename]];
        if(![self fileDoesExistAtPath:newImagePath]) {
            [UIImagePNGRepresentation(_selectedImageView.image) writeToFile:newImagePath atomically:true];
            NSLog(@"saved %@",newImagePath);
            Peers *newPeer = (Peers *)[NSEntityDescription insertNewObjectForEntityForName:@"Peers" inManagedObjectContext:_managedObjectContext];
            [newPeer setPeerName:_peerNameTextField.text];
            [newPeer setPeerRating:_peerRatingTextField.text];
            [newPeer setPeerDescription:_peerDescriptionTextView.text];
            [newPeer setPeerImageFilename:imageFilename];
            [self incrementFileNameCounter];
            [_appDelegate saveContext];
        }
    }
    
    
}

#pragma mark - Database Methods

-(NSArray *)fetchPeers {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Peers" inManagedObjectContext:_managedObjectContext];
    [fetchRequest setEntity:entity];
    
    //NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"contactName" ascending:true];
    //NSArray *sortDescriptors = @[sortDescriptor];//add mroe sort descriptors to sort first by one thing then by the next
    //[fetchRequest setSortDescriptors:sortDescriptors];
    
    return  [_managedObjectContext executeFetchRequest:fetchRequest error:nil];
}

-(IBAction)newPeerToJudge:(id)sender {
    Peers *newPeer = (Peers *)[NSEntityDescription insertNewObjectForEntityForName:@"Peers" inManagedObjectContext:_managedObjectContext];
    [newPeer setPeerName:_peerNameTextField.text];
    [newPeer setPeerRating:_peerRatingTextField.text];
    [newPeer setPeerDescription:_peerDescriptionTextView.text];
    [_appDelegate saveContext];

}

#pragma mark - imagepickercontroller methods

-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info{
    _selectedImageView.image = [info objectForKey:UIImagePickerControllerOriginalImage];
    [picker dismissViewControllerAnimated:true completion:nil];
}

-(void) imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [picker dismissViewControllerAnimated:true completion:nil];
}

#pragma mark - core methods

- (BOOL)fileDoesExistAtPath:(NSString *)path {
    BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:path];
    return fileExists;
}

- (NSString *)getDocumentPathForFile:(NSString *)filename {
    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, true)lastObject];
    path = [path stringByAppendingPathComponent:filename];
    NSLog(@"path is %@",path);
    return path;
}

-(void)copyFromPath:(NSString *)fromPath toPath:(NSString *)toPath {
    NSError *error = nil;
    [[NSFileManager defaultManager]copyItemAtPath:fromPath toPath:toPath error:&error];
    if (error) {
        NSLog(@"errror %@",error);
    }
}

//-(void)copySettingsToDocumentsIfNecessary {
//    NSString *sourcePath = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"plist"];
//    NSString *destPath = [self getDocumentPathForFile:@"Settings.plist"];
//    if (![self fileDoesExistAtPath:destPath]) {
//        [self copyFromPath:sourcePath toPath:destPath];
//    }
//}
////
-(NSString *)saveImageFile {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *imageFilename = [NSString stringWithFormat:@"image%i",[_fileNameCounter filenameCounter]];
    NSData *imageData = UIImagePNGRepresentation(_selectedImageView.image);
    BOOL didWriteToFile = [imageData writeToFile:documentsDirectory atomically:true];
    if (didWriteToFile) {
        return imageFilename;
    }
    return nil;
}

-(void)incrementFileNameCounter {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Settings" inManagedObjectContext:_managedObjectContext];
    [fetchRequest setEntity:entity];
    NSArray *settings = [_managedObjectContext executeFetchRequest:fetchRequest error:nil];
    _fileNameCounter = [settings objectAtIndex:0];
    int value = [[_fileNameCounter filenameCounter]intValue];
    [_fileNameCounter setFilenameCounter:[NSNumber numberWithInt:value + 1]];
    [_appDelegate saveContext];
}




#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
//    [self copySettingsToDocumentsIfNecessary];
    _appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    _managedObjectContext = _appDelegate.managedObjectContext;
    _peerArray = [self fetchPeers];
    NSLog(@"count is %li",_peerArray.count);
    UIBarButtonItem *galleryBtn = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSearch target:self action:@selector(galleryButtonTapped:)];
    UIBarButtonItem *cameraBtn = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemCamera target:self action:@selector(cameraButtonTapped:)];
    UIBarButtonItem *saveBtn = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(saveButtonPressed:)];
    NSArray *btnArray = @[cameraBtn, galleryBtn, saveBtn];
    self.navigationItem.rightBarButtonItems = btnArray;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Settings" inManagedObjectContext:_managedObjectContext];
    [fetchRequest setEntity:entity];
    NSArray *settings = [_managedObjectContext executeFetchRequest:fetchRequest error:nil];
    if (!settings.count) {
        NSLog(@"settings is nil");
        Settings *firstAndOnlyCounter = (Settings *)[NSEntityDescription insertNewObjectForEntityForName:@"Settings" inManagedObjectContext:_managedObjectContext];
        NSNumber *testNum = [NSNumber numberWithInt:0];
        [firstAndOnlyCounter setFilenameCounter:testNum];
    }
    else {
        _fileNameCounter = [settings objectAtIndex:0];
        int value = [[_fileNameCounter filenameCounter]intValue];
        [_fileNameCounter setFilenameCounter:[NSNumber numberWithInt:value + 1]];
        
    }
    NSLog(@"SETTINGS COUNT IS %@",[_fileNameCounter filenameCounter]);
    [_appDelegate saveContext];
    if (_rowSelected != nil){
        Peers *peerToAppear = [_peerArray objectAtIndex:[_rowSelected intValue]];
        _peerNameTextField.text = [[_peerArray objectAtIndex:[_rowSelected intValue]]peerName];
        _peerRatingTextField.text = [[_peerArray objectAtIndex:[_rowSelected intValue]]peerRating];
        _peerDescriptionTextView.text = [[_peerArray objectAtIndex:[_rowSelected intValue]]peerDescription];
        NSArray *sysPaths = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES );
        NSString *docDirectory = [sysPaths objectAtIndex:0];
        NSString *filePath = [NSString stringWithFormat:@"%@/%@.png", docDirectory, [peerToAppear peerImageFilename]];
        _selectedImageView.image = [[UIImage alloc] initWithContentsOfFile:filePath];
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
