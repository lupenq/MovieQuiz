//
//  StatisticService.swift
//  MovieQuiz
//
//  Created by Ilia Degtiarev on 15.11.25.
//

import Foundation

private enum Keys: String {
    case gamesCount // Для счётчика сыгранных игр
    case bestGameCorrect // Для количества правильных ответов в лучшей игре
    case bestGameTotal // Для общего количества вопросов в лучшей игре
    case bestGameDate // Для даты лучшей игры
    case totalCorrectAnswers // Для общего количества правильных ответов за все игры
    case totalQuestionsAsked // Для общего количества вопросов, заданных за все игры
}

final class StatisticService: StatisticServiceProtocol {
    private let storage: UserDefaults = .standard

    private var totalCorrectAnswers: Int {
        get {
            storage.integer(forKey: Keys.totalCorrectAnswers.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.totalCorrectAnswers.rawValue)
        }
    }

    private var totalQuestionsAsked: Int {
        get {
            storage.integer(forKey: Keys.totalQuestionsAsked.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.totalQuestionsAsked.rawValue)
        }
    }

    var gamesCount: Int {
        get {
            storage.integer(forKey: Keys.gamesCount.rawValue)
        }
        set {
            storage.set(newValue, forKey: Keys.gamesCount.rawValue)
        }
    }

    var bestGame: GameResult {
        get {
            let correct = storage.integer(forKey: Keys.bestGameCorrect.rawValue)
            let total = storage.integer(forKey: Keys.bestGameTotal.rawValue)
            let date = storage.object(forKey: Keys.bestGameDate.rawValue) as? Date ?? Date()

            return GameResult(correct: correct, total: total, date: date)
        }
        set {
            storage.set(newValue.correct, forKey: Keys.bestGameCorrect.rawValue)
            storage.set(newValue.total, forKey: Keys.bestGameTotal.rawValue)
            storage.set(newValue.date, forKey: Keys.bestGameDate.rawValue)
        }
    }

    var totalAccuracy: Double {
        if totalCorrectAnswers == 0 || totalQuestionsAsked == 0 {
            return 0.0
        }

        return Double(totalCorrectAnswers) / Double(totalQuestionsAsked) * 100
    }

    func store(correct count: Int, total amount: Int) {
        totalCorrectAnswers += count
        totalQuestionsAsked += amount
        gamesCount += 1

        let newGameResult = GameResult(correct: count, total: amount, date: Date())
        if newGameResult.isBetterThan(bestGame) {
            bestGame = newGameResult
        }
    }
}
