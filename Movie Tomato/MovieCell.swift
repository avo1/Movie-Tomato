//
//  MovieCell.swift
//  Movie Tomato
//
//  Created by Dave Vo on 11/9/15.
//  Copyright © 2015 DaveVo. All rights reserved.
//

import UIKit

class MovieCell: UITableViewCell {
  
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var synopsisLabel: UILabel!
  @IBOutlet weak var posterView: UIImageView!
  @IBOutlet weak var yearLabel: UILabel!
  @IBOutlet weak var mpaaRateLabel: UILabel!
  @IBOutlet weak var lengthLabel: UILabel!
  @IBOutlet weak var ratingLabel: UILabel!
  @IBOutlet weak var ratingImage: UIImageView!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    // Initialization code
  }
  
  override func setSelected(selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
}
