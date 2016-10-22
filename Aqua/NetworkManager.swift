//
//  NetworkManager.swift
//  Aqua
//
//  Created by Edgard Aguirre Rozo on 10/22/16.
//  Copyright © 2016 Edgard Aguirre Rozo. All rights reserved.
//

import Foundation
import Alamofire
import ApiAI

struct NetworkManagerConfig {
    static let baseUrlString = "http://10.11.83.15:3000"
    static let openUrlString = "/hola/open"
    static let closeUrlString = "/hola/close"
}

class NetworkManager {
    static let sharedInstance = NetworkManager()
    private init(){}
    
    func makeOpenRequest(completion: @escaping ([AnyObject]?) -> Void ) {
        let url = NetworkManagerConfig.baseUrlString + NetworkManagerConfig.openUrlString
        Alamofire.request(url).responseString { response in
            
        }
        
    }
    
    func makeCloseRequest(completion: @escaping ([AnyObject]?) -> Void ) {
        let url = NetworkManagerConfig.baseUrlString + NetworkManagerConfig.closeUrlString
        Alamofire.request(url).responseString { response in
            
        }
        
    }
    
    func textRequest(withText writtenRequest: String, completion: @escaping (NSDictionary) -> Void) {
        let request = ApiAI.shared().textRequest()
        request?.query = [writtenRequest]
        
        request?.setCompletionBlockSuccess({(request, response) -> Void in
            print(response)
            completion(response as! NSDictionary)
            }, failure: { (request, error) -> Void in
                
        });        
        ApiAI.shared().enqueue(request)
    }
    
}
