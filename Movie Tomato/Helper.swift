//
//  Helper.swift
//  Movie Tomato
//
//  Created by Dave Vo on 11/15/15.
//  Copyright © 2015 DaveVo. All rights reserved.
//

import Foundation

class Helper {
  class func hasConnectivity() -> Bool {
    let reachability: Reachability
    do {
      reachability = try Reachability.reachabilityForInternetConnection()
      let networkStatus: Int = reachability.currentReachabilityStatus.hashValue
      //print(networkStatus)
      return networkStatus != 0
    } catch {
      print("Unable to create Reachability")
      return false
    }
  }
}
