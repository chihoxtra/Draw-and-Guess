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

class CurrentGameProfile: NSObject {

    var playerObjRef:GKPlayer
    var myRole:gRoleOfPlayerOption
    var myScore:Int = 0
    var playerGuessAnsToQuestion: answerToQuestion = answerToQuestion.correct
    var correctAns:Int = 0
    var wrongAns:Int = 0
    var pictureDrawn = 0
    var isConnnected:Bool
    
    enum gRoleOfPlayerOption {
        case roleDrawer
        case roleGuesser
    }
    
    enum answerToQuestion {
        case correct
        case inCorrect
    }
    
    init(player: GKPlayer, role: gRoleOfPlayerOption, connectionStatus: Bool) {
        playerObjRef = player
        myRole = role
        isConnnected = connectionStatus
        
    }
    
    func aQuestionIsDone(ansStatus: answerToQuestion) {
        if myRole == gRoleOfPlayerOption.roleGuesser {
            if ansStatus == answerToQuestion.correct {
                correctAns += 1
            } else {
                wrongAns += 1
            }
        } else if myRole == gRoleOfPlayerOption.roleDrawer {
            
        }
    }

}

class MainMenuViewController: UIViewController, GKGameCenterControllerDelegate, GKMatchmakerViewControllerDelegate, GKLocalPlayerListener, GKMatchDelegate  {

    var mainMenuAlreadyLoadedOnce = false

    /*Game Center Related Settings*/
    
    var gMultiPlayerMode:Bool = false
    
    var playerIsAuthenticated:Bool = false
    
    var localPlayerInitiateMatch:Bool = false
    
    var localPlayerReceiveInvite:Bool = false
    
    let gMaxNumberOfPlayer = 4 /* for muliplayers */
    
    let gMinNumberOfPlayer = 2 /* for muliplayers */
    
    let gDefaultNumberOfPlayer = 2 /* for muliplayers */
    
    let gTotalNumberOfPicToBeDrawnPerRound = 5 /* number of pictures each player need to draw per round */
    
    var gMyFriendsPlayerList = [GKPlayer]()
    
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
        
        let gGameCenterVC = GKGameCenterViewController()
        
