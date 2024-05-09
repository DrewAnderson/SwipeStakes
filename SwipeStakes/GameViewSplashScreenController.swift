//
//  GameViewSplashScreenController.swift
//  SwipeStakes
//
//  Created by Andrew Anderson on 5/8/24.
//
import AVFoundation
import UIKit
var audioPlayer: AVAudioPlayer?


class SplashViewController: UIViewController {
    
    let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "TVI Bag Logo")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "SwipeStakes"
        label.font = UIFont.systemFont(ofSize: 28, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    let footerLabel: UILabel = {
        let label = UILabel()
        label.text = "(C) 2024 TVI Corporation."
        label.font = UIFont.systemFont(ofSize: 10)  // Tiny font size
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackground()
        setupViews()
        animateLogo()
        //playSound(fileName: "moneysoundfx", fileType: "mp3")
        playSound()
    }
    
    func setupBackground() {
        view.addSubview(backgroundView)
        backgroundView.frame = view.bounds
        animateFloatingDollarSigns()
    }
    
    func animateFloatingDollarSigns() {
        let emitter = CAEmitterLayer()
        emitter.emitterPosition = CGPoint(x: view.frame.size.width / 2, y: view.frame.size.height / 2)
        emitter.emitterShape = .rectangle
        emitter.emitterSize = view.frame.size  // Cover the whole view

        let cell = CAEmitterCell()
        cell.contents = UIImage(named: "dollarsign")?.cgImage
        cell.birthRate = 5  // Increase for more frequent particle generation
        cell.lifetime = 5.0
        cell.velocity = 210  // Increase velocity for faster movement
        cell.velocityRange = 100
        cell.emissionLongitude = -.pi  // Emitting in all directions
        cell.emissionRange = .pi * 2  // Full circular emission
        cell.spin = 2.0  // Faster spin
        cell.scale = 0.14  // small scale
        cell.scaleRange = 0.04  // Some variation in size
        cell.alphaRange = 0.5  // Range of transparency to apply
        cell.alphaSpeed = -0.3  // Speed at which the particle’s alpha value decreases, making it fade out


        emitter.emitterCells = [cell]
        view.layer.addSublayer(emitter)
    }


    
    func setupViews() {
        view.addSubview(logoImageView)
        view.addSubview(titleLabel)
        view.addSubview(footerLabel)
        
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        footerLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            logoImageView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -30),
            logoImageView.widthAnchor.constraint(equalToConstant: 200),
            logoImageView.heightAnchor.constraint(equalToConstant: 200),
            
            titleLabel.topAnchor.constraint(equalTo: logoImageView.bottomAnchor, constant: 20),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            footerLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10),
            footerLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            footerLabel.leftAnchor.constraint(equalTo: view.leftAnchor),
            footerLabel.rightAnchor.constraint(equalTo: view.rightAnchor)
        ])
    }
    
    func animateLogo() {
        // Starting with a scale of 0
        logoImageView.transform = CGAffineTransform(scaleX: 0, y: 0)
        
        // Animation to scale up the logo
        UIView.animate(withDuration: 2.5, delay: 0.5, usingSpringWithDamping: 0.5, initialSpringVelocity: 2, options: .curveEaseInOut, animations: {
            self.logoImageView.transform = CGAffineTransform.identity
        }) { _ in
            UIView.animate(withDuration: 2.5, animations: {
                self.titleLabel.alpha = 1
                self.footerLabel.alpha = 1
            }) { _ in
                self.transitionToMainInterface()
            }
        }
    }
    
    func transitionToMainInterface() {
        // Delay the transition to extend splash screen time to 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            if let window = self.view.window {
                let mainViewController = GameViewController() // Assume GameViewController exists
                window.rootViewController = mainViewController
            }
        }
    }
    /*func playSound(fileName: String, fileType: String) {
        let subfolderName = "Sounds"
        if let resourcePath = Bundle.main.resourcePath {
            let soundsPath = resourcePath + "/Sounds"
            do {
                let soundFiles = try FileManager.default.contentsOfDirectory(atPath: soundsPath)
                print("All sound files in bundle: \(soundFiles)")
            } catch {
                print("Error while enumerating files \(soundsPath): \(error.localizedDescription)")
            }
        }
        guard let folderPath = Bundle.main.resourcePath?.appending("/\(subfolderName)") else {
            print("Error: Could not construct folder path.")
            return
        }
        let filePath = URL(fileURLWithPath: folderPath).appendingPathComponent("\(fileName).\(fileType)").path

        // Check if file exists before trying to play it
        if FileManager.default.fileExists(atPath: filePath) {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: URL(fileURLWithPath: filePath))
                audioPlayer?.prepareToPlay()
                audioPlayer?.play()
            } catch {
                print("Error: Failed to initialize audio player with error \(error), File Path: \(filePath)")
            }
        } else {
            print("File does not exist at path: \(filePath)")
        }
    }*/
    func playSound() {
        //fileName: "moneysoundfx", fileType: "mp3"
           if let path = Bundle.main.path(forResource: "money-soundfx", ofType: "mp3") {
               let url = URL(fileURLWithPath: path)
               print("Play Sound path \(url)")
               do {
                   // Set up audio session
                   try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
                   try AVAudioSession.sharedInstance().setActive(true)
                   
                   // Initialize audio player and play
                   audioPlayer = try AVAudioPlayer(contentsOf: url)
                   audioPlayer?.play()
               } catch let error {
                   print("Could not play sound file. Error: \(error.localizedDescription)")
               }
           }
       }


}
