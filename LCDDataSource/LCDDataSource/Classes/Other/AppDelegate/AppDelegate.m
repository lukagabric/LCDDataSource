#import "AppDelegate.h"
#import "LGCoreDataController.h"
#import "HomeViewController.h"


@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[LGCoreDataController sharedCDController] initializeWithDatabaseFileName:@"LCDDataSource" andDataModelFileName:@"LCDDataSource"];
    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:[HomeViewController new]];
    [self.window makeKeyAndVisible];
    
    return YES;
}


@end