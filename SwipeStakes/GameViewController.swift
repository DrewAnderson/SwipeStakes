// Lobby 
import UIKit
import AVFoundation

class GameViewController: UIViewController, QuestionnaireDelegate {
   
    // Properties
    var videoPlayerView: UIView!
    var videoPlayer: AVQueuePlayer!
    var playerAnswers: [String] = [] // Store player's answers
    var guestID: String = ""
    var timerLabel: UILabel!
    var countdownTimer: Timer?
    var secondsLeft: Int = 15
    var carouselView: UIImageView!
    var players: [Player] = []
    var winner: Player?
    
    // Buttons
       var playButton: UIButton!
       var pauseButton: UIButton!

    //VerticalNav
    var profileButton: UIButton!
      let icons = ["heart.fill", "message.fill", "paperplane.fill", "bookmark.fill", "ellipsis"]
    let playlistURLs = GameConfiguration.playlistURLs
    let questionsAPIURL = GameConfiguration.questionsAPIURL
    let answersAPIURL = GameConfiguration.answersAPIURL
    let raffleAPIURL = GameConfiguration.raffleAPIURL
    let guestIDAPIURL = GameConfiguration.guestIDAPIURL
    let signInAPIUrl = GameConfiguration.signInAPIUrl
    let signUpAPIUrl = GameConfiguration.signUpAPIUrl
    
    override func viewDidLoad() {
        super.viewDidLoad()
         
        // Load game content
        loadVideoPlaylist()
        
        // Setup countdown timer label
        setupTimerLabel()
        
        // Setup bottom Toolbar
        setupToolbar()
        
        //Setup ProfileButton and Vertical Button Stack
        setupProfileButton()
        setupButtonStack()
        setupVideoSwipeGestures()
        
  
    }

    // MARK: - Load Lobby Video Content
    
