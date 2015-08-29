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

class MainMenuViewController: UIViewController, GKGameCenterControllerDelegate, GKMatchmakerViewControllerDelegate, GKLocalPlayerListener, GKInviteEventListener, GKMatchDelegate  {

    var mainMenuAlreadyLoadedOnce = false

    /*Game Center Related Settings*/
    
    var gMultiPlayerMode:Bool = false
    
    var playerIsAuthenticated = false
    
    var localPlayerInitiateMatch = false
    
    var localPlayerReceiveInvite = false
    
    let gMaxNumberOfPlayer = 4 /* for muliplayers */
    
    let gMinNumberOfPlayer = 1 /* for muliplayers */
    
    let gDefaultNumberOfPlayer = 1 /* for muliplayers */
    
    let gUseGameCenter = true
    
    var gFriendsPlayerList = [GKPlayer]()
    
    var gGameCenterVC = GKGameCenterViewController()
    
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
        statusLabel.text = str
    }
    
    /************************** STEP 1: PLAYER AUTHENTICATION ****************************/
                                        /* AND */
    /************************** STEP 3: RETRIEVE  LIST OF FRIENDS ************************/
    
    func authenticatePlayer() {
        /* Game initial settings set up as well as ask users to login to Game Center */
        
        /*GKLocalPlayer Singleton handler implementation*/
        GKLocalPlayer.localPlayer().authenticateHandler = {( gameCenterVC, gameCenterError) -> Void in
            
            
            if gameCenterVC != nil {
                /* present GameCenterVC and ask users to login */
                
                //self.gGameCenterVC = gameCenterVC as! GKGameCenterViewController
                self.gGameCenterVC.gameCenterDelegate = self
                
                self.presentViewController(gameCenterVC!, animated: true, completion: { () -> Void in
                    /* present game login screen to users*/
                    self.debug("DEBUG: No login cookie, prompt user to login")
                })
            } else if GKLocalPlayer.localPlayer().authenticated == true && self.playerIsAuthenticated == false {

                    /* authenticated once and is authenticated and prepare GKLocalPlayer.localPlayer() object*/
                    self.debug("DEBUG: game center authentication ok" + String(GKLocalPlayer.localPlayer().playerID))
                
                    /* attempt to set up event handler*/
                    // self.setUpInviteHandler()
                
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
                
                
                    /* take action to creat a new match for user */
                
                    // self.player(GKLocalPlayer.localPlayer(), didRequestMatchWithPlayers: ["G:17880138"])
                
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
            gMatchRequest.recipientResponseHandler = { (playerID, response) -> Void in
                if response ==  GKInviteRecipientResponse.InviteeResponseAccepted {
                    self.debug("DEBUG: match sent accepted")
                    self.startMatch()
                }
            }
            
            if gMultiplayerStatus == .standardGameCenterInterface {
                /* option 1 game center standard interface */
                
                /*initializing a Game Center Match Maker View Controller for users to customize*/
                let matchMakerViewController = GKMatchmakerViewController(matchRequest: gMatchRequest)! /* initWithMatchRequest: */
                
                matchMakerViewController.hosted = false
                matchMakerViewController.matchmakerDelegate = self  /*to followup on the response from other players unpon receiving my invitations sent*/
                
                
                self.presentViewController(matchMakerViewController, animated: true, completion: {() -> Void in
                    self.debug("DEBUG: Standard Match Maker VC presented")
                })
            } else if gMultiplayerStatus == .programmeToCreateMatch {
                /* option 2 programmatically find match */
                
                self.debug("DEBUG: attempt to create match programmatically")
                GKMatchmaker.sharedMatchmaker().findMatchForRequest(gMatchRequest, withCompletionHandler: { (match, error) -> Void in
                    if !(error != nil) {
                        self.debug("DEBUG: There is an error" + String(error))
                    } else if match != nil {
                        /* Match created now add more players */

                        self.debug("DEBUG: Match created la!")
                        GKMatchmaker.sharedMatchmaker().addPlayersToMatch(match!, matchRequest: gMatchRequest, completionHandler: {(err) -> Void in
                        })

                    }
                })


            } else if gMultiplayerStatus == .programmeInviteSpecificPlayers {
                /* option 3 invite specific player */
                
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
        
    }
    
    
    /*************************** NEW VERSION OF INVITE GKLocalPlayerListener PROTOCOL  ****************************/

    
    /*protocol for implementing listener: when user accept invitation from others*/
    func player(player: GKPlayer, didAcceptInvite invite: GKInvite) {
        self.debug("did received and accepted an invite" + String(player.playerID))
        
        GKMatchmaker.sharedMatchmaker().matchForInvite(invite, completionHandler: { match, error -> Void in
            self.debug("Invite received")

            let alert = UIAlertController(title: "Game Invitation", message: "Message", preferredStyle: UIAlertControllerStyle.Alert)
            let alertAction1 = UIAlertAction(title: "Accept", style: UIAlertActionStyle.Default) { (UIAlertAction) -> Void in }
            let alertAction2 = UIAlertAction(title: "No la", style: UIAlertActionStyle.Default) { (UIAlertAction) -> Void in }
            alert.addAction(alertAction1)
            alert.addAction(alertAction2)
            self.presentViewController(alert, animated: true) { () -> Void in }
            
        })
        

    }
    
    
    
    func player(player: GKPlayer, didRequestMatchWithRecipients playerIDsToInvite: [GKPlayer]) {
        print("DEBUG: player send Invite with specific ID")
        
        let gMatchRequest:GKMatchRequest = GKMatchRequest()
        
        gMatchRequest.maxPlayers = gMaxNumberOfPlayer
        gMatchRequest.minPlayers = gMinNumberOfPlayer
        gMatchRequest.defaultNumberOfPlayers = gDefaultNumberOfPlayer
        gMatchRequest.playerAttributes = 0 ; // NO SPECIAL ATTRIBS
        gMatchRequest.playerGroup = 0
        gMatchRequest.inviteMessage = "Let's Play Draw and Guess la 哇卡！"
        gMatchRequest.recipients = playerIDsToInvite
        

    
    }
    
    /********************* For MatchmakerController Delegate ***************************/
    
    func gameCenterViewControllerDidFinish(gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismissViewControllerAnimated(true, completion: nil)
        self.debug("DEBUG: game center interaction is done")
    }
    /* * */
    
    func matchmakerViewController(viewController: GKMatchmakerViewController,
        didFailWithError error: NSError) {
            self.debug("matchmakerViewController")
    }
    
//    func matchmakerViewController(_ viewController: GKMatchmakerViewController!,
//        didFindPlayers playerIDs: [AnyObject]!) {
//    }
    
    func matchmakerViewControllerWasCancelled(viewController: GKMatchmakerViewController) {
        viewController.dismissViewControllerAnimated(true, completion: {() -> Void in
            self.debug("matchmakerViewController closed as user cancelled it")
        })
    }
    

    
    
    func startMatch() {
        
    }
    
    /********************************** CORE *********************************/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        /* Make sure layout of buttons are ok before loading the view */
        statusLabel.frame.origin.x = self.view.frame.size.width/2 - statusLabel.frame.width/2
        buttonForAutoMatch.frame.origin.x = self.view.frame.size.width/2 - buttonForAutoMatch.frame.width/2
        buttonForGameCenter.frame.origin.x = self.view.frame.size.width/2 - buttonForGameCenter.frame.width/2
        buttonForSpecificPlayers.frame.origin.x = self.view.frame.size.width/2 - buttonForSpecificPlayers.frame.width/2
        greenButton.frame.origin.x = self.view.frame.size.width/2 - greenButton.frame.width/2
        
        print("DEBUG: viewDidAppear - readjust position of buttons")
        
        authenticatePlayer()
    }
    
    override func viewWillLayoutSubviews() {
        /* viewWillLayoutSubviews is where you position and layout the subviews if needed. This will be called after rotations or other events results in the view controller's view being sized. This can happen many times in the lifetime of the view controller.  */
        if !mainMenuAlreadyLoadedOnce {
            super.viewWillLayoutSubviews()
            mainMenuAlreadyLoadedOnce = true
            print("DEBUG: viewWillLayoutSubviews")
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
    
    /*********** Implementation for GKLocalPlayerListener *********************/

    
    func player(player: GKPlayer, didReceiveChallenge challenge: GKChallenge) {
        
    }
    
    func player(player: GKPlayer, wantsToPlayChallenge challenge: GKChallenge) {
        
    }


    

    

}
