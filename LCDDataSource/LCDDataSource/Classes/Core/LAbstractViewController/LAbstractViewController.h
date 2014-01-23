#import <UIKit/UIKit.h>


@interface LAbstractViewController : UIViewController
{
	BOOL _visible;
}


@property (readonly, nonatomic, getter = isVisible) BOOL visible;


@end


#pragma mark - Protected methods


@interface LAbstractViewController ()


- (void)initialize;
- (void)loadGUI;
- (void)bindGUI;
- (void)layoutGUI;
- (void)loadData;

- (void)appWillEnterForeground;
- (void)appDidEnterBackground;
- (void)appWillResignActive;
- (void)appDidBecomeActive;


@end