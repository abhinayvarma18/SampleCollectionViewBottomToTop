//
//  StoryModel.swift
//  3x3Connect
//
//  Created by abhinay varma on 29/01/19.
//  Copyright © 2019 abhinay varma. All rights reserved.
//

import Foundation

struct StoryDetailModel:Decodable {
    var storyId:String?
    var title:String?
    var storydesc:String?
    var imageUrl:String?
    var timeStamp:String?
    var senderId:String?
    var likesAndComments:StoryLikes?
    var senderUser:User?
    
    func fetchTimeLeft() -> String {
        //based in story created time stamp
        return "12 hrs"
    }
}

struct User:Codable {
    var name:String?
    var image:String?
    var email:String?
    var phone:Int64?
}

struct StoryLikes:Decodable {
    var userLikes:UserLikeResponse?
    var shares:Int?
    
    func totalLikes() -> Int {
        return userLikes?.likeUserIds?.keys.count ?? 0
    }
}

struct UserLikeResponse:Decodable {
    var likeUserIds:[String:Bool]?
    var haha:[String:Bool]?
    var sad:[String:Bool]?
    var like:[String:Bool]?
    var love:[String:Bool]?
    var wow:[String:Bool]?
}

enum LikeType:String {
    case like = "like"
    case love = "love"
    case haha = "haha"
    case wow = "wow"
    case sad = "sad"
    case angry = "angry"
}

