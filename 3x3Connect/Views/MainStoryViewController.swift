//
//  ViewController.swift
//  3x3Connect
//
//  Created by abhinay varma on 29/01/19.
//  Copyright © 2019 abhinay varma. All rights reserved.
//

import UIKit

class MainStoryViewController: UIViewController,AppLoaderPresenter {
    //MARK:Instance Properties
    var stories:[StoryDetailModel] = []
    var loadedDataIndex = 0
    var dataLimitExceeded:Bool = false
    var numberOfSectionsInCollectionView = Constants.numberOfSectionsInCollectionView
    //MARK: Outlets/Views
    @IBOutlet weak var mainCollectionView: UICollectionView!
    @IBOutlet weak var collectionLayout: ReverseCollectionViewLayout!
    @IBOutlet weak var totalCellsLoaded: UILabel!
    @IBOutlet weak var sectionTextfiels: UITextField!
    
    
    //MARK: LoaderView
    var bgIndicatorView: UIView = {
        let mainView = UIView(frame: UIScreen.main.bounds)
        mainView.backgroundColor = UIColor.init(white:0.1, alpha: 0.8).withAlphaComponent(0.8)
        return mainView
    }()
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
    
    
    //MARK: LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        mainCollectionView.register(UINib.init(nibName: Constants.collectionViewCellNibName, bundle: nil), forCellWithReuseIdentifier: Constants.collectionViewCellIdentifier)
        mainCollectionView.register(UINib.init(nibName: Constants.collectionFooterNibName, bundle: nil), forSupplementaryViewOfKind: Constants.collectionElementKindSectionFooter, withReuseIdentifier: Constants.collectionFooterIdentifier)
        self.sectionTextfiels.endEditing(false)
        self.view.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(self.viewClicked(_:))))
    }
    
    @objc func viewClicked(_ gesture:UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setUsesNormalFlowLayout(false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadDataFromFirebase()
    }
    
    //MARK: loading data in chunks of 10 on ui
    //after reaching the bottom most cell while scrolling
    func loadDataFromFirebase() {
        self.showActivityIndicator()
        FirebaseManager.sharedInstance.fetchFirstTimeStories(first: loadedDataIndex, { [weak self](models, error,flag)  in
            if error == nil && models != nil {
                self?.dataLimitExceeded = flag ?? false
                self?.stories += (models ?? [])
                if flag ?? false {
                    self?.loadedDataIndex += (self?.stories.count ?? 0)%Constants.initialDataToLoad
                }else {
                    self?.loadedDataIndex += Constants.initialDataToLoad
                }
              
                DispatchQueue.main.async {
                    self?.mainCollectionView.reloadData()
                    self?.hideActivityIndicator()
                }
            }else{
                //error
                DispatchQueue.main.async {
                  self?.hideActivityIndicator()
                  self?.loadErrorView("ErrorParsing Story Data")
                }
            }
        })
    }
    
    //MARK: On Increasing Cell Grid From Lower Number To Higher Auto Refresh is done since the last cell is been displayed
    @IBAction func refreshClicked(_ sender: Any) {
        self.view.endEditing(true)
        if (sectionTextfiels.text?.isEmpty ?? false) || sectionTextfiels.text ?? "3"
            == String(Int(numberOfSectionsInCollectionView)) {
            self.stories = []
            loadedDataIndex = 0
            dataLimitExceeded = false
            self.sectionTextfiels.text = "3"
            self.numberOfSectionsInCollectionView = 3
            self.loadDataFromFirebase()
        }else{
            self.numberOfSectionsInCollectionView = CGFloat(Int(sectionTextfiels?.text ?? "3") ?? 3)
            self.mainCollectionView.reloadData()
        }
    }
    
    //MARK: ErrorView
    func loadErrorView(_ withText:String) {
        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ErrorPopUp") as! AlertViewController
        popOverVC.textValue = withText
        popOverVC.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
        DispatchQueue.main.async {
            self.present(popOverVC, animated: true)
        }
    }
}


//MARK: CollectionView/CollectionViewFloeLayout Delegate and Datasource implementation
extension MainStoryViewController:UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout {
    //MARK: Number of Items In sections and row
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = self.stories.count
        let totalImagesDisplayed = (section) * Int(self.numberOfSectionsInCollectionView)
        let imagesLeftToDisplay = count - totalImagesDisplayed
        return imagesLeftToDisplay <= 0 ? 0 : (imagesLeftToDisplay > Int(self.numberOfSectionsInCollectionView) ? Int(self.numberOfSectionsInCollectionView) : imagesLeftToDisplay)
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return stories.count == 0 ? 0 : ((stories.count)/(Int(self.numberOfSectionsInCollectionView)) + 1)
    }
    
    //MARK: Size of item and layouting of grid
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let sizeToReturn = CGSize(width: (UIScreen.main.bounds.size.width-40.0)/self.numberOfSectionsInCollectionView, height: (UIScreen.main.bounds.size.width + 180.0)/self.numberOfSectionsInCollectionView)
        return sizeToReturn
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
    }
    
    //MARK: Cell Configuration/Assigning Data to cell
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let feedCell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.collectionViewCellIdentifier, for: indexPath) as? BottomRightToLeftCollectionViewCell
        feedCell?.dataModel = stories[indexPath.section*Int(self.numberOfSectionsInCollectionView) + indexPath.row]
        return feedCell ?? UICollectionViewCell()
    }
    
    //MARK: Header/FooterView Config
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var identifier:String? = ""
        if kind == UICollectionElementKindSectionHeader {
            identifier = "header"
        }else if kind == UICollectionElementKindSectionFooter {
            identifier = "footer"
        }else {
            print("unknown element kind -: \(kind)")
            return UICollectionReusableView()
        }
        let supplementaryView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: identifier!, for: indexPath)
        return supplementaryView
    }

    
    
    //MARK: Setting the custom layout
    func setUsesNormalFlowLayout(_ enabled:Bool) {
        let newLayout = self.flowLayoutNormal(enabled)
        collectionLayout = newLayout as! ReverseCollectionViewLayout
        newLayout.invalidateLayout()
    }
    
    func flowLayoutNormal(_ normal:Bool)->(UICollectionViewFlowLayout) {
        var layout = normal ? UICollectionViewFlowLayout() : ReverseCollectionViewLayout()
        layout = collectionLayout
        layout.headerReferenceSize = CGSize(width: 0, height: 0)
        layout.footerReferenceSize = CGSize(width: 5, height: 5)
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        layout.sectionInset =  UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
        return layout
    }
    
    //MARK: Load More Data
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        if !activityIndicator.isAnimating && indexPath.section == 0 && indexPath.row == 0 {
            //load more
            if self.dataLimitExceeded {
                //alert no data available on server
                loadErrorView(ErrorResponse.dataBreached)
            }else{
                self.loadDataFromFirebase()
            }
        }
    }
}

