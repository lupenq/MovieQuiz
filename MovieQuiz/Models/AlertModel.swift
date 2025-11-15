//
//  AlertModel.swift
//  MovieQuiz
//
//  Created by Ilia Degtiarev on 15.11.25.
//

import Foundation

struct AlertModel {
    var title: String
    var message: String
    var buttonText: String
    var completion: () -> Void
}
