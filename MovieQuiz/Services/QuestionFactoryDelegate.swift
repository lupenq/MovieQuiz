//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Ilia Degtiarev on 15.11.25.
//

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
}
