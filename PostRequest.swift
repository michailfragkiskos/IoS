//
//  PostRequest.swift  
//
//  Created by  on 15/01/2015.
//  Copyright (c) 2015 michail fragkiskos. All rights reserved.

import UIKit
import Foundation
import SystemConfiguration

public enum ReachabilityType {
    case WWAN,
    WiFi,
    NotConnected
}

extension NSBundle {
    
    var releaseVersionNumber: String? {
        return self.infoDictionary?["CFBundleShortVersionString"] as? String
    }
    
    var buildVersionNumber: String? {
        return self.infoDictionary?["CFBundleVersion"] as? String
    }
    
}

struct progresViewText{
    static var progLabel:progresViewProtocol! = nil
}



//, NSURLSessionDataDelegate
class postRequest: UIViewController, NSXMLParserDelegate,  NSURLSessionDataDelegate{
    private var downloadTask: NSURLSessionDownloadTask?
    var addValues   = [String]()
    
    
    /*
     * Escape the spesial characters from the XMLRpc String
     **/

    class func XmlEscape(var val:String)->String{
        if(val.hasPrefix("<nil>")){
            return val;
        }
        
        val = val.stringByReplacingOccurrencesOfString("&", withString: "&amp;");
        val = val.stringByReplacingOccurrencesOfString("<", withString: "&lt;");
        val = val.stringByReplacingOccurrencesOfString(">", withString: "&gt;");
        val = val.stringByReplacingOccurrencesOfString("'", withString: "&apos;");

        
        return val;
    }
    
    
    
    
    class func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        let defaultRouteReachability = withUnsafePointer(&zeroAddress) {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
        }
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
         
