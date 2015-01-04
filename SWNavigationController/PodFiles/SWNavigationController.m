//
//  SWNavigationController.m
//  SWNavigationController
//
//  Created by Christopher Wendel on 12/31/14.
//  Copyright (c) 2014 Christopher Wendel. All rights reserved.
//

#import "SWNavigationController.h"
#import "SWPushAnimatedTransitioning.h"

#define kSWGestureVelocityThreshold 800

typedef void (^SWNavigationControllerPushCompletion)(void);

@interface SWNavigationController () {
    UIScreenEdgePanGestureRecognizer *_interactivePushGestureRecognizer;
}

@property (nonatomic, strong) UIPercentDrivenInteractiveTransition *percentDrivenInteractiveTransition;
@property (nonatomic, strong, readwrite) UIScreenEdgePanGestureRecognizer *interactivePushGestureRecognizer;

@property (nonatomic, strong) NSMutableArray *pushableViewControllers; // View controllers we can push onto the navigation stack by pulling in from the right screen edge.

// Extra state used to implement completion blocks on pushViewController:
@property (nonatomic, copy) SWNavigationControllerPushCompletion pushCompletion;
@property (nonatomic, strong) UIViewController *pushedViewController;

@end

@implementation SWNavigationController

#pragma mark - Initializers

-(instancetype)initWithNavigationBarClass:(Class)navigationBarClass toolbarClass:(Class)toolbarClass
{
    self = [super initWithNavigationBarClass:navigationBarClass toolbarClass:toolbarClass];
    
    if (self) {
        [self setup];
    }
    
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    
    if (self) {
        [self setup];
    }
    
    return self;
}

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController
{
    self = [super initWithRootViewController:rootViewController];
    
    if (self) {
        [self setup];
    }
    
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        [self setup];
    }
    
    return self;
}

- (void)setup
{
    _pushableViewControllers = [NSMutableArray array];
    
    self.delegate = self;
    
    // By default, we use SWPushAnimatedTransitioning, which is a clone of the default push transition
    self.pushAnimatedTransitioningClass = [SWPushAnimatedTransitioning class];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _interactivePushGestureRecognizer = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handleRightSwipe:)];
    _interactivePushGestureRecognizer.edges = UIRectEdgeRight;
    self.interactivePushGestureRecognizer.delegate = self;
    [self.view addGestureRecognizer:self.interactivePushGestureRecognizer];
    
    // To ensure swipe-back is still recognized
    self.interactivePopGestureRecognizer.delegate = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    [_pushableViewControllers removeAllObjects];
}

#pragma mark - Gesture Handlers

- (void)handleRightSwipe:(UIScreenEdgePanGestureRecognizer *)swipeGestureRecognizer
{
    CGFloat progress = ABS(-[swipeGestureRecognizer translationInView:self.view].x / self.view.frame.size.width); // 1.0 When the pushable vc has been pulled into place
    
    // Start, update, or finish the interactive push transition
    switch (swipeGestureRecognizer.state) {
        case UIGestureRecognizerStateBegan:
            [self pushNextViewControllerFromRight];
            break;
        case UIGestureRecognizerStateChanged:
            [self.percentDrivenInteractiveTransition updateInteractiveTransition:progress];
            break;
        case UIGestureRecognizerStateEnded:
            // Figure out if we should finish the transition or not
            [self handleEdgeSwipeEndedWithProgress:progress velocity:[swipeGestureRecognizer velocityInView:self.view].x];
            break;
        case UIGestureRecognizerStateFailed:
            [self.percentDrivenInteractiveTransition cancelInteractiveTransition];
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStatePossible:
        default:
            break;
    }
}

- (void)handleEdgeSwipeEndedWithProgress:(CGFloat)progress velocity:(CGFloat)velocity
{
    // kSWGestureVelocityThreshold threshold indicates how hard the finger has to flick left to finish the push transition
    if (velocity < 0 && (progress > 0.5 || velocity < -kSWGestureVelocityThreshold))
        [self.percentDrivenInteractiveTransition finishInteractiveTransition];
    else
        [self.percentDrivenInteractiveTransition cancelInteractiveTransition];
}

