//
//  StartPracticeSmilingViewController.swift
//  Joey
//
//  Created by Toriq Wahid Syaefullah on 22/10/20.
//

import UIKit
import ARKit

class StartPracticeSmilingViewController: UIViewController {
    
    @IBOutlet weak var labelSmile: UILabel!
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var labelInstruction: UILabel!
    @IBOutlet weak var navBar: NavigationBar!
    var progressBarTimer: Timer!
    var isRunning = false
    var isSmile = false
    
    var countdownTimer: Timer!
    var totalTime = 60
    var emotion: FollowUp.EmotionType?
    
    let notification = UINotificationFeedbackGenerator()
    
    var imageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.image = UIImage(named: "page_background3")
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI(){
        startTimer()
        navBar.delegate = self
        sceneView.delegate = self
//        progressView.progress = 0.0
//        progressView.layer.cornerRadius = 4
        self.view.insertSubview(imageView, at: 0)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        let configuration = ARFaceTrackingConfiguration()
        configuration.isLightEstimationEnabled = true
        sceneView.session.run(configuration)
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        sceneView.session.pause()
        countdownTimer.invalidate()
    }
    
    func handleSmile(smileValue: CGFloat) {
        if smileValue > 0.2 {
            isSmile = true
        }
        else {
            isSmile = false
        }
    }
    
    
    func startTimer() {
        countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateTime), userInfo: nil, repeats: true)
    }
    
    @objc func updateTime() {
        navBar.labelTitle.text = "\(timeFormatted(totalTime))"
        if totalTime < 55 && totalTime > 10 {
            DispatchQueue.main.async {
                if self.isSmile {
                    self.notification.notificationOccurred(.success)
                    self.labelInstruction.text = "Your smile is cool, right? Hold on your smile for 5 seconds!"
                } else {
                    self.labelInstruction.text = "Think of something positive about yourself and try to smile naturally"
                }
            }
        }
        else if totalTime < 10 && totalTime > 0 {
            labelInstruction.text = "Almost there.."
        }
        
        
        if totalTime != 0 {
            totalTime -= 1
        } else {
            endTimer()
            performSegue(withIdentifier: "toAfterActivity", sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? AfterActivityViewController, let emotion = emotion {
            vc.activityInstruction = activitiesInstructionArray[1]
            vc.data = FollowUp(emotion: emotion)
        }
    }
    
    func endTimer() {
        countdownTimer.invalidate()
    }
    
    func timeFormatted(_ totalSeconds: Int) -> String {
        let seconds: Int = totalSeconds % 60
        let minutes: Int = (totalSeconds / 60) % 60
        //     let hours: Int = totalSeconds / 3600
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

// MARK: - ARSCNView Delegate

extension StartPracticeSmilingViewController: ARSCNViewDelegate {
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let faceAnchor = anchor as? ARFaceAnchor else {
            return
        }
        
        let data = FaceData(faceAnchor)
        
        if data.browDownRight > 0.3 && data.browDownLeft > 0.3 {
            emotion = .angry
        } else if data.mouthFrownRight > 0.3 && data.mouthFrownLeft > 0.3 {
            emotion = .sad
        } else if data.mouthSmileRight > 0.3 && data.mouthSmileLeft > 0.3 {
            emotion = .happy
        } else {
            emotion = .neutral
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            self.handleSmile(smileValue: CGFloat((data.mouthSmileLeft + data.mouthSmileRight)/2.0))
        }
//
//        let workItem = DispatchWorkItem {
//            self.handleSmile(smileValue: CGFloat((data.mouthSmileLeft + data.mouthSmileRight)/2.0))
//        }
//        DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: workItem)
        
    }
}