         return (isReachable && !needsConnection) ? true : false
    }
    
    class func isConnectedToNetworkOfType() -> ReachabilityType {
        
        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
        zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        let defaultRouteReachability = withUnsafePointer(&zeroAddress) {
            SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0)) //.takeRetainedValue()
        }
        
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return .NotConnected
        }
        
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
         let isWWAN = flags.contains(.IsWWAN)
        if(isReachable && isWWAN){
            return .WWAN
        }
        if(isReachable && !isWWAN){
            return .WiFi
        }
        
        return .NotConnected
      }
        
    /*
    * this appenting a String
    * val the actual Value
    */
    
    func appendXmlValue(val:AnyObject){
            if val is String {
               addValues.append("<param><value><string>\(postRequest.XmlEscape(val as! String))</string></value></param>")
            }
            else if val is Double || val is Int {
             addValues.append("<param><value><int>\(val)</int></value></param>")
            }else if val is Bool {
                if val as! Bool {
                  addValues.append("<param><value><boolean>1</boolean></value></param>")
                } else {
                  addValues.append("<param><value><boolean>0</boolean></value></param>")
                }
             }
              else if val is NSDate {
                let dateFormatter = NSDateFormatter()
                dateFormatter.dateFormat = "dd-MM-yyyy HH:mm:ss"
                addValues.append("<param><value><dateTime.iso8601>\(val as! NSDate)</dateTime.iso8601></value></param>")
             } else if val as! String == "" {
            addValues.append("<param><value><nil>Null</nil></value></param>")
             }
        
    }
    
    /*
    * this Append an Array
    * val array of strings 
    * [type: the type of the element (int,string,bool,date),
    *  value: the actual value]
    */
    
    func appendXmlArray(val:[String:String]){
        var values = ""
        for (value,type) in val{
            values+="<value><\(type)>\(value)</\(type)></value>"
        }
        self.createArray(values)
    }
    
    /*
    * This append a Struct
    * data [Int:[String:String]]
    * [name:the name of the elemet,
    *  type: the type of the element (int,string,bool,date),
    *  value: the actual value]
    *  inArray default true 'create Struct in Array' or else false 'create only a Struct'
    */
    
    func appendXmlStruct(data:[Int:[String:String]], inArray:Bool = true){
        var formatedData=""
          if data.count > 0 {
            for (_, alldata) in data {
                if alldata.count > 0 {
                    formatedData += "<value><struct>"
            for (name,val) in alldata {
                if (!name.isEmpty && !val.isEmpty) {
                    formatedData += "<member>"
                 formatedData += "<name>\(name)</name>"
                let type = (mainVars.types["\(name)"] != nil) ? mainVars.types["\(name)"]: "string"
                let element = self.createElement(val, type: "\(type!)")
                 formatedData += "\(element)"
                formatedData += "</member>"
                }
                    }
                    formatedData += "</struct></value>"
            }
        }
        }
        if inArray == true {
            self.createArray("\(formatedData)")
        }else{
            addValues.append("\(formatedData)")
        }
     }
    
    /*
    * Create An xmlRpc element
    *
    */
    
   func createElement(data:String,type:String)->String{
        return "<value><\(type)>\(data)</\(type)></value>"
    }
    
    /*
    * Create An Array
    *
    */
    
     func createArray(vals:String){
        addValues.append("<param><value><array><data>\(vals)</data></array></value></param>")
    }     
   
    /*
    * Send post request to the server
    */
     func sendPost(method : String, completion: ((retdata: String?) -> ())) {
        if postRequest.isConnectedToNetwork() == false {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            completion(retdata:  "")
            return
        }
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        let w = setingsUrl.getSetings()
        let host: AnyObject =  w["hostname"]!
        let serv: AnyObject =  w["service"]!
        var post = "<?xml version=\"\(setingsUrl.getDefaultVersion)\" encoding=\"\(setingsUrl.getDefaultEncode)\"?><methodCall><methodName>\(method)</methodName><params>"
        for vals in addValues {
            post += "\(vals)"
        }
        post += "</params></methodCall>"
         let postData:NSData = post.dataUsingEncoding(NSUTF8StringEncoding)!
        let postLength:NSString = String(postData.length)
        let url = NSURL(string: "\(host)\(serv)" )
        let request = NSMutableURLRequest(URL: url!)
            request.setValue("\(postLength)", forHTTPHeaderField: "Content-Length")
            request.setValue("text/xml", forHTTPHeaderField: "Content-Type")
            request.setValue("\(setingsUrl.getUserEngine())", forHTTPHeaderField: "User-Agent")
            request.setValue("application/xml", forHTTPHeaderField: "Accept")
            request.HTTPMethod = "POST"
            request.HTTPShouldHandleCookies = false
            request.HTTPBody = postData
                
        NSURLSessionConfiguration.defaultSessionConfiguration().HTTPMaximumConnectionsPerHost = 6;
        NSURLSessionConfiguration.defaultSessionConfiguration().timeoutIntervalForResource = 50;
        NSURLSessionConfiguration.defaultSessionConfiguration().timeoutIntervalForRequest = 50;
         let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(), delegate: self, delegateQueue: NSOperationQueue.mainQueue())
        let downloadTask = session.dataTaskWithRequest(request, completionHandler: {
            (data,response,error) in
             // handle the errors
             if(error != nil){
                  mainVars.connectionErrorCode = (mainVars.connectionErrorMsg[Int(error!.code)] != nil) ? Int(error!.code) : -1
               dispatch_async(dispatch_get_main_queue(), {
                alerts.shared.ShowAlert(mainVars.connectionErrorMsg[mainVars.connectionErrorCode]!)
                })
                completion(retdata: "")
                  return
            }
           // handle the response
            if let httpResponse = response as? NSHTTPURLResponse {
                     if httpResponse.statusCode > 400 {
                          if(httpResponse.statusCode == 0  && mainVars.Inform==false){
                        mainVars.connectionErrorCode = (mainVars.connectionErrorMsg[httpResponse.statusCode] != nil) ? httpResponse.statusCode : -1
                          }
                        completion(retdata: "")
                        return
                   }
               }
            if(data != nil && data != ""){
            let data1 = NSString(data: data!, encoding: NSUTF8StringEncoding)
              let returnedData = dataXml.parse(String(data1))
                if returnedData["methodResponse"]["fault"]{
                    let ret = returnedData["methodResponse"]["fault"]["value"]["struct"]
                    for fault in ret["member"] {
                        if let name = fault["value"]["string"].element?.text! {
                            alerts.shared.ShowAlert("\(name)",title: StaticFileds.data_mobile_msg)
                        }
                    }
                    alerts.shared.hideProgressView()
                     UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    completion(retdata: "")
                    return
                }
              UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                
                if dataXml.validateXML(String(data1!)) == false {
                    alerts.shared.hideProgressView()
                     alerts.shared.ShowAlert(StaticFileds.url_ProxyError_msg)
                    completion(retdata: "")
                    return
                }
            completion(retdata: String(data1!))
            }else{
                completion(retdata: "")
            }
            self.resetView()
             return
                     })
        downloadTask.resume()
                }
    
     func resetView() {
            downloadTask?.cancel()
        }
    
   /***********************************************************/
   /*
    * Test the connection
    * With the Server
    */
    class func TestconnectWithdata()->Bool{
        if postRequest.isConnectedToNetwork() == false {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
           return  false
        }
         if postRequest.isConnectedToNetwork() == true {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        let post = postRequest()
            post.appendXmlValue(1)
            var d:Bool=false
        post.sendPost("data.mobile.test.ping"){
                data in
        if(data != ""){
            
            let pingdata = dataXml.parse(data!)
            
            
                 if let auth1 = pingdata["methodResponse"]["params"]["param"]["value"]["string"].element?.text {
                    if auth1 != "" || !auth1.isEmpty {
                      d = true
                    }else{
                      d = false
                    }
                }
          
        }
            }
        return d
    }else{
    if(mainVars.Inform==false){
    mainVars.connectionErrorCode = 0
    }
    return false
    }

    }
    
   /*
    * Check if the remote file exists
    */
    class func checkIfFileExists(query:NSString, completion: ((data: Int) -> ())){
        
        if postRequest.isConnectedToNetwork() == false {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
             completion(data:  400)
            return
        }
        
        if postRequest.isConnectedToNetwork() == true {
    UIApplication.sharedApplication().networkActivityIndicatorVisible = true
    let urlPath: String = query as String
    let url: NSURL = NSURL(string: urlPath)!
    let request: NSMutableURLRequest = NSMutableURLRequest(URL: url)
        request.setValue("\(setingsUrl.getUserEngine())", forHTTPHeaderField: "User-Agent")
        request.HTTPMethod = "GET"
        request.HTTPShouldHandleCookies = false
            NSURLSessionConfiguration.defaultSessionConfiguration().HTTPMaximumConnectionsPerHost = 6;
            NSURLSessionConfiguration.defaultSessionConfiguration().timeoutIntervalForResource = 60;
            NSURLSessionConfiguration.defaultSessionConfiguration().timeoutIntervalForRequest = 60;
            let session = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration(), delegate: self.init(), delegateQueue: NSOperationQueue.mainQueue())
            let downloadTask = session.dataTaskWithRequest(request, completionHandler: {
                (data,response,error) in
                if(error != nil){
                                            mainVars.ConnectionAlerded = true
                    mainVars.connectionErrorCode = (mainVars.connectionErrorMsg[Int(error!.code)] != nil) ? Int(error!.code) : -1
                   dispatch_async(dispatch_get_main_queue(), {
                    
                    alerts.shared.ShowAlert(mainVars.connectionErrorMsg[mainVars.connectionErrorCode]!)
                   })
                    completion(data: 400)
                    return
                }
                if let httpResponse = response as? NSHTTPURLResponse {
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                   completion(data: httpResponse.statusCode)
                    return
                }else{
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                   completion(data: 400)
                   return
                }
            })
            downloadTask.resume()
        }
        else{
    if(mainVars.Inform==false){
    mainVars.connectionErrorCode = 0
    }
    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
         
        return
            }
    }
    
    /*
     * Get the remote files from the server
     * If for eny reason cant retrive this file 
     * will return the questionmark img 
     * name the name of the pic if oyu want to save in the icons folder
     * url the url of the img
     */
    class func getDataFromUrl(urL:NSURL, name:String = "" , completion: ((data: NSData?) ->())) {
        if postRequest.isConnectedToNetwork() == false {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            completion(data:  nil)
            return
        }
        if postRequest.isConnectedToNetwork() == true {
           UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            NSURLSessionConfiguration.defaultSessionConfiguration().HTTPMaximumConnectionsPerHost = 6;
            NSURLSessionConfiguration.defaultSessionConfiguration().timeoutIntervalForResource = 60;
            NSURLSessionConfiguration.defaultSessionConfiguration().timeoutIntervalForRequest = 60;
           ImageLoader.sharedLoader.imageForUrl(urL, filename:"\(setingsUrl.FilePath)\(name).png", completionHandler:{
                (image: NSData?, url: NSURL, filename:String) in
                if(image != nil){
                        if(!name.isEmpty)  {
                UIImagePNGRepresentation(UIImage(data: image!)!)?.writeToFile(filename, atomically: true)
                     completion(data: NSData(data: image!))
                    }
                else{
                        completion(data: NSData(data: image!))
                                       }
                }
               else{
                     completion(data:  nil)
                }
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                return
            })
        }
    }
    
   /*
    *
    */

    class func getImageDataFromUrl(urL:NSURL, view:UIView, completion: ((data: NSData?) -> Void)) {
        if postRequest.isConnectedToNetwork() == false {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            completion(data: nil)
            return
        }
    if (postRequest.isConnectedToNetwork() == true ){
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
         dispatch_async(dispatch_get_main_queue(), {
             alerts.shared.showProgress(view)
        })
        NSURLSessionConfiguration.defaultSessionConfiguration().HTTPMaximumConnectionsPerHost = 6;
        NSURLSessionConfiguration.defaultSessionConfiguration().timeoutIntervalForResource = 60;
        NSURLSessionConfiguration.defaultSessionConfiguration().timeoutIntervalForRequest = 60;
        ImageLoader.sharedLoader.imageForUrl(urL, filename:"", completionHandler:{
            (image: NSData?, url: NSURL, filename:String) in
            if(image != nil){
                    completion(data: NSData(data: image!))
                           }
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            return
        })
    }else{
         dispatch_async(dispatch_get_main_queue(), {
           alerts.shared.hideProgressView()
            if(mainVars.ConnectionAlerded == false){
                mainVars.ConnectionAlerded = true
           alerts.shared.ShowAlert(mainVars.connectionErrorMsg[0]!)
        }
            })
          UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        completion(data: nil)
        return
        }
        
    }
    
    

}// end of class




