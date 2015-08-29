//: Playground - noun: a place where people can play

import SpriteKit
import GameKit
import GameController
import GameplayKit

let alert = UIAlertController(title: "Game Invitation", message: "Message", preferredStyle: UIAlertControllerStyle.Alert)
let alertAction1 = UIAlertAction(title: "Accept", style: UIAlertActionStyle.Default) { (UIAlertAction) -> Void in }
let alertAction2 = UIAlertAction(title: "No la", style: UIAlertActionStyle.Default) { (UIAlertAction) -> Void in }
alert.addAction(alertAction1)
alert.addAction(alertAction2)
presentViewController(alert, animated: true) { () -> Void in }
