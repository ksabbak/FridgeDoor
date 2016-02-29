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

protocol ConnectionManagerGetUserDelegate {
    func connectionManagerDidGetUser(user: User)
    func connectionManagerDidFailToGetUser()
}

protocol ConnectionManagerGetListDelegate {
    func connectionManagerDidGetList(list: List)
    func connectionManagerDidFailToGetList()
}

protocol ConnectionManagerGetUserAndUpdateListsDelegate {
    func connectionManagerDidGetUserAndUpdateLists(user: User)
    func connectionManagerDidFailToGetUserAndUpdateLists()
}

protocol ConnectionManagerGetListAndUpdateUsersDelegate {
    func connectionManagerDidGetListAndUpdateUsers(list: List)
    func connectionManagerDidFailToGetListAndUpdateUsers()
}

protocol ConnectionManagerLogInUserDelegate {
    func connectionManagerDidLogInUser()
    func connectionManagerDidFailToLogInUser(error: NSError)
}

protocol ConnectionManagerAddListToUserDelegate {
    func connectionManagerDidAddListToUser()
    func connectionManagerDidFailToAddListToUser()
}

protocol ConnectionManagerAddMemberDelegate {
    func connectionManagerDidAddMember()
    func connectionManagerDidFailToAddMember()
}

protocol ConnectionManagerAddItemDelegate {
    func connectionManagerDidAddItem()
    func connectionManagerDidFailToAddItem()
}

protocol ConnectionManagerAddHistoryItemDelegate {
    func connectionManagerDidAddHistoryItem()
    func connectionManagerDidFailToAddHistoryItem()
}

protocol ConnectionManagerMakeListDelegate {
    func connectionManagerDidMakeList(list: List)
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

protocol ConnectionManagerGetAllUsersDelegate {
    func connectionManagerDidGetAllUsers(users:[User])
    func connectionmanagerDidFailToGetAllUsers()
}

protocol ConnectionManagerSetUpCurrentUserDelegate {
    func connectionManagerDidSetUpCurrentUser(currentUser:User)
    func connectionmanagerDidFailToSetUpCurrentUser()
}

protocol ConnectionManagerPopulateUsersArrayDelegate {
    func connectionManagerDidPopulateUsersArray(currentUser:User)
    func connectionmanagerDidFailToPopulateUsersArray()
}

protocol ConnectionManagerGetAllHistoryItemsDelegate {
    func connectionManagerDidGetAllHistoryItems(historyItems:[History])
    func connectionmanagerDidFailToGetAllHistoryItems()
}

protocol ConnectionManagerListChangesDelegate {
//    func connectionManagerListWasAdded(list: List)
//    func connectionManagerListWasDeleted(list: List)
    func connectionManagerListWasChanged(list: List)
}

protocol ConnectionManagerUserChangesDelegate {
//    func connectionManagerUserWasAdded(user: User)
//    func connectionManagerUserWasDeleted(user: User)
    func connectionManagerUserWasChanged(user: User)
}

protocol ConnectionManagerHistoryItemChangesDelegate {
    func connectionManagerHistoryItemWasAdded(historyItem: History)
    func connectionManagerHistoryItemWasDeleted(historyItem: History)
    func connectionManagerHistoryItemWasChanged(historyItem: History)
}

protocol ConnectionManagerLogOutDelegate {
    func connectionManagerDidLogOut()
}

protocol ConnectionManagerCommentCreatedDelegate {
    func connectionManagerDidSetUpComment(comments: [Comment])
    func connectionmanagerDidFailToSetUpComment()
}

protocol ConnectionManagerItemChangedDelegate {
    func connectionManagerItemWasChanged(item: Item)
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
    var getListDelegate:     ConnectionManagerGetListDelegate?
    var createUserDelegate:  ConnectionManagerCreateUserDelegate?
    var logInUserDelegate:   ConnectionManagerLogInUserDelegate?
    var makeListDelegate:    ConnectionManagerMakeListDelegate?
    var deleteListDelegate:  ConnectionManagerDeleteListDelegate?
    var getAllListsDelegate: ConnectionManagerGetAllListsDelegate?
    var getAllUsersDelegate: ConnectionManagerGetAllUsersDelegate?
    var listChangedDelegate: ConnectionManagerListChangesDelegate?
    var userChangedDelegate: ConnectionManagerUserChangesDelegate?
    var logoutDelegate:      ConnectionManagerLogOutDelegate?
    var addMemberDelegate:   ConnectionManagerAddMemberDelegate?
    var addItemDelegate:     ConnectionManagerAddItemDelegate?
    var addHistoryItemDelegate: ConnectionManagerAddHistoryItemDelegate?
    var addListToUserDelegate: ConnectionManagerAddListToUserDelegate?
    var populateUsersArrayDelegate: ConnectionManagerPopulateUsersArrayDelegate?
    var setupCurrentUserDelegate: ConnectionManagerSetUpCurrentUserDelegate?
    var getAllHistoryItemsDelegate: ConnectionManagerGetAllHistoryItemsDelegate?
    var historyItemsChangedDelegate:  ConnectionManagerHistoryItemChangesDelegate?
    var getUserAndUpdateListsDelegate: ConnectionManagerGetUserAndUpdateListsDelegate?
    var getListAndUpdateUsersDelegate: ConnectionManagerGetListAndUpdateUsersDelegate?
    var commentCreatedDelegate: ConnectionManagerCommentCreatedDelegate?
    var itemChangedDelegate: ConnectionManagerItemChangedDelegate?
    
