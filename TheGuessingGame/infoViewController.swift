import UIKit

class infoViewController: UIViewController {
    
    @IBOutlet weak var appLogoImageView: UIImageView!
    @IBOutlet weak var visitorCountLabel: UILabel!
    @IBOutlet weak var appInfoLabel: UILabel!
    
    var leaderboardEntries: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadLeaderboard()
        updateVisitorCountLabel()
        displayAppInfo()
        loadAppLogo()
    }
    
    func loadLeaderboard() {
        if let leaderboard = UserDefaults.standard.dictionary(forKey: "HangmanLeaderboard") as? [String: Int] {
            leaderboardEntries = leaderboard.count
        }
    }
    
    func updateVisitorCountLabel() {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                let visitorCount = appDelegate.visitorCount
                visitorCountLabel.text = "Visitors: \(visitorCount)"
            }
        }
    
    func displayAppInfo() {
        let appInfo = "Welcome to the Guessing Game\n\n" +
                      "Embark on a journey where you'll test your intuition and trust your instincts!\n\n" +
                      "🎲 Guess the Number\n" +
                      "🔤 Guess the Word\n" +
                      "✉️ Guess the Letter\n" +
                      "💀 Hangman\n\n" +
                      "Trust your Instincts!"
        
        appInfoLabel.text = appInfo
    }

    
    func loadAppLogo() {
        // Set your app logo image here
        let appLogoImage = UIImage(named: "guessLogo")
        appLogoImageView.image = appLogoImage
    }
}
