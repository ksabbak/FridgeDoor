//
//  ConnectionManager.swift
//  
//
//  Created by Steven Fellows on 2/16/16.
//
//


import Foundation
import Firebase

protocol ConnectionManagerCreateUserDelegate {
    func connectionManagerDidCreateUser(user: User)
    func connectionManagerDidFailToCreateUser(error: NSError)
}

//Deprecated
protocol ConnectionManagerGetUserDelegate {
    func connectionManagerDidGetUser(user: User)
    func connectionManagerDidFailToGetUser()
}

protocol ConnectionManagerLogInUserDelegate {
    func connectionManagerDidLogInUser()
    func connectionManagerDidFailToLogInUser(error: NSError)
}

protocol ConnectionManagerMakeHistoryItemDelegate {
    func connectionManagerDidMakeHistoryItem()
    func connectionManagerDidFailToMakeHistoryItem()
}

protocol ConnectionManagerMakeListDelegate {
    func connectionManagerDidMakeList()
    func connectionManagerDidFailToMakeList()
}

protocol ConnectionManagerDeleteListDelegate {
    func connectionManagerDidDeleteList()
    func connectionManagerDidFailToDeleteList()
}

protocol ConnectionManagerGetAllListsDelegate {
    func connectionManagerDidGetAllLists(lists:[List])
    func connectionmanagerDidFailToGetAllLists()
}

protocol ConnectionManagerListChangesDelegate {
    func connectionManagerListWasAdded(post: List)
    func connectionManagerListWasDeleted(post: List)
    func connectionManagerListWasChanged(post: List)
}

protocol ConnectionManagerLogOutDelegate {
    func connectionManagerDidLogOut()
}

//MARK:
class ConnectionManager {
    
    class var sharedManager: ConnectionManager {
        struct Static {
            static var onceToken: dispatch_once_t = 0
            static var instance: ConnectionManager? = nil
        }
        dispatch_once(&Static.onceToken) {
            Static.instance = ConnectionManager()
        }
        return Static.instance!
    }
    
    
    //MARK: - Properties
    
    var getUserDelegate:     ConnectionManagerGetUserDelegate?
    var createUserDelegate:  ConnectionManagerCreateUserDelegate?
    var logInUserDelegate:   ConnectionManagerLogInUserDelegate?
    var makeListDelegate:    ConnectionManagerMakeListDelegate?
    var deleteListDelegate:  ConnectionManagerDeleteListDelegate?
    var getAllListsDelegate: ConnectionManagerGetAllListsDelegate?
    var listChangedDelegate: ConnectionManagerListChangesDelegate?
    var logoutDelegate:      ConnectionManagerLogOutDelegate?
    var makeHistoryItemDelegate: ConnectionManagerMakeHistoryItemDelegate?
    
    private
    
    let rootRef = Firebase(url:"fridgedoor.firebaseIO.com")
    var usersRef: Firebase!
    var listsRef: Firebase!
    var historyItemsRef: Firebase!
    var authData: FAuthData?
    
    
    
    var userData: User?
    
    private var users: [User] = []
    private var lists: [List] = []
    private var historyItems: [History] = []
    
    private var selfUserUID: String
    {
        return userUID()!
    }
    
    //MARK: - Public Functions
    
    
    //MARK: - User handling
    
