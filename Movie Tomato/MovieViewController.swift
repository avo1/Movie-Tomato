//
//  ViewController.swift
//  Movie Tomato
//
//  Created by Dave Vo on 11/9/15.
//  Copyright © 2015 DaveVo. All rights reserved.
//

import UIKit
import AFNetworking

class MovieViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITabBarDelegate {
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var tabbarController: UITabBar!
  @IBOutlet weak var noNetworkLabel: UILabel!
  
  var movies = [NSDictionary] ()
  var refreshControl = UIRefreshControl()
  
  let movieDataURL = "https://coderschool-movies.herokuapp.com/movies?api_key=xja087zcvxljadsflh214"
  let dvdDataURL = "https://coderschool-movies.herokuapp.com/dvds?api_key=xja087zcvxljadsflh214"
  var jsonURL: String!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    //hasConnectivity()
    
    self.tableView.dataSource = self
    self.tableView.delegate = self
    self.tabbarController.delegate = self
    
    //    let attributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
    //    let attributedTitle = NSAttributedString(string: "Pull to refresh", attributes: attributes)
    //    refreshControl.attributedTitle = attributedTitle
    refreshControl.tintColor = UIColor.whiteColor()
    refreshControl.addTarget(self, action: Selector("fetchMovies"), forControlEvents: UIControlEvents.ValueChanged)
    tableView.addSubview(refreshControl)
    
    noNetworkLabel.alpha = 0
    noNetworkLabel.frame.origin.y = 40
    tabbarController.selectedItem = tabbarController.items![0]
    tabbarController.tintColor = UIColor.blackColor()
    jsonURL = movieDataURL
    
    CozyLoadingActivity.show("Loading...", disableUI: true)
    fetchMovies()
  }
  
  func fetchMovies() {
    
    let url = NSURL(string: jsonURL)
    //let request = NSURLRequest(URL: url!)
    let session = NSURLSession.sharedSession()
    let task = session.dataTaskWithURL(url!) { (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
      
      guard error == nil else {
        print("error in fetchMovie")
        // Show a network error indicator here
        UIView.animateWithDuration(1, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
          self.noNetworkLabel.alpha = 1
          self.noNetworkLabel.frame.origin.y = 65
          
          //      // Move down the tableView
          //      var frame = self.tableView.frame
          //      frame.origin.y = 90
          //      self.tableView.frame = frame
          }, completion: nil)
        
        // Hide the hud
        CozyLoadingActivity.hide(success: true, animated: false)
        return
      }
      
      // Normal position
      self.noNetworkLabel.alpha = 0
      self.noNetworkLabel.frame.origin.y = 40
      
      let json = try! NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as! NSDictionary
      self.movies = json["movies"] as! [NSDictionary]
      //print("json", self.movies)
      
      dispatch_async(dispatch_get_main_queue(), { () -> Void in
        self.tableView.reloadData()
        self.refreshControl.endRefreshing()
        CozyLoadingActivity.hide(success: true, animated: false)
      })
    }
    
    task.resume()
  }
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    // Use indexPath.section instead of .row because each section contains 1 row only
    let movie = movies[indexPath.section]
    let cell = tableView.dequeueReusableCellWithIdentifier("movieCell") as! MovieCell
    
    // Make the round corner
    cell.layer.cornerRadius = 5
    cell.layer.masksToBounds = true
    cell.layer.borderWidth = 0.5
    cell.layer.borderColor = UIColor.grayColor().CGColor
    
    cell.titleLabel?.text = movie["title"] as? String
    cell.synopsisLabel?.text = movie["synopsis"] as? String
    cell.yearLabel?.text = String(movie["year"] as! Int)
    cell.mpaaRateLabel?.text = movie["mpaa_rating"] as? String
    cell.lengthLabel?.text = String(movie["runtime"] as! Int) + "'"
    cell.ratingLabel?.text = String(movie.valueForKeyPath("ratings.critics_score") as! Int) + "%"
    
    if let rating = movie.valueForKeyPath("ratings.critics_rating") as? String {
      switch rating {
      case "Certified Fresh":
        cell.ratingImage.image = UIImage(named: "cfresh")
      case "Fresh":
        cell.ratingImage.image = UIImage(named: "fresh")
      case "Rotten":
        cell.ratingImage.image = UIImage(named: "rotten")
      default:
        cell.ratingImage.image = UIImage(named: "fresh")
      }
    }
    //cell.posterView?.contentMode = .ScaleAspectFit
    cell.posterView?.setImageWithURL(NSURL(string: movie.valueForKeyPath("posters.thumbnail") as! String)!)
    
    return cell
  }
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return movies.count
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }
  
  func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
    return 10.0
  }
  
  func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
    let footerView = UIView(frame: CGRectMake(0, 0, tableView.frame.size.width, 10))
    footerView.backgroundColor = UIColor.clearColor()
    return footerView
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if (segue.identifier == "detailSegue") {
      let detailVC: DetailViewController = segue.destinationViewController as! DetailViewController
      let data = sender as! NSDictionary
      detailVC.movie = data
    }
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    // Perform segue
    let movie = movies[indexPath.section]
    
    performSegueWithIdentifier("detailSegue", sender: movie)
  }
  
  func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
    // Switch view
    var newURL: String!
    if tabbarController.selectedItem == tabbarController.items![0] {
      newURL = movieDataURL
    } else {
      newURL = dvdDataURL
    }
    // Don't reload if user taps on the current tabBarItem again
    if newURL != jsonURL {
      jsonURL = newURL
      CozyLoadingActivity.show("Loading...", disableUI: true)
      fetchMovies()
    }
  }
  
  // Check network status using Reachability, no need in this assignment
  //  func hasConnectivity() -> Bool {
  //    let reachability: Reachability
  //    do {
  //      reachability = try Reachability.reachabilityForInternetConnection()
  //      let networkStatus: Int = reachability.currentReachabilityStatus.hashValue
  //      print(networkStatus)
  //      return networkStatus != 0
  //    } catch {
  //      print("Unable to create Reachability")
  //      return false
  //    }
  //  }
  
}



