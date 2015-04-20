//
//  MBViewController.m
//  MBVineVideo
//
//  Created by inket on 04/16/2015.
//  Copyright (c) 2014 inket. All rights reserved.
//

#import "MBViewController.h"
#import "../../Pod/Classes/MBVineVideo.h"
#import <MediaPlayer/MediaPlayer.h>

@interface MBViewController ()

@end

@implementation MBViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [MBVineVideo fetchVineFromURL:@"http://vine.co/v/euEpIVegiIx" completionHandler:^(MBVineVideo *vine, NSError *error) {
        NSLog(@"%@\n%@\n%@\n%@", vine, vine.title, vine.thumbnailURL, vine.videoURL);
        
        MPMoviePlayerViewController* videoPlayerViewController = [[MPMoviePlayerViewController alloc] initWithContentURL:vine.videoURL];
        [self presentMoviePlayerViewControllerAnimated:videoPlayerViewController];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
