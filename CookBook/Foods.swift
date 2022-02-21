//
//  Foods.swift
//  CookBook
//
//  Created by Nihat on 20.02.2022.
//

import Foundation
import UIKit

class Foods {
    var name : String
    var details : String
    var image : UIImage
    
    init(foodName : String , foodDetails : String ,foodImage : UIImage){
        name = foodName
        details = foodDetails
        image = foodImage
    }
    
}
