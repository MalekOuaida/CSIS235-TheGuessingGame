import UIKit

class guessTheNumberViewController: UIViewController, UITableViewDataSource {
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var guessField: UITextField!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var leaderboardTable: UITableView!
    @IBOutlet weak var guessButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    
    var randomNumber: Int = 0
    var guessCount: Int = 0
    var leaderboard: [String: Int] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        leaderboardTable.dataSource = self
        setupGame()
        leaderboard = loadLeaderboard()
        leaderboardTable.register(UITableViewCell.self, forCellReuseIdentifier: "LeaderboardCell")
    }
    
    @IBAction func guessButtonTapped(_ sender: Any) {
        submitGuess()
    }
    
    @IBAction func resetGame(_ sender: Any) {
        setupGame()
        leaderboardTable.reloadData()
    }
    
    func setupGame() {
        randomNumber = Int(arc4random_uniform(100)) + 1
        guessCount = 0
        nameField.text = ""
        guessField.text = ""
        messageLabel.text = "Guess a number between 1 and 100"
    }
    
    func submitGuess() {
        guard let guess = Int(guessField.text ?? "") else {
            showAlertWithTitle("Invalid Input", message: "Please enter a number between 1 and 100.")
            return
        }
        
        if guess < 1 || guess > 100 {
            showAlertWithTitle("Invalid Input", message: "Please enter a number between 1 and 100.")
            return
        }
        
        guessCount += 1
        let playerName = nameField.text?.isEmpty ?? true ? "Anonymous" : nameField.text!
        let currentScore = leaderboard[playerName] ?? 0
        
        if guess == randomNumber {
            let newScore = currentScore + 1
            leaderboard[playerName] = newScore
            messageLabel.text = "Correct! You've earned a point. The number was \(randomNumber)."
        } else {
            if guessCount >= 5 {
                if leaderboard[playerName] == nil {
                    leaderboard[playerName] = 0
                }
                messageLabel.text = "Incorrect. You've used all 5 guesses! The number was \(randomNumber). Try again by pressing the reset button!"
            } else {
                let hotOrCold = abs(randomNumber - guess) <= 10 ? "Hot" : "Cold"
                messageLabel.text = "\(hotOrCold). You have \(5 - guessCount) guesses left."
            }
        }
        
        guessField.text = ""
        saveLeaderboard()
        leaderboardTable.reloadData()
    }
    
    func showAlertWithTitle(_ title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return leaderboard.keys.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LeaderboardCell", for: indexPath)
        
        let playerName = Array(leaderboard.keys)[indexPath.row]
        let score = leaderboard[playerName] ?? 0
        cell.textLabel?.text = "\(playerName): \(score)"
        
        return cell
    }
    
    func saveLeaderboard() {
        UserDefaults.standard.set(leaderboard, forKey: "Leaderboard")
    }
    
    func loadLeaderboard() -> [String: Int] {
        if let savedLeaderboard = UserDefaults.standard.dictionary(forKey: "Leaderboard") as? [String: Int] {
            return savedLeaderboard
        }
        return [:]
    }
}
