//
//  Client.swift
//  WiseBookLife
//
//  Created by 서보경 on 2021/07/05.
//  Copyright © 2021 서보경. All rights reserved.
//

import UIKit

// MARK:- Client ID/Secret Model

struct ClientData: Codable {
    var requestURL: String
    var requestHeader: [String: String]
    init() {
        guard let path = Bundle.main.path(forResource: "ApplicationInfo", ofType: "plist") else {
            requestURL = "None"
            requestHeader = [:]
            return
        }
        guard let xml = FileManager.default.contents(atPath: path) else {
            requestURL = "None"
            requestHeader = [:]
            return
        }
        guard let data = try? PropertyListDecoder().decode(ClientData.self, from: xml) else {
            requestURL = "None"
            requestHeader = [:]
            return
        }
        
        requestURL = data.requestURL
        requestHeader = data.requestHeader
    }
}

// MARK:- Request/Result Model

struct RequestParam {
    var query: String
    var display: Int?
    var start: Int?
    var sort: String?
}

struct ResultModel: Codable {
    var lastBuildDate: String = ""
    var total: Int = 0
    var start: Int = 0
    var display: Int = 0
    var items: [BookItem] = []
}


// MARK:- API Service

class SearchBook {
    var results: [BookItem] = []
    
    func callAPI(additional_param: [String: String], target: UIViewController, completion: @escaping (() -> Void)) {
        let clientData = ClientData()
        let naver_book_url = clientData.requestURL
        
        var urlComponents = URLComponents(string: naver_book_url)
        urlComponents?.query = additional_param.queryString
        
        guard let hasURL = urlComponents?.url else { return }
        var request = URLRequest(url: hasURL)
        request.addValue(clientData.requestHeader["X-Naver-Client-Id"] ?? "", forHTTPHeaderField: "X-Naver-Client-Id")
        request.addValue(clientData.requestHeader["X-Naver-Client-Secret"] ?? "", forHTTPHeaderField: "X-Naver-Client-Secret")
        
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            guard let data = data else {
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "알림", message: "네트워크 에러가 발생했습니다\n잠시 후 다시 시도해 주세요.", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "확인", style: .default, handler: nil)
                    alert.addAction(ok)

                    target.present(alert, animated: true, completion: nil)
                }
                return
            }
            
            let decoder = JSONDecoder()
            
            do {
                let user = try decoder.decode(ResultModel.self, from: data)
                var datas: [BookItem] = []
                for item in user.items {
                    let newItem = BookItem(title: item.title.removeHTMLTag(), link: item.link, image: item.image, author: item.author.removeHTMLTag(), price: item.price, discount: item.discount, publisher: item.publisher, isbn: item.isbn, description: item.description.removeHTMLTag(), pubdate: item.pubdate)
                    datas.append(newItem)
                }
                self.results = datas
                DispatchQueue.main.async {
                    completion()
                }
                
            } catch let error {
                // error 처리
                print(error.localizedDescription)
                DispatchQueue.main.async {
                    let alert = UIAlertController(title: "알림", message: "네트워크 에러가 발생했습니다\n잠시 후 다시 시도해 주세요.", preferredStyle: .alert)
                    let ok = UIAlertAction(title: "확인", style: .default, handler: nil)
                    alert.addAction(ok)

                    target.present(alert, animated: true, completion: nil)
                }
            }
        }.resume()
            
    }
}

// MARK: - Extensions for Service

extension Dictionary {
    var queryString: String {
        var output = ""
        for (key, value) in self {
            output += "\(key)=\(value)&"
        }
        output = String(output.dropLast())
        
        return output
    }
}

extension String {
    func removeHTMLTag() -> String {
        let rmFirst = self.replacingOccurrences(of: "<b>", with: "")
        let result = rmFirst.replacingOccurrences(of: "</b>", with: "")
        return result
    }
}
