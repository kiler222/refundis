//
//  FirebaseManager.swift
//
//  Created by kiler on 24.03.2019.


import Foundation
//import FirebaseStorage
import FirebaseFirestore
import FirebaseAuth
//import Firebase



class FirebaseManager: NSObject {
    public var token : String?
    static let sharedInstance  = FirebaseManager()
    var db: Firestore = Firestore.firestore()
    
    
    
    
    public func write2Firestore(collection: String, document: String, dataSet: [String : Any], completionHander: @escaping () -> Void){
        
       
        
        db.collection(collection).document(document).setData(dataSet) { err in
            if let err = err {
                print("Error writing2Firestore document: \(err)")
                 completionHander()
            } else {
                print("Document added with ID: \(document)")   //"\(ref!.documentID)")
                completionHander()
            }
        }
        
    }
    
    
   
    
    //TODO - dodać completion handler do tej funkcji i poprawić ją potem m.in. przy odrzucaniu zaproszenia
    public func update2Firestore(collection: String, document: String, dataSet: [String : Any]){
        
//        let settings = FirestoreSettings()
//        Firestore.firestore().settings = settings
//        db = Firestore.firestore()
        
        db.collection(collection).document(document).updateData(dataSet) { err in
            if let err = err {
                print("Error updating2Firestore document: \(err)")
            } else {
                print("Document updated with ID: \(document)")   //"\(ref!.documentID)")
            }
        }
        
    }
    

    
    
    public func checkIfExist(collection: String, document: String, completionHandler: @escaping (Bool) -> Void) {
        
//        let settings = FirestoreSettings()
//        Firestore.firestore().settings = settings
//        db = Firestore.firestore()
        //     print(collection, document)
        db.collection(collection).document(document).getDocument { (document, error) in
            if let document = document, document.exists {
                //                let dane = document.data()
                completionHandler(true)
            } else {
                print("Document does not exist w checkIfExist")
                completionHandler(false)
                
            }
        }
        
    }
    
    
    
    
    public func deleteFromWardrobe(wardrobeID: String, completionHandler: @escaping (Bool) -> Void){
        
        db.collection("wardrobe").document(wardrobeID).delete() { (err) in
            
            if let err = err {
                print("Error deleting  wardrobeID document: \(err)")
                completionHandler(false)
            } else {
                print("Deleted  wardrobeID: \(wardrobeID) document")
                completionHandler(true)
            }
            
        }
    }
    
    
    
   
    
    
   
    
    public func readFirestore(collection: String, document: String, completion: @escaping ([String:Any]) -> Void){
        
//        let settings = FirestoreSettings()
//        Firestore.firestore().settings = settings
//        db = Firestore.firestore()
        
        db.collection(collection).document(document).getDocument { (document, error) in
            if let document = document, document.exists {
                let dane = document.data()
                completion(dane!)
            } else {
                print("Document does not exist, cant read firestore")
                completion(["error":"error"])
            }
        }
        
    }
    
    
    /*
    public func upload2Firestore(requestID: String, images: Array<RequestItemModel>, accessUsers: [String : String], completionHandler2: @escaping () -> Void) -> Void{
        
        
        let storage = Storage.storage()
        let storageRef = storage.reference()
        let metaData = StorageMetadata()
        metaData.contentType = "image/jpg"
        metaData.customMetadata = accessUsers
        
        
        
        func uploadImages(completionHandler: @escaping ([String]) -> ()){
            
            var uploadCount = 0
            let imagesCount = images.count
            //            var imagesUrl = [String]()
            var urlDataSet = [String:String]()
            
            for image in images{
                
                let imageName = image.name // Unique string to reference image
                let imageRef = storage.reference().child("requests").child(requestID).child("\(imageName).jpg")
                
                guard let myImage = image.image else{
                    return
                }
                guard let uplodaData = myImage.jpegData(compressionQuality: 0.6) else{
                    return
                }
                
                // Upload image to firebase
                _ = imageRef.putData(uplodaData, metadata: metaData, completion: { (metadata, error) in
                    if error != nil{
                        print(error as Any)
                        return
                    }
                    imageRef.downloadURL { (url, error) in
                        guard url != nil else {
                            // Uh-oh, an error occurred!
                            print(error as Any)
                            //                            completionHandler(error as! [String])
                            return
                        }
                        //                        print("pokaż downloadURL: \(downloadURL)")
                        //                        imagesUrl.append((url?.absoluteString)!)
                        urlDataSet[imageName] = url?.absoluteString
                        uploadCount += 1
                        if uploadCount == imagesCount{
                            //                            print(imagesUrl)
                            //                            print(urlDataSet)
                            var finalDataSet = [String:Any]()
                            finalDataSet["imagesURLs"] = urlDataSet //uzupełniam w danych requestu linki do plików ze zdjeciami
                            self.update2Firestore(collection: "requests", document: requestID, dataSet: finalDataSet)
                            self.update2Firestore(collection: "users", document: SessionManager.sharedInstance.currentUserUid, dataSet: ["myRequests" : FieldValue.arrayUnion([requestID])]) //dopisuje ID requestu do usera
                            completionHandler2()
                            
                        }
                    }
                    
                    
                })
                
                //TODO - dorobić obsługę błędów uploadowania obrazków
                //                observeUploadTaskFailureCases(uploadTask : uploadTask)
            }
        }
        
        
        
        uploadImages { (imagesUrl) in
            //            print(imagesUrl)
        }
        
    }
    
    */


    
}
