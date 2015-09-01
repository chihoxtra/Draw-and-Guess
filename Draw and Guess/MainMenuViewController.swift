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

/*
Notes:
Do not implement GKInviteEventListener directly, instead use GKLocalPlayerListener. The GKLocalPlayerListener protocol inherits methods from GKInviteEventListener, GKChallengeListener, and GKTurnBasedEventListener in order to handle multiple events.


*/

class MainMenuViewController: UIViewController, GKGameCenterControllerDelegate, GKMatchmakerViewControllerDelegate, GKLocalPlayerListener, GKMatchDelegate  {

    var mainMenuAlreadyLoadedOnce = false

    /*Game Center Related Settings*/
    
    var gMultiPlayerMode:Bool = false
    
    var playerIsAuthenticated = false
    
    var localPlayerInitiateMatch = false
    
    var localPlayerReceiveInvite = false
    
    let gMaxNumberOfPlayer = 4 /* for muliplayers */
    
    let gMinNumberOfPlayer = 2 /* for muliplayers */
    
    let gDefaultNumberOfPlayer = 2 /* for muliplayers */
    
    var gFriendsPlayerList = [GKPlayer]()
    
//    var gGameCenterVC = GKGameCenterViewController()
    
    var gCurrentMatchRequest = GKMatchRequest()
    
    var gMultiplayerStatus = gMultiplayerOption.standardGameCenterInterface
    
    enum gMultiplayerOption {
        case standardGameCenterInterface
        case programmeToCreateMatch
        case programmeInviteSpecificPlayers
        
    }
    @IBAction func buttonForGameCenter(sender: AnyObject) {
        localPlayerInitiateMatch = true
        gMultiplayerStatus = .standardGameCenterInterface
        createAndSendMatchRequest()
    }
    
    @IBAction func buttonForAutoMatch(sender: AnyObject) {
        localPlayerInitiateMatch = true
        gMultiplayerStatus = .programmeToCreateMatch
        createAndSendMatchRequest()
    }
    
    @IBAction func buttonForSpecificPlayers(sender: AnyObject) {
        localPlayerInitiateMatch = true
        gMultiplayerStatus = .programmeInviteSpecificPlayers
        createAndSendMatchRequest()
    }

    @IBAction func greenButton(sender: AnyObject) {
        authenticatePlayer()
    }
    
    @IBOutlet var greenButton: UIButton!
    @IBOutlet var buttonForGameCenter: UIButton!
    @IBOutlet var buttonForAutoMatch: UIButton!
    @IBOutlet var buttonForSpecificPlayers: UIButton!
    @IBOutlet var statusLabel: UILabel!
    @IBOutlet var statusTextView: UITextView!

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
    
    func debug(str: String) {
        print("DEBUG: " + str)
        
        NSRunLoop.mainRunLoop().runUntilDate(NSDate(timeIntervalSinceNow: 1.0))
        
        dispatch_async(dispatch_get_main_queue(), {
            self.statusTextView.text = self.statusTextView.text! + "\n" + str
            self.statusTextView.setNeedsDisplay()
            let btm:NSRange = NSMakeRange(self.statusTextView.text.lengthOfBytesUsingEncoding(NSUTF8StringEncoding) - 1, 1)
            self.statusTextView.scrollRangeToVisible(btm)
        })
    }
    
    /************************** STEP 1: PLAYER AUTHENTICATION ****************************/
                                        /* AND */
    /************************** STEP 3: RETRIEVE  LIST OF FRIENDS ************************/
    
