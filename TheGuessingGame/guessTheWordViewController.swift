import UIKit

class guessTheWordViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var guessButton: UIButton!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var leaderboardTable: UITableView!
    @IBOutlet weak var wordPicker: UIPickerView!
    
    let words = ["apple", "banana", "orange", "grape", "kiwi", "melon", "peach", "pear", "plum", "strawberry"]
    var guessCount: Int = 0
    var correctGuesses: Int = 0
    var selectedWord: String = ""
    var leaderboard: [String: Int] = [:]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGame()
        leaderboardTable.dataSource = self
        wordPicker.dataSource = self
        wordPicker.delegate = self
        
        leaderboard = loadLeaderboard()
        
        // Register the cell class for the table view
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
        guessCount = 0
        nameField.text = ""
        selectedWord = words.randomElement() ?? ""
        messageLabel.text = "Guess the word!"
        wordPicker.reloadAllComponents()
    }
    
    func submitGuess() {
        guard let playerName = nameField.text, !playerName.isEmpty else {
            showAlertWithTitle("Invalid Input", message: "Please enter your name.")
            return
        }
        
        let guessedWordIndex = wordPicker.selectedRow(inComponent: 0)
        let guessedWord = words[guessedWordIndex]
        guessCount += 1
        
        // Add player's name to leaderboard with a default score of 0
        leaderboard[playerName, default: 0] += 0
        
        if guessedWord == selectedWord {
            correctGuesses += 1
            messageLabel.text = "Correct! You've earned a point. You guessed the word \(selectedWord) correctly!"
            leaderboard[playerName] = (leaderboard[playerName] ?? 0) + 1
            saveLeaderboard()
            leaderboardTable.reloadData()
        } else {
            if guessCount >= 3 {
                messageLabel.text = "You are out of tries. The word was \(selectedWord)."
                
                // Add player to leaderboard with a score of 0
                leaderboard[playerName, default: 0] += 0
                saveLeaderboard()
                leaderboardTable.reloadData()
            } else {
                messageLabel.text = "Incorrect. You have \(3 - guessCount) tries left."
            }
        }
    }



    // MARK: - UIPickerViewDataSource methods
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return words.count
    }
    
    // MARK: - UIPickerViewDelegate method
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return words[row]
    }
    
    // MARK: - UITableViewDataSource methods
    
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
    
    func showAlertWithTitle(_ title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func saveLeaderboard() {
        UserDefaults.standard.set(leaderboard, forKey: "GuessTheWordLeaderboard")
    }
    
    func loadLeaderboard() -> [String: Int] {
        if let savedLeaderboard = UserDefaults.standard.dictionary(forKey: "GuessTheWordLeaderboard") as? [String: Int] {
            return savedLeaderboard
        }
        return [:]
    }
}
