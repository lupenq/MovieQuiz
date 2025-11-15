//
//  GameResult.swift
//  MovieQuiz
//
//  Created by Ilia Degtiarev on 15.11.25.
//

import Foundation

struct GameResult {
    let correct: Int
    let total: Int
    let date: Date
    
    func isBetterThan(_ another: GameResult) -> Bool {
            correct > another.correct
    }
}
