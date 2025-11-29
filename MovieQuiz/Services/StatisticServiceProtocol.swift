//
//  StatisticServiceProtocol.swift
//  MovieQuiz
//
//  Created by Ilia Degtiarev on 15.11.25.
//

protocol StatisticServiceProtocol {
    var gamesCount: Int { get }
    var bestGame: GameResult { get }
    var totalAccuracy: Double { get }

    func store(correct count: Int, total amount: Int)
}
