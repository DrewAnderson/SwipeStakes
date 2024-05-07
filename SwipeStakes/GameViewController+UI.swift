//
//  GameViewController+UI.swift
//  SwipeStakes
//
//  Created by Andrew Anderson on 5/7/24.
//
import UIKit
import AVFoundation
let maxItems = 5
var currentIndex: Int = 0
// MARK: - Footer UI Setup
extension GameViewController {
    
    func setupToolbar() {
        let toolbar = UIToolbar()
        toolbar.translatesAutoresizingMaskIntoConstraints = false  // Use Auto Layout
        view.addSubview(toolbar)

        // Adjust constraints to make toolbar flush with the screen bottom
        NSLayoutConstraint.activate([
            toolbar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            toolbar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            toolbar.bottomAnchor.constraint(equalTo: view.bottomAnchor),  // Changed from safeAreaLayoutGuide to view
            toolbar.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.07)  // Set the height of the toolbar to 10% of the screen height
        ])

        // Set the toolbar items and their configurations as previously defined
        toolbar.tintColor = UIColor.white  // Set all UIBarButtonItem to white
        let playButton = UIBarButtonItem(barButtonSystemItem: .play, target: self, action: #selector(playVideo))
        let pauseButton = UIBarButtonItem(barButtonSystemItem: .pause, target: self, action: #selector(pauseVideo))
        let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let additionalButton1 = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(refreshAction))
        let additionalButton2 = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addAction))
        let logoButton = UIButton(type: .custom)
        logoButton.setImage(UIImage(named: "SwipeStakes Icon 60x60"), for: .normal)
        logoButton.frame = CGRect(x: 0, y: 0, width: 3, height: 30)
        let logoBarButtonItem = UIBarButtonItem(customView: logoButton)

        toolbar.setItems([
            flexibleSpace,
            playButton,
            flexibleSpace,
            additionalButton1,
            flexibleSpace,
            logoBarButtonItem,
            flexibleSpace,
            additionalButton2,
            flexibleSpace,
            pauseButton,
            flexibleSpace
        ], animated: false)

        // Adjust background and alpha as needed
        toolbar.setBackgroundImage(UIImage(), forToolbarPosition: .any, barMetrics: .default)
        toolbar.backgroundColor = UIColor.blue.withAlphaComponent(0.3)
    }

    @objc func refreshAction() {
        print("Refresh button tapped")
        
    }

    @objc func addAction() {
        print("Add Action button tapped")
    }

    @objc func playVideo() {
        print("Play Video button tapped")
        videoPlayer.play()
    }

    @objc func pauseVideo() {
        print("Pause Video button tapped")
        videoPlayer.pause()
    }
    
    // MARK: - Setup Vertical Stack
    func setupProfileButton() {
            profileButton = UIButton(frame: CGRect(x: 0, y: 0, width: 240, height: 240))
            profileButton.layer.cornerRadius = 25
            profileButton.layer.borderWidth = 2
            profileButton.layer.borderColor = UIColor.white.cgColor
            profileButton.clipsToBounds = true
            profileButton.setImage(UIImage(systemName: "person.fill"), for: .normal)  // Default gray person icon
            profileButton.tintColor = .white
            profileButton.backgroundColor = .gray
            profileButton.addTarget(self, action: #selector(profileButtonTapped), for: .touchUpInside)
        }
        
        func setupButtonStack() {
            let stackView = UIStackView()
            stackView.axis = .vertical
            stackView.distribution = .fillEqually
            stackView.alignment = .center
            stackView.spacing = 10
            
            // Add profile button at the top
            stackView.addArrangedSubview(profileButton)
            
            // Create other buttons based on icons array
            for icon in icons {
                let button = UIButton()
                button.frame = CGRect(x: 0, y: 0, width: 240, height: 240)
                button.layer.cornerRadius = 20
                button.layer.borderWidth = 2
                button.layer.borderColor = UIColor.white.cgColor
                button.setImage(UIImage(systemName: icon), for: .normal)
                button.tintColor = .white
                button.backgroundColor = .clear
                stackView.addArrangedSubview(button)
            }
            
            stackView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(stackView)
            
            // Constraints
            NSLayoutConstraint.activate([
                stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
                stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
                stackView.widthAnchor.constraint(equalToConstant: 50)
            ])
        }
        
        @objc func profileButtonTapped() {
            // Handle profile button tap
            print("Profile button tapped")
        }
    
    // MARK: - Setup Swipe Interface for Lobby view
    func setupVideoSwipeGestures() {
        print("setupVideoSwipeGestures")
        let swipeUp = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeUp))
        swipeUp.direction = .up
        videoPlayerView.addGestureRecognizer(swipeUp)

        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeDown))
        swipeDown.direction = .down
        videoPlayerView.addGestureRecognizer(swipeDown)

        // Make sure the video player view can interact
        videoPlayerView.isUserInteractionEnabled = true
    }
    @objc func handleSwipeUp() {
        print("goToPreviousVideo SWIPED")
        goToPreviousVideo()
    }

    @objc func handleSwipeDown() {
        print("goToNextVideo SWIPED")
        goToNextVideo()
    }
    

    func setupPlaylist(startingFrom index: Int = 0) {
        videoPlayer.pause()
        videoPlayer.removeAllItems()

        // Add items to the player starting from the specified index
        for i in 0..<maxItems {
            let itemIndex = (index + i) % playlistURLs.count
            let url = URL(string: playlistURLs[itemIndex])!
            let playerItem = AVPlayerItem(url: url)
            videoPlayer.insert(playerItem, after: nil)
        }

        videoPlayer.advanceToNextItem()  // Start playing from the first item inserted
        videoPlayer.play()
        print("Playlist (re)initialized starting from index: \(index)")
    }

    @objc func goToNextVideo() {
        print(">> Going To Next Video")

        if videoPlayer.items().isEmpty {
            print("The playlist is empty.")
            return
        }

        currentIndex = (currentIndex + 1) % maxItems  // Increment and wrap around if necessary
        let nextURL = playlistURLs[currentIndex]
        print("Moving to next video, index: \(currentIndex), URL: \(nextURL)")

        // Create a new player item and set it as the current item
        let nextItem = AVPlayerItem(url: URL(string: nextURL)!)
        videoPlayer.replaceCurrentItem(with: nextItem)
        videoPlayer.play()
        print("Video is now playing.")
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




    
}