    func authenticatePlayer() {
        /* Game initial settings set up as well as ask users to login to Game Center */
        debug("authenticating player...")
        
        var gGameCenterVC = GKGameCenterViewController()
        
        /*GKLocalPlayer Singleton handler implementation*/
        GKLocalPlayer.localPlayer().authenticateHandler = {( gameCenterVC, gameCenterError) -> Void in
            
            
            if gameCenterVC != nil {
                /* present GameCenterVC and ask users to login */
                
                gGameCenterVC = gameCenterVC as! GKGameCenterViewController
                gGameCenterVC.gameCenterDelegate = self
                
                self.presentViewController(gameCenterVC!, animated: true, completion: { () -> Void in
                    /* present game login screen to users*/
                    self.debug("DEBUG: No login cookie, prompt user to login")
                })
            } else if GKLocalPlayer.localPlayer().authenticated == true && self.playerIsAuthenticated == false {
                
                
                    /* authenticated once and is authenticated and prepare GKLocalPlayer.localPlayer() object*/
                    self.debug("DEBUG: game center authentication ok" + String(GKLocalPlayer.localPlayer().playerID))
                
                    /* attempt to set up event handler*/
                    // self.setUpInviteHandler()
                
                    self.rearrangeDisplayedItems()
                
                    self.playerIsAuthenticated = true
                
                    /* display user login info*/
                    self.statusLabel.text = (String(GKLocalPlayer.localPlayer().playerID) + GKLocalPlayer.localPlayer().displayName!)
                
                    /* register invitation listener*/
                    GKLocalPlayer.localPlayer().unregisterAllListeners()
                    GKLocalPlayer.localPlayer().registerListener(self)
                    /* The GKLocalPlayerListener protocol inherits the methods from GKChallengeListener, GKInviteEventListener, and GKTurnBasedEventListener in order to handle multiple events. */
                
                    /*retrieve friend list if any*/
                    GKLocalPlayer.localPlayer().loadFriendPlayersWithCompletionHandler( {(playerlist, err) -> Void in
                    if playerlist != nil {
                        for player in playerlist! {
                            self.gFriendsPlayerList.append(player)
                            self.debug("DEBUG: player's friend retrieved: " + String(player))
                        }
                    }
                    if err != nil {
                        self.debug("DEBUG: Game Center error: \(err)")
                    }
                })
                
                
            } else  {
                /* cannot authenticate local user*/
                self.playerIsAuthenticated = false
                self.debug("DEBUG: cannot authenticate user 怎麼辦")
            }
            if gameCenterError != nil {
                /*there is an error from game center*/
                self.playerIsAuthenticated = false
                self.debug("DEBUG: Game Center error: \(gameCenterError)")
            }
        }
    }
    
    
    /************************ CREATE and SEND SPECIFIC MATCH REQUEST to PLAYERS *****************/
    
    
    
    func createAndSendMatchRequest() {
        
        if playerIsAuthenticated == true {

            let gMatchRequest:GKMatchRequest = GKMatchRequest()
            
            
            gMatchRequest.maxPlayers = gMaxNumberOfPlayer
            gMatchRequest.minPlayers = gMinNumberOfPlayer
            gMatchRequest.defaultNumberOfPlayers = gDefaultNumberOfPlayer
            gMatchRequest.inviteMessage = "Let's Play Draw and Guess la 哇卡！"
            gMatchRequest.recipients = gFriendsPlayerList
            GKMatchType.PeerToPeer
            gMatchRequest.recipientResponseHandler = { (playerID, response) -> Void in
                if response ==  GKInviteRecipientResponse.InviteeResponseAccepted {
                    self.debug("DEBUG: match sent accepted")
                    /* more work here*/

                }
            }
            
            if gMultiplayerStatus == .standardGameCenterInterface {
                /* OPTION 1 game center standard interface */
                
                /*initializing a Game Center Match Maker View Controller for users to customize*/
                let matchMakerViewController = GKMatchmakerViewController(matchRequest: gMatchRequest)! /* initWithMatchRequest: */
                
                matchMakerViewController.hosted = false
                matchMakerViewController.matchmakerDelegate = self  /*to followup on the response from other players unpon receiving my invitations sent*/
                
                
                self.presentViewController(matchMakerViewController, animated: true, completion: {() -> Void in
                    self.debug("DEBUG: Standard Match Maker VC presented")
                })
            } else if gMultiplayerStatus == .programmeToCreateMatch {
                
                /* OPTION 2 programmatically find peer to peer real time match */
                
                self.debug("DEBUG: attempt to create  match programmatically")
                GKMatchmaker.sharedMatchmaker().findMatchForRequest(gMatchRequest, withCompletionHandler: { (match, error) -> Void in
                    if (error != nil) {
                        self.debug("DEBUG: There is an error" + String(error))
                    } else if match != nil {
                        /* Match created now add more players */

                        self.debug("DEBUG: Match created la!")
                        GKMatchmaker.sharedMatchmaker().addPlayersToMatch(match!, matchRequest: gMatchRequest, completionHandler: {(err) -> Void in
                        })

                    }
                })


            } else if gMultiplayerStatus == .programmeInviteSpecificPlayers {
                /* OPTION 3 invite specific player for  peer to peer real time match*/
                
                gMatchRequest.recipients = gFriendsPlayerList
                
                GKMatchmaker.sharedMatchmaker().findMatchForRequest(gMatchRequest, withCompletionHandler: { (match, error) -> Void in
                    if !(error != nil) {
                        self.debug("DEBUG: There is an error" + String(error))
                    } else if match != nil {
                        
                        self.debug("DEBUG: Match created la!")
                    }
                })
                self.debug("DEBUG: send Invite with specific ID")
                
            }
        }

    }
    
    
    
