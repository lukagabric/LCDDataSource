#import "LDataUpdateOperationManager.h"


@interface DataSourceFactory : NSObject


+ (LDataUpdateOperationManager *)contactsDataManagerWithActivityView:(UIView *)activityView;


@end