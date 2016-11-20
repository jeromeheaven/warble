//
//  SearchPostView.swift
//  Tempo
//
//  Created by Alexander Zielenski on 4/12/15.
//  Copyright (c) 2015 Alexander Zielenski and Mark Bryan. All rights reserved.
//

import UIKit
import MediaPlayer

class SearchPostView: UIView, UIGestureRecognizerDelegate {
	var tapGestureRecognizer: UITapGestureRecognizer?
	@IBOutlet var profileNameLabel: UILabel?
	@IBOutlet var avatarImageView: UIImageView?
	@IBOutlet var descriptionLabel: UILabel?
	@IBOutlet var spacingConstraint: NSLayoutConstraint?
 
    fileprivate var updateTimer: Timer?
    fileprivate var notificationHandler: AnyObject?
    
    var post: Post? {
        didSet {
            if let handler: AnyObject = notificationHandler {
                NotificationCenter.default.removeObserver(handler)
            }

            // update stuff
			if let post = post {
				avatarImageView?.layer.cornerRadius = 7
                profileNameLabel?.text = post.song.title
                descriptionLabel?.text = post.song.artist
            } else {
                updateTimer?.invalidate()
                updateTimer = nil
            }
        }
    }
    
    override func didMoveToWindow() {
        
        if tapGestureRecognizer == nil {
            tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(SearchPostView.postViewPressed(_:)))
            tapGestureRecognizer?.delegate = self
            tapGestureRecognizer?.cancelsTouchesInView = false
            addGestureRecognizer(tapGestureRecognizer!)
        }
        
        avatarImageView?.clipsToBounds = true
        isUserInteractionEnabled = true
        avatarImageView?.isUserInteractionEnabled = true
        profileNameLabel?.isUserInteractionEnabled = true
        
        layer.borderColor = UIColor.tempoDarkGray.cgColor
        layer.borderWidth = CGFloat(0.7)
    }
    
    override func didMoveToSuperview() {
        super.didMoveToSuperview()
    }
	
	func updatePlayingStatus() {
		updateProfileLabel()
		
		if updateTimer == nil && post?.player.isPlaying ?? false {
			// 60 fps
			updateTimer = Timer(timeInterval: 1.0 / 60.0,
			                            target: self, selector: #selector(timerFired(timer:)),
			                            userInfo: nil,
			                            repeats: true)
			RunLoop.current.add(updateTimer!, forMode: RunLoopMode.commonModes)
		} else {
			updateTimer?.invalidate()
			updateTimer = nil
		}
	}
	
    dynamic private func timerFired(timer: Timer) {
        if post?.player.isPlaying ?? false {
            setNeedsDisplay()
        }
	}
	
    // Customize view to be able to re-use it for search results.
    func flagAsSearchResultPost() {
        descriptionLabel?.text = post!.song.title + " · " + post!.song.album
    }
    
    func updateProfileLabel() {
        if let post = post {
            var color: UIColor!
			let font = UIFont(name: "Avenir-Medium", size: 14)
            let duration = TimeInterval(0.3) as TimeInterval
            let label = profileNameLabel!
            if post.player.isPlaying {
                color = UIColor.tempoLightRed
                // Will scroll labels
            } else {
                color = UIColor.white
            }
            
            if !label.textColor.isEqual(color) {
                UIView.transition(with: label, duration: duration, options: UIViewAnimationOptions.transitionCrossDissolve, animations: {
                    label.textColor = color
					label.font = font
                    }, completion: { _ in
                        label.textColor = color
						label.font = font
                })
            }
        }
    }
	
	override func draw(_ rect: CGRect) {
        var fill = 0
        if let post = post {
			fill = post.player.isPlaying ? 1 : 0
        }
        super.draw(rect)
        UIColor.tempoDarkGray.setFill()
        UIGraphicsGetCurrentContext()?.fill(CGRect(x: 0, y: 0, width: bounds.width * CGFloat(fill), height: bounds.height))
    }
    
    func postViewPressed(_ sender: UITapGestureRecognizer) {
        if let post = post {
            if post.player.isPlaying {
                let tapPoint = sender.location(in: self)
                let hitView = hitTest(tapPoint, with: nil)
                
                if hitView == avatarImageView || hitView == profileNameLabel {
                    // GO TO PROFILE VIEW CONTROLLER=
                }
            }
        }
    }
}