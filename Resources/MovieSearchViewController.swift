//
//  MovieSearchViewController.swift
//  Resources
//
//  Created by Josh Rideout on 01/09/2022.
//

import UIKit

/*
 This application does not contain any UI, but rather this main view controller exists
 purely for the purpose of demonstrating how you go about constructing resources for
 fetching data that a page in your app might rely on in a scalable way.
*/
final class MovieViewController: UIViewController {
    
    @IBOutlet private var searchInput: UITextField!
    @IBOutlet private var searchButton: UIButton!
    private let dataSource = MovieDatasource()
        
    @IBAction private func searchButtonTapped() {
        
        // The movie you want to search for
        let queryString = searchInput.text ?? ""
        
        dataSource.fetchMovieDetails(forQuery: queryString) { result in
            switch result {
            case .success(let movie):
                dump(movie)
            case .failure:
                print("Failed to find movie details")
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

}
