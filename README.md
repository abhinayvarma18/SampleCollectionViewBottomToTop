# SampleTask
The project consists of some of the basic functionalities of a generic collectionView Layout.

## Installation

Install the code using bit-bucket repo "https://github.com/abhinayvarma18/SampleCollectionViewBottomToTop/edit/master/"

Use the package manager [PODS](https://cocoapods.org/) to install cocoapods.

			   Step1-:	cd projectDirectory
  			   Step2-:   pod install

You can then open xcworkspace file to have an clear understanding of the codebase.

#Usage

a) There are 3 end points in firebase which is been used -:
i)  ##StoryBasicDetailNode 

  	    "storyDetail" : [ {
	    "imageUrl" : "https://www.s3bucket/category/imgname1.jpg",
	    "senderId" : "uid-1",
	    "storyId" : "storyId0",
	    "storydesc" : "this is an article to describe moon and sun distance with respect to plutos velocity",
	    "timeStamp" : "2019-01-29-13:20:23 ",
	    "title" : "Coming all the way"
 	 }]
  
ii) ##StoriesLikeAndCommentDetails

  	"storyLikes" : {
		"storyId1" : {
	      "shares" : 2,
	      "userLikes" : {
		"angry" : {
		  "uid-1" : false
		},
		"haha" : {
		  "uid-1" : true,
		  "uid-2" : false
		},
		"like" : {
		  "uid-2" : false
		},
		"love" : {
		  "uid-4" : true
		},
		"sad" : {
		  "uid-4" : false
		},
		"wow" : {
		  "uid-2" : false
		}
	      }
    	}
iii)  ##UserNode 

    "users" : {
    "uid-1" : {
      "email" : "abhinaycpian@gmail.com",
      "image" : "https://www.s3bucket.profilehtos/abhinay",
      "name" : "abhinay",
      "phone" : 9530452298
    }

Currently Static data is been loaded since no update/save data implementation is been touched,
henceforth the ui doesn't react to the live changes on firebase. Methods for the same is been commented and are there in the
Singleton NetworkManagerFile which is handling all firebase operations.

b) Layout is flexible , you can edit number of sections you wish to see by updating the textfield present on the homescreen
  which after edditing and clicking of refresh loads the new layout.





# CopyRights
