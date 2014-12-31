//
//  SWNavigationController.h
//  SWNavigationController
//
//  Created by Christopher Wendel on 12/31/14.
//  Copyright (c) 2014 Christopher Wendel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SWNavigationController : UINavigationController <UINavigationControllerDelegate, UIGestureRecognizerDelegate>

/** A gesture recognizer responsible for pushing the most recently popped view controller back onto the navigation stack. (read-only)
 *
 *  Handles the right-to-left edge swipe gesture. Disable this gesture recognizer to disable the interactive push of the next view controller.
 *  Enabled by default
 */
@property (nonatomic, strong, readonly) UIGestureRecognizer *interactivePushGestureRecognizer;

/** The Class that handles the push transition when a view controller is pushed onto the navigation stack.
 *
 *  A new instance of this Class is initialized when a push occurs.
 *  The Class must implement the protocol UIViewControllerAnimatedTransitioning.
 *  By default this is set to SWPushAnimatedTransitioning.
 */
@property (nonatomic, strong) Class pushAnimatedTransitioningClass;


/** The Class that handles the pop transition when a view controller is popped off the navigation stack.
 *
 *  A new instance of this Class is initialized when a pop occurs.
 *  The Class must implement the protocol UIViewControllerAnimatedTransitioning
 *  If this is nil, UINavigationController's default pop animation will be used.
 */
@property (nonatomic, strong) Class popAnimatedTransitioningClass;

@end
