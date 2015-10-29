//
//  Song.swift
//  IceFishing
//
//  Created by Alexander Zielenski on 4/12/15.
//  Copyright (c) 2015 Lucas Derraugh. All rights reserved.
//

import UIKit
import SwiftyJSON

let spotifyAPIBaseURL = NSURL(string: "https://api.spotify.com/v1/tracks/")
let SongDidDownloadArtworkNotification = "SongDidDownloadArtwork"

class Song: NSObject {
	var title = ""
	var artist = ""
	var album = ""
	var largeArtworkURL: NSURL?
	var smallArtworkURL: NSURL?
	
	private var largeArtwork: UIImage?
	func fetchArtwork() -> UIImage? {
		if largeArtwork == nil && largeArtworkURL != nil {
			loadImageAsync(largeArtworkURL!, completion: { [weak self] (image, error) -> () in
				self?.largeArtwork = image
				NSNotificationCenter.defaultCenter().postNotificationName(SongDidDownloadArtworkNotification, object: self)
				})
		}
		return largeArtwork
	}
	
	var spotifyID: String = ""
	var previewURL: NSURL!
	
	init(songID: String) {
		super.init()
		spotifyID = songID
		self.setSongID(songID)
	}
	
	convenience init(spotifyURI: String) {
		let components = spotifyURI.componentsSeparatedByString(":") as [String]
		var id = ""
		if components.count > 0 {
			id = components.last!
		}
		self.init(songID: id)
	}
	
	init(responseDictionary: Dictionary<String, AnyObject>) {
		super.init()
		initializeFromResponseDictionary(responseDictionary)
	}
	
	init(json: JSON) {
		super.init()
		initializeFromResponse(json)
	}
	
	private func initializeFromResponseDictionary(response: Dictionary<String, AnyObject>) {
		initializeFromResponse(JSON(response))
	}
	
	private func initializeFromResponse(json: JSON) {
		if let track = json["name"].string {
			title = track
			let preview = json["preview_url"].stringValue
			previewURL = NSURL(string: preview)
			let artists = json["artists"].arrayValue
			if artists.count > 1 {
				artist = "Various Artists"
			} else if artists.count == 0 {
				artist = "Unknown Artist"
			} else {
				artist = artists[0]["name"].string ?? "Unknown Artist"
			}
			
			let albums = json["album"].dictionaryValue
			album = albums["name"]?.string ?? "Unknown Album"
			
			let images = albums["images"]?.arrayValue ?? []
			if images.count > 0 {
				var firstImage = images[images.count - 1].dictionaryValue
				smallArtworkURL = NSURL(string: firstImage["url"]?.stringValue ?? "")
				
				firstImage = images[0].dictionaryValue
				largeArtworkURL = NSURL(string: firstImage["url"]?.stringValue ?? "")
			}
			spotifyID = json["id"].stringValue
		} else if let track = json["track"].string {
			title = track
			artist = json["artist"].stringValue
			spotifyID = json["id"].stringValue
		}
	}
	
	private func setSongID(id: String) {
		//TODO: This section needs a major rewrite, unfortunately the player won't work if this call is converted to be asynchronous
		let request = NSURLRequest(URL: NSURL(string: spotifyID, relativeToURL: spotifyAPIBaseURL)!)
		var error:NSError? = nil
		let data: NSData?
		do {
			data = try NSURLConnection.sendSynchronousRequest(request, returningResponse: nil)
		} catch let error1 as NSError {
			error = error1
			data = nil
		}
		if let data = data {
			let json = JSON(data: data, options: NSJSONReadingOptions(rawValue: 0), error: &error)
			initializeFromResponse(json)
		} else {
			print("got error: %@", (error!).description)
		}
//		NSURLSession.sharedSession().dataTaskWithRequest(request) { [weak self] data, _, _ in
//			if let data = data {
//				var error:NSError? = nil
//				let json = JSON(data: data, options: NSJSONReadingOptions(rawValue: 0), error: &error)
//				if error != nil {
//					print(error)
//				} else {
//					dispatch_async(dispatch_get_main_queue()) {
//						self?.initializeFromResponse(json)
//						print(self)
//					}
//				}
//			}
//		}.resume()
	}
	
	override init() {
		assertionFailure("use init(songID:)")
	}
	
	override var description: String {
		return "Song: \(title) \(artist)"
	}
}