class ImageLoader {
    
    let cache = NSCache()
    class var sharedLoader : ImageLoader {
        struct Static {
            static let instance : ImageLoader = ImageLoader()
        }
        return Static.instance
    }
    
    
    func imageForUrl(urlString: NSURL, filename:String , completionHandler:(image: NSData?, url: NSURL,filename:String) -> ()) {
        
          dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), {()in
            let data: NSData? = self.cache.objectForKey(urlString) as? NSData
            if let goodData = data {
                 dispatch_async(dispatch_get_main_queue(), {() in
                    //let fileManager = NSFileManager.defaultManager()
                    //fileManager.createFileAtPath(filename, contents: data!, attributes: nil)
                    if(self.cache.objectForKey(urlString) != nil){
                    self.cache.removeObjectForKey(urlString)
                    }
                    completionHandler(image: goodData, url: urlString, filename:filename)
                })
                return
            }
            
        let downloadTask: NSURLSessionDataTask = NSURLSession.sharedSession().dataTaskWithURL(urlString
, completionHandler: {
    (data: NSData?, response: NSURLResponse?, error: NSError?) -> Void in
                if (error != nil) {
                    completionHandler(image: nil, url: urlString, filename:filename)
                    return
                }
                if let data = data {
                     self.cache.setObject(data, forKey: urlString)
                    dispatch_async(dispatch_get_main_queue(), {() in
                           completionHandler(image: data, url: urlString, filename:filename)
                    })
                    return
                }
            })
               downloadTask.resume()
                    })
            }
    
    
    func imageForUpload(request:NSURLRequest, completionHandler:(upload:Bool) -> ()){
       dispatch_async(dispatch_get_main_queue(), {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        })
        let urlconfig = NSURLSessionConfiguration.defaultSessionConfiguration()
        urlconfig.timeoutIntervalForRequest = 600
        urlconfig.timeoutIntervalForResource = 600
        urlconfig.HTTPMaximumConnectionsPerHost = 50
        let session = NSURLSession(configuration: urlconfig, delegate: nil, delegateQueue: nil)
        
        var uploadTask: NSURLSessionDataTask = NSURLSessionDataTask()
        uploadTask = session.dataTaskWithRequest(request,completionHandler: {
            (data,response,error) -> Void in
         // handle the errors
            if(error != nil){
    mainVars.uploadError = ((mainVars.connectionErrorMsg[Int(error!.code)] != nil) ? mainVars.connectionErrorMsg[Int(error!.code)] : mainVars.connectionErrorMsg[-1])!
                              if( mainVars.TotalImgForUpload > 0){
                 mainVars.TotalImgForUpload--
                }
            
                    completionHandler(upload: false)
                return
            }
        
             // handle the response
            if let httpResponse = response as? NSHTTPURLResponse {
                   if httpResponse.statusCode == 200 {
                    if( mainVars.TotalImgForUpload > 0){
                        mainVars.TotalImgForUpload--
                    }
                   
                      completionHandler(upload: true)
                    return
                }
                  else{
                         if( mainVars.TotalImgForUpload > 0){
                            mainVars.TotalImgForUpload--
                        }
            let resPdata = NSString(data:data!, encoding:NSUTF8StringEncoding) as String?
             let messageArray = resPdata!.componentsSeparatedByString("id=\"message\">")
                    if(messageArray.count > 1){
            let message = messageArray[1].componentsSeparatedByString("</p>")
                  mainVars.uploadError = "\(message[0])"
                          completionHandler(upload: false)
                            return
                        
                    }
                    else{
                             mainVars.uploadError = "400 Bad Request"
                            completionHandler(upload: false)
                            return
                                             }
                    
                     }
            }
            dispatch_async(dispatch_get_main_queue(), {
             UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            })
           })
        
        uploadTask.resume()
        }
    
}


