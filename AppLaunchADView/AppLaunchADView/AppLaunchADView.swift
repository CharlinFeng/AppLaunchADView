//
//  AppLaunchADView.swift
//  AppLaunchADView
//
//  Created by 冯成林 on 16/1/27.
//  Copyright © 2016年 冯成林. All rights reserved.
//

import UIKit

let AppLaunchADViewKey = "AppLaunchADViewKey"

class AppLaunchADView: UIView {
    
    var delay: Int!
    
    @IBOutlet weak var skipBtn: UIButton!
    @IBOutlet weak var imageV: UIImageView!
    
    
    lazy var str: String = "跳过 "
    
    lazy var timer: NSTimer!  = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "run", userInfo: nil, repeats: true)
    
}

extension AppLaunchADView{
    
    class func show(window: UIWindow!, delay: Int){
        
        let data = NSKeyedUnarchiver.unarchiveObjectWithFile(arcPath) as? NSData
        
        if data == nil {return}
        
        let img = UIImage(data: data!)
        
        let adView = NSBundle.mainBundle().loadNibNamed("AppLaunchADView", owner: nil, options: nil).first as! AppLaunchADView
        
        adView.imageV.image = img
        
        adView.delay = delay
        
        adView.frame = UIScreen.mainScreen().bounds
        
        window.rootViewController?.view.addSubview(adView)
        
        adView.timer.fire()
    }
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        skipBtn.layer.cornerRadius = 4
    }
    
    
    func run(){
        
        skipBtn.setTitle(str + "\(delay)s", forState: UIControlState.Normal)
        delay = delay - 1
        if delay < 0 {skipAction(false)}
    }
    
    
    
    @IBAction func skipAction(sender: AnyObject!) {
        
        UIView.animateWithDuration(1, animations: { () -> Void in
            
            self.alpha = 0
            
            }) { (c) -> Void in
                
                self.delay = 0
                self.timer.invalidate()
                self.timer = nil
                self.removeFromSuperview()
        }
    }
    
    private static var arcPath: String! {
        
        let cachePath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true).first!
        let path = cachePath + "/AppLaunchADView.arc"
        
        return path
    }
    
    private class func saveADData(data: NSData,url: String!) {
        
        let res = NSKeyedArchiver.archiveRootObject(data, toFile: arcPath)
        
        if res {
            NSUserDefaults.standardUserDefaults().setObject(url, forKey: AppLaunchADViewKey)
            print("广告数据保存成功")
        }else {
            
            print("广告数据保存失败")
        }
    }
    
    class func saveADWithUrlString(url url: String!){
        
        let url_cache = NSUserDefaults.standardUserDefaults().objectForKey(AppLaunchADViewKey) as? String
        
        if url_cache != nil && url_cache! == url {
            
            print("广告数据与上一次是一样的，跳过保存！")
            return
        }
        
        let u = NSURL(string: url)
        
        let request = NSURLRequest(URL: u!)
        
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue()) { (r, d, e) -> Void in
            
            if e == nil && (d?.length ?? 0) > 0{
                
                saveADData(d!,url: url)
                
            }else{
                print("广告数据下载失败")
            }
        }
    }
}