    func test()
    {
        getAllUsers()
        //self.users.append(user)
        print(users)
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(2 * Double(NSEC_PER_SEC))), dispatch_get_main_queue())
            {
        print(self.users[0].username)
        print(self.usersRef)
        }
        print(":(")
    }
    
    func isLoggedIn() -> Bool
    {
        if authData != nil
        {
            return true
        }
        return false
    }
    
    
    func userUID() -> String?
    {
        guard
            let aData = authData,
            let auth = aData.auth,
            let userUID = auth.first,
            let userUIDKey = userUID.1 as? String
            else { Debug.log("No Auth Data Found")
                logout()
                return ""
        }
        return userUIDKey
    }
    
    
    func logout()
    {
        rootRef.unauth()
        authData = nil
        logoutDelegate?.connectionManagerDidLogOut()
    }
    
    func logInUser(email: String, password: String) {
        
        
        rootRef.authUser(email, password: password) { (error:NSError!, authData:FAuthData!) -> Void in
            
            
            guard
                error == nil
                else {
                    Debug.log("Log in user failed" + error.localizedDescription)
                    self.logInUserDelegate?.connectionManagerDidFailToLogInUser(error)
                    return
            }
            
            self.authData = authData
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.logInUserDelegate?.connectionManagerDidLogInUser()
            })
            
        }
    }
    
    
    
    func createUser(userObject user: User, password: String)
    {
        rootRef.createUser(user.email, password: password, withValueCompletionBlock: { error, result in
            
            guard
                error == nil,
                let uid = result["uid"] as? String
                else {
                    Debug.log("Create user failed " + error.localizedDescription)
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.createUserDelegate?.connectionManagerDidFailToCreateUser(error)
                    })
                    return
            }
            
            print("Successfully created user account with uid: \(uid)")
            
            let newUserRef = self.usersRef.childByAppendingPath(uid)
            
            user.UID = uid
            
            let userData: [String:String] =
            ["image_name":user.imageName,
                "username":user.username,
                "UID":user.UID,
                "email":user.email]
            
            newUserRef.setValue(userData)
            
            self.logInUser(user.email, password: password)
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.createUserDelegate?.connectionManagerDidCreateUser(user)
                
            })
        })
        
    }
    
    func updateUser(user: User)
    {
        let userRef = usersRef.childByAppendingPath(user.UID)
        
        let userData: [String:AnyObject] =
        ["image_name":user.imageName,
            "username":user.username,
//            "bio":user.bio
        ]
        
        userRef.updateChildValues(userData)
    }
    
    
    func getUserFor(userUID userUID: String) -> User?
    {
        var matchingUser: User!
        
        for user in users {
            if user.UID == userUID {
                matchingUser = user
                break
            }
        }
        
        guard matchingUser != nil
            else {
                Debug.log("No Such user")
                logout()
                self.getUserDelegate?.connectionManagerDidFailToGetUser() //Deprecated
                return nil
        }
        
        self.getUserDelegate?.connectionManagerDidGetUser(matchingUser) //Deprecated
        return matchingUser
    }
    
    
    func allUsers() -> [User] {
        return users
    }
    
    func addListToUser(listUID: String, toUser userUID: String)
    {
        let userListRef = usersRef.childByAppendingPath("\(userUID)/user_lists/\(listUID)")
        let userListData = ["time":String(NSDate().timeIntervalSince1970)]
        
        userListRef.updateChildValues(userListData)
    }
    
    func removeListFromUser(listUID: String, fromUser userUID: String)
    {
        let userListRef = usersRef.childByAppendingPath("\(userUID)/user_lists/\(listUID)")
        userListRef.removeValue()
    }
    
    
    //MARK: - History Handling
    
    func createHistoryItem(history: History)
    {
        let historyRef = historyItemsRef.childByAutoId()
        
        let historyData =
        ["item_name":history.itemName,
            "purchaser_UID":history.purchaserUID,
            "list_UID":history.listUID,
            "time":NSDate().timeIntervalSince1970,
            "UID":historyRef.key]
        
        historyRef.setValue(historyData) { (error:NSError!, snapshot:Firebase!) -> Void in
            guard error == nil else {
                self.makeHistoryItemDelegate?.connectionManagerDidFailToMakeHistoryItem()
                return
            }
            self.makeHistoryItemDelegate?.connectionManagerDidMakeHistoryItem()
        }
    }
    
    func deleteHistoryItem(historyUID: String)
    {
        let historyRef = historyItemsRef.childByAppendingPath(historyUID)
        
        let foundIndex = historyItems.indexOf { (history:History) -> Bool in
            if history.UID == historyUID {
                return true
            }
            return false
        }
        
        if let index = foundIndex {
            historyItems.removeAtIndex(index)
            historyRef.removeValue()
        }
        
    }
    
    func allHistoryItems() -> [History] {
        return historyItems
    }
    
    
    //MARK: - List Handling
    
    func createList(list: List)
    {
        let listRef = listsRef.childByAutoId()
        
        let listData =
        ["name":list.name,
         "UID":listRef.key]
        
        listRef.setValue(listData) { (error:NSError!, snapshot:Firebase!) -> Void in
            guard error == nil else {
                self.makeListDelegate?.connectionManagerDidFailToMakeList()
                return
            }
            self.makeListDelegate?.connectionManagerDidMakeList()
        }
    }
    
    func deleteList(listUID: String)
    {
        let listRef = listsRef.childByAppendingPath(listUID)
        
        let foundIndex = lists.indexOf { (list:List) -> Bool in
            if list.UID == listUID {
                return true
            }
            return false
        }
        
        if let index = foundIndex {
            historyItems.removeAtIndex(index)
            listRef.removeValue()
        }
        
    }
    
    func getListFor(listUID listUID: String) -> List?
    {
        var matchingList: List!
        
        for list in lists {
            if list.UID == listUID {
                matchingList = list
                break
            }
        }
        
        guard matchingList != nil
            else {
                Debug.log("No Such list")
                logout()
                return nil
        }
        
        return matchingList
    }

    
    func allLists() -> [History] {
        return historyItems
    }
    
    //MARK: - Member Handling
    
    func addMember(userUID: String, toList listUID: String)
    {
        let memberRef = listsRef.childByAppendingPath("\(listUID)/members/\(userUID)")
        let memberData = ["time":String(NSDate().timeIntervalSince1970)]
        
        memberRef.updateChildValues(memberData)
    }

    func deleteMember(userUID: String, fromList listUID: String)
    {
        let memberRef = listsRef.childByAppendingPath("\(listUID)/members/\(userUID)")
        memberRef.removeValue()
    }
    
    //MARK: - Item Handling
    
    func addItem(name: String, toList listUID: String)
    {
        let itemRef = listsRef.childByAppendingPath("\(listUID)/items/").childByAutoId()
        
        let itemData = ["name":name,
                        "UID":itemRef.key]
        
        itemRef.setValue(itemData)
    }
    
    func deleteItem(itemUID: String, fromList listUID: String)
    {
        let itemRef = listsRef.childByAppendingPath("\(listUID)/items/\(itemUID)")
        
        itemRef.removeValue()
        
    }
    
    //MARK: - Comment Handling
    
    
    func addComment(comment: String, toItem itemUID: String, onList listUID: String)
    {
        let listCommentRef = listsRef.childByAppendingPath("\(listUID)/items/\(itemUID)/comments/").childByAutoId()
        
        let metaData = ["UID":listCommentRef.key,
                        "comment":comment,
                        "time":NSDate().timeIntervalSince1970,
                        "user_UID":selfUserUID]
        
        listCommentRef.setValue(metaData)
    }
    
    func deleteComment(commentUID: String, fromItem itemUID: String, onList listUID: String)
    {
        let listCommentRef = listsRef.childByAppendingPath("\(listUID)/items/\(itemUID)/comments/\(commentUID)")
        
        listCommentRef.removeValue()
    }
    
    //MARK: - Essential Handling
    
    func markAsEssential(itemUID: String, onList listUID: String)
    {
        let listItemEssentialRef = listsRef.childByAppendingPath("\(listUID)/items/\(itemUID)")
        let essentialData = ["Essential":"true"]
        
        listItemEssentialRef.setValue(essentialData)
    }
    
    func unmarkEssential(itemUID: String, fromList listUID: String)
    {
        let listItemEssentialRef = listsRef.childByAppendingPath("\(listUID)/items/\(itemUID)")
        let essentialData = ["Essential":"false"]
        
        listItemEssentialRef.setValue(essentialData)
    }
    
    
    //MARK: - Internal Functions
    
    init() {
        print("Connection Manager Started")
        usersRef = rootRef.childByAppendingPath("Users")
        listsRef = rootRef.childByAppendingPath("Lists")
        historyItemsRef = rootRef.childByAppendingPath("history_items")
        authData = rootRef.authData
        setupListeners()
        getAllUsers()
        testCode()
    }
    
    private func setupListeners() {
        
        
        //MARK: User Observers
        
        usersRef.observeEventType(.ChildChanged) { (snapshot:FDataSnapshot!) -> Void in
            
            let userData = snapshot.value as! [String:AnyObject]
            
            let updatedUser = self.unpackUser(userData)
            
            if let foundIndex = self.users.indexOf({ $0.UID == updatedUser.UID }) {
                self.users.removeAtIndex(foundIndex)
                self.users.insert(updatedUser, atIndex: foundIndex)
            }
        }
        
        usersRef.observeEventType(.ChildAdded) { (snapshot:FDataSnapshot!) -> Void in
            
            let userData = snapshot.value as! [String:AnyObject]
            
            let newUser = self.unpackUser(userData)
            
            self.users.append(newUser)
            
        }
        
        usersRef.observeEventType(.ChildRemoved) { (snapshot:FDataSnapshot!) -> Void in
            
            let userData = snapshot.value as! [String:AnyObject]
            
            let updatedUser = self.unpackUser(userData)
            
            if let foundIndex = self.users.indexOf({ $0.UID == updatedUser.UID }) {
                self.users.removeAtIndex(foundIndex)
            }
        }
        
        
        //MARK: List Observers
        
        
        listsRef.observeEventType(.ChildChanged) { (snapshot:FDataSnapshot!) -> Void in
            
            let listData = snapshot.value as! [String:AnyObject]
            
            let updatedList = self.unpackList(listData)
            
            if let foundIndex = self.lists.indexOf({ $0.UID == updatedList.UID }) {
                self.lists.removeAtIndex(foundIndex)
                self.lists.insert(updatedList, atIndex: foundIndex)
            }
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                self.listChangedDelegate?.connectionManagerListWasChanged(updatedList)
            })
        }
        
        listsRef.observeEventType(.ChildAdded) { (snapshot:FDataSnapshot!) -> Void in
            
            let listData = snapshot.value as! [String:AnyObject]
            
            let newList = self.unpackList(listData)
            
            self.lists.append(newList)
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                self.listChangedDelegate?.connectionManagerListWasAdded(newList)
            })
        }
        
        listsRef.observeEventType(.ChildRemoved) { (snapshot:FDataSnapshot!) -> Void in
            
            let listData = snapshot.value as! [String:AnyObject]
            
            let removedList = self.unpackList(listData)
            
            self.deleteList(removedList.UID)
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.listChangedDelegate?.connectionManagerListWasDeleted(removedList)
            })
            
        }
        
        //MARK: HistoryItem Observers
        
        
        historyItemsRef.observeEventType(.ChildChanged) { (snapshot:FDataSnapshot!) -> Void in
            
            let historyItemData = snapshot.value as! [String:AnyObject]
            
            let updatedHistoryItem = self.unpackHistoryItem(historyItemData)
            
            if let foundIndex = self.historyItems.indexOf({ $0.UID == updatedHistoryItem.UID }) {
                self.historyItems.removeAtIndex(foundIndex)
                self.historyItems.insert(updatedHistoryItem, atIndex: foundIndex)
            }
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
//                self.historyItemChangedDelegate?.connectionManagerHistoryItemWasChanged(updatedHistoryItem)
            })
        }
        
        historyItemsRef.observeEventType(.ChildAdded) { (snapshot:FDataSnapshot!) -> Void in
            
            let historyItemData = snapshot.value as! [String:AnyObject]
            
            let newHistoryItem = self.unpackHistoryItem(historyItemData)
            
            self.historyItems.append(newHistoryItem)
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
//                self.historyItemChangedDelegate?.connectionManagerHistoryItemWasAdded(newHistoryItem)
            })
        }
        
        historyItemsRef.observeEventType(.ChildRemoved) { (snapshot:FDataSnapshot!) -> Void in
            
            let historyItemData = snapshot.value as! [String:AnyObject]
            
            let removedHistoryItem = self.unpackHistoryItem(historyItemData)
            
            self.deleteHistoryItem(removedHistoryItem.UID)
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                self.historyItemChangedDelegate?.connectionManagerHistoryItemWasDeleted(removedHistoryItem)
            })
            
        }

        
        
        
        
    }
    
    private func unpackList(listData: [String:AnyObject]) -> List {
        let newList = List()
        
        newList.UID         = listData["UID"] as! String
        newList.name        = listData["name"] as! String
        
        if let members = listData["members"] as? [String:[String:String]]
        {
            for member in members
            {
                newList.members.append(Member(time: member.1["time"]!, userUID: member.0))
            }
        }
        
        if let items = listData["items"] as? [String:AnyObject]
        {
            for item in items
            {
                let newItem = self.unpackItem([item.0:item.1])
                newList.items.append(newItem)
            }
        }
               
        return newList
    }
    
    private func unpackItem(itemData: [String:AnyObject]) -> Item
    {
        var newItem = Item()
        
        newItem.UID         = itemData["UID"] as! String
        newItem.name        = itemData["name"] as! String
        if let essential = itemData["essential"] as? String
        {
            newItem.essential = essential
        }
        
        if let comments = itemData["comments"] as? [String:AnyObject]
        {
            for comment in comments
            {
                let time = comment.1["time"] as! Double
                let message = comment.1["comment"] as! String
                let userUID = comment.1["user_UID"] as! String
                
                let UID = comment.0
                
                newItem.comments.append(Comment(time: time, userUID: userUID, message: message, UID: UID))
            }
        }
        
        return newItem
    }

    
    private func unpackUser(userData: [String:AnyObject]) -> User {
        
        let username = userData["username"] as! String
        let email = userData["email"] as! String
        let imageName = userData["image_name"] as! String
        let newUser = User(username: username, email: email, imageName: imageName)
        
        newUser.UID = userData["UID"] as! String
        
        if let userLists = userData["user_lists"] as? [String:[String:String]]
        {
            for userList in userLists
            {
                newUser.userLists.append(UserList(time: userList.1["time"]!, listUID: userList.0))
            }
        }
        
        return newUser
    }
    
    private func unpackHistoryItem(historyData: [String:AnyObject]) -> History {
        
        let itemName = historyData["item_name"] as! String
        let purchaserUID = historyData["purchaser_UID"] as! String
        let listUID = historyData["list_UID"] as! String
        let time = historyData["time"] as! Double
        let newHistoryItem = History(itemName: itemName, purchaserUID: purchaserUID, listUID: listUID, time: time)
        
        newHistoryItem.UID = historyData["UID"] as! String
        
        return newHistoryItem
    }

    private func getAllUsers()
    {
        users = []
        
        usersRef.observeSingleEventOfType(.Value) { (snapshot:FDataSnapshot!) -> Void in
            
            let keys = snapshot.value.allKeys as! [String]
            
            var allUsers = [User]()
            
            for key in keys
            {
                
                guard let userData = snapshot.value.objectForKey(key) as? [String:AnyObject]
                    else { Debug.log("Invalid user in database"); break }
                
                let newUser = self.unpackUser(userData)
                
                allUsers.append(newUser)
            }
        }
    }
    
    
    private func getAllLists()
    {
        listsRef.observeSingleEventOfType(.Value) { (snapshot:FDataSnapshot!) -> Void in
            
            let keys = snapshot.value.allKeys as! [String]
            
            var allLists = [List]()
            
            for key in keys
            {
                
                guard let listData = snapshot.value.objectForKey(key) as? [String:AnyObject]
                    else { Debug.log("Invalid list in database"); break }
                
                let newList = self.unpackList(listData)
                
                allLists.append(newList)
            }
        }
    }
    
    
    
    // TODO: deleteme
    func testCode() {
        
    }
    
}