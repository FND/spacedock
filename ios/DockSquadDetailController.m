#import "DockSquadDetailController.h"

#import "DockEquippedShip+Addons.h"
#import "DockEditValueController.h"
#import "DockShipsViewController.h"
#import "DockShip+Addons.h"
#import "DockSquad+Addons.h"
#import "DockUtilsMobile.h"

@interface DockSquadDetailController ()
@property (nonatomic, strong) UITextView *nameTextView;
@end

@implementation DockSquadDetailController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return @"Details";
    }

    return @"Ships";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 2;
    }
    return _squad.equippedShips.count + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = [indexPath indexAtPosition: 0];
    UITableViewCell *cell = nil;
    if (section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"detail" forIndexPath:indexPath];
        NSInteger row = [indexPath indexAtPosition: 1];
        if (row == 0) {
            cell.textLabel.text = @"Name";
            cell.detailTextLabel.text = _squad.name;
        } else {
            cell.textLabel.text = @"Cost";
            cell.detailTextLabel.text = [NSString stringWithFormat: @"%d", _squad.cost];
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    } else {
        NSInteger row = [indexPath indexAtPosition: 1];
        NSInteger shipCount = _squad.equippedShips.count;
        if (row == shipCount) {
            cell = [tableView dequeueReusableCellWithIdentifier:@"addShip" forIndexPath:indexPath];
        } else {
            cell = [tableView dequeueReusableCellWithIdentifier:@"ship" forIndexPath:indexPath];
            DockEquippedShip* es = _squad.equippedShips[row];
            DockShip* ship = es.ship;
            cell.textLabel.text = ship.title;
            if ([ship isUnique]) {
                cell.detailTextLabel.text = ship.shipClass;
            } else {
                cell.detailTextLabel.text = @"";
            }
        }
    }
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = [indexPath indexAtPosition: 0];
    return section > 0;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger row = [indexPath indexAtPosition: 1];
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        DockEquippedShip* es = _squad.equippedShips[row];
        [_squad removeEquippedShip: es];
        NSError* error;
        if (!saveItem(_squad, &error)) {
            presentError(error);
        }
        [self.tableView deleteRowsAtIndexPaths: @[indexPath] withRowAnimation: UITableViewRowAnimationAutomatic];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = [indexPath indexAtPosition: 0];
    NSInteger row = [indexPath indexAtPosition: 1];
    if (section == 0) {
        return row == 0;
    } else {
        NSInteger shipCount = _squad.equippedShips.count;
        return row < shipCount;
    }
    return YES;
}

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    id destination = [segue destinationViewController];
    if ([[segue identifier] isEqualToString:@"PickShip"]) {
        DockShipsViewController *shipsViewController = (DockShipsViewController *)destination;
        shipsViewController.managedObjectContext = [_squad managedObjectContext];
        [shipsViewController targetSquad: _squad onPicked: ^(DockShip* theShip) { [self addShip: theShip]; }];
    } else if ([[segue identifier] isEqualToString:@"EditName"]) {
        DockEditValueController* editValue = (DockEditValueController*)destination;
        editValue.valueName = @"Name";
        editValue.initialValue = _squad.name;
        editValue.onSave = ^(NSString* newValue) {
            _squad.name = newValue;
            NSError *error;
            if (!saveItem(_squad, &error)) {
                presentError(error);
            }
            [self.tableView reloadData];
        };
    }
}

-(void)addShip:(DockShip*)ship
{
    DockEquippedShip* es = [DockEquippedShip equippedShipWithShip: ship];
    [_squad addEquippedShip: es];
    [self.navigationController popViewControllerAnimated:YES];
    NSError *error;
    if (![_squad.managedObjectContext save:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. 
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    [self.tableView reloadData];
}
@end
