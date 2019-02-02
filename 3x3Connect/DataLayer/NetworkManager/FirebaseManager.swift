//
//  FirebaseManager.swift
//  3x3Connect
//
//  Created by abhinay varma on 29/01/19.
//  Copyright © 2019 abhinay varma. All rights reserved.
//

import Foundation
import FirebaseAuth
import Firebase
import FirebaseDatabase

class FirebaseManager {
     //MARK: Singleton Instance to firebase
    static var sharedInstance = FirebaseManager()
    let firebaseDbRef:DatabaseReference? = Database.database().reference()
    
    //MARK: SignIn to firebase
    func logIntoFirebase(_ completion:@escaping(Error?)->()) {
        Auth.auth().signInAnonymously { (result, error) in
            if error != nil {
                print("Sign In Problem -: \(error.debugDescription)")
                completion(error)
                return
            }
            completion(nil)
        }
    }
    
    //MARK: fetch user based on user-id from user node("users")
    func fetchUser(_ userId:String,_ completion:@escaping(User?,Error?)->()) {
        firebaseDbRef?.child("users").child(userId).observeSingleEvent(of: .value, with: { (snapshot) in
            guard let value = snapshot.value as? Dictionary<String,Any> else {
               // print("error parsing content \(error)")
                completion(nil,nil)
                return
            }
            if let theJSONData = try? JSONSerialization.data(
                withJSONObject: value,
                options: []) {
                do {
                    let model = try JSONDecoder().decode(User.self, from:theJSONData)
                    completion(model,nil)
                }catch { let error = error
                    
                    completion(nil,error)
                    return
                }
            }})
    }
    
    //MARK: fetch like/comment data of the storyId from node (StoryLikes)
    func fetchLikesShare(storyId:String,_ completion:@escaping(StoryLikes?,Error?)->()) {
        firebaseDbRef?.child(FirebaseConstants.storyLikeNode).child(storyId).observe(.value, with: { (snapshot) in
            guard let value = snapshot.value as? Dictionary<String,Any> else {return}
            if let jsonData = try? JSONSerialization.data(withJSONObject: value, options: []) {
                do {
                    let likeModel = try JSONDecoder().decode(StoryLikes.self, from: jsonData)
                    completion(likeModel,nil)
                    return
                }catch { let error = error
                    
                    completion(nil,error)
                    return
                }
            }
        })
    }
    
    //MARK:Method To Load Data in chunk
    func fetchFirstTimeStories(first:Int,_ completion:@escaping([StoryDetailModel]?,Error?,Bool?)->()) {
        firebaseDbRef?.child(FirebaseConstants.storyDetailNode).queryOrderedByKey().queryStarting(atValue: "\(first)").queryLimited(toFirst: UInt(Constants.initialDataToLoad)).observeSingleEvent(of:.value, with: { (snapshot) in
            
            guard var storyDetails = snapshot.value as? [Dictionary<String,Any>?] else {
                //In case data is dictionary(last fetches)
                guard var storyDictDetails = snapshot.value as? Dictionary<String,Any> else {
                    completion(nil,nil,false)
                    return
                }
                //case server data exceeded
                var newModelArray:[StoryDetailModel] = []
                for story in storyDictDetails.values {
                    if let jsonModelArrayData = try? JSONSerialization.data(withJSONObject: story, options: []) {
                        do{
                            let storyModel = try JSONDecoder().decode(StoryDetailModel.self, from: jsonModelArrayData)
                            newModelArray.append(storyModel)
                        }catch{let error = error
                            completion(nil,error,false)
                        }
                    }
                }
                self.fetchStoryUserDataAndLikesDetail(newModelArray.count % Constants.initialDataToLoad != 0,newModelArray, completion)
                return
            }
            //In case data is array of dictionary(1st 2 fetches)
            storyDetails.removeFirst(first)
            if let jsonModelArrayData = try? JSONSerialization.data(withJSONObject: storyDetails, options: []) {
                do{
                    let storyModelArray = try JSONDecoder().decode([StoryDetailModel].self, from: jsonModelArrayData)
                    self.fetchStoryUserDataAndLikesDetail(false,storyModelArray, completion)
                }catch{
                    completion(nil,error,false)
                }
            }
        })
    }
    
    
    //MARK: Takes an array of stories and fetch its associated storydata from other nodes
    func fetchStoryUserDataAndLikesDetail(_ flag:Bool,_ storyModelArray:[StoryDetailModel],_ completion:@escaping([StoryDetailModel]?,Error?,Bool?)->()) {
                var newArray = storyModelArray
                for story in storyModelArray {
                    let storyId = story.storyId
                    let index = storyModelArray.index(where: { (model) -> Bool in
                        return model.storyId == storyId
                    })
                    self.fetchUser(story.senderId!, { (user, error) in
                        if error == nil && user != nil {
                            newArray[index!].senderUser = user
                        }else{
                            newArray[index!].senderUser = nil
                        }
                        self.fetchLikesShare(storyId: storyId!, { (likes, error) in
                            if error == nil && likes != nil {
                                newArray[index!].likesAndComments = likes
                            }else{
                                newArray[index!].likesAndComments = nil
                            }
                            if(index! == storyModelArray.count - 1) {
                                newArray.sort(by: { (model, newModel) -> Bool in
                                    Int(model.storyId?.replacingOccurrences(of: FirebaseConstants.storyIdString, with: "") ?? "0")!  <  Int(newModel.storyId?.replacingOccurrences(of: FirebaseConstants.storyIdString, with: "") ?? "0")!
                                })
                                completion(newArray,nil,flag)
                            }
                        })
                    })
                }
    }
}

