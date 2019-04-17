//
//  CommitsViewController.swift
//  SourceHub
//
//  Created by APPLE on 4/8/19.
//  Copyright © 2019 SourceHub. All rights reserved.
//

import UIKit
import GitHub


class CommitsViewController: UITableViewController {

	convenience init() {
		self.init(nibName: nil, bundle: nil)
	}
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

		title = "Commits"
	}
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}

	var repo: GitHub.Repository?
	private var commits = [GitHub.Commit]()

	override func viewDidLoad() {
		super.viewDidLoad()
        fetchCommits()
		tableView.register(UITableViewCell.self, forCellReuseIdentifier: "reuseIdentifier")
        tableView.reloadData()
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return commits.count
	}
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)
        cell = UITableViewCell(style: .subtitle, reuseIdentifier: "reuseIdentifier")
		let commit = commits[indexPath.row]

		cell.textLabel?.text = commit.committer.login
		cell.detailTextLabel?.text = commit.commit.message
        
		return cell
	}

	private func fetchCommits() {
		GitHub.handleAuthenticatedUser(with: Handler { [weak self] result in
			switch result {
			case .failure(let error):
				debugPrint(error)

				DispatchQueue.main.async {
					self?.alertUser(title: "Error Fetching Commits", message: error.localizedDescription)
				}

			case .success(let authenticatedUser):
				guard let repo = self?.repo else { return }

				GitHub.handleCommits(owner: authenticatedUser.login, repo: repo.name, with: Handler{ [weak self] result in
					switch result {
					case .failure(let error):
						debugPrint(error)

					case .success(let commit):
						self?.commits = commit

						DispatchQueue.main.async {
							self?.tableView.reloadData()
						}
					}
				})
			}
		})
	}

}