    func loadVideoPlaylist() {
        // Create array to hold player items
        var playerItems = [AVPlayerItem]()

        // Create player items for each video URL in the playlistURLs array
        for videoURLString in playlistURLs {
            guard let videoURL = URL(string: videoURLString) else {
                print("Invalid video URL in playlist: \(videoURLString)")
                continue
            }
            let playerItem = AVPlayerItem(url: videoURL)
            playerItems.append(playerItem)
        }

        // Create a queue player with the player items
        videoPlayer = AVQueuePlayer(items: playerItems)

        // Create a player layer and add it to the video player view
        videoPlayerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
        view.addSubview(videoPlayerView)
        let playerLayer = AVPlayerLayer(player: videoPlayer)
        playerLayer.frame = videoPlayerView.bounds
        playerLayer.videoGravity = .resizeAspectFill
        videoPlayerView.layer.addSublayer(playerLayer)

        // Observe the player item's end
        NotificationCenter.default.addObserver(self, selector: #selector(handlePlayerItemEnd), name: .AVPlayerItemDidPlayToEndTime, object: videoPlayer.currentItem)

        // Start playing the playlist
        videoPlayer.play()

        // Show toolbars
        navigationController?.setNavigationBarHidden(false, animated: false)
        tabBarController?.tabBar.isHidden = false
    }

    @objc func handlePlayerItemEnd(notification: Notification) {
        // Check if there's more videos to play and advance to the next item
        if videoPlayer.items().count > 1 {
            videoPlayer.advanceToNextItem()
        } else {
            // Loop to the first item if at the end of the list
            videoPlayer.removeAllItems()
            loadVideoPlaylist()  // Reload the playlist to start over
        }
    }



    
    @objc func videoPlaybackDidFinish() {
        // Fetch questions from API
        guard let raffleAPIURL = URL(string: questionsAPIURL) else {
            fatalError("Invalid API URL")
        }
        
        URLSession.shared.dataTask(with: raffleAPIURL) { [weak self] (data, response, error) in
            guard let data = data else {
                print("Error fetching questions from API: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            do {
                // Parse questions data
                let questions = try JSONDecoder().decode([Question].self, from: data)
                
                DispatchQueue.main.async {
                    // Present questionnaire view
                    let questionnaireVC = QuestionnaireViewController(questions: questions)
                    questionnaireVC.delegate = self
                    self?.present(questionnaireVC, animated: true, completion: nil)
                }
            } catch {
                print("Error decoding questions JSON: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    // MARK: - Questionnaire Delegate

    func didSubmitAnswers(_ answers: [String]) {
        // Save player's answers
        playerAnswers = answers
        
        // Start countdown timer
        startCountdownTimer()
    }
    
    func startCountdownTimer() {
        countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimer() {
        secondsLeft -= 1
        timerLabel.text = "\(secondsLeft) seconds left"
        
        if secondsLeft == 0 {
            // Countdown timer reached zero, perform raffle
            performRaffle()
        }
    }
    
    func performRaffle() {
        // Perform raffle by calling API
        guard let raffleAPIURL = URL(string: raffleAPIURL) else {
            fatalError("Invalid API URL")
        }
        
        // Implement raffle logic...
    }
    
    // Setup countdown timer label
    func setupTimerLabel() {
        // Implement setupTimerLabel...
    }
}

// MARK: - QuestionnaireViewController

protocol QuestionnaireDelegate: AnyObject {
    func didSubmitAnswers(_ answers: [String])
}

class QuestionnaireViewController: UIViewController {
    
    // Properties
    let questions: [Question]
    weak var delegate: QuestionnaireDelegate?
    
    // Init
    init(questions: [Question]) {
        self.questions = questions
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Present questionnaire UI...
    }
}

// MARK: - Model

struct Question: Codable {
    let title: String
    let options: [String]
}

// MARK: - RaffleViewController

class RaffleViewController: UIViewController {
    
    // Properties
    var carouselView: UIImageView!
    var players: [Player]
    var winner: Player?
    
    // Timer
    var timer: Timer?
    var secondsLeft: Int = 15
    
    // Init
    init(players: [Player]) {
        self.players = players
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create carousel view
        carouselView = UIImageView(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height))
        carouselView.contentMode = .scaleAspectFit
        view.addSubview(carouselView)
        
        // Start spinning the carousel
        startSpinningCarousel()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Stop the timer when the view disappears
        timer?.invalidate()
    }
    
    func startSpinningCarousel() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    @objc func updateTimer() {
        secondsLeft -= 1
        
        // Update carousel view with random player image
        let randomIndex = Int.random(in: 0..<players.count)
        let playerImage = players[randomIndex].avatar
        carouselView.image = UIImage(named: playerImage)
        
        if secondsLeft == 0 {
            // Select winner from players who answered all questions correctly
            let correctPlayers = players.filter { $0.allAnswersCorrect }
            if let randomWinner = correctPlayers.randomElement() {
                winner = randomWinner
                showWinner()
            }
        }
    }
    
    func showWinner() {
        // Stop the timer
        timer?.invalidate()
        
        // Display winner's image with a trophy and congratulations message
        let winnerImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
        winnerImageView.center = view.center
        winnerImageView.image = UIImage(named: winner?.avatar ?? "")
        view.addSubview(winnerImageView)
        
        let trophyImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
        trophyImageView.center = CGPoint(x: view.center.x, y: view.center.y + 150)
        trophyImageView.image = UIImage(named: "trophy")
        view.addSubview(trophyImageView)
        
        let congratsLabel = UILabel(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 50))
        congratsLabel.center = CGPoint(x: view.center.x, y: view.center.y + 250)
        congratsLabel.text = "Congratulations! You've won $100!"
        congratsLabel.textAlignment = .center
        view.addSubview(congratsLabel)
    }
    
    
}

struct Player {
    let name: String
    let avatar: String
    var allAnswersCorrect: Bool
}
