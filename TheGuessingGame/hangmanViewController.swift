import UIKit

class HangmanViewController: UIViewController, UITableViewDataSource {
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var guessField: UITextField!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var leaderboardTable: UITableView!
    @IBOutlet weak var guessButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    
    var words = ["SWIFT", "PYTHON", "JAVASCRIPT", "JAVA", "HTML", "CSS"]
    var randomWord: String = ""
    var dashedWord: String = ""
    var guessedLetters: [Character] = []
    var incorrectGuesses: Int = 0
    var leaderboard: [String: Int] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        leaderboardTable.dataSource = self
        setupGame()
        leaderboardTable.register(UITableViewCell.self, forCellReuseIdentifier: "LeaderboardCell")
        
        // Load leaderboard
        leaderboard = UserDefaults.standard.dictionary(forKey: "HangmanLeaderboard") as? [String: Int] ?? [:]
        print("Leaderboard loaded: \(leaderboard)")
    }
    
    @IBAction func guessButtonTapped(_ sender: Any) {
        submitGuess()
    }
    
    @IBAction func resetGame(_ sender: Any) {
        setupGame()
        leaderboardTable.reloadData()
    }
    
    func setupGame() {
        randomWord = words.randomElement() ?? ""
        dashedWord = String(repeating: "_ ", count: randomWord.count).trimmingCharacters(in: .whitespaces)
        guessedLetters = []
        messageLabel.text = "Guess a letter: \(dashedWord)"
        incorrectGuesses = 0
    }
    
    func submitGuess() {
        guard let guessText = guessField.text?.uppercased(), guessText.count == 1, let guessLetter = guessText.first else {
            showAlertWithTitle("Invalid Input", message: "Please enter a single letter.")
            return
        }
        
        if guessedLetters.contains(guessLetter) {
            showAlertWithTitle("Already Guessed", message: "You've already guessed this letter.")
            return
        }
        
        guessedLetters.append(guessLetter)
        
        var newDashedWord = ""
        var correctGuess = false
        
        for (index, char) in randomWord.enumerated() {
            if char == guessLetter {
                newDashedWord.append(guessLetter)
                newDashedWord.append(" ")
                correctGuess = true
            } else {
                let dashedIndex = dashedWord.index(dashedWord.startIndex, offsetBy: index * 2)
                newDashedWord.append(dashedWord[dashedIndex])
                newDashedWord.append(" ")
            }
        }
        
        dashedWord = newDashedWord.trimmingCharacters(in: .whitespaces)
        messageLabel.text = "Guess a letter: \(dashedWord)"
        
        if !dashedWord.contains("_") {
            messageLabel.text = "Congratulations! You guessed the word: \(randomWord)"
            updateLeaderboard()
        } else if !correctGuess {
            incorrectGuesses += 1
            if incorrectGuesses >= 6 {
                messageLabel.text = "You lost! The word was \(randomWord). Try again!"
            } else {
                messageLabel.text = "Incorrect guess. Try again!"
            }
        }
        
        guessField.text = ""
    }
    
    func updateLeaderboard() {
        let playerName = nameField.text?.isEmpty ?? true ? "Anonymous" : nameField.text!
        let currentScore = leaderboard[playerName] ?? 0
        leaderboard[playerName] = currentScore + 1
        saveLeaderboard() // Save leaderboard after updating
        leaderboardTable.reloadData()
        print("Leaderboard updated for player \(playerName)")
    }
    
    func saveLeaderboard() {
        UserDefaults.standard.set(leaderboard, forKey: "HangmanLeaderboard")
        print("Leaderboard saved: \(leaderboard)")
    }
    
    func showAlertWithTitle(_ title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return leaderboard.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LeaderboardCell", for: indexPath)
        
        let playerName = Array(leaderboard.keys)[indexPath.row]
        let score = leaderboard[playerName] ?? 0
        cell.textLabel?.text = "\(playerName): \(score)"
        
        return cell
    }
}
