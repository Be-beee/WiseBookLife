//
//  HeartListViewController.swift
//  WiseBookLife
//
//  Created by 서보경 on 2020/06/24.
//  Copyright © 2020 서보경. All rights reserved.
//

import UIKit


class HeartListViewController: UIViewController {

    @IBOutlet var heartView: UITableView!
    
    var heartList: [BookItem] = []
    override func viewDidLoad() {
        super.viewDidLoad()

        self.navigationItem.title = "나의 관심도서 😍"
        heartView.register(UINib(nibName: "CommonCell", bundle: nil), forCellReuseIdentifier: "commonCell")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        heartList = []
        for (_, value) in CommonData.heartDic {
            heartList.append(value)
        }
        heartList.sort(by: {$0.title < $1.title})
        heartView.reloadData()
    }

    
    // MARK:- cell button action methods
    
    @objc func onOffHeartBtn(_ sender: UIButton!) {
//        sender.isSelected = !sender.isSelected
        if sender.imageView?.image == UIImage(systemName: "heart.fill") {
            sender.setImage(UIImage(systemName: "heart"), for: .normal)
            CommonData.heartDic.removeValue(forKey: heartList[sender.tag].isbn)
//            saveData(data: heartDic, at: "heart")
            refreshData()
        }
    }
    
    func refreshData() {
        heartList = []
        for (_, value) in CommonData.heartDic {
            heartList.append(value)
        }
        
        heartView.reloadData()
    }
    
}


// MARK:- Extensions
extension HeartListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 135
    }
}
extension HeartListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return heartList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = heartView.dequeueReusableCell(withIdentifier: "commonCell", for: indexPath) as! CommonCell
        
        cell.bookCover.image = urlToImage(from: heartList[indexPath.row].image)
        
        if heartList[indexPath.row].title == "" {
            cell.titleLabel.text = "[NO TITLE]"
            cell.titleLabel.textColor = .lightGray
        } else {
            cell.titleLabel.text = heartList[indexPath.row].title
        }
        
        cell.authorLabel.text = heartList[indexPath.row].author
        
        cell.heartBtn.tag = indexPath.row
        cell.heartBtn.addTarget(self, action: #selector(onOffHeartBtn), for: .touchUpInside)
        cell.heartBtn.setImage(UIImage(systemName: "heart.fill"), for: .normal)
        

        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detailVC = UIStoryboard(name: "BookDetailVC", bundle: nil).instantiateViewController(withIdentifier: "bookDetailVC") as! BookDetailViewController
        detailVC.bookData = heartList[indexPath.row]
        detailVC.modalPresentationStyle = .fullScreen
        if CommonData.heartDic[heartList[indexPath.row].isbn] != nil {
            detailVC.isHeartBtnSelected = true
        } else {
            detailVC.isHeartBtnSelected = false
        }
        
        present(detailVC, animated: true, completion: nil)
    }
}

