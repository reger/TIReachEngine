//
//  ReachEngineAppDelegate.h
//  ReachEngine
//
//  Created by Tom Irving on 20/09/2010.
//  Copyright 2010 Tom Irving. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReachEngineAppDelegate : NSObject <UIApplicationDelegate> {
    
    UIWindow * window;
    UINavigationController * navigationController;
}

@property (nonatomic, retain) UIWindow * window;
@property (nonatomic, retain) UINavigationController * navigationController;

@end

