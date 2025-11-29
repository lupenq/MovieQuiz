import UIKit

final class MovieQuizViewController: UIViewController, QuestionFactoryDelegate {
    @IBOutlet private var imageView: UIImageView!

    @IBOutlet private var counterLabel: UILabel!

    @IBOutlet private var textLabel: UILabel!

    @IBOutlet var noButtonView: UIButton!

    @IBOutlet var yesButtonView: UIButton!

    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    //
    private let questionsAmount: Int = 10
    private var questionFactory: QuestionFactoryProtocol!
    private var currentQuestion: QuizQuestion?
    //

    private var alertPresenter = AlertPresenter()

    private var statisticService: StatisticServiceProtocol!

    private var currentQuestionIndex = 0

    private var correctAnswers = 0

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.layer.cornerRadius = 20
        questionFactory = QuestionFactory(moviesLoader: MoviesLoader(), delegate: self)
        statisticService = StatisticService()

        yesButtonView.isEnabled = false
        noButtonView.isEnabled = false
        yesButtonView.alpha = 0.5
        noButtonView.alpha = 0.5

        showLoadingIndicator()
        questionFactory.loadData()
        toggleDisableButtons()
    }

    func toggleDisableButtons() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }

            self.yesButtonView.isEnabled.toggle()
            self.noButtonView.isEnabled.toggle()

            if self.yesButtonView.isEnabled {
                self.yesButtonView.alpha = 1.0
                self.noButtonView.alpha = 1.0
            } else {
                self.yesButtonView.alpha = 0.5
                self.noButtonView.alpha = 0.5
            }
        }
    }

    func showLoading() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }

            self.imageView.alpha = 0
            self.toggleDisableButtons()
            self.textLabel.text = ""
            self.showLoadingIndicator()
        }
    }

    func hideLoading() {
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }

            self.imageView.alpha = 1
            self.toggleDisableButtons()
            self.hideLoadingIndicator()
        }
    }

    // MARK: - QuestionFactoryDelegate

    func didReceiveNextQuestion(question: QuizQuestion?) {
        guard let question = question else {
            return
        }

        currentQuestion = question
        let viewModel = convert(model: question)

        DispatchQueue.main.async { [weak self] in
            self?.show(quiz: viewModel)
        }
    }

    func didLoadDataFromServer() {
        hideLoadingIndicator()

        questionFactory.requestNextQuestion()
    }

    func didFailToLoadData(with error: Error) {
        showNetworkError(message: error.localizedDescription)
    }

    private func showLoadingIndicator() {
        activityIndicator.isHidden = false // говорим, что индикатор загрузки не скрыт
        activityIndicator.startAnimating() // включаем анимацию

        imageView.alpha = 0
    }

    private func hideLoadingIndicator() {
        activityIndicator.isHidden = true // говорим, что индикатор загрузки скрыт
        activityIndicator.stopAnimating() // выключаем анимацию

        imageView.alpha = 1
    }

    private func showNetworkError(message: String) {
        hideLoadingIndicator()

        let model = AlertModel(title: "Ошибка",
                               message: message,
                               buttonText: "Попробовать еще раз")
        { [weak self] in
            guard let self = self else { return }

            self.currentQuestionIndex = 0
            self.correctAnswers = 0

            self.questionFactory.requestNextQuestion()
        }

        alertPresenter.show(in: self, model: model)
    }

    private func setUpImageView() {
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 20
    }

    private func convert(model: QuizQuestion) -> QuizStepViewModel {
        return QuizStepViewModel(
            image: UIImage(data: model.image) ?? UIImage(),
            question: model.text,
            questionNumber: "\(currentQuestionIndex + 1)/\(questionsAmount)"
        )
    }

    private func show(quiz step: QuizStepViewModel) {
        imageView.image = step.image
        textLabel.text = step.question
        counterLabel.text = step.questionNumber
    }

    private func showAnswerResult(isCorrect: Bool) {
        if isCorrect {
            correctAnswers += 1
        }

        imageView.layer.borderWidth = 8
        imageView.layer.borderColor = isCorrect ? UIColor.ypGreen.cgColor : UIColor.ypRed.cgColor

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            guard let self = self else { return }

            self.showNextQuestionOrResults()
            toggleDisableButtons()
        }
    }

    func show(quiz result: QuizResultsViewModel) {
        let message = """
        \(result.text)
        Количество сыгранных квизов: \(statisticService.gamesCount)
        Рекорд: \(statisticService.bestGame.correct)/\(statisticService.bestGame.total) (\(statisticService.bestGame.date.dateTimeString))
        Средняя точность: \(String(format: "%.2f", statisticService.totalAccuracy))%
        """

        let model = AlertModel(title: result.title, message: message, buttonText: result.buttonText) { [weak self] in
            guard let self = self else { return }

            self.currentQuestionIndex = 0
            self.correctAnswers = 0
            self.questionFactory.requestNextQuestion()
        }

        alertPresenter.show(in: self, model: model)
    }

    private func showNextQuestionOrResults() {
        imageView.layer.borderWidth = 0

        if currentQuestionIndex == questionsAmount - 1 {
            statisticService.store(correct: correctAnswers, total: questionsAmount)

            let text = "Ваш результат: \(correctAnswers)/10"
            let viewModel = QuizResultsViewModel(
                title: "Этот раунд окончен!",
                text: text,
                buttonText: "Сыграть ещё раз"
            )
            show(quiz: viewModel)
        } else {
            currentQuestionIndex += 1

            questionFactory.requestNextQuestion()
        }
    }

    @IBAction private func yesButtonClicked(_: UIButton) {
        if !yesButtonView.isEnabled { return }

        guard let currentQuestion = currentQuestion else {
            return
        }

        let givenAnswer = true
        toggleDisableButtons()

        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }

    @IBAction private func noButtonClicked(_: UIButton) {
        if !yesButtonView.isEnabled { return }

        guard let currentQuestion = currentQuestion else {
            return
        }

        let givenAnswer = false
        toggleDisableButtons()

        showAnswerResult(isCorrect: givenAnswer == currentQuestion.correctAnswer)
    }
}
