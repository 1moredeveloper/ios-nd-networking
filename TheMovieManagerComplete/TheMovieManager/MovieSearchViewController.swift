//
//  MovieSearchViewController.swift
//  TheMovieManager
//
//  Created by Jarrod Parkes on 2/11/15.
//  Copyright © 2015 Jarrod Parkes. All rights reserved.
//

import UIKit

// MARK: - MovieSearchViewController: UIViewController

class MovieSearchViewController: UIViewController {
    
    // MARK: Properties
    
    let moviesDataSource = MoviesDataSource(cellType: .search)
    var searchQueue: OperationQueue? // last operation queue (allows us to cancel it)
    
    // MARK: Outlets
    
    @IBOutlet weak var moviesTableView: UITableView!
    @IBOutlet weak var moviesSearchBar: UISearchBar!
    
    // MARK: Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        moviesTableView.delegate = self
        moviesTableView.dataSource = moviesDataSource
        
        // logout button
        parent?.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .reply, target: self, action: #selector(logout))
        
        // tap recognizer to dismiss keyboard
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleSingleTap(_:)))
        tapRecognizer.numberOfTapsRequired = 1
        tapRecognizer.delegate = self
        view.addGestureRecognizer(tapRecognizer)
    }
    
    // MARK: Actions
    
    @objc func handleSingleTap(_ recognizer: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    @objc func logout() {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - MovieSearchViewController: UISearchBarDelegate

extension MovieSearchViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        // if query is empty, then we are done
        if searchText == "" {
            moviesDataSource.movies = [Movie]()
            moviesTableView?.reloadData()
            return
        }
        
        // if the search is still running, then cancel all the operations on the queue
        if let searchQueue = searchQueue {
            searchQueue.cancelAllOperations()
        }
        
        // start new search
        searchQueue = moviesDataSource.loadDataWithRequest(.searchMovies(searchText), completion: {
            self.searchQueue = nil
            self.moviesTableView.reloadData()
        }) { (error) in
            self.alertError(error, handler: nil)
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
}

// MARK: - MovieSearchViewController: UIGestureRecognizerDelegate

extension MovieSearchViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return moviesSearchBar.isFirstResponder
    }
}

// MARK: - MovieSearchViewController: UITableViewDelegate

extension MovieSearchViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let controller = storyboard?.instantiateViewController(withIdentifier: "MovieDetailViewController") as? MovieViewController {
            let movie = moviesDataSource.movies[indexPath.row]
            controller.movieDataSource = MovieDataSource(movie: movie)
            navigationController?.pushViewController(controller, animated: true)
        }
    }
}
