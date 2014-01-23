#import "AppDelegate.h"
#import "LCoreDataController.h"
#import "HomeViewController.h"


@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[LCoreDataController sharedCDController] initializeWithDatabaseFileName:@"LCDDataSource" andDataModelFileName:@"LCDDataSource"];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[HomeViewController new]];
    [self.window makeKeyAndVisible];
    
    return YES;
}


@end