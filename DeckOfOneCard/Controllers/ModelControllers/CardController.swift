//
//  CardController.swift
//  DeckOfOneCard
//
//  Created by Natalie Hall on 8/3/21.
//  Copyright © 2021 Warren. All rights reserved.
//

import UIKit

class CardController {
    //https://deckofcardsapi.com/api/deck/new/draw/?count=1
    static let baseURL = URL(string: "https://deckofcardsapi.com/api/deck/")
    static let newEndPoint = "new"
    static let drawEndPoint = "draw"
    
    static func fetchCard(completion: @escaping (Result <Card, CardError>) -> Void) {
        // 1 - Prepare URL
        guard let baseURL = baseURL else { return completion(.failure(.invalidURL)) }
        let totalBaseURL = baseURL.appendingPathComponent(newEndPoint).appendingPathComponent(drawEndPoint)
        var components = URLComponents(url: totalBaseURL, resolvingAgainstBaseURL: true)
        let categoryQuery = URLQueryItem(name: "count", value: "1")
        components?.queryItems = [categoryQuery]
        
        guard let finalURL = components?.url else { return completion(.failure(.invalidURL)) }
        print(finalURL)
        
        // 2 - Contact server
        URLSession.shared.dataTask(with: finalURL) { data, _, error in
        
        // 3 - Handle errors from the server
            if let error = error {
                return completion(.failure(.thrownError(error)))
            }
            
        // 4 - Check for json data
            guard let data = data else { return completion(.failure(.noData)) }
        
        // 5 - Decode json into a Card
            do {
                let topLevelObject = try JSONDecoder().decode(TopLevelObject.self, from: data)
                guard let card = topLevelObject.cards.first else { return completion(.failure(.noData)) }
                return completion(.success(card))
            } catch {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                return completion(.failure(.thrownError(error)))
            }
            
        }.resume()
    }

    static func fetchImage(for card: Card, completion: @escaping (Result <UIImage, CardError>) -> Void) {

        // 1 - Prepare URL
        let imageURL = card.image
        // 2 - Contact server
        URLSession.shared.dataTask(with: imageURL) { data, _, error in

            // 3 - Handle errors from the server
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                return completion(.failure(.thrownError(error)))
            }

            // 4 - Check for image data
            guard let data = data else { return completion(.failure(.noData)) }

            // 5 - Initialize an image from the data
            guard let image = UIImage(data: data) else { return completion(.failure(.unableToDecode)) }
            return completion(.success(image))

        }.resume()
    }

}  // End of Class