    private
    
    let rootRef = Firebase(url:"fridgedoor.firebaseIO.com")
    var usersRef: Firebase!
    var listsRef: Firebase!
    var requestsRef: Firebase!
    var historyItemsRef: Firebase!
    var authData: FAuthData?
    
    
    
    var userData: User?
    
    var currentListMemberUIDs: [String] = []
    var currentUserListUIDs: [String] = []
    
    private var currentUser: User?
    private var users: [User] = []
    private var lists: [List] = []
    private var historyItems: [History] = []
    
    private var selfUserUID: String
    {
        return userUID()!
    }
    
    //MARK: - Public Functions
    
    
    //MARK: - User handling
    
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
        print("We are legion: \(users.count)")
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
            
            self.checkFloatingPendingRequestsFor(newUserEmail: user.email, completion: { (list, fromUser) -> () in
                if list.characters.count > 0
                {
                    self.setPendingRequest(fromUser, toUID: user.UID, forList: list)
                }
            })
            
            
            let newUserRef = self.usersRef.childByAppendingPath(uid)
            
            user.UID = uid
            
            let userData: [String:String] =
            ["image_name":user.imageName,
                "username":user.username,
                "UID":user.UID,
                "email":user.email]
            
            newUserRef.setValue(userData)
            
            self.logInUser(user.email, password: password)
            print("A")
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                self.createUserDelegate?.connectionManagerDidCreateUser(user)
                print("B")
                
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
    
    
    
    func setupCurrentUser()
    {
        let userUID = self.userUID()
        print("userUID: \(userUID!)")
        let thisUserRef = usersRef.childByAppendingPath("\(userUID!)")
        thisUserRef.observeSingleEventOfType(.Value) { (snapshot:FDataSnapshot!) -> Void in
            
            guard let userData = snapshot.value as? [String:AnyObject]
                else { Debug.log("Invalid user in database"); return}
            
            let user = self.unpackUser(userData)
            self.currentUser = user
            
            if self.currentUser != nil
            {
                self.setupCurrentUserDelegate?.connectionManagerDidSetUpCurrentUser(user)
            }
            else
            {
                self.setupCurrentUserDelegate?.connectionmanagerDidFailToSetUpCurrentUser()
            }
        }
    }
    
    func getUserFor(userUID userUID: String) -> User?
    {
        
        var matchingUser: User!
        
        print("Check users array: \(self.users)")
        for user in self.users
        {
            if user.UID == userUID
            {
                matchingUser = user
                break
            }
        }
        
        guard matchingUser != nil
            else {
                Debug.log("No Such user")
                logout()
                self.getUserDelegate?.connectionManagerDidFailToGetUser()
                return nil
        }
        
        self.getUserDelegate?.connectionManagerDidGetUser(matchingUser)
        return matchingUser
    }
    
    ///Returns a user in the completion block
    func getUserFor(userUID: String, completion: (User) -> Void)
    {
        let matchingUser: User!
        
        print("Check users array: \(self.users.count)")
        for user in self.users
        {
            if user.UID == userUID
            {
                matchingUser = user
                completion(matchingUser)
                break
            }
        }
    }
    
    func allUsers() -> [User] {
        return users
    }
    
    func addListToUser(listUID: String, toUser userUID: String)
    {
        let userListRef = usersRef.childByAppendingPath("\(userUID)/user_lists/\(listUID)")
        let userListData = ["time":String(NSDate().timeIntervalSince1970)]
        
        userListRef.updateChildValues(userListData) { (error:NSError!, snapshot:Firebase!) -> Void in
            guard error == nil else {
                self.addListToUserDelegate?.connectionManagerDidFailToAddListToUser()
                return
            }
            self.addListToUserDelegate?.connectionManagerDidAddListToUser()
        }
    }
    
    func removeListFromUser(listUID: String, fromUser userUID: String)
    {
        let userListRef = usersRef.childByAppendingPath("\(userUID)/user_lists/\(listUID)")
        userListRef.removeValue()
    }
    
    
    //MARK: - List Handling
    
    func createListReturnListUID(list: List) -> String
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
            
