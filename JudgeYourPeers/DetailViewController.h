//
//  ViewController.h
//  JudgeYourPeers
//
//  Created by Jack Borthwick on 6/29/15.
//  Copyright (c) 2015 Jack Borthwick. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController  <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) IBOutlet NSNumber         *rowSelected;

@end