//MARK: Dynamice Functions for realtime integration of the same model
//TODO: By integrating this we can assure instant changes on updation of data on firebase
extension FirebaseManager {
    
    func getStoryDataUpdate(_ completion:@escaping(StoryDetailModel?,Error?)->()) {
        firebaseDbRef?.child(FirebaseConstants.storyLikeNode).observe(.childAdded, with: { (snapshot) in
            guard let value = snapshot.value as? Dictionary<String,Any> else { return }
            do {
                if let theJSONData = try? JSONSerialization.data(
                    withJSONObject: value,
                    options: []) {
                    var model = try JSONDecoder().decode(StoryDetailModel.self, from:theJSONData)
                    self.fetchUser(model.senderId ?? "", { (user, error) in
                        if error == nil && user != nil {
                            model.senderUser = user
                            self.fetchLikesShare(storyId: snapshot.key, { (likes, error) in
                                if error == nil && likes != nil {
                                    model.likesAndComments = likes
                                    completion(model,nil)
                                }else{
                                    completion(model,nil)
                                }
                            })
                        }else{
                            completion(nil,error)
                        }
                    })
                }
            }catch { let error = error
                completion(nil,error)
                return
            }
        })
    }
    
    func updateStoryDataUpdate(_ completion:@escaping(StoryDetailModel?,Error?)->()) {
        firebaseDbRef?.child(FirebaseConstants.storyDetailNode).observe(.childChanged, with: { (snapshot) in
            guard let value = snapshot.value as? Data else { return }
            if let theJSONData = try? JSONSerialization.data(
                withJSONObject: value,
                options: []) {
                do {
                    let model = try JSONDecoder().decode(StoryDetailModel.self, from:theJSONData)
                    completion(model,nil)
                }catch { let error = error
                    completion(nil,error)
                    return
                }
            }else{
                completion(nil,nil)
            }
        })
    }
    
    func deleteStoryData(_ completion:@escaping(StoryDetailModel?,Error?)->()) {
        firebaseDbRef?.child(FirebaseConstants.storyDetailNode).observe(.childRemoved, with: { (snapshot) in
            guard let value = snapshot.value as? Data else { return }
            if let theJSONData = try? JSONSerialization.data(
                withJSONObject: value,
                options: []) {
                do {
                    let model = try JSONDecoder().decode(StoryDetailModel.self, from:theJSONData)
                    completion(model,nil)
                }catch { let error = error
                    completion(nil,error)
                    return
                }
            }})
    }
    
}