            listRef.observeSingleEventOfType(.Value) { (snapshot:FDataSnapshot!) -> Void in
                
                guard let listData = snapshot.value as? [String:AnyObject]
                    else { Debug.log("Invalid list in database"); return}
                
                let list = self.unpackList(listData)
                self.makeListDelegate?.connectionManagerDidMakeList(list)
            }

        }
        return listRef.key
    }
    
    
    ///Deletes a list entirely
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
            lists.removeAtIndex(index)
            listRef.removeValue()
        }
        
    }
    
    ///Returns the List corresponding with the listUID that a user is a member of.
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
                self.getListDelegate?.connectionManagerDidFailToGetList()
                return nil
        }
        self.getListDelegate?.connectionManagerDidGetList(matchingList)
        return matchingList
    }
    
    
    
    
    ///Grabs from ALL the lists from the backend, not just the one the current user is part of.
    func getListFromAllListsFor(listUID: String, completion: (List) -> Void)
    {
        
        //listsRef.observeSingleEventOfType(.Value) { (snapshot:FDataSnapshot!) -> Void in
        listsRef.observeEventType(.Value) { (snapshot: FDataSnapshot!) -> Void in
            
            let keys = snapshot.value.allKeys as! [String]
            
            for key in keys
            {
                print("this is a key: \(key)")
                if key == listUID
                {
                    let listData = snapshot.value.objectForKey(key) as? [String:AnyObject]
                    
                    let returnList = self.unpackList(listData!)
                    
                    completion(returnList)
                    return
                }
            }
        }
    }

    

