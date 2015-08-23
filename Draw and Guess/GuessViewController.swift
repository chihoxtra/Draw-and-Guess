//
//  GuessViewController.swift
//  DrawAndGuess
//
//  Created by pun samuel on 22/8/15.
//  Copyright © 2015 Samuel Pun. All rights reserved.
//

import UIKit

class GuessViewController: UIViewController {
    
    var gCurrentCorrectAns = ""

    @IBOutlet var myGuess: UITextField!
    
    @IBAction func sumitButton(sender: AnyObject) {
        submitNewGuess(myGuess.text!)
    }
    @IBOutlet var guessList: UITextView!
    
    @IBOutlet var broadcastedImageView: UIImageView!
    
    func getCurrentTimeStamp() -> String {
        let date = NSDate()
        let calendar = NSCalendar.currentCalendar()
        let components = calendar.componentsInTimeZone(NSTimeZone.localTimeZone(), fromDate: date)
        return (String(Int(components.hour)%12) + ":" + String(components.minute) + ":" + String(components.second))
    }
    
    func submitNewGuess(ans: String) {
        if ans != "" {
            
            guessList.text = guessList.text + "\n" + getCurrentTimeStamp() + ":" + ans
            
            let range:NSRange = NSMakeRange(guessList.text.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) - 1, 1)
            guessList.scrollRangeToVisible(range)
            print(range)
            
            myGuess.text = ""

        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
