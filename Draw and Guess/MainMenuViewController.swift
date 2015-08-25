//
//  MainMenuViewController.swift
//  DrawAndGuess
//
//  Created by pun samuel on 22/8/15.
//  Copyright © 2015 Samuel Pun. All rights reserved.
//

import SpriteKit
import GameKit
import GameController
import GameplayKit

class MainMenuViewController: UIViewController, GKGameCenterControllerDelegate, GKMatchmakerViewControllerDelegate, GKLocalPlayerListener, GKMatchDelegate,GKInviteEventListener  {
    
    var mainMenuAlreadyLoadedOnce = false

    /*Game Center Related Settings*/
    
    var gMultiPlayerMode:Bool = false
    
    var playerIsAuthenticated = false
    
    var localPlayerInitiateMatch = false
    
    var localPlayerReceiveInvite = false
    
    let gMaxNumberOfPlayer = 4 /* for muliplayers */
    
    let gMinNumberOfPlayer = 2 /* for muliplayers */
    
    let gDefaultNumberOfPlayer = 2 /* for muliplayers */
    
    var gGameCenterVC = GKGameCenterViewController()
    
    @IBAction func redButton(sender: AnyObject) {
        localPlayerInitiateMatch = true
        createANewMatch()
    }
    
    @IBAction func greenButton(sender: AnyObject) {
        authenticatePlayer()
    }
    @IBOutlet var redButton: UIButton!
    
    @IBOutlet var greenButton: UIButton!
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {

        if (segue.identifier == "showDrawControllerMultiPlayer") {
            
            //Checking identifier is crucial as there might be multiple
            // segues attached to same view
            
            let finalViewController = segue.destinationViewController as! GameViewController;
            finalViewController.gMultiPlayerMode = true
        } else if (segue.identifier == "showGuessControllerMultiPlayer") {
            _ = segue.destinationViewController as! GuessViewController;
        }
    }
    