    /************************ STEP 2: INVITE HANDLER ??? ****************************/

//    func setUpInviteHandler() {
//        
//        GKMatchmaker.sharedMatchmaker().matchForInvite(GKInvite(), completionHandler: { match, error -> Void in
//            self.debug("Invite received")
//        })
//
//    }
    
    /************************ STEP 3: CREATE MATCH REQUEST ****************************/
    
    
    /************************  RANDOM MATCH ****************************/
    
    
    func finishMatchmakingForMatch(match: GKMatch!) {
        /*
        If your game uses programmatic matchmaking, it makes a series of calls to the findMatchForRequest:withCompletionHandler: and addPlayersToMatch:matchRequest:completionHandler: methods to fill a match with players. When the match has the proper number of players, call thefinishMatchmakingForMatch: method before starting the match.
        */
        self.startMatch(match)
    }
    
    /**************************************** STEP 2: INVITE HANDLER ??? ****************************************/
    
    /*************************** NEW VERSION OF INVITE GKLocalPlayerListener PROTOCOL  ****************************/

    
    /*protocol for implementing listener: when user accept invitation from others*/
    func player(player: GKPlayer, didAcceptInvite invite: GKInvite) {
        self.debug("did received and accepted an invite" + String(player.playerID))
        
        let matchMakerViewController = GKMatchmakerViewController(invite: invite)!
        
        matchMakerViewController.hosted = false
        matchMakerViewController.matchmakerDelegate = self  /*to followup on the response from other players unpon receiving my invitations sent*/
        
        
        self.presentViewController(matchMakerViewController, animated: true, completion: {() -> Void in
            self.debug("DEBUG: standard GC UI presented with Invite")
        })
        
//        GKMatchmaker.sharedMatchmaker().matchForInvite(invite, completionHandler: { match, error -> Void in
//            self.debug("Invite received")
//
//            let alert = UIAlertController(title: "Game Invitation", message: "Message", preferredStyle: UIAlertControllerStyle.Alert)
//            let alertAction1 = UIAlertAction(title: "Accept", style: UIAlertActionStyle.Default) { (UIAlertAction) -> Void in
//                self.startMatch(match!)
//            
//            }
//            let alertAction2 = UIAlertAction(title: "No la", style: UIAlertActionStyle.Default) { (UIAlertAction) -> Void in }
//            alert.addAction(alertAction1)
//            alert.addAction(alertAction2)
//            self.presentViewController(alert, animated: true) { () -> Void in }
//            
//            
//            
//        })
        

    }
    
    
    func player(player: GKPlayer, didRequestMatchWithRecipients recipientPlayers: [GKPlayer]) {
        print("player function called")
    
    }
    
    func player(player: GKPlayer, didReceiveChallenge challenge: GKChallenge) {
        
    }
    
    func player(player: GKPlayer, wantsToPlayChallenge challenge: GKChallenge) {
        
    }
    
