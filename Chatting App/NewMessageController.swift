//
//  NewMessageController.swift
//  Chatting App
//
//  Created by Raju on 7/24/18.
//  Copyright © 2018 Raju. All rights reserved.
//

import UIKit

class NewMessageController: UITableViewController {

    lazy var cancel: UIBarButtonItem = {
        UIBarButtonItem.init(barButtonSystemItem: .cancel, target: self, action: #selector(self.cancelAction))
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = cancel
    }

    @objc private func cancelAction() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewMessageCell", for: indexPath)
        cell.textLabel?.text = "LALALALA"
        return cell
    }

}
