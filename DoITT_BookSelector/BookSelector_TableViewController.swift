//
//  BookSelector_TableViewController.swift
//  DoITT_BookSelector
//
//  Created by Amitai Blickstein on 4/21/16.
//  Copyright © 2016 Amitai Blickstein, LLC. All rights reserved.
//

import UIKit
import Alamofire


class BookSelector_TableViewController: UITableViewController {

    let kGOOGLE_APIKEY = "AIzaSyA6AYE6tkCG7kdalGnftIC9PaYbjTcPghw"
    
    var searchString: String?
    var bookList = [Book]()
    var bookSelection: Book?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        //Make Network request here.
        if let qString = searchString {
            requestGoogleBookListWithQuery(qString) { responseBookList in
                guard let bookList = responseBookList else { return }
                self.bookList = bookList
                self.tableView.reloadData()
            }
        } else {
            print("Error, malformed request string.")
        }
    }
    
    func requestGoogleBookListWithQuery(searchString: String, withCompletion completion: ([Book]?)->()) {
        let params: [String: AnyObject] = ["q" : searchString,
                                           "langRestrict" : "en",
                                           "maxResults" : 20,
                                           "printType" : "books",
                                           "orderBy" : "relevance"]
        
        request(.GET, "https://www.googleapis.com/books/v1/volumes", parameters: params, encoding: .URL, headers: nil)
            .validate()
        .responseJSON { (response) in
            guard response.result.isSuccess else {
                print("Error fetching book choices: \(response.result.error)")
                completion(nil)
                return
            }
            
            guard let value = response.result.value as? [String: AnyObject],
            bookObjects = value["items"] as? [[String: AnyObject]] else {
                    print("Error, malformed data received from Google service.")
                completion(nil)
                return
            }
            
            
            
        }
        
        
        
    }
    
    
    func getBookFromGoogleBookObject(googleResponseObject: [String: AnyObject]) -> Book {
        var author = "Unknown author"
        var description = "No description provided"
        guard let volumeInfo = googleResponseObject["volumeInfo"] as? [String: AnyObject],
            let title = volumeInfo["title"] as? String else { fatalError(#function) }
        if let authorResponse = volumeInfo["authors"]
        
        return Book(title: title, ISBN: nil, author: author, description: description)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return (bookList.count != 0) ?  1 : 0
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bookList.count
    }

    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("reuseIdentifier", forIndexPath: indexPath)
        let book = bookList[indexPath.row]
        
        cell.textLabel?.text = book.title
        cell.detailTextLabel?.text = book.description

        return cell
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        bookSelection = bookList[indexPath.row]
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