//    func getListForAndUpdateListUsers(listUID listUID: String) -> List?
//    {
//        var matchingList: List!
//        
//        for list in lists {
//            if list.UID == listUID {
//                matchingList = list
//                break
//            }
//        }
//        
//        guard matchingList != nil
//            else {
//                Debug.log("No Such list")
//                logout()
//                self.getListAndUpdateUsersDelegate?.connectionManagerDidFailToGetListAndUpdateUsers()
//                return nil
//        }
//        self.getListAndUpdateUsersDelegate?.connectionManagerDidGetListAndUpdateUsers(matchingList)
//        return matchingList
//    }

    
    func allLists() -> [List] {
        return lists
    }
    
    //MARK: - History Item Handling
    
    func addHistoryItem(item: Item, toList listUID: String, purchasedBy userUID: String)
    {
        let historyRef = listsRef.childByAppendingPath("\(listUID)/history_items/").childByAutoId()
        
        let historyData =
        ["item_name":item.name,
            "item_UID": item.UID,
            "purchaser_UID":userUID,
            "list_UID":listUID,
            "time":NSDate().timeIntervalSince1970,
            "UID":historyRef.key]
        
        historyRef.setValue(historyData) { (error:NSError!, snapshot:Firebase!) -> Void in
            guard error == nil else {
                self.addHistoryItemDelegate?.connectionManagerDidFailToAddHistoryItem()
                return
            }
            self.addHistoryItemDelegate?.connectionManagerDidAddHistoryItem()
        }
    }
    
    func deleteHistoryItem(historyUID: String, fromList listUID: String)
    {
        let historyRef = listsRef.childByAppendingPath("\(listUID)/history_items/\(historyUID)")
        
        historyRef.removeValue()
        
    }
    
    func allHistoryItems() -> [History] {
        return historyItems
    }
    
    //MARK: - Member Handling
    
    func addMember(userUID: String, toList list: List)
    {
        let memberRef = listsRef.childByAppendingPath("\(list.UID)/members/\(userUID)")
        let memberData = ["time":String(NSDate().timeIntervalSince1970)]
        
        for item in list.items
        {
            if item.rotating == "true" || item.rotating == "false"
            {
                let rotateRef = listsRef.childByAppendingPath("\(list.UID)/items/\(item.UID)/Rotate")
                
                let placeInLine = item.rotate.count + 1
                let currentUserData = ["\(userUID)":"\(placeInLine)"]
                rotateRef.updateChildValues(currentUserData)
            }
        }
        
        memberRef.updateChildValues(memberData) { (error:NSError!, snapshot:Firebase!) -> Void in
            guard error == nil else {
                self.addMemberDelegate?.connectionManagerDidFailToAddMember()
                return
            }
            self.addMemberDelegate?.connectionManagerDidAddMember()
        }

    }

    func deleteMember(userUID: String, fromList list: List)
    {
        let memberRef = listsRef.childByAppendingPath("\(list.UID)/members/\(userUID)")
        memberRef.removeValue()
        for item in list.items
        {
            if item.rotating == "true" || item.rotating == "false"
            {
                let rotateRef = listsRef.childByAppendingPath("\(list.UID)/items/\(item.UID)/Rotate/\(userUID)")
                rotateRef.removeValue()
            }
        }
    }
    
    //MARK: - Item Handling
    
    func addItem(name: String, toList listUID: String)
    {
        let itemRef = listsRef.childByAppendingPath("\(listUID)/items/").childByAutoId()
        
        let itemData = ["name":name,
                        "UID":itemRef.key,
                        "Active":["active":"true"]
                        ]
        
        itemRef.setValue(itemData) { (error:NSError!, snapshot:Firebase!) -> Void in
            guard error == nil else {
                self.addItemDelegate?.connectionManagerDidFailToAddItem()
                return
            }
            self.addItemDelegate?.connectionManagerDidAddItem()
        }

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
        
        listCommentRef.setValue(metaData) { (error: NSError!, snapshot: Firebase!) -> Void in
            guard error == nil else {
                print("Comment not added")
                return
            }
            
            let listCommentsRef = self.listsRef.childByAppendingPath("\(listUID)/items/\(itemUID)/comments/")
            listCommentsRef.observeSingleEventOfType(.Value) { (snapshot:FDataSnapshot!) -> Void in
                
                guard let commentsData = snapshot.value as? [String:AnyObject]
                    else { Debug.log("Comment not yet in database"); return}
                
                let comments = self.unpackComments(commentsData)
                
                if comments.count > 0
                {
                    self.commentCreatedDelegate?.connectionManagerDidSetUpComment(comments)
                }
                else
                {
                    self.commentCreatedDelegate?.connectionmanagerDidFailToSetUpComment()
                }
            }

        }
    }
    
    func deleteComment(commentUID: String, fromItem itemUID: String, onList listUID: String)
    {
        let listCommentRef = listsRef.childByAppendingPath("\(listUID)/items/\(itemUID)/comments/\(commentUID)")
        
        listCommentRef.removeValue()
    }
    
    //MARK: - Active toggling
    
    func makeActive(itemUID: String, onList listUID: String)
    {
        let listItemStatusRef = listsRef.childByAppendingPath("\(listUID)/items/\(itemUID)/Active")
        let status = ["active":"true"]
        
        listItemStatusRef.setValue(status)
    }

    func makeActive(itemUID: String, onList listUID: String, completion: () -> Void)
    {
        let listItemStatusRef = listsRef.childByAppendingPath("\(listUID)/items/\(itemUID)/Active")
        let status = ["active":"true"]
        
        listItemStatusRef.setValue(status) { (error: NSError!, snapshot: Firebase!) -> Void in
            guard error == nil else {
                print("Active status not toggled. :(")
                return
            }
            
            completion()
        }
        
    }
    
    func makeInctive(itemUID: String, onList listUID: String, completion: () -> Void)
    {
        let listItemStatusRef = listsRef.childByAppendingPath("\(listUID)/items/\(itemUID)/Active")
        
        listItemStatusRef.removeValueWithCompletionBlock { (error: NSError!, snapshot:Firebase!) -> Void in
            guard error == nil else {
                print("Active status not toggled to inactive. :(")
                return
            }
            
            print("&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&")
            completion()
            
        }
    }
    
    func makeInactive(itemUID: String, onList listUID: String)
    {
        let listItemStatusRef = listsRef.childByAppendingPath("\(listUID)/items/\(itemUID)/Active")
        
        listItemStatusRef.removeValue()
    }
    
    //MARK: - Essential Handling
    
    func markAsEssential(itemUID: String, onList listUID: String)
    {
        let listItemEssentialRef = listsRef.childByAppendingPath("\(listUID)/items/\(itemUID)/Essential")
        let essentialData = ["essential":"true"]
        
        listItemEssentialRef.setValue(essentialData)
    }
    
    func unmarkEssential(itemUID: String, fromList listUID: String)
    {
        let listItemEssentialRef = listsRef.childByAppendingPath("\(listUID)/items/\(itemUID)/Essential")
        
        listItemEssentialRef.removeValue()
    }
    
    //MARK: - High Alert Handling
    
    func markAsHighAlert(itemUID: String, onList listUID: String)
    {
        let listItemHighAlertRef = listsRef.childByAppendingPath("\(listUID)/items/\(itemUID)/High_Alert")
        let highAlertData = ["high_alert":"true"]
        
        listItemHighAlertRef.setValue(highAlertData)
    }
    
    func unmarkHighAlert(itemUID: String, fromList listUID: String)
    {
        let listItemHighAlertRef = listsRef.childByAppendingPath("\(listUID)/items/\(itemUID)/High_Alert")
        
        listItemHighAlertRef.removeValue()
    }
    
    //MARK: - Volunteer Handling
    
    func volunteer(volunteerUID: String, forItem itemUID: String, onList listUID: String)
    {
        print("Volunteer Function fired")
        print("VolunteerUID: \(volunteerUID), itemUID: \(itemUID), listUID: \(listUID)")
        let listItemVolunteerRef = listsRef.childByAppendingPath("\(listUID)/items/\(itemUID)/Volunteer")
        let volunteerData = ["volunteerUID":"\(volunteerUID)"]
        
        listItemVolunteerRef.setValue(volunteerData)
    }
    
    func unvolunteer(volunteerUID: String, forItem itemUID: String, fromList listUID: String)
    {
        let listItemVolunteerRef = listsRef.childByAppendingPath("\(listUID)/items/\(itemUID)/Volunteer")
        
        listItemVolunteerRef.removeValue()
    }

    //MARK: - Rotate Handling
    
    func setUpRotatingItem(currentUserUID: String, itemUID: String, onList listUID: String, memberUIDsAndOrder: [String:String])
    {
        let rotateRef = listsRef.childByAppendingPath("\(listUID)/items/\(itemUID)/Rotate")
        
        let rotatingData = ["rotating":"true"]
        let currentUserData = ["\(currentUserUID)":"1"]
        
        rotateRef.setValue(rotatingData)
        rotateRef.updateChildValues(currentUserData)
        rotateRef.updateChildValues(memberUIDsAndOrder)
    }
    
    func rotatingOn(itemUID: String, onList listUID: String)
    {
        let rotateRef = listsRef.childByAppendingPath("\(listUID)/items/\(itemUID)/Rotate")
        let rotatingData = ["rotating":"true"]
        
        rotateRef.updateChildValues(rotatingData)
    }
    
    func rotatingOff(itemUID: String, onList listUID: String)
    {
        let rotateRef = listsRef.childByAppendingPath("\(listUID)/items/\(itemUID)/Rotate")
        let rotatingData = ["rotating":"false"]
        
        rotateRef.updateChildValues(rotatingData)
    }
    
    func rotate(item: Item, onList listUID: String)
    {
        let rotateRef = listsRef.childByAppendingPath("\(listUID)/items/\(item.UID)/Rotate")
        var userTurnArray = item.rotate
        userTurnArray.sortInPlace({ $0.turn < $1.turn })
        userTurnArray.append(userTurnArray.removeAtIndex(0))
        
        var memberDictionary = [String:String]()
        var i = 1
        for userTurn in userTurnArray
        {
            memberDictionary["\(userTurn.userTurnUID)"] = "\(i)"
            i = i + 1
        }
        
        rotateRef.updateChildValues(memberDictionary)
    }

    
    
    //MARK: - Internal Functions
    
    init()
    {
        print("Connection Manager Started")
        usersRef = rootRef.childByAppendingPath("/Users")
        listsRef = rootRef.childByAppendingPath("/Lists")
        requestsRef = rootRef.childByAppendingPath("/Pending")
        authData = rootRef.authData
//        setupListeners()
//        getAllUsers()
        testCode()
//        currentUser = getCurrentUser()
    }
    
    func setupListObservers(currentUser: User)
    {
        currentUserListUIDs.removeAll()
        for list in currentUser.userLists
        {
            let listUID = list.listUID
            currentUserListUIDs.append(listUID)
        }
        setupListListeners()
    }
    
    func setupMemberObservers(list: List)
    {
        currentListMemberUIDs.removeAll()
        for member in list.members
        {
            let memberUID = member.userUID
            currentListMemberUIDs.append(memberUID)
        }
        setupMemberListeners()
    }
    
    func setupItemObserver(itemUID: String, listUID: String)
    {
        print("Item Observer Fired")
        let thisItemRef = listsRef.childByAppendingPath("\(listUID)/items/\(itemUID)")
        thisItemRef.observeEventType(.Value) { (snapshot:FDataSnapshot!) -> Void in
            
            let itemData = snapshot.value as! [String:AnyObject]
            
            let updatedItem = self.unpackItem(itemData)
            
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                
                self.itemChangedDelegate?.connectionManagerItemWasChanged(updatedItem)
            })
        }
    }
    
    private func setupMemberListeners()
    {
        //MARK: Current User Observers
        
        for memberUID in currentListMemberUIDs
        {
            let thisUserRef = usersRef.childByAppendingPath("\(memberUID)")
            thisUserRef.observeEventType(.Value) { (snapshot:FDataSnapshot!) -> Void in
                
                let userData = snapshot.value as! [String:AnyObject]
                
                let updatedUser = self.unpackUser(userData)
                
                if let foundIndex = self.users.indexOf({ $0.UID == updatedUser.UID }) {
                    self.users.removeAtIndex(foundIndex)
                    self.users.insert(updatedUser, atIndex: foundIndex)
                }
                else
                {
                    self.users.append(updatedUser)
                }
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    self.userChangedDelegate?.connectionManagerUserWasChanged(updatedUser)
                })
            }
        }
        
