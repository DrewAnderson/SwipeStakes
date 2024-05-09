//
//  GameViewController+UI.swift
//  SwipeStakes
//  Created by Andrew Anderson on 5/7/24.
//
import UIKit
import AVFoundation
let maxItems = 5

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
        //goToNextVideo()
    }

    @objc func addAction() {
        print("Add Action button tapped")
    }

    @objc func playVideo() {
        print("Play Next Video button tapped")
        //videoPlayer.play()
        goToNextVideo()
    }

    @objc func pauseVideo() {
        print("Pause Video button tapped")
        videoPlayer.pause()
        //goToPreviousVideo()
    }
    
    // MARK: - Setup Vertical Toolbar Stack
        func setupProfileButton() {
            profileButton = UIButton(frame: CGRect(x: 0, y: 0, width: 140, height: 140)) // Increased size
            profileButton.layer.cornerRadius = 3 // Adjusted for larger size
            //profileButton.layer.borderWidth = 2
            //profileButton.layer.borderColor = UIColor.white.cgColor
            profileButton.clipsToBounds = true
            profileButton.setImage(UIImage(systemName: "person.fill"), for: .normal)
            profileButton.tintColor = .white
            profileButton.backgroundColor = .clear
            profileButton.addTarget(self, action: #selector(profileButtonTapped), for: .touchUpInside)
        }

        func setupButtonStack() {
            let stackView = UIStackView()
            stackView.axis = .vertical
            stackView.distribution = .fillEqually
            stackView.alignment = .fill  // Change alignment to fill to stretch buttons to fit the stack view's width
            stackView.spacing = 20  // Maintain the increased spacing for aesthetics

            // Add profile button at the top
            stackView.addArrangedSubview(profileButton)

            // Create other buttons based on icons array
            for icon in icons {
                let button = UIButton()
                button.frame = CGRect(x: 0, y: 0, width: 100, height: 100)  // Button size increased for visibility
                button.layer.cornerRadius = 3  // Adjust corner radius proportionally
                //button.layer.borderWidth = 2
                //button.layer.borderColor = UIColor.white.cgColor
                button.setImage(UIImage(systemName: icon), for: .normal)
                button.tintColor = .white
                button.backgroundColor = .clear
                stackView.addArrangedSubview(button)
            }

            stackView.translatesAutoresizingMaskIntoConstraints = false
            view.addSubview(stackView)

            // Adjusted constraints for flush right alignment
            NSLayoutConstraint.activate([
                stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0), // Ensure there is no constant offset
                stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),  // Center vertically in the view
                stackView.widthAnchor.constraint(equalToConstant: 50)  // Match width of buttons
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
    
}
