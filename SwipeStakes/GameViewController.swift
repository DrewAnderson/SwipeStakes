// Lobby View
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
    var players: [Shopper] = []
    var winner: Shopper?
    var maxItems = 5 // Assuming a maximum number of video items to preload
    
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
    var currentIndex: Int = 0
    var index = 0
    var itemIndex = 0
    
    // MARK: - Setup Lobby Modules
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup Lobby
        setupVideoPlayer()        // Lobby Video Player Instance and End Play detector
          NotificationCenter.default.addObserver(self, selector: #selector(videoDidEnd), name: .AVPlayerItemDidPlayToEndTime, object: nil)
        setupPlayerView()         // Lobby Player View
        setupTimerLabel()         // Game play timer - fires every 15m
        setupToolbar()            // Footer Toolbar
        setupProfileButton()      // Footer Buttons
        setupButtonStack()        // Vertical Buttons
        setupVideoSwipeGestures() // Tik Tok like
  
    }
    deinit { // Lobby Video Player
          NotificationCenter.default.removeObserver(self)
      }
    func setupVideoPlayer() {
        videoPlayer = AVQueuePlayer()
        loadAndPlayVideo(at: currentIndex)
    }
    func setupPlayerView() {
           videoPlayerView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height))
           view.addSubview(videoPlayerView)
           
           let playerLayer = AVPlayerLayer(player: videoPlayer)
           playerLayer.frame = videoPlayerView.bounds
           playerLayer.videoGravity = .resizeAspectFill
           videoPlayerView.layer.addSublayer(playerLayer)
           
           let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
           videoPlayerView.addGestureRecognizer(swipeUp)
    }
    
    // MARK: - Load Lobby Video Content
    func loadAndPlayVideo(at index: Int) {
        guard let url = URL(string: playlistURLs[index]) else {
            print("Invalid URL at index: \(index)")
            return
        }
        DispatchQueue.global(qos: .userInitiated).async {
            let playerItem = AVPlayerItem(url: url)
            DispatchQueue.main.async {
                self.videoPlayer.replaceCurrentItem(with: playerItem)
                self.videoPlayer.play()
            }
        }
    }

    @objc func handleSwipe(_ gesture: UISwipeGestureRecognizer) {
        if gesture.direction == .down {
            updateIndex(forward: true)
        } else if gesture.direction == .up {
            updateIndex(forward: false)
        }
    }

    @objc func videoDidEnd(_ notification: Notification) {
        updateIndex(forward: true)
    }
    
    func updateIndex(forward: Bool) {
        if forward {
            currentIndex = (currentIndex + 1) % playlistURLs.count
        } else {
            currentIndex = (currentIndex - 1 + playlistURLs.count) % playlistURLs.count
        }
        loadAndPlayVideo(at: currentIndex)
    }
    @objc func goToNextVideo() {
        print(">> Going To Next Video")

        if videoPlayer.items().isEmpty {
            print("The playlist is empty.")
            var url = URL(string: playlistURLs[itemIndex])!
            if url == URL(string: playlistURLs[itemIndex]) {
                let playerItem = AVPlayerItem(url: url)
                print("Playlist (re)initialized starting from index: \(itemIndex)")
                if(itemIndex) > maxItems{itemIndex = 5}
                videoPlayer.insert(playerItem, after: nil) // Inserting at the end of the queue
            }
            //return
        }

        currentIndex = (currentIndex + 1) % maxItems  // Increment and wrap around if necessary
        let nextURL = playlistURLs[currentIndex]
        print("Moving to next video, index: \(currentIndex), URL: \(nextURL)")

        // Create a new player item and set it as the current item
        let nextItem = AVPlayerItem(url: URL(string: nextURL)!)
        videoPlayer.replaceCurrentItem(with: nextItem)
        print("Go To Next Video - \(nextItem) Video is playing.")
        videoPlayer.play()
    }

    @objc func goToPreviousVideo() {
        print("<< Going To Previous Video")

        if videoPlayer.items().isEmpty {
            print("The playlist is empty.")
            return
        }

        currentIndex = (currentIndex - 1 + maxItems) % maxItems  // Decrement and wrap around if necessary
        let previousURL = playlistURLs[currentIndex]
        print("Moving to previous video, index: \(currentIndex), URL: \(previousURL)")

        // Create a new player item and set it as the current item
        let previousItem = AVPlayerItem(url: URL(string: previousURL)!)
        videoPlayer.replaceCurrentItem(with: previousItem)
        videoPlayer.play()
        print("Video is now playing.")
    }

    func initializePlaylist(startingFrom index: Int) {
        videoPlayer.pause()
        videoPlayer.removeAllItems()
        
        // Create and insert new AVPlayerItems starting from the specified index
        let items = (index..<index + maxItems).map { i in
            AVPlayerItem(url: URL(string: playlistURLs[i % maxItems])!)
        }
        
        for item in items {
            videoPlayer.insert(item, after: videoPlayer.items().last)
        }
        
        videoPlayer.advanceToNextItem()
        videoPlayer.play()
        print("Playlist reinitialized starting from index \(index)")
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
        var shoppers: [Shopper]
        var winner: Shopper?
        
        // Timer
        var timer: Timer?
        var secondsLeft: Int = 15
        
        // Init
        init(shoppers: [Shopper]) {
            self.shoppers = shoppers
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
            let randomIndex = Int.random(in: 0..<shoppers.count)
            let playerImage = shoppers[randomIndex].avatar
            carouselView.image = UIImage(named: playerImage)
            
            if secondsLeft == 0 {
                // Select winner from players who answered all questions correctly
                let correctShoppers = shoppers.filter { $0.allAnswersCorrect }
                if let randomWinner = correctShoppers.randomElement() {
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

struct Shopper { //aka Player
    let name: String
    let avatar: String
    var allAnswersCorrect: Bool
    let merchant: Bool
}
