//
//  AccountFunctions.swift
//  HomeFoods
//
//  Created by Andrew Li on 1/22/25.
//

import FirebaseAuth

func signUp(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
    Auth.auth().createUser(withEmail: email, password: password) { result, error in
        if let error = error {
            completion(.failure(error))
        } else {
            completion(.success(()))
        }
    }
}


func login(email: String, password: String, completion: @escaping (Result<Void, Error>) -> Void) {
    Auth.auth().signIn(withEmail: email, password: password) { result, error in
        if let error = error {
            completion(.failure(error))
        } else {
            completion(.success(()))
        }
    }
}
