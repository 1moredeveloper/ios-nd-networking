//
//  ParseImageOperation.swift
//  TheMovieManager
//
//  Created by Jarrod Parkes on 10/10/17.
//  Copyright © 2017 Udacity. All rights reserved.
//

import UIKit
import Foundation

// MARK: - ParseImageOperation: BaseOperation

class ParseImageOperation: BaseOperation {
    
    // MARK: Properties
    
    var parsedImage: UIImage?
    var parsedError: Error?
    
    // MARK: Operation
    
    override func start() {
        guard !isCancelled else { return }
        
        state = .executing
        
        // get image from finished fetch operation
        if let imageFetchOp = dependencies.first as? FetchOperation {
            if let data = imageFetchOp.fetchedData {
                parsedImage = UIImage(data: data)
            }
            parsedError = imageFetchOp.fetchedError
        }
        
        state = .finished
    }
}
