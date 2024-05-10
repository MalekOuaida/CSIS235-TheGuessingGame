import UIKit

class guessTheLetterViewController: UIViewController, UITableViewDataSource {
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var guessField: UITextField!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var leaderboardTable: UITableView!
    @IBOutlet weak var guessButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    
    var randomLetter: Character = "A"
    var guessCount: Int = 0
    var leaderboard: [String: Int] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        leaderboardTable.dataSource = self
        leaderboard = loadLeaderboard()
        setupGame()
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
        let letters = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ")
        randomLetter = letters[Int(arc4random_uniform(UInt32(letters.count)))]
        guessCount = 0
        nameField.text = ""
        guessField.text = ""
        messageLabel.text = "Guess a letter between A and Z"
    }
    
    func submitGuess() {
        guard let guessText = guessField.text?.uppercased(), let guessLetter = guessText.first else {
            showAlertWithTitle("Invalid Input", message: "Please enter a letter between A and Z.")
            return
        }
        
        if !guessLetter.isLetter || guessText.count != 1 {
            showAlertWithTitle("Invalid Input", message: "Please enter a single letter between A and Z.")
            return
        }
        
        guessCount += 1
        let playerName = nameField.text?.isEmpty ?? true ? "Anonymous" : nameField.text!
        let currentScore = leaderboard[playerName] ?? 0
        
        if guessLetter == randomLetter {
            let newScore = currentScore + 1
            leaderboard[playerName] = newScore
            messageLabel.text = "Correct! You've earned a point. The letter was \(randomLetter)."
        } else {
            if guessCount >= 5 {
                if leaderboard[playerName] == nil {
                    leaderboard[playerName] = 0
                }
                messageLabel.text = "Incorrect. You've used all 5 guesses! The letter was \(randomLetter). Try again by pressing the reset button!"
            } else {
                messageLabel.text = "Incorrect. You have \(5 - guessCount) guesses left."
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
        UserDefaults.standard.set(leaderboard, forKey: "GuessTheLetterLeaderboard")
    }
    
    func loadLeaderboard() -> [String: Int] {
        if let savedLeaderboard = UserDefaults.standard.dictionary(forKey: "GuessTheLetterLeaderboard") as? [String: Int] {
            return savedLeaderboard
        }
        return [:]
    }
}
