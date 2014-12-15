//
//  NAVNavigationControllerUpdater.m
//  NavigationRouter
//

@import ObjectiveC;

#import "NAVNavigationControllerUpdater.h"

#define NAVNavigationControllerDidSetDelegateNotification @"NAVNavigationControllerDidSetDelegate"

@interface NAVNavigationControllerUpdater () <UINavigationControllerDelegate>
@property (weak, nonatomic) UINavigationController *navigationController;
@property (weak, nonatomic) id<UINavigationControllerDelegate> navigationDelegate;
@end

@implementation NAVNavigationControllerUpdater

+ (void)initialize
{
    [self swizzleNavigationControllerSetter];
}

- (instancetype)initWithNavigationController:(UINavigationController *)navigationController
{
    NSParameterAssert(navigationController);
    
    if(self = [super init]) {
        // store our direct properties
        _navigationController = navigationController;
        
        // hijack the navigation controller's delegate
        [self updateNavigationDelegate:navigationController.delegate];
        
        // observe delegate updates for this particular nav controller
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(navigationControllerDidSetDelegate:)
                                                     name:NAVNavigationControllerDidSetDelegateNotification object:navigationController];
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

# pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController didShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    // forward this method explicitly to original the delegate (if it cares)
    if([self.navigationDelegate respondsToSelector:_cmd]) {
        [self.navigationDelegate navigationController:navigationController didShowViewController:viewController animated:animated];
    }   
}

//
// Proxying
//

- (BOOL)respondsToSelector:(SEL)selector
{
    return [super respondsToSelector:selector] || [self shouldForwardSelector:selector];
}

- (id)forwardingTargetForSelector:(SEL)selector
{
    return [self shouldForwardSelector:selector] ? self.navigationDelegate : nil;
}

- (BOOL)shouldForwardSelector:(SEL)selector
{
    // get the corresponding method description from the UINavigationControllerDelegate protocol
    struct objc_method_description method = protocol_getMethodDescription(@protocol(UINavigationControllerDelegate), selector, NO, YES);
    // verify that the method is part of this protocol, and that the original delegate responds to it
    return method.name != NULL && [self.navigationDelegate respondsToSelector:selector];
}

# pragma mark - Notifications

- (void)navigationControllerDidSetDelegate:(NSNotification *)notification
{
    // we want to know if someone new (and besides us) became the nav controller's delegate
    if(notification.object == self || notification.object == self.navigationDelegate) {
        return;
    }
    
    // if so, let's capture it and set ourselves as the delgate again
    [self updateNavigationDelegate:notification.object];
}

- (void)updateNavigationDelegate:(id<UINavigationControllerDelegate>)navigationDelegate
{
    self.navigationDelegate = navigationDelegate;
    self.navigationController.delegate = self;
}

# pragma mark - Swizzling

static IMP original_setDelegate;

+ (void)swizzleNavigationControllerSetter
{
    // get the delegate setter for navigation controller
    Method method = class_getInstanceMethod(UINavigationController.class, @selector(setDelegate:));
    // swizzle and store the original implementation to call from our swizzled setter
    original_setDelegate = method_setImplementation(method, (IMP)nav_setDelegate);
}

void nav_setDelegate(id self, SEL cmd, id<UINavigationControllerDelegate> delegate)
{
    original_setDelegate(self, cmd, delegate);
    // post a notification that this nav controller updated its delegate
    [[NSNotificationCenter defaultCenter] postNotificationName:NAVNavigationControllerDidSetDelegateNotification object:self];
}

@end
