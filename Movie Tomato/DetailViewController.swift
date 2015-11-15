//
//  DetailViewController.swift
//  Movie Tomato
//
//  Created by Dave Vo on 11/10/15.
//  Copyright © 2015 DaveVo. All rights reserved.
//

import UIKit
import AFNetworking


class DetailViewController: UIViewController, UIGestureRecognizerDelegate {
  
  @IBOutlet weak var posterImageView: UIImageView!
  @IBOutlet weak var synopsisText: UITextView!
  @IBOutlet weak var dimmingView: UIView!
  @IBOutlet weak var networkView: UIView!
  @IBOutlet weak var hideNoNetworkButton: UIButton!
  
  var movie: NSDictionary!
  var isReadingFullSynopsis: Bool!
  var tapGesture: UITapGestureRecognizer!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    // Do any additional setup after loading the view.
    
    
    // Create the content: title (year) + synopsis
    var text = (movie["title"] as? String)! + " (" + String(movie["year"] as! Int) + ")\n\n"
    let titleLength = text.characters.count
    text += (movie["synopsis"] as? String)!
    let textLength = text.characters.count
    
    let attributedText: NSMutableAttributedString = NSMutableAttributedString(string: text)
    
    // Make bold title, regular synopsis, all white
    attributedText.addAttributes([NSFontAttributeName: UIFont.boldSystemFontOfSize(17)], range: NSRange(location: 0, length: titleLength - 2))
    attributedText.addAttributes([NSFontAttributeName: UIFont.systemFontOfSize(15)], range: NSRange(location: titleLength, length: textLength - titleLength))
    attributedText.addAttribute(NSForegroundColorAttributeName, value: UIColor.whiteColor() , range: NSRange(location: 0, length: textLength))
    
    // Why if I uncheck "selectable" in storyboard, the textView will be empty regardless to whatever the text I set?
    synopsisText.attributedText = attributedText
    synopsisText.selectable = false
    
    // Create the "padding" for the text
    synopsisText.textContainerInset = UIEdgeInsetsMake(0, 10, 0, 10)
    isReadingFullSynopsis = false
    showSynopsis(UIScreen.mainScreen().bounds.height - 100, bgAlpha: 0.1)
    
    // Just set the bg color's alpha
    // Don't set the view's alpha else the subView will inherit it
    dimmingView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.1)
    tapGesture = UITapGestureRecognizer(target: self, action: "showMore:")
    self.view.addGestureRecognizer(tapGesture)
    
    // Load the thumbnail first for user to see while waiting for loading the full image
    let thumbnailURLString = movie.valueForKeyPath("posters.thumbnail") as! String
    posterImageView.setImageWithURL(NSURL(string: thumbnailURLString)!)
    
    let posterURLString = movie.valueForKeyPath("posters.detailed") as! String
    posterImageView.setImageWithURL(NSURL(string: posterURLString)!)
    
    // Indicate network status
    if Helper.hasConnectivity() {
      showNoNetwork(invisiblePosition)
    } else {
      showNoNetwork(visiblePosition)
    }
  }
  
  func showMore(gesture: UITapGestureRecognizer) {
    if gesture.state == UIGestureRecognizerState.Ended {
      let tapLocation = gesture.locationInView(self.view)
      if tapLocation.y >= dimmingView.frame.origin.y {
        if !isReadingFullSynopsis {
          isReadingFullSynopsis = true
          showSynopsis(65, bgAlpha: 0.8)
        } else {
          isReadingFullSynopsis = false
          showSynopsis(UIScreen.mainScreen().bounds.height - 100, bgAlpha: 0.1)
        }
      }
    }
  }
  
  // This can detect the tap, but the scroll will be recognized as tap as well :(
  //  override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
  //    let touch = touches.first
  //    let touchLocation = touch!.locationInView(self.view)
  //    if touchLocation.y >= dimmingView.frame.origin.y {
  //      if !isReadingFullSynopsis {
  //        isReadingFullSynopsis = true
  //        showSynopsis(65, bgAlpha: 0.7)
  //      } else {
  //        isReadingFullSynopsis = false
  //        showSynopsis(UIScreen.mainScreen().bounds.height - 100, bgAlpha: 0.1)
  //      }
  //    }
  //  }
  
  
  func showSynopsis(y: CGFloat, bgAlpha: CGFloat) {
    UIView.animateWithDuration(0.3, delay: 0.0, options: UIViewAnimationOptions.CurveEaseOut, animations: {
      self.dimmingView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: bgAlpha)
      var frame = self.dimmingView.frame
      frame.origin.y = y
      frame.size.height = UIScreen.mainScreen().bounds.height - y
      self.dimmingView.frame = frame
      
      // The size of the textView to fit its content
      let newSize = self.synopsisText.sizeThatFits(CGSize(width: self.synopsisText.frame.width, height: CGFloat.max))
      
      let textHeight = min(frame.height - 10, newSize.height)
      self.synopsisText.frame.size.height = textHeight
      self.synopsisText.frame.origin.y = frame.height - (textHeight + 10)
      }, completion: nil)
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