    /********************* For MatchmakerController Delegate ***************************/
    
    func matchmakerViewController(viewController: GKMatchmakerViewController, didFindMatch match: GKMatch) {
            debug("did find match")
    }
    
    
    func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismissViewControllerAnimated(true, completion: nil)
        self.debug("DEBUG: game center interaction is done")
        self.rearrangeDisplayedItems()
    }
    /* * */
    
    func matchmakerViewController(viewController: GKMatchmakerViewController,
        didFailWithError error: NSError) {
            self.debug("MatchView Controller error: " +  String(error))
    }
    
//    func matchmakerViewController(_ viewController: GKMatchmakerViewController!,
//        didFindPlayers playerIDs: [AnyObject]!) {
//    }
    
    func matchmakerViewControllerWasCancelled(viewController: GKMatchmakerViewController) {
        viewController.dismissViewControllerAnimated(true, completion: {() -> Void in
            self.debug("matchmakerViewController closed as user cancelled it")
            self.rearrangeDisplayedItems()
        })
    }
    
    /********************************** For GKMatchDelegate *********************************/
    
    func match(match: GKMatch, didReceiveData data: NSData, fromRemotePlayer player: GKPlayer) {
        print("receiving data from another player")
    }
    
    func match(match: GKMatch, shouldReinviteDisconnectedPlayer player: GKPlayer) -> Bool {
        return true
    }
    
    func match(match: GKMatch, player: GKPlayer, didChangeConnectionState state: GKPlayerConnectionState) {
        print("player state changed")
    }
    
    /************************************* The Match Logic ******************************/

    func randomizePlayerArray(var arr: [GKPlayer]) -> [GKPlayer] {
        
        var randomizedPlayerResultArray = [GKPlayer]()
        
        if (arr.count > 0) {
            let tmp:GKPlayer  = arr.removeAtIndex(Int(arc4random_uniform(UInt32(arr.count))))
            randomizedPlayerResultArray.append(tmp)
            randomizePlayerArray(arr)
        }
        return randomizedPlayerResultArray
        
    }
    
    func startMatch(match: GKMatch) {
        /*preparation*/
        var allPlayersArray = [GKPlayer]()
        allPlayersArray = match.players
        let data = NSData(base64EncodedString: "hello", options: NSDataBase64DecodingOptions.IgnoreUnknownCharacters)
        
        do {
            try match.sendData(data!, toPlayers: allPlayersArray, dataMode: GKMatchSendDataMode.Reliable)
        } catch {
            debug("cannot send data")
        }
        
        /* randomize players*/
        allPlayersArray = randomizePlayerArray(allPlayersArray)
        
        

            
        /* explain how to play and start? */
        /* Go to the randomize role view */
        /* randomize question and display to both drawer and guesser */
    }
    

    
    /********************************** CORE *********************************/
    
    func rearrangeDisplayedItems() {
        /* Make sure layout of buttons are ok before loading the view */
        statusLabel.frame.origin.x = self.view.frame.size.width/2 - statusLabel.frame.width/2
        buttonForAutoMatch.frame.origin.x = self.view.frame.size.width/2 - buttonForAutoMatch.frame.width/2
        buttonForGameCenter.frame.origin.x = self.view.frame.size.width/2 - buttonForGameCenter.frame.width/2
        buttonForSpecificPlayers.frame.origin.x = self.view.frame.size.width/2 - buttonForSpecificPlayers.frame.width/2
        greenButton.frame.origin.x = self.view.frame.size.width/2 - greenButton.frame.width/2
        print("DEBUG: viewDidAppear - readjust position of buttons")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        debug("viewDidLoad")
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        debug("ViewDidAppear")

        rearrangeDisplayedItems()
        
        authenticatePlayer()
    }
    
    override func viewWillLayoutSubviews() {
        /* viewWillLayoutSubviews is where you position and layout the subviews if needed. This will be called after rotations or other events results in the view controller's view being sized. This can happen many times in the lifetime of the view controller.  */
        
        // debug("viewWillLayoutSubviews")
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
    
   

}