#pragma mark - UIGestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    BOOL shouldBegin = NO;
    
    if (gestureRecognizer == self.interactivePushGestureRecognizer) {
        shouldBegin = self.pushableViewControllers.count > 0 && !(self.pushableViewControllers.lastObject == self.topViewController);
    } else {
        shouldBegin = self.viewControllers.count > 1;
    }
    
    return shouldBegin;
}

#pragma mark - UINavigationController

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    [self.pushableViewControllers removeAllObjects];
    
    [super pushViewController:viewController animated:animated];
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
    // Dismiss the current view controllers keyboard (if it is displaying one), to avoid first responder problems when pushing back onto the stack
    [self.topViewController.view endEditing:YES];
    
    UIViewController *poppedViewController = [super popViewControllerAnimated:animated];
    [self.pushableViewControllers addObject:poppedViewController];
    return poppedViewController;
}

- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    NSArray *poppedViewControllers = [super popToViewController:viewController animated:animated];
    
    self.pushableViewControllers = [NSMutableArray arrayWithArray:[[poppedViewControllers reverseObjectEnumerator] allObjects]];
    
    return poppedViewControllers;
}

- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated
{
    NSArray *poppedViewControllers = [super popToRootViewControllerAnimated:YES];
    
    self.pushableViewControllers = [NSMutableArray arrayWithArray:[[poppedViewControllers reverseObjectEnumerator] allObjects]];
    
    return poppedViewControllers;
}

- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated
{
    [super setViewControllers:viewControllers animated:animated];
    
    [self.pushableViewControllers removeAllObjects];
}

#pragma mark - 

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(SWNavigationControllerPushCompletion)completion
{
    self.pushedViewController = viewController;
    self.pushCompletion = completion;
    [super pushViewController:viewController animated:animated];
}

- (void)pushNextViewControllerFromRight
{
    UIViewController *pushedViewController = [self.pushableViewControllers lastObject];
    
    if (pushedViewController && self.visibleViewController && !self.visibleViewController.isBeingPresented && !self.visibleViewController.isBeingDismissed) {
        [self pushViewController:pushedViewController animated:YES completion:^{
            [self.pushableViewControllers removeLastObject];
        }];
    }
}

#pragma mark - UINavigationControllerDelegate

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC
{
    // If we are either pulling in a new VC onto the stack or we have a custom pushAnimatedTransitioningClass that we want to use to transition
    if (operation == UINavigationControllerOperationPush && ([[(SWNavigationController *)navigationController interactivePushGestureRecognizer] state] == UIGestureRecognizerStateBegan || (self.pushAnimatedTransitioningClass != [SWPushAnimatedTransitioning class]))) {
        return [self.pushAnimatedTransitioningClass new];
    } else if (operation == UINavigationControllerOperationPop && self.popAnimatedTransitioningClass) {
        return [self.popAnimatedTransitioningClass new];
    }
    
    return nil;
}

- (id<UIViewControllerInteractiveTransitioning>)navigationController:(UINavigationController *)navigationController interactionControllerForAnimationController:(id<UIViewControllerAnimatedTransitioning>)animationController
{
    SWNavigationController *navController = (SWNavigationController *)navigationController;
    if (navController.interactivePushGestureRecognizer.state == UIGestureRecognizerStateBegan) {
        navController.percentDrivenInteractiveTransition = [UIPercentDrivenInteractiveTransition new];
        navController.percentDrivenInteractiveTransition.completionCurve = UIViewAnimationCurveEaseOut;
    } else {
        navController.percentDrivenInteractiveTransition = nil;
    }
    
    return navController.percentDrivenInteractiveTransition;
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (self.pushedViewController != viewController) {
        self.pushedViewController = nil;
        self.pushCompletion = nil;
    }
}

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (self.pushCompletion && self.pushedViewController == viewController) {
        self.pushCompletion();
    }
    
    self.pushCompletion = nil;
    self.pushedViewController = nil;
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
