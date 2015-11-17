//
//  Moovee.swift
//  Movie Tomato
//
//  Created by Dave Vo on 11/15/15.
//  Copyright © 2015 DaveVo. All rights reserved.
//

import Foundation
import SwiftyJSON

class Moovee {
  var title = ""
  var year = 0
  var length = ""
  var synopsis = ""
  var mpaaRating = ""
  var ratingPercentage = ""
  var ratingIconName = ""
  var thumbnailURLstring = ""
  var posterURLstring = ""
  
  init(json: JSON) {
    title = json["title"].stringValue
    year = json["year"].intValue
    length = String(json["runtime"].intValue) + "'"
    synopsis = json["synopsis"].stringValue
    mpaaRating = json["mpaa_rating"].stringValue
    
    ratingPercentage = String(json["ratings"]["critics_score"].intValue) + "%"
    
    let rating = json["ratings"]["critics_rating"]
    switch rating {
    case "Certified Fresh":
      ratingIconName = "cfresh"
    case "Fresh":
      ratingIconName = "fresh"
    case "Rotten":
      ratingIconName = "rotten"
    default:
      ratingIconName = "fresh"
    }
    
    thumbnailURLstring = json["posters"]["thumbnail"].stringValue
    posterURLstring = json["posters"]["detailed"].stringValue
  }
  
  static func moviesWithArray(array: [JSON]) -> [Moovee] {
    var movies = [Moovee]()
    for item in array {
      let movie = Moovee(json: item)
      movies.append(movie)
    }
    return movies
  }
  
  func titleWithYear () -> String {
    return title + " (" + String(year) + ")\n\n"
  }
}

