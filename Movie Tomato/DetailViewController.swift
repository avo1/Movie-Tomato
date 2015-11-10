//
//  DetailViewController.swift
//  Movie Tomato
//
//  Created by Dave Vo on 11/10/15.
//  Copyright © 2015 DaveVo. All rights reserved.
//

import UIKit
import AFNetworking


class DetailViewController: UIViewController {
  
  @IBOutlet weak var posterImageView: UIImageView!
  @IBOutlet weak var synopsisLabel: UILabel!
  
  var movie: NSDictionary!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    // Load the thumbnail first for user to see while waiting for loading the full image
    let thumbnailURLString = movie.valueForKeyPath("posters.thumbnail") as! String
    posterImageView.setImageWithURL(NSURL(string: thumbnailURLString)!)
    
    let posterURLString = movie.valueForKeyPath("posters.detailed") as! String
    posterImageView.setImageWithURL(NSURL(string: posterURLString)!)
    
    synopsisLabel.text = movie["synopsis"] as? String
  }
  
  /*
  // MARK: - Navigation
  
  // In a storyboard-based application, you will often want to do a little preparation before navigation
  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
  // Get the new view controller using segue.destinationViewController.
  // Pass the selected object to the new view controller.
  }
  */
  
}
