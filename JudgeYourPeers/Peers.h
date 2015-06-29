//
//  Peers.h
//  JudgeYourPeers
//
//  Created by Jack Borthwick on 6/29/15.
//  Copyright (c) 2015 Jack Borthwick. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Peers : NSManagedObject

@property (nonatomic, retain) NSString * peerName;
@property (nonatomic, retain) NSString * peerRating;
@property (nonatomic, retain) NSString * peerImageFilename;
@property (nonatomic, retain) NSString * peerDescription;

@end
