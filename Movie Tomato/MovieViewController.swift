//
//  ViewController.swift
//  Movie Tomato
//
//  Created by Dave Vo on 11/9/15.
//  Copyright © 2015 DaveVo. All rights reserved.
//

import UIKit
import AFNetworking
import SwiftyJSON

let visiblePosition: CGFloat = 65.0
let invisiblePosition: CGFloat = 34.0

class MovieViewController: UIViewController, UITabBarDelegate, UIGestureRecognizerDelegate {
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var tabbarController: UITabBar!
  @IBOutlet weak var noNetworkLabel: UILabel!
  @IBOutlet weak var networkView: UIView!
  @IBOutlet weak var hideNoNetworkButton: UIButton!
  @IBOutlet weak var searchBar: UISearchBar!
  @IBOutlet weak var dimmingView: UIView!
  
  var movies = [Moovee]()
  var foundMovies = [Moovee] ()
  var isSearching: Bool = false
  var refreshControl = UIRefreshControl()
  var tapGestureOnDimming: UITapGestureRecognizer!
  var tapGestureOnTable: UITapGestureRecognizer!
  
  let movieDataURL = "https://coderschool-movies.herokuapp.com/movies?api_key=xja087zcvxljadsflh214"
  let dvdDataURL = "https://coderschool-movies.herokuapp.com/dvds?api_key=xja087zcvxljadsflh214"
  var jsonURL: String!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
    tableView.dataSource = self
    tableView.delegate = self
    tabbarController.delegate = self
    searchBar.delegate = self
    networkView.frame.origin.y = invisiblePosition
    dimmingView.frame.origin.y = tableView.frame.origin.y
    dimmingView.frame.size.height = tableView.frame.size.height
    dimmingView.hidden = true
    
    refreshControl.tintColor = UIColor.whiteColor()
    refreshControl.addTarget(self, action: Selector("fetchMovies"), forControlEvents: UIControlEvents.ValueChanged)
    tableView.addSubview(refreshControl)
    
    tabbarController.selectedItem = tabbarController.items![0]
    tabbarController.tintColor = UIColor(red: 1, green: 99/255, blue: 71/255, alpha: 1)
    jsonURL = movieDataURL
    
    // When user seaching and tap on the dimmingView then cancel the search
    // This behavior is exactly the same with seach in Setting on iOS
    tapGestureOnDimming = UITapGestureRecognizer(target: self, action: "cancelSearch:")
    dimmingView.addGestureRecognizer(tapGestureOnDimming)
    //    tapGestureOnTable = UITapGestureRecognizer(target: self, action: "hideKeyboard:")
    //    tableView.addGestureRecognizer(tapGestureOnTable)
    
    CozyLoadingActivity.show("Loading...", disableUI: true)
    fetchMovies()
    
  }
  
  func fetchMovies() {
    // Cancel all search
    searchBarCancelButtonClicked(searchBar)
    
    // This is for display purpose only, the request will use the cache
    // No need to handle the noNetwork in the request
    if Helper.hasConnectivity() {
      showNoNetwork(invisiblePosition)
    } else {
      showNoNetwork(visiblePosition)
    }
    
    let url = NSURL(string: jsonURL)
    let request = NSURLRequest(URL: url!, cachePolicy: NSURLRequestCachePolicy.ReturnCacheDataElseLoad, timeoutInterval: 5)
    let session = NSURLSession.sharedSession()
    let task = session.dataTaskWithRequest(request) { (dataFromNetwork: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
      
      guard error == nil else {
        print("error in fetchMovie")
        // Stop refreshing, hide the hud
        self.refreshControl.endRefreshing()
        CozyLoadingActivity.hide(success: false, animated: false)
        return
      }
      
      //let json = try! NSJSONSerialization.JSONObjectWithData(data!, options: .AllowFragments) as! NSDictionary
      //self.movies = json["movies"] as! [NSDictionary]
      
      let json = JSON(data: dataFromNetwork!)
      if let listMovie = json["movies"].array {
        self.movies = Moovee.moviesWithArray(listMovie)
      }
      
      dispatch_async(dispatch_get_main_queue(), { () -> Void in
        self.tableView.reloadData()
        self.refreshControl.endRefreshing()
        CozyLoadingActivity.hide(success: true, animated: false)
      })
    }
    
    task.resume()
    
  }
  
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if (segue.identifier == "detailSegue") {
      let detailVC: DetailViewController = segue.destinationViewController as! DetailViewController
      let data = sender as! Moovee
      detailVC.movie = data
    }
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
  
  // MARK: Network
  
  func showNoNetwork(yPosition: CGFloat) {
    UIView.animateWithDuration(0.5, animations: {
      self.networkView.frame.origin.y = yPosition
    })
  }
  
  @IBAction func hideNetworkMessage(sender: AnyObject) {
    showNoNetwork(invisiblePosition)
  }
  
}

