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
import GameController
import GameplayKit


class GameViewController: UIViewController, GKGameCenterControllerDelegate, GKMatchmakerViewControllerDelegate, GKLocalPlayerListener, GKInviteEventListener {

    var currentScene:GameScene = GameScene()
    var lastButtonClicked:UIButton = UIButton()

    var gGameStarted = false
    
    var gcEnabled:Bool = false
    
    var defaultButtonVerticalPosition:CGFloat = 450.0

    /*Game Center Related Settings*/
    
    var gMultiPlayerMode:Bool = false
    
    var playerIsAuthenticated = false
    
    let gMaxNumberOfPlayer = 6
    
    let gMinNumberOfPlayer = 2 /* for muliplayers */
    
    let gInvite = GKInvite()

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
//        let gMatchMaker = GKMatchmaker()
        
//        var d:NSData = NSData()
 
    }
    
    
    func createANewMatch() {
        /* user take the initiation to invite other players to play*/
        
        let gMatchRequest:GKMatchRequest = GKMatchRequest()
        
        gMatchRequest.maxPlayers = gMaxNumberOfPlayer
        gMatchRequest.minPlayers = gMinNumberOfPlayer
        gMatchRequest.inviteMessage = String(GKLocalPlayer.localPlayer().playerID) + "Let's Play Draw and Guess la 哇卡！"
        gMatchRequest.recipientResponseHandler = {(playerID, response) -> Void in
            if response == GKInviteeResponse.InviteeResponseAccepted {
                print(String(playerID) + "aaccepted my request sent")
            }

        }
        
        let matchMakerViewController = GKMatchmakerViewController(matchRequest: gMatchRequest)
        matchMakerViewController!.matchmakerDelegate = self
        
        matchMakerViewController?.hosted = false
        
        self.presentViewController(matchMakerViewController!, animated: true, completion: {() -> Void in
            print("done in presenting view controller")
            })
        
    }
    
    


    func matchForInvite(receivedInvite: GKInvite!,  completionHandler: ((GKMatch!, NSError!) -> Void)!) {
        print("received and invite")
        if receivedInvite != nil {
            
            
            
        }
    }
    
    func player(player: GKPlayer, didRequestMatchWithPlayers playerIDsToInvite: [String]) {
        print("Did request matchmaking")
    }
    
    
    /*protocol for implementing listener: when user accept invitation from others*/
    func player(player: GKPlayer, didAcceptInvite invite: GKInvite) {
        
        print("did received and accepted an invite")
        GKMatchmaker.sharedMatchmaker().matchForInvite (invite, completionHandler: {(InvitedMatch, error) in
            
            if InvitedMatch != nil {
                
                
                
            }
        })
    }
    
    
    func authenticatePlayer() {
        /* Game initial settings set up as well as ask users to login to Game Center */
        
        /*GKLocalPlayer Singleton handler implementation*/
        GKLocalPlayer.localPlayer().authenticateHandler = {( gameCenterVC, gameCenterError) -> Void in
            
            if gameCenterVC != nil {
                //showAuthenticationDialogWhenReasonable: is an example method name. Create your own method that displays an authentication view when appropriate for your app.
                //showAuthenticationDialogWhenReasonable(gameCenterVC!)
                
                self.presentViewController(gameCenterVC!, animated: true, completion: { () -> Void in
                    /* present game login screen to users*/
                })
            } else if GKLocalPlayer.localPlayer().authenticated == true && self.playerIsAuthenticated == false {
                print("game center authentication ok")
                
                self.playerIsAuthenticated = true
                
                /* register invitation listener*/
                GKLocalPlayer.localPlayer().unregisterAllListeners()
                GKLocalPlayer.localPlayer().registerListener(self)
                
                /* take action to creat a new match for user */
                self.createANewMatch()
                // self.player(GKLocalPlayer.localPlayer(), didRequestMatchWithPlayers: ["G:17880138"])
                print("Current ID is " + String(GKLocalPlayer.localPlayer().playerID))
            } else  {
                self.playerIsAuthenticated = false
                print("cannot authenticate user 怎麼辦")
            }
            if gameCenterError != nil {
                /*there is an error from game center*/
                print("Game Center error: \(gameCenterError)")
            }
        }
    }

    
    override func viewDidLoad() {
        /* viewDidLoad is a good place to create and initialize subviews you wish to add to your main view. It is also a good place to further customize your main view. It's also a good place to initialize data structures because any properties should have been set on the view controller by the time this is called. This typically only needs to be done once. */
        super.viewDidLoad()
        
        mainImageView.frame.size = self.view.frame.size

    }
    
    override func viewWillLayoutSubviews() {
        /* viewWillLayoutSubviews is where you position and layout the subviews if needed. This will be called after rotations or other events results in the view controller's view being sized. This can happen many times in the lifetime of the view controller.  */
        if gGameStarted == false {
            gGameStarted = true
            super.viewWillLayoutSubviews()
            
            if gMultiPlayerMode {
                print("mutiplayer mode on")
                authenticatePlayer()
            }
            
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
    
//    func matchmakerViewController(viewController: GKMatchmakerViewController!,
//        didFindHostedPlayers players: [AnyObject]!) {
//            
//    }
    
    func player(player: GKPlayer, didReceiveChallenge challenge: GKChallenge) {
        
    }
    
    func player(player: GKPlayer, wantsToPlayChallenge challenge: GKChallenge) {
        
    }
    
    func player(player: GKPlayer, didRequestMatchWithRecipients recipientPlayers: [GKPlayer]) {
        print("request sent")
    }
    
    
    
    func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func matchmakerViewController(viewController: GKMatchmakerViewController,
        didFailWithError error: NSError) {
    }
    
    func matchmakerViewControllerWasCancelled(viewController: GKMatchmakerViewController) {
    }
    
    func matchmakerViewController(viewController: GKMatchmakerViewController,
        hostedPlayerDidAccept player: GKPlayer) {
    }
    
    
//    func matchmakerViewController(viewController: GKMatchmakerViewController!, didFindMatch match: GKMatch!) {
//        
//        print("match found")
//        
//        var goToMatch = GamePlay(size: self.size)
//        var transitionToMatch = SKTransition.fadeWithDuration(1.0)
//        goToMatch.scaleMode = SKSceneScaleMode.AspectFill
//        self.scene!.view?.presentScene(goToMatch, transition: transitionToMatch)
//        
//        presentingViewController = viewController
//        self.presentingViewController.dismissViewControllerAnimated(true, completion: nil)
//        
//        self.match = match
//        self.match.delegate = self
//        
//        self.lookupPlayers()
//    }
//    
//    
//    func matchmakerViewController(viewController: GKMatchmakerViewController!, didReceiveAcceptFromHostedPlayer playerID: String!) {
//        
//    }
//    
//    
//    func matchmakerViewController(viewController: GKMatchmakerViewController!, didFindPlayers playerIDs: [AnyObject]!) {
//        
//    }
//    
//    
//    func matchmakerViewController(viewController: GKMatchmakerViewController!, didFailWithError error: NSError!) {
//        
//        presentingViewController = viewController
//        self.presentingViewController.dismissViewControllerAnimated(true, completion: nil);
//        println("Error finding match: \(error.localizedDescription)");
//        
//    }
//    
//    
//    func matchmakerViewController(viewController: GKMatchmakerViewController!, didFindHostedPlayers players: [AnyObject]!) {
//        
//    }
//    
//    
//    
//    func matchmakerViewControllerWasCancelled(viewController: GKMatchmakerViewController!) {
//        
//        println("go back to main menu")
//        
//        presentingViewController = viewController
//        self.presentingViewController.dismissViewControllerAnimated(true, completion: nil)
//        
//        
//        
//    }
    
    
}

