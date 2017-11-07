//
//  DownloadViewController.swift
//  ImageRequest
//
//  Created by Jarrod Parkes on 11/3/17.
//  Copyright © 2017 Udacity. All rights reserved.
//

import UIKit

// MARK: - DownloadViewController: ExampleViewController

class DownloadViewController: ExampleViewController {
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // create components
        var components = URLComponents()
        components.scheme = Constants.URLSession.scheme
        components.host = Constants.URLSession.host
        components.path = Constants.URLSession.path
        
        // create url from components
        guard let imageURL = components.url else { return }
        
        // create url request
        let request = URLRequest(url: imageURL)
        
        // create session config
        let configuration = URLSessionConfiguration.default
        
        // create session and specify delegate
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: .main)
        
        // create task
        let task = session.downloadTask(with: request)
        
        // start task
        task.resume()
    }
}

// MARK: - DownloadViewController: URLSessionDownloadDelegate

extension DownloadViewController: URLSessionDownloadDelegate {
    
    // MARK: URLSessionDownloadDelegate
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        // "save file" by moving it to a permanent location (documents directory)
        if let permanentURL = move(tempURL: location, toDocumentsWithName: "uploaded_image.jpg"), let imageData = try? Data(contentsOf: permanentURL) {
            // update UI on the main thread
            DispatchQueue.main.async {
                self.imageView.image = UIImage(data: imageData)
            }
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let downloadProgress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)        
        print("\(downloadProgress * 100)% downloaded")
    }
    
    func move(tempURL: URL, toDocumentsWithName name: String) -> URL? {
        // create file path
        guard let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return nil }
        let fileURL = documentsURL.appendingPathComponent(name)
        
        // remove existing file (if exists), then copy temporary file to documents directory
        do {
            if FileManager.default.fileExists(atPath: fileURL.path) {
                try FileManager.default.removeItem(at: fileURL)
            }
            try FileManager.default.copyItem(at: tempURL, to: fileURL)
        } catch let error {
            print("error creating a file \(fileURL): \(error)")
            return nil
        }
        
        return fileURL
    }
    
    // MARK: URLSessionTaskDelegate
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            print(error)
        }
    }
}