        /*GKLocalPlayer Singleton handler implementation*/
        GKLocalPlayer.localPlayer().authenticateHandler = {( gameCenterVC, gameCenterError) -> Void in
            
            
            if gameCenterVC != nil {
                /* present GameCenterVC and ask users to login */
                
                // gGameCenterVC = gameCenterVC as! GKGameCenterViewController
                gGameCenterVC.gameCenterDelegate = self
                
                self.presentViewController(gameCenterVC!, animated: true, completion: { () -> Void in
                    /* present game login screen to users*/
                    self.debug("No login cookie, prompt user to login")
                })
            } else if GKLocalPlayer.localPlayer().authenticated == true && self.playerIsAuthenticated == false {
                
                
                    /* authenticated once and is authenticated and prepare GKLocalPlayer.localPlayer() object*/
                    self.debug("game center authentication ok" + String(GKLocalPlayer.localPlayer().playerID))
                
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
                            self.gMyFriendsPlayerList.append(player)
                            self.debug("player's friend retrieved: " + String(player))
                        }
                    }
                    if err != nil {
                        self.debug("Game Center error: \(err)")
                    }
                })
                
                
            } else  {
                /* cannot authenticate local user*/
                self.playerIsAuthenticated = false
                self.debug("cannot authenticate user 怎麼辦")
            }
            if gameCenterError != nil {
                /*there is an error from game center*/
                self.playerIsAuthenticated = false
                self.debug("Game Center error: \(gameCenterError)")
            }
        }
    }
    
    
    /************************ CREATE and SEND SPECIFIC MATCH REQUEST to PLAYERS *****************/
    
    /************************** STEP 4: CREATE MATCH REQUEST ************************/
                                /* AND */
    /************************** STEP 5: FIND MATCH REQUEST ************************/
                                /* AND */
    /************************** STEP 6: SEND REQUEST TO PLAYERS ************************/
                                /* AND */
    /************************** STEP 8: INVITE RESPONSE HANDLER ************************/
    
    func createAndSendMatchRequest() {
        
        if playerIsAuthenticated == true {

            let gMatchRequest:GKMatchRequest = GKMatchRequest()
            
            
            gMatchRequest.maxPlayers = gMaxNumberOfPlayer
            gMatchRequest.minPlayers = gMinNumberOfPlayer
            gMatchRequest.defaultNumberOfPlayers = gDefaultNumberOfPlayer
            gMatchRequest.inviteMessage = "Let's Play Draw and Guess la 哇卡！"
            gMatchRequest.recipientResponseHandler = { (playerID, response) -> Void in
                if response ==  GKInviteRecipientResponse.InviteeResponseAccepted {
                    self.debug(String(playerID) +  "DEBUG: match sent accepted")
                    /* more work here*/
                }
            }
            
            if gMultiplayerStatus == .standardGameCenterInterface {
                /* OPTION 1 game center standard interface */
                
                gMatchRequest.recipients = gMyFriendsPlayerList

                
                /*initializing a Game Center Match Maker View Controller for users to customize*/
                let matchMakerViewController = GKMatchmakerViewController(matchRequest: gMatchRequest)! /* initWithMatchRequest: */
                
                matchMakerViewController.hosted = false
                matchMakerViewController.matchmakerDelegate = self  /*to followup on the response from other players unpon receiving my invitations sent*/
                
                
                self.presentViewController(matchMakerViewController, animated: true, completion: {() -> Void in
                    if matchMakerViewController.isBeingPresented() {
                        self.debug("starndard Match Maker VC presented")
                    }
                })
            } else if gMultiplayerStatus == .programmeToCreateMatch {
                
                /* OPTION 2 programmatically find peer to peer real time match */
                gMatchRequest.recipientResponseHandler = { (playerID, response) -> Void in
                    if response ==  GKInviteRecipientResponse.InviteeResponseAccepted {
                        self.debug(String(playerID) +  "DEBUG: match sent accepted")
                        /* more work here*/
                    }
                }
                
                self.debug("attempt to create  match programmatically")
                GKMatchmaker.sharedMatchmaker().findMatchForRequest(gMatchRequest, withCompletionHandler: { (match, error) -> Void in
                    if (error != nil) {
                        self.debug("There is an error" + String(error))
                    } else if match != nil {
                        /* Match created now add more players */

                        self.debug("Match created la!")
                        GKMatchmaker.sharedMatchmaker().addPlayersToMatch(match!, matchRequest: gMatchRequest, completionHandler: {(err) -> Void in
                        })

                    }
                })


            } else if gMultiplayerStatus == .programmeInviteSpecificPlayers {
                /* OPTION 3 invite specific player for  peer to peer real time match*/
                
                gMatchRequest.recipients = gMyFriendsPlayerList
                gMatchRequest.recipientResponseHandler = { (playerID, response) -> Void in
                    if response ==  GKInviteRecipientResponse.InviteeResponseAccepted {
                        self.debug(String(playerID) +  "DEBUG: match sent accepted")
                        /* more work here*/
                    }
                }
                
                GKMatchmaker.sharedMatchmaker().findMatchForRequest(gMatchRequest, withCompletionHandler: { (match, error) -> Void in
                    if !(error != nil) {
                        self.debug("There is an error" + String(error))
                    } else if match != nil {
                        
                        self.debug("Match created la!")
                    }
                })
                self.debug("send Invite with specific ID")
                
            }
        }

    }
    
    
    /************************  RANDOM MATCH ****************************/
    
    
    func finishMatchmakingForMatch(match: GKMatch!) {
        /*
        If your game uses programmatic matchmaking, it makes a series of calls to the findMatchForRequest:withCompletionHandler: and addPlayersToMatch:matchRequest:completionHandler: methods to fill a match with players. When the match has the proper number of players, call thefinishMatchmakingForMatch: method before starting the match.
        */
        self.startMatch(match)
    }
    
    /**************************************** STEP 2: INVITE HANDLER ??? ****************************************/
    
    /*************************** NEW VERSION OF INVITE GKLocalPlayerListener PROTOCOL  ****************************/
    
    /************************************ STEP 7: INVITE HANDLER to HANDLE INVITE ********************************/

    
    /*protocol for implementing listener: when user accept invitation from others*/
    
    func player(player: GKPlayer, didAcceptInvite invite: GKInvite) {
        self.debug("did received and accepted an invite" + String(player.playerID))
        
        let matchMakerViewController = GKMatchmakerViewController(invite: invite)!
        
        matchMakerViewController.hosted = false
        matchMakerViewController.matchmakerDelegate = self  /*to followup on the response from other players unpon receiving my invitations sent*/
        
        
        self.presentViewController(matchMakerViewController, animated: true, completion: {() -> Void in
            self.debug("DEBUG: standard GC UI presented with Invite")
        })
        
        GKMatchmaker.sharedMatchmaker().matchForInvite(invite, completionHandler: { match, error -> Void in
            self.debug("Invite received")

            let alert = UIAlertController(title: "Game Invitation", message: "Message", preferredStyle: UIAlertControllerStyle.Alert)
            let alertAction1 = UIAlertAction(title: "Accept", style: UIAlertActionStyle.Default) { (UIAlertAction) -> Void in
                self.startMatch(match!)
            
            }
            let alertAction2 = UIAlertAction(title: "No la", style: UIAlertActionStyle.Default) { (UIAlertAction) -> Void in }
            alert.addAction(alertAction1)
            alert.addAction(alertAction2)
            self.presentViewController(alert, animated: true) { () -> Void in }

            
        })
        

    }
    
    
    func player(player: GKPlayer, didRequestMatchWithRecipients recipientPlayers: [GKPlayer]) {
        debug("player function called, waiting for other players to accept the invite ...")
    
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
        if gameCenterViewController.isBeingDismissed() {
            self.debug("game center interaction is done")
            self.rearrangeDisplayedItems()
        }
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
                                            /* AND */
    /********************************* STEP 9: DID CHANGE STATE *******************************/
                                            /* AND */
    /********************************* STEP 10: SYNC DATA and START *******************************/

    
    func match(match: GKMatch, didReceiveData data: NSData, forRecipient recipient: GKPlayer, fromRemotePlayer player: GKPlayer) {
        debug("receiving data from another player")
    }
    
    func match(match: GKMatch, didReceiveData data: NSData, fromRemotePlayer player: GKPlayer) {
        debug("receiving data from another player")
    }
    
    func match(match: GKMatch, shouldReinviteDisconnectedPlayer player: GKPlayer) -> Bool {
        return true
    }
    
    func match(match: GKMatch, player: GKPlayer, didChangeConnectionState state: GKPlayerConnectionState) {
        debug("player state changed")

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