//        usersRef.observeEventType(.ChildAdded) { (snapshot:FDataSnapshot!) -> Void in
//            
//            let userData = snapshot.value as! [String:AnyObject]
//            
//            let newUser = self.unpackUser(userData)
//            
//            self.users.append(newUser)
//            
//            dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                
//                self.userChangedDelegate?.connectionManagerUserWasAdded(newUser)
//            })
//            
//        }
//        
//        usersRef.observeEventType(.ChildRemoved) { (snapshot:FDataSnapshot!) -> Void in
//            
//            let userData = snapshot.value as! [String:AnyObject]
//            
//            let updatedUser = self.unpackUser(userData)
//            
//            if let foundIndex = self.users.indexOf({ $0.UID == updatedUser.UID }) {
//                self.users.removeAtIndex(foundIndex)
//            }
//            
//            dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                self.userChangedDelegate?.connectionManagerUserWasDeleted(updatedUser)
//            })
//        }
    }
    
    
    private func setupListListeners()
    {
        //MARK: Current List Observers
        
        for listUID in currentUserListUIDs
        {
            print("listUID in listeners: \(listUID)")
            let thisListRef = listsRef.childByAppendingPath("\(listUID)")
            thisListRef.observeEventType(.Value) { (snapshot:FDataSnapshot!) -> Void in
                
                let listData = snapshot.value as! [String:AnyObject]
                
                let updatedList = self.unpackList(listData)
                
                if let foundIndex = self.lists.indexOf({ $0.UID == updatedList.UID }) {
                    self.lists.removeAtIndex(foundIndex)
                    self.lists.insert(updatedList, atIndex: foundIndex)
                }
                else
                {
                    self.lists.append(updatedList)
                }
                
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    
                    print("A TROLL IN THE DUNGEON!!!!!!!!!!!!!!!")
                    self.listChangedDelegate?.connectionManagerListWasChanged(updatedList)
                })
            }
        }
        