// MARK: - TableView

extension MovieViewController: UITableViewDataSource, UITableViewDelegate {
  
  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    // Use indexPath.section instead of .row because each section contains 1 row only
    let movie = isSearching ? foundMovies[indexPath.section] : movies[indexPath.section]
    let cell = tableView.dequeueReusableCellWithIdentifier("movieCell") as! MovieCell
    
    // Make the round corners
    cell.layer.cornerRadius = 5
    cell.layer.masksToBounds = true
    cell.layer.borderWidth = 0.5
    cell.layer.borderColor = UIColor.grayColor().CGColor
    
    cell.titleLabel?.text = movie.title
    cell.synopsisLabel?.text = movie.synopsis
    cell.yearLabel?.text = String(movie.year)
    cell.mpaaRateLabel?.text = movie.mpaaRating
    cell.lengthLabel?.text = movie.length
    cell.ratingLabel?.text = movie.ratingPercentage
    cell.ratingImage.image = UIImage(named: movie.ratingIconName)
    
    let url = NSURL(string: movie.thumbnailURLstring)
    //cell.posterView?.setImageWithURL(url!)
    
    let request = NSURLRequest(URL: url!, cachePolicy: NSURLRequestCachePolicy.ReturnCacheDataElseLoad, timeoutInterval: 5)
    cell.posterView?.setImageWithURLRequest(request, placeholderImage: nil,
      success: {(request: NSURLRequest, response: NSHTTPURLResponse?, image: UIImage) -> Void in
        if Helper.hasConnectivity() {
          // Fade in image
          cell.posterView.alpha = 0.0
          UIView.animateWithDuration(0.3, animations: {
            cell.posterView.image = image
            cell.posterView.alpha = 1.0
            }, completion: nil)
        } else {
          // Load immediatelly
          cell.posterView.image = image
        }
      }, failure: {(request: NSURLRequest,response: NSHTTPURLResponse?, error: NSError) -> Void in
        
    })
    
    return cell
  }
  
  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return isSearching ? foundMovies.count : movies.count
  }
  
  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return 1
  }
  
  func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    return 10.0
  }
  
  func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    let footerView = UIView(frame: CGRectMake(0, 0, tableView.frame.size.width, 10))
    footerView.backgroundColor = UIColor.clearColor()
    return footerView
  }
  
  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    // Perform segue
    let movie = isSearching ? foundMovies[indexPath.section] : movies[indexPath.section]
    
    performSegueWithIdentifier("detailSegue", sender: movie)
  }
  
}

// MARK: - Search Function

extension MovieViewController: UISearchBarDelegate {
  
  func cancelSearch(gesture: UITapGestureRecognizer) {
    if gesture.state == UIGestureRecognizerState.Ended {
      searchBarCancelButtonClicked(searchBar)
    }
  }
  
  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
    self.view.superview?.superview?.endEditing(true)
    searchBar.resignFirstResponder()
  }
  
  //  func hideKeyboard(gesture: UITapGestureRecognizer) {
  //    searchBar.resignFirstResponder()
  //  }
  
  func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
    if let st = searchBar.text {
      dimmingView.hidden = !st.isEmpty
    }
    searchBar.enablesReturnKeyAutomatically = true
    searchBar.showsCancelButton = true
  }
  
  func searchBarTextDidEndEditing(searchBar: UISearchBar) {
    searchBar.resignFirstResponder()
  }
  
  func searchBarCancelButtonClicked(searchBar: UISearchBar) {
    searchBar.text = ""
    isSearching = false
    dimmingView.hidden = true
    self.tableView.reloadData()
    searchBar.resignFirstResponder()
  }
  
  func searchBarSearchButtonClicked(searchBar: UISearchBar) {
    searchBar.resignFirstResponder()
  }
  
  func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
    if searchText.isEmpty {
      // Load all
      isSearching = false
      self.tableView.reloadData()
      dimmingView.hidden = false
      return
    }
    
    isSearching = true
    dimmingView.hidden = true
    foundMovies = movies.filter({ (movie) -> Bool in
      let mv: Moovee = movie
      let range = NSString(string: mv.title).rangeOfString(searchText, options: NSStringCompareOptions.CaseInsensitiveSearch)
      return range.location != NSNotFound
    })
    
    self.tableView.reloadData()
  }
  
}
