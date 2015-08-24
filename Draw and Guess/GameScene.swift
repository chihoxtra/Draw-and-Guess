//
//  GameScene.swift
//  DrawAndGuess//
//  Created by pun samuel on 11/8/15.
//  Copyright (c) 2015 Samuel Pun. All rights reserved.
//

import SpriteKit
import GameKit
import GameController
import GameplayKit

class GameScene: SKScene {
    
    // reference to view controller to access items (like images) there
    weak var viewController: GameViewController!
    
    var gtracer:Int = 0
    
    var gTimer:Int = 0
    
    var firstTimeDraw:Bool = true
    
    var gBrush:brush = brush(c: brushColorOption.black)
    
    var randomizedKeywordsList:[String] = [String] ()
    
    let dataSourceLocation = "http://chihoxtra.ddns.net/games/DrawAndGuess/keywords.txt"
    
    class brush {
        
        var colorOption: brushColorOption
        var color = UIColor()
        var size: Int = 8
        
        init(c: brushColorOption) {
            colorOption = c
            switch colorOption {
            case brushColorOption.black:
                color = UIColor(red: 0.122, green: 0.122, blue: 0.122, alpha: 1.00)
            case brushColorOption.darkBlue:
                color = UIColor(red: 0.125, green: 0.000, blue: 0.502, alpha: 1.00)
            case brushColorOption.blue:
                color = UIColor(red: 0.200, green: 0.000, blue: 0.867, alpha: 1.00)
            case brushColorOption.lightBlue:
                color = UIColor(red: 0.000, green: 0.765, blue: 1.000, alpha: 1.00)
            case brushColorOption.darkGreen:
                color = UIColor(red: 0.000, green: 0.529, blue: 0.255, alpha: 1.00)
            case brushColorOption.green:
                color = UIColor(red: 0.000, green: 0.855, blue: 0.086, alpha: 1.00)
            case brushColorOption.yellow:
                color = UIColor(red: 0.914, green: 0.976, blue: 0.000, alpha: 1.00)
            case brushColorOption.orange:
                color = UIColor(red: 1.000, green: 0.365, blue: 0.000, alpha: 1.00)
            case brushColorOption.red:
                color = UIColor(red: 1.000, green: 0.000, blue: 0.000, alpha: 1.00)
            case brushColorOption.magenta:
                color = UIColor(red: 1.000, green: 0.000, blue: 0.718, alpha: 1.00)
            case brushColorOption.pink:
                color = UIColor(red: 1.000, green: 0.600, blue: 0.678, alpha: 1.00)
            case brushColorOption.burgendy:
                color = UIColor(red: 0.702, green: 0.004, blue: 0.098, alpha: 1.00)
            }
        }

    }

    
    enum brushColorOption: String {
        case black
        case darkBlue
        case blue
        case lightBlue
        case darkGreen
        case green
        case yellow
        case orange
        case red
        case magenta
        case pink
        case burgendy
    }
    
    func changeBrushValueStringtoValue(str: String) {
        /* pass the label of button and change it to enum value */
        gBrush = brush(c: brushColorOption(rawValue: str)!)

    }
    
    func randomizeArray(var arr: [String]){
        
        if (arr.count > 0) {
            let tmp:String  = arr.removeAtIndex(Int(arc4random_uniform(UInt32(arr.count))))
            if tmp != "" {
                randomizedKeywordsList.append(tmp)
                randomizeArray(arr)
            }
            
        }
        
    }
    