//        listsRef.observeEventType(.ChildAdded) { (snapshot:FDataSnapshot!) -> Void in
//            
//            let listData = snapshot.value as! [String:AnyObject]
//            
//            let newList = self.unpackList(listData)
//            
//            self.lists.append(newList)
//            
//            dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                
//                self.listChangedDelegate?.connectionManagerListWasAdded(newList)
//            })
//        }
//        
//        listsRef.observeEventType(.ChildRemoved) { (snapshot:FDataSnapshot!) -> Void in
//            
//            let listData = snapshot.value as! [String:AnyObject]
//            
//            let removedList = self.unpackList(listData)
//            
//            self.deleteList(removedList.UID)
//            
//            dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                self.listChangedDelegate?.connectionManagerListWasDeleted(removedList)
//            })
//            
//        }
    }
    
        //MARK: HistoryItem Observers
        
        
//        historyItemsRef.observeEventType(.ChildChanged) { (snapshot:FDataSnapshot!) -> Void in
//            
//            let historyItemData = snapshot.value as! [String:AnyObject]
//            
//            let updatedHistoryItem = self.unpackHistoryItem(historyItemData)
//            
//            if let foundIndex = self.historyItems.indexOf({ $0.UID == updatedHistoryItem.UID }) {
//                self.historyItems.removeAtIndex(foundIndex)
//                self.historyItems.insert(updatedHistoryItem, atIndex: foundIndex)
//            }
//            
//            dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                
//                self.historyItemsChangedDelegate?.connectionManagerHistoryItemWasChanged(updatedHistoryItem)
//            })
//        }
//        
//        historyItemsRef.observeEventType(.ChildAdded) { (snapshot:FDataSnapshot!) -> Void in
//            
//            let historyItemData = snapshot.value as! [String:AnyObject]
//            
//            let newHistoryItem = self.unpackHistoryItem(historyItemData)
//            
//            self.historyItems.append(newHistoryItem)
//            
//            dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                
//                self.historyItemsChangedDelegate?.connectionManagerHistoryItemWasAdded(newHistoryItem)
//            })
//        }
//        
//        historyItemsRef.observeEventType(.ChildRemoved) { (snapshot:FDataSnapshot!) -> Void in
//            
//            let historyItemData = snapshot.value as! [String:AnyObject]
//            
//            let removedHistoryItem = self.unpackHistoryItem(historyItemData)
//            
//            self.deleteHistoryItem(removedHistoryItem.UID)
//            
//            dispatch_async(dispatch_get_main_queue(), { () -> Void in
//                self.historyItemsChangedDelegate?.connectionManagerHistoryItemWasDeleted(removedHistoryItem)
//            })
//            
//        }


    
    private func unpackList(listData: [String:AnyObject]) -> List
    {
        let name            = listData["name"] as! String
        let newList = List(name: name)
        
        newList.UID         = listData["UID"] as! String
        
        if let members = listData["members"] as? [String:[String:String]]
        {
            for member in members
            {
                newList.members.append(Member(time: member.1["time"]!, userUID: member.0))
            }
        }
        
        if let items = listData["items"] as? [String:[String:AnyObject]]
        {
            for item in items
            {
                let newItem = self.unpackItem(item.1)
                newList.items.append(newItem)
            }
        }
        
        if let historyItems = listData["history_items"] as? [String:AnyObject]
        {
            for historyItem in historyItems
            {
                if historyItem.0.characters.count > 0
                {
                    //print("Historyitem: \(historyItem)")
                let newHistoryItem = self.unpackHistoryItem([historyItem.0:historyItem.1])
                newList.historyItems.append(newHistoryItem)
                }
            }
        }
               
        return newList
    }
    
    private func unpackItem(itemData: [String:AnyObject]!) -> Item
    {
        let name            = itemData["name"] as! String
        var newItem = Item(name: name)
        
        newItem.UID         = itemData["UID"] as! String
        
        if let active = itemData["Active"] as? [String:String]
        {
            newItem.active  = active["active"]!
        }
        
        if let essential = itemData["Essential"] as? [String:String]
        {
            newItem.essential = essential["essential"]!
        }
        
        if let highAlert = itemData["High_Alert"] as? [String:String]
        {
            newItem.highAlert = highAlert["high_alert"]!
        }
        
        if let volunteer = itemData["Volunteer"] as? [String:String]
        {
            newItem.volunteerUID = volunteer["volunteerUID"]!
        }
        
        if let rotating = itemData["Rotate"] as? [String:String]
        {
            newItem.rotating = rotating["rotating"]!
            
            
            for key in rotating.keys
            {
                if key != "rotating"
                {
                    let userTurnUID = key
                    let userTurn = rotating["\(key)"]
                    newItem.rotate.append(UserTurn(userTurnUID: userTurnUID, turn: userTurn!))
                }
            }
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
    
    private func unpackComments(commentsData: [String:AnyObject]) -> [Comment]
    {
        var comments = [Comment]()
            for comment in commentsData
            {
                let time = comment.1["time"] as! Double
                let message = comment.1["comment"] as! String
                let userUID = comment.1["user_UID"] as! String
                
                let UID = comment.0
                
                let newComment = Comment(time: time, userUID: userUID, message: message, UID: UID)
                comments.append(newComment)
            }
        
        return comments
    }

    private func unpackHistoryItem(historyData: [String:AnyObject]) -> History
    {
        
        let historyUID = historyData.keys.first!
        
        let historyDictionary = historyData[historyUID] as! [String:AnyObject]
        
        let itemName = historyDictionary["item_name"] as! String
        let itemUID = historyDictionary["item_UID"] as! String
        let purchaserUID = historyDictionary["purchaser_UID"] as! String
        let listUID = historyDictionary["list_UID"] as! String
        let time = historyDictionary["time"] as! Double
        var newHistoryItem = History(itemName: itemName, itemUID: itemUID, purchaserUID: purchaserUID, listUID: listUID, time: time)
        
        newHistoryItem.UID = historyUID
        
        return newHistoryItem
    }
    
//    func getCurrentUser() -> User
//    {
//        let currentUser = self.getUserFor(userUID: self.userUID()!)
//        return currentUser!
//    }

    private func unpackUser(userData: [String:AnyObject]) -> User
    {
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
        
        if let pending = userData["Pending"] as? [String:[String:String]]
        {
            print("PENDING!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n\(pending)")
            
            for request in pending
            {
                var pendingDictionary = request.1
                pendingDictionary["pending"] = request.0
                newUser.pending.append(pendingDictionary)
            }
        }
        
        return newUser
    }
    
//    func populateUsersArray()
//    {
//        print("populateUsersArray called")
//        
//        usersRef.observeSingleEventOfType(.Value) { (snapshot:FDataSnapshot!) -> Void in
//            print("\(snapshot.value.allKeys)")
//            let keys = snapshot.value.allKeys as! [String]
//            
//            var allUsers = [User]()
//            
//            for key in keys
//            {
//                
//                guard let userData = snapshot.value.objectForKey(key) as? [String:AnyObject]
//                    else { Debug.log("Invalid user in database"); break }
//                
//                let newUser = self.unpackUser(userData)
//                
//                allUsers.append(newUser)
//            }
//            print("Users array count before fire: \(self.users.count)")
//            if self.users.count > 0
//            {
//                let currentUser = self.getCurrentUser()
//                print("Current user: \(currentUser)")
//                print("should fire populate users delegate")
//                self.populateUsersArrayDelegate?.connectionManagerDidPopulateUsersArray(currentUser)
//            }
//            else
//            {
//                self.populateUsersArrayDelegate?.connectionmanagerDidFailToPopulateUsersArray()            }
//        }
//    }

    
    private func getAllUsers()
    {
        print("getAllUsers called")
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
            if self.users.count > 0
            {
                self.getAllUsersDelegate?.connectionManagerDidGetAllUsers(self.users)
            }
            else
            {
                self.getAllUsersDelegate?.connectionmanagerDidFailToGetAllUsers()
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
            if allLists.count > 0
            {
                self.getAllListsDelegate?.connectionManagerDidGetAllLists(allLists)
            }
            else
            {
                self.getAllListsDelegate?.connectionmanagerDidFailToGetAllLists()
            }
        }
    }
    
    
    //MARK: - Regarding Pending Requests
    
    
    ///For floating requests - the requested user doesn't exist yet
    func setPendingRequest(fromUID: String, toEmail: String, forList: String)
    {
        let requestData =
        ["from":fromUID,
            "to":toEmail,
        "onList":forList]
        
        let requestRef = requestsRef.childByAutoId()
        
        requestRef.setValue(requestData) { (error:NSError!, snapshot:Firebase!) -> Void in
            guard error == nil else {
                print("A floating request error occurred: \(error)")
                return
            }
        }
    }
    
    ///For request to users that already have an account
    func setPendingRequest(fromUID: String, toUID: String, forList: String)
    {
        let newRef = self.usersRef.childByAppendingPath("/\(fromUID)/username/")
        newRef.observeSingleEventOfType(.Value, withBlock: { (snap:FDataSnapshot!) -> Void in
            
            let requestData =
            ["from":snap.value,
            "forList":forList]
            
            
            let firstRef = self.usersRef.childByAppendingPath("/\(toUID)/Pending")
            let requestRef = firstRef.childByAutoId()
            print(requestRef)
            
            requestRef.setValue(requestData)
        })
    }
    
    
    
    ///Checks an email against all possible users to see if the user already exists. If yes, the completion block will return the userUID for email's user, if not the completion block will return an empty string.
    func checkEmailAgainstExistingUsers(email: String, completion: (success: String) -> Void)
    {
        
        print("USERS REF: \(usersRef)")
        usersRef.observeSingleEventOfType(.Value) { (snapshot: FDataSnapshot!) -> Void in
            let keys = snapshot.value.allKeys
            
            var noEmailExistsCount = 0
            for key in keys
            {
                let newRef = self.usersRef.childByAppendingPath("/\(key)/email/")
                newRef.observeSingleEventOfType(.Value, withBlock: { (snap:FDataSnapshot!) -> Void in
                    

                    if snap.value as! String == email
                    {
                        completion(success: key as! String)
                        return
                    }
                    
                    //BE VERY CAREFUL WITH THIS PLACEMENT
                    noEmailExistsCount++                     //This can only be incremented AFTER a possible return statement.
                    
                    if noEmailExistsCount == keys.count
                    {
                        completion(success: "") //This will only be called once we go through the FULL list and no one is found.
                    }
                })
            }
        }
    }
    
    ///Deletes pending request
    func deletePending(userUID: String, pendingUID: String)
    {
        let pendingRef = usersRef.childByAppendingPath("\(userUID)/Pending/\(pendingUID)")
    
        pendingRef.removeValue()
    }
    
    ///Checks if the invited user is already a list member
    func checkUser(userUID: String, againstExistingList listUID: String, completion: (doesExist: Bool) -> ())
    {
        let checkRef = self.usersRef.childByAppendingPath("/\(userUID)/user_lists/")
        
        var noListExistsCount = 0
        
        checkRef.observeSingleEventOfType(.Value, withBlock: { (snapshot:FDataSnapshot!) -> Void in
            for snap in snapshot.value.allKeys
            {
                if snap as! String == listUID
                {
                    print("We did find a matching list")
                    completion(doesExist: true)
                    return
                }
                
                //BE VERY CAREFUL WITH THIS PLACEMENT
                noListExistsCount++                     //This can only be incremented AFTER a possible return statement.
                
                if noListExistsCount == snapshot.value.allKeys.count
                {
                    print("We did not find a matching list")
                    completion(doesExist: false) //This will only be called once we go through the FULL list and the list isn't found.
                }
            }
        })
    }

    //I mean there's no reason for this to be private except that there's no reason for it to be public if it's only called in the connection manager.
    private func checkFloatingPendingRequestsFor(newUserEmail email: String, completion: (list: String, fromUser: String) -> ())
    {
        let checkRef = self.rootRef.childByAppendingPath("/Pending")
        
        checkRef.observeSingleEventOfType(.Value, withBlock: { (snapshot:FDataSnapshot!) -> Void in
            let keys = snapshot.value.allKeys
            
            
            
            var noEmailExistsCount = 0
            for key in keys
            {
                let newRef = checkRef.childByAppendingPath("/\(key)/")
                newRef.observeSingleEventOfType(.Value, withBlock: { (snap:FDataSnapshot!) -> Void in
                    
                    print("This is the snap.value: \(snap.value)")
                    print("This is teh key: \(key)")
                    let pendingDictionary = snap.value as! [String:String]
                    
                    
                    if pendingDictionary["to"] == email
                    {
                        completion(list: pendingDictionary["onList"]!, fromUser: pendingDictionary["from"]!)
                        return
                    }
                    
                    //BE VERY CAREFUL WITH THIS PLACEMENT
                    noEmailExistsCount++                     //This can only be incremented AFTER a possible return statement.
                    
                    if noEmailExistsCount == keys.count
                    {
                        completion(list: "", fromUser: "") //This will only be called once we go through the FULL list and no one is found.
                    }
                })
            }
        })

    }
    
    
    // TODO: deleteme
    func testCode()
    {
        
    }
    
}