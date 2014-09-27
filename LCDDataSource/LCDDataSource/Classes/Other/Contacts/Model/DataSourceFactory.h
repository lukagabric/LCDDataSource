#import "LGDataUpdateOperationManager.h"


@interface DataSourceFactory : NSObject


+ (LGDataUpdateOperationManager *)contactsDataManagerWithActivityView:(UIView *)activityView;


@end