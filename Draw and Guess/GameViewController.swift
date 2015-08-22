//
//  GameViewController.swift
//  DrawAndGuess
//
//  Created by pun samuel on 11/8/15.
//  Copyright (c) 2015 Samuel Pun. All rights reserved.
//

import UIKit
import SpriteKit
import GameKit


class GameViewController: UIViewController, GKGameCenterControllerDelegate {
    

    var currentScene:GameScene = GameScene()
    var lastButtonClicked:UIButton = UIButton()

    var gGameStarted = false
    
    var gcEnabled:Bool = false
    
    var defaultButtonVerticalPosition:CGFloat = 450.0

    /*Game Center Related Settings*/
    
    var gMultiPlayerMode:Bool = false
    
    let gMatch:GKMatch = GKMatch()
    let gMatchMaker:GKMatchmaker = GKMatchmaker()
    let gInvite:GKInvite = GKInvite()
    
    let gMaxNumberOfPlayer = 6
    
    let gMinNumberOfPlayer = 2 /* for muliplayers */
    


    @IBOutlet weak var timerLabel: UILabel!
    
    @IBOutlet weak var keywordLabel: UILabel!

    
    /*Creating a list of references to the color pencils */

    @IBOutlet var black: UIButton!
    
    @IBAction func black(sender: AnyObject) {
        switchPencilColor(sender as! UIButton)
    }
    
    @IBAction func darkBlue(sender: AnyObject) {
        switchPencilColor(sender as! UIButton)
    }
    
    @IBAction func blue(sender: AnyObject) {
        switchPencilColor(sender as! UIButton)
    }
    
    @IBAction func lightBlue(sender: AnyObject) {
        switchPencilColor(sender as! UIButton)
    }

    @IBAction func darkGreen(sender: AnyObject) {
        switchPencilColor(sender as! UIButton)
    }

    @IBAction func green(sender: AnyObject) {
        switchPencilColor(sender as! UIButton)
    }
    
    @IBAction func yellow(sender: AnyObject) {
        switchPencilColor(sender as! UIButton)
    }
    
    @IBAction func orange(sender: AnyObject) {
        switchPencilColor(sender as! UIButton)
    }
    
    @IBAction func red(sender: AnyObject) {
        switchPencilColor(sender as! UIButton)
    }
    
    @IBAction func magenta(sender: AnyObject) {
        switchPencilColor(sender as! UIButton)
    }
    
    /* This is the main view controller*/
    @IBOutlet weak var mainImageView: UIImageView!
    
    func switchPencilColor(button: UIButton) {
        lastButtonClicked.frame.origin.y = defaultButtonVerticalPosition /* reset pencils to the original positions */
        button.frame.origin.y = button.frame.origin.y - 50
        lastButtonClicked = button
        currentScene.changeBrushValueStringtoValue((button.titleLabel?.text)!)
    }
    
    func dataPreparation() {
        var d:NSData = NSData()
        
        
        
        
    }
    
    func initiateMatch() {
        let gMatchRequest:GKMatchRequest = GKMatchRequest()
        
        gMatchRequest.maxPlayers = gMaxNumberOfPlayer
        gMatchRequest.minPlayers = gMinNumberOfPlayer
        gMatchRequest.inviteMessage = "Let's Play Draw and Guess la 哇卡！"
        
        let gMatchView:GKMatchmakerViewController = GKMatchmakerViewController(matchRequest: gMatchRequest)!
        
        gMatchMaker.findMatchForRequest(gMatchRequest, withCompletionHandler: { (outGoingMatch , findMatchError) -> Void in
            
            if findMatchError != nil {
                // error out
                print("Game Center error: \(findMatchError)")
            }
            
            if outGoingMatch != nil {
                // success
                print("invitation sent!")
                
                gMatch.sendData(<#T##data: NSData##NSData#>, toPlayers: <#T##[GKPlayer]#>, dataMode: <#T##GKMatchSendDataMode#>)
            }
        })


    }
 
    
    func setupMatchHandler() {
        /* This function handles invite as sent by other users */

        
        gMatchMaker.matchForInvite(gInvite , completionHandler: { (incomingMatch , gInviteErr) -> Void in
            
            if gInviteErr != nil {
                // error out
                print("Game Center error: \(gInviteErr)")
            }
            
            if incomingMatch != nil {
                // success
                print("invitation received!")
            }
        })
        
    }
    
    func authenticatePlayer() {
        /* Game initial settings set up as well as ask users to login to Game Center */
        let localPlayer:GKLocalPlayer = GKLocalPlayer()
        
        localPlayer.authenticateHandler = {( gameCenterVC, gameCenterError) -> Void in
            if gameCenterVC != nil {
                //showAuthenticationDialogWhenReasonable: is an example method name. Create your own method that displays an authentication view when appropriate for your app.
                //showAuthenticationDialogWhenReasonable(gameCenterVC!)
                
                self.presentViewController(gameCenterVC!, animated: true, completion: { () -> Void in
                    // no idea
                })
            } else if localPlayer.authenticated == true {
                print("game center ok")
                self.setupMatchHandler()
            } else  {
                print("game center not ok")
            }
            
            if gameCenterError != nil
            { print("Game Center error: \(gameCenterError)")}
        }
    }

    
    override func viewDidLoad() {
        /* viewDidLoad is a good place to create and initialize subviews you wish to add to your main view. It is also a good place to further customize your main view. It's also a good place to initialize data structures because any properties should have been set on the view controller by the time this is called. This typically only needs to be done once. */
        super.viewDidLoad()
        mainImageView.frame.size = self.view.frame.size
        
        if gMultiPlayerMode {
            print("multi")
            authenticatePlayer()
        }

    }
    
    override func viewWillLayoutSubviews() {
        /* viewWillLayoutSubviews is where you position and layout the subviews if needed. This will be called after rotations or other events results in the view controller's view being sized. This can happen many times in the lifetime of the view controller.  */
        if gGameStarted == false {
            gGameStarted = true
            super.viewWillLayoutSubviews()
            
            if let scene = GameScene(fileNamed:"GameScene") {
                // Configure the view.
                let skView = self.view as! SKView
                skView.showsFPS = true
                skView.showsNodeCount = true
                
                /* Sprite Kit applies additional optimizations to improve rendering performance */
                skView.ignoresSiblingOrder = true
                
                /* Set the scale mode to scale to fit the window */
                scene.scaleMode = .AspectFill
                
                skView.presentScene(scene)
                
                /* pass a reference of viewController to the scene */
                scene.viewController = self
                
                /* get a reference to the scene */
                currentScene = scene
                

            }
        }
    
    }

    override func shouldAutorotate() -> Bool {
        return true
    }

    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if UIDevice.currentDevice().userInterfaceIdiom == .Phone {
            return .AllButUpsideDown
        } else {
            return .All
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }

    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismissViewControllerAnimated(true, completion: nil)
    }


    
    
}

