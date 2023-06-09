//
//  ConversationsController.swift
//  ChatApp
//
//  Created by YE002 on 31/05/23.
//

import UIKit
import Firebase
private let reuseIdentifier = "ConversationCell"

class ConversationsController : UIViewController {
   
    //MARK: - Properties
    private let tableView = UITableView()
    private var conversations = [Conversation]()
    private var conversationsDictionary = [String: Conversation]()
    
    private let newMessegeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.backgroundColor = .systemPurple
        button.tintColor = .white
        button.imageView?.setDimensions(height: 24, width: 24)
        button.addTarget(self, action: #selector(showNewMessage), for: .touchUpInside )
        return button
    }()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        authenticateUser()
        fetchConversations()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configureNavigationBar(withTitle: "Messages", prefersLargeTitles: true)

    }
    
    //MARK: - Selectors
    
    @objc func showProfile(){
       // let controller = ProfileController()
        let controller = ProfileController(style: .insetGrouped)
        controller.delegate = self
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
        
    }
    
    @objc func showNewMessage(){

        let controller = NewMessageController()
        controller.delegate = self
        let nav = UINavigationController(rootViewController: controller)
        nav.modalPresentationStyle = .fullScreen
        present(nav, animated: true, completion: nil)
        
    }
    
    
    //MARK: - API
    
    func fetchConversations(){
        showLoader(true)
        
        Service.fetchConversation { conversations in
                        
            conversations.forEach { conversation in
                let message = conversation.message
                self.conversationsDictionary[message.chatpartnerId] = conversation
            }
            
            self.showLoader(false)
 
            self.conversations = Array(self.conversationsDictionary.values)
            self.tableView.reloadData()
        }
    }
    
    func authenticateUser(){
        if Auth.auth().currentUser?.uid == nil {
            print("DEBUG: User is not logged in, present Login Screen here")
            presentLoginScreen()
        }
    }
    
    func logout(){
        do{
            try Auth.auth().signOut()
            presentLoginScreen()
        }catch{
            print("DEBUG: Error signing out..")
        }
    }
    
    
    //MARK: - Helpers
    
    func presentLoginScreen(){
        DispatchQueue.main.async {
            let controller = LoginController()
            controller.delegate = self
            let nav = UINavigationController(rootViewController: controller)
            nav.modalPresentationStyle = .fullScreen
            self.present(nav, animated: true, completion: nil)
        }
    }
    
    func configureUI(){
        view.backgroundColor = .white
        
        configureTableView()
        
        let image = UIImage(systemName: "person.circle.fill")
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(showProfile))
        
        view.addSubview(newMessegeButton)
        newMessegeButton.setDimensions(height: 56, width: 56)
        newMessegeButton.layer.cornerRadius = 56 / 2
        
        newMessegeButton.anchor(bottom: view.safeAreaLayoutGuide.bottomAnchor , right: view.rightAnchor ,
                                paddingBottom: 16 , paddingRight: 24)
    }
    
    func configureTableView(){
        tableView.backgroundColor = .white
        tableView.rowHeight = 80
        tableView.register(ConversationCell.self, forCellReuseIdentifier: reuseIdentifier)
        tableView.tableFooterView = UIView()
       
        tableView.delegate = self
        tableView.dataSource = self
        
        view.addSubview(tableView)
        tableView.frame = view.frame
    }
    
    func showChatController(forUser user: User){
        let controller = ChatController(user: user)
        navigationController?.pushViewController(controller, animated: true)
    }
}


extension ConversationsController : UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier , for: indexPath) as! ConversationCell
        
        cell.conversation = conversations[indexPath.row]
        
        return cell
    }
    
    
}

extension ConversationsController : UITableViewDelegate{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = conversations[indexPath.row].user
        showChatController(forUser: user)
    }
}


//MARK: - NewMessageControllerDelegate

extension ConversationsController : NewMessageControllerDelegate {
    func controller(_ controller: NewMessageController, wantsToStartChatWith user: User) {
        print("user in conversation is \(user.username)")
        dismiss(animated: true, completion: nil)
        showChatController(forUser: user)
    }
}


extension ConversationsController : ProfileControllerDelegate {
    func handleLogout() {
        logout()
    }
    
    
}

extension ConversationsController: AuthenticationDelegate {
    func authenticationComplete() {
        dismiss(animated: true, completion: nil)
        configureUI()
        fetchConversations()
    }
}