    /**************************** PLAYER AUTHENTICATION ****************************/
    
    
    func authenticatePlayer() {
        /* Game initial settings set up as well as ask users to login to Game Center */
        
        /*GKLocalPlayer Singleton handler implementation*/
        GKLocalPlayer.localPlayer().authenticateHandler = {( gameCenterVC, gameCenterError) -> Void in
            
            
            if gameCenterVC != nil {
                //showAuthenticationDialogWhenReasonable: is an example method name. Create your own method that displays an authentication view when appropriate for your app.
                //showAuthenticationDialogWhenReasonable(gameCenterVC!)
                
                //self.gGameCenterVC = gameCenterVC as! GKGameCenterViewController
                self.gGameCenterVC.gameCenterDelegate = self
                
                self.presentViewController(gameCenterVC!, animated: true, completion: { () -> Void in
                    /* present game login screen to users*/
                })
            } else if GKLocalPlayer.localPlayer().authenticated == true && self.playerIsAuthenticated == false {

                    /* cookied Login */
                    print("game center authentication ok")
                
                    self.playerIsAuthenticated = true
                    print("Current ID is " + String(GKLocalPlayer.localPlayer().playerID))
                
                    /* register invitation listener*/
                    print(GKLocalPlayer.localPlayer().displayName)
                    GKLocalPlayer.localPlayer().unregisterAllListeners()
                    GKLocalPlayer.localPlayer().registerListener(self)
                
                    /* take action to creat a new match for user */
                
                    // self.player(GKLocalPlayer.localPlayer(), didRequestMatchWithPlayers: ["G:17880138"])
                
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
    
    
    
    func createANewMatch() {
        print("create match")
        
        
        let gMatchRequest:GKMatchRequest = GKMatchRequest()
        
        gMatchRequest.maxPlayers = gMaxNumberOfPlayer
        gMatchRequest.minPlayers = gMinNumberOfPlayer
        gMatchRequest.defaultNumberOfPlayers = gDefaultNumberOfPlayer
        gMatchRequest.playerAttributes = 0 ; // NO SPECIAL ATTRIBS
        gMatchRequest.playerGroup = 0
        gMatchRequest.inviteMessage = "Let's Play Draw and Guess la 哇卡！"
        
        /*initializing a Game Center Match Maker View Controller for users to customize*/
        let matchMakerViewController = GKMatchmakerViewController(matchRequest: gMatchRequest)!
        
        matchMakerViewController.hosted = false
        matchMakerViewController.matchmakerDelegate = self  /*to followup on the response from other players unpon resceiving my invitations sent*/
        
        self.presentViewController(matchMakerViewController, animated: true, completion: {() -> Void in
            print("Match Maker VC presented")
        })
    }
    
    
    
    
    func matchForInvite(receivedInvite: GKInvite!,  completionHandler: ((GKMatch!, NSError!) -> Void)!) {
        print("received and invite")
        if receivedInvite != nil {
            
        }
    }
    
    
    /*protocol for implementing listener: when user accept invitation from others*/
    func player(player: GKPlayer, didAcceptInvite invite: GKInvite) {
        print("did received and accepted an invite")
        
        /*If user is receving invite*/
        let matchMakerViewController = GKMatchmakerViewController(invite: invite)!
        
        matchMakerViewController.hosted = false
        matchMakerViewController.matchmakerDelegate = self  /*to followup on the response from other players unpon resceiving my invitations sent*/
        
        self.presentViewController(matchMakerViewController, animated: true, completion: {() -> Void in
            print("Match Maker VC presented")
        })
    }
    
    
    
    func player(player: GKPlayer, didRequestMatchWithRecipients recipientPlayers: [GKPlayer]) {
        print("did send an invite")
        
        let gMatchRequest:GKMatchRequest = GKMatchRequest()
        
        gMatchRequest.maxPlayers = gMaxNumberOfPlayer
        gMatchRequest.minPlayers = gMinNumberOfPlayer
        gMatchRequest.defaultNumberOfPlayers = gDefaultNumberOfPlayer
        gMatchRequest.playerAttributes = 0 ; // NO SPECIAL ATTRIBS
        gMatchRequest.playerGroup = 0
        gMatchRequest.inviteMessage = "Let's Play Draw and Guess la 哇卡！"
        
        
        
        /*initializing a Game Center Match Maker View Controller for users to customize*/
        let matchMakerViewController = GKMatchmakerViewController(matchRequest: gMatchRequest)!
        
        matchMakerViewController.hosted = false
        matchMakerViewController.matchmakerDelegate = self  /*to followup on the response from other players unpon resceiving my invitations sent*/
        
        self.presentViewController(matchMakerViewController, animated: true, completion: {() -> Void in
            print("Match Maker VC presented")
        })
    }
    
    
    
    
    
    
    /**************************** Core Functions of the APP ****************************/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        /* Make sure layout of buttons are ok before loading the view */
        redButton.frame.origin.x = self.view.frame.size.width/2 - redButton.frame.width/2
        greenButton.frame.origin.x = self.view.frame.size.width/2 - greenButton.frame.width/2
        
        print("View did appear done - readjust position of buttons")
    }
    
    override func viewWillLayoutSubviews() {
        /* viewWillLayoutSubviews is where you position and layout the subviews if needed. This will be called after rotations or other events results in the view controller's view being sized. This can happen many times in the lifetime of the view controller.  */
        if !mainMenuAlreadyLoadedOnce {
            super.viewWillLayoutSubviews()
            mainMenuAlreadyLoadedOnce = true
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("Did receive memory warning")
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
    
    //    func matchmakerViewController(viewController: GKMatchmakerViewController!,
    //        didFindHostedPlayers players: [AnyObject]!) {
    //
    //    }
    
    func match(match: GKMatch, didReceiveData data: NSData, fromRemotePlayer player: GKPlayer) {
        print("receiving data from another player")
    }
    
    func match(match: GKMatch, player: GKPlayer, didChangeConnectionState state: GKPlayerConnectionState) {
        print("player state changed")
    }
    
    
    func player(player: GKPlayer, didReceiveChallenge challenge: GKChallenge) {
        
    }
    
    func player(player: GKPlayer, wantsToPlayChallenge challenge: GKChallenge) {
        
    }

    
    
    
    func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismissViewControllerAnimated(true, completion: nil)
    }
    
    func matchmakerViewController(viewController: GKMatchmakerViewController,
        didFailWithError error: NSError) {
            print("matchmakerViewController")
    }
    
    func matchmakerViewControllerWasCancelled(viewController: GKMatchmakerViewController) {
        viewController.dismissViewControllerAnimated(true, completion: {() -> Void in
            print("matchmakerViewController closed as user cancelled it")
        })
    }
    
    func matchmakerViewController(viewController: GKMatchmakerViewController,
        hostedPlayerDidAccept player: GKPlayer) {
    }
    
    
    func matchmakerViewController(viewController: GKMatchmakerViewController, didFindMatch theMatch: GKMatch) {
        print("match found")
        
        theMatch.delegate = self

    }
    

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
