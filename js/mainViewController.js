var MainViewController = JSB.defineClass('MainViewController : UITableViewController', {
  viewDidLoad: function() {
    self.navigationItem.title = 'UICatalog';

    self.list = [{
      title: 'Buttons',
      explanation: 'Various uses of UIButton',
    },
    {
      title: 'Controls',
      explanation: 'Various uses of UIControl',
    },
    {
      title: 'Table View',
      explanation: 'Use of UITableView',
    },
    {
      title: 'Collection View',
      explanation: 'Use of UICollectionView',
    },
    {
      title: 'Web',
      explanation: 'Use of UIWebView',
    },
    {
      title: 'Map',
      explanation: 'Use of MKMapView',
    },
    {
      title: 'Gesture',
      explanation: 'Use of UIGestureRecognizer',
    },
    {
      title: 'Gradient Layer',
      explanation: 'Use of CAGradientLayer',
    },
    {
      title: 'SpriteKit',
      explanation: 'Use of SpriteKit',
    }]
  },
  tableViewNumberOfRowsInSection: function(tableView, section) {
    return self.list.length;
  },
  tableViewCellForRowAtIndexPath: function(tableView, indexPath) {
    var cell = UITableViewCell.alloc().initWithStyleReuseIdentifier(3, 'Cell');
    cell.accessoryType = 1;
    cell.textLabel.text = self.list[indexPath.row]['title'];
    cell.detailTextLabel.text = self.list[indexPath.row]['explanation'];

    return cell;
  }
//  tableViewDidSelectRowAtIndexPath: function(tableView, indexPath) {
//    var targetViewController = UIViewController.new();
//    self.navigationController.pushViewControllerAnimated(targetViewController, true);
//  }
});

module.exports = MainViewController;