    func keywordsPreparation() {
        
        // fetching external data and fill up dataItem Array
        
        /* Updated plist to avoid temporally turn off erro */
        let dataSource = NSURL(string: dataSourceLocation)
        
        let task = NSURLSession.sharedSession().dataTaskWithURL(dataSource!) {(rawdata, response, connectionError) in
            
            if connectionError == nil {
                let dataBuffer = NSString(data: rawdata!, encoding:NSUTF8StringEncoding) as String?
                var dataKeywordsList = dataBuffer!.componentsSeparatedByString("\n")
            
                dataKeywordsList.removeAtIndex(dataKeywordsList.indexOf("")!)
            
                self.randomizeArray(dataKeywordsList)
                var dataLine:[String] = self.randomizedKeywordsList
            
                for i in 0 ... (dataLine.count - 1) {
                    if dataLine[i] != "" {
                        /* handle each line in of text in the file*/
                        print(dataLine[i])
                    
                    }
                }
            }
        }
        task.resume()
    }
    
    
    /* a temp array holding points created */
    var pointArray: [CGPoint] = [CGPoint(x: 0, y: 0)]

    
    func addPointsToArray(point:CGPoint) {
        
        pointArray.append(point)
        
    }
    

    func drawLineWithTwoPoints(fromPoint: CGPoint, toPoint: CGPoint) {
        
        let mainImageView = self.viewController.mainImageView
        
         /* A temporal View to hold the graphics before presentation */
        let tmpImgView: UIImageView = UIImageView()
        tmpImgView.frame.size = mainImageView.frame.size
        
        let viewWidth = mainImageView.frame.size.width
        let viewHeight = mainImageView.frame.size.height
        
        /* Create a bitmap base image to present to Image View*/
        UIGraphicsBeginImageContext((viewController?.mainImageView.frame.size)!)
        let context = UIGraphicsGetCurrentContext()
        

        tmpImgView.image?.drawInRect(CGRect(x: 0, y: 0, width:  viewWidth, height: viewHeight))
        
        /* Creation of the line's two coordinates*/
        
        CGContextMoveToPoint(context, fromPoint.x, fromPoint.y)
        CGContextAddLineToPoint(context, toPoint.x, toPoint.y)
        
        let myCIColor = CIColor(color: gBrush.color)

        CGContextSetLineCap(context, CGLineCap(rawValue: 5)!)
        CGContextSetLineWidth(context, 5)
        CGContextSetRGBStrokeColor(context, myCIColor.red, myCIColor.green, myCIColor.blue, myCIColor.alpha)
        
        
        CGContextSetBlendMode(context, CGBlendMode(rawValue: 1)!)
        
        /* Draw la*/
        CGContextStrokePath(context)
        
        /* Draw on top of what is existing now */
        tmpImgView.image = UIGraphicsGetImageFromCurrentImageContext()
        tmpImgView.alpha = 1.0
        
        UIGraphicsEndImageContext()
        
        
        // Merge tempImageView into mainImageView
        UIGraphicsBeginImageContext((mainImageView?.frame.size)!)
        
        mainImageView!.image?.drawInRect(CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight), blendMode: CGBlendMode(rawValue: 1)!, alpha: 1.0)
        
        tmpImgView.image?.drawInRect(CGRect(x: 0, y: 0, width: viewWidth, height: viewHeight), blendMode: CGBlendMode(rawValue: 1)!, alpha: 1.0)
        
        mainImageView!.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        tmpImgView.image = nil
        
    }
    
    
    override func didMoveToView(view: SKView) {
        /* initilzing basics of apps */
        
//        _ = NSTimer.scheduledTimerWithTimeInterval(1.0, target: self, selector: Selector("updateTimer"), userInfo: nil, repeats: true)
        keywordsPreparation()
    }
    
    
    func updateTimer() {
        self.viewController.timerLabel.text = String(gTimer++)
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
        /* if some residue points from last touch is still here*/

        if pointArray.count > 0 {
            pointArray.removeAll()
        }
        
    }
    
    override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
        
    }
    
    override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
       /* Called when a touch begins */
       
        for touch in touches {

            let touchLocation = (touch as UITouch).locationInView(self.viewController?.mainImageView)

            addPointsToArray(touchLocation)

        }
    }
    
    
    func consumePointsWithTimer() {
        
        while pointArray.count > 1 {
            drawLineWithTwoPoints(pointArray[0], toPoint: pointArray[1])
            pointArray.removeAtIndex(0)
        }
        
    }
   
    override func update(currentTime: CFTimeInterval) {
        /* Called before each frame is rendered */
        
            consumePointsWithTimer()

    }
}
