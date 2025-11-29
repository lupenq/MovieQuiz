//
//  QuestionFactoryDelegate.swift
//  MovieQuiz
//
//  Created by Ilia Degtiarev on 15.11.25.
//

protocol QuestionFactoryDelegate: AnyObject {
    func didReceiveNextQuestion(question: QuizQuestion?)
    func didLoadDataFromServer() // сообщение об успешной загрузке
    func didFailToLoadData(with error: Error) // сообщение об ошибке загрузки
    func showLoading()
    func hideLoading()
}
