#import "LAbstractViewController.h"


@implementation LAbstractViewController


#pragma mark - Synthesize


@synthesize visible = _visible;


#pragma mark - Init & Dealloc


- (id)init
{
	self = [super init];
	if (self)
	{
		[self initialize];
	}
	return self;
}


- (id)initWithCoder:(NSCoder *)aDecoder
{
	self = [super initWithCoder:aDecoder];
	if (self)
	{
		[self initialize];
	}
	return self;
}


- (void)initialize
{
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.navigationController.navigationBar.translucent = NO;

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillEnterForeground) name:UIApplicationWillEnterForegroundNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidEnterBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appWillResignActive) name:UIApplicationWillResignActiveNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidBecomeActive) name:UIApplicationDidBecomeActiveNotification object:nil];
}


- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}


#pragma mark - Memory Warning


- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}


#pragma mark - UIApplication notifications


- (void)appWillEnterForeground
{

}


- (void)appDidEnterBackground
{

}


- (void)appWillResignActive
{

}


- (void)appDidBecomeActive
{

}


#pragma mark - View


- (void)viewDidLoad
{
	[super viewDidLoad];

	[self loadGUI];
	[self loadData];
	[self bindGUI];
}


- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    
	_visible = YES;
    
	[self layoutGUI];
}


- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];

	_visible = NO;
}


#pragma mark loadGUI


- (void)loadGUI
{

}


#pragma mark bindGUI


- (void)bindGUI
{
    
}


#pragma mark layoutGUI


- (void)layoutGUI
{
    
}


#pragma mark - Data


- (void)loadData
{
    
}


#pragma mark - Orientation


- (BOOL)shouldAutorotate
{
	return YES;
}


- (NSUInteger)supportedInterfaceOrientations
{
	return UIInterfaceOrientationMaskPortrait;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
	return (toInterfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark -


@end