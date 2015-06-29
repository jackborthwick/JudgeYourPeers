//
//  TableView.m
//  JudgeYourPeers
//
//  Created by Jack Borthwick on 6/29/15.
//  Copyright (c) 2015 Jack Borthwick. All rights reserved.
//

#import "TableView.h"
#import <CoreData/CoreData.h>
#import "Peers.h"
#import "AppDelegate.h"
#import "DetailViewController.h"
@interface TableView ()
@property (nonatomic,strong) IBOutlet UITableView    *tableView;
@property (nonatomic,strong) NSArray                 *peerArray;
@property (nonatomic, strong) AppDelegate               *appDelegate;
@property (nonatomic, strong) NSManagedObjectContext    *managedObjectContext;
@end

@implementation TableView

int rowSelected;

-(NSArray *)fetchPeers {
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Peers" inManagedObjectContext:_managedObjectContext];
    [fetchRequest setEntity:entity];
    

    
    return  [_managedObjectContext executeFetchRequest:fetchRequest error:nil];
}

-(IBAction)newPeerToReview:(id)sender{
    [self performSegueWithIdentifier:@"newPeerSegue" sender:self];

}

#pragma mark - Table View Methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _peerArray.count;//_peerArray.count;
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *cellId = @"Cell";
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellId];
    //NSLog(@"NAME%@",[[_peerArray objectAtIndex:indexPath.row] peerName]);
    if (cell == nil) {//else if you dont have one to reuse lets make a new one
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellId];
        cell.textLabel.textColor = [UIColor purpleColor];
    }
    NSArray *sysPaths = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES );
    NSString *docDirectory = [sysPaths objectAtIndex:0];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@.png", docDirectory, [[_peerArray objectAtIndex:indexPath.row] peerImageFilename]];
    cell.imageView.image = [[UIImage alloc] initWithContentsOfFile:filePath];
    cell.textLabel.text = [[_peerArray objectAtIndex:indexPath.row] peerName];
    cell.detailTextLabel.text = [[_peerArray objectAtIndex:indexPath.row]peerRating];
    //NSLog(@"NAME%@",[[_peerArray objectAtIndex:indexPath.row] peerName]);
    return cell;
}

-(void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"select");
    rowSelected = indexPath.row;
    [self performSegueWithIdentifier:@"viewPeerSegue" sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    DetailViewController *destController = [segue destinationViewController];
    NSIndexPath *indexPath = [_tableView indexPathForSelectedRow];
    if ([[segue identifier] isEqualToString:@"viewPeerSegue"]) {
        
        destController.rowSelected = [NSNumber numberWithInt:indexPath.row];
    }
    else if ([[segue identifier] isEqualToString:@"newPeerSegue"]){
        destController.rowSelected = nil;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    _managedObjectContext = _appDelegate.managedObjectContext;
    _peerArray = [self fetchPeers];
    NSLog(@"COUNT IS %lu",(unsigned long)_peerArray.count);
    //NSLog(@"yoyoy %li", _peerArray.count);
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
