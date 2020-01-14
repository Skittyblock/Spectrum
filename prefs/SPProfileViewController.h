// SPProfileViewController.h

#import <Preferences/PSViewController.h>

@interface SPProfileViewController : PSViewController <UITableViewDelegate, UITableViewDataSource, UISearchControllerDelegate, UISearchBarDelegate>

@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) NSDictionary *properties;
@property (nonatomic, retain) NSArray<NSDictionary *> *profiles;
@property (nonatomic, assign) NSInteger selected;

- (id)initWithProperties:(NSDictionary *)properties;

@end
