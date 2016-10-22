//
//  MainViewController.swift
//  Aqua
//
//  Created by Edgard Aguirre Rozo on 10/21/16.
//  Copyright © 2016 Edgard Aguirre Rozo. All rights reserved.
//

import UIKit
import SpeechKit

struct MainViewControllerConfig {
    static let didBegingRecordingResponse = "transactionDidBeginRecording"
    static let didFinishRecordingResponse = "transactionDidFinishRecording"
    static let didReceiveRecognitionResponse = "transactionDidReceiveRecognition"
    static let didReceiveServiceResponse = "didReceiveServiceResponse"
    static let didFinishWithSuggestionResponse = "didFinishWithSuggestion"
    static let didFailWithErrorMessage = "didFailWithError"
    
    static let greetingMessage = "Good morning"//"Hello... Would you like to take a shower?"
    static let couldNotProcessMessage = "I could not hear you... Please try again."
    static let yesMessage = "Yes"
    static let timingMessage = "Ok ... For how many minutes would you like to take your shower?"
    static let startingShowerMessage = "Ok perfect! Please enjoy your shower!"
    
    static let initialLitresText = "0.0 litres"
    static let litresConsumedFormat = "%.2f litres"
}

class MainViewController: UIViewController, SKTransactionDelegate {
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var loadingIndicatorView: LoadingIndicatorView!
    @IBOutlet weak var micButton: UIButton!
    @IBOutlet weak var bottomBar: UIView!
    @IBOutlet weak var showerView: UIView!
    @IBOutlet weak var progressBarBorder: UIView!
    @IBOutlet weak var progressBarFilled: UIView!
    @IBOutlet weak var progressBarEmpty: UIView!
    @IBOutlet weak var progressBarLitresLabel: UILabel!
    @IBOutlet weak var progressBarTimeLabel: UILabel!
    @IBOutlet weak var litresUsedLabel: UILabel!
    @IBOutlet weak var endOfShowerView: UIView!
    
    let gradientStartColor = UIColor(red: 79.0/255.0, green: 79.0/255.0, blue: 255.0/255.0, alpha: 1.0)
    let gradientEndColor = UIColor(red: 149.0/255.0, green: 135.0/255.0, blue: 255.0/255.0, alpha: 1.0)
    let litersPerSecond = 0.6333
    var gradientLayer: CAGradientLayer!
    var currentLitres = 0.0
    var showerTime = 0
    var increments : Double  {
        get {
            return totalLitres / Double(showerTime)
        }
    }
    var totalLitres : Double {
        get {
            return litersPerSecond * Double(showerTime)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SpeechManager.sharedInstance.speechDelegate = self
        UIApplication.shared.statusBarStyle = .lightContent
        setupProgressBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        createGradientLayer()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        startArtificialIntelligenceInteraction()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func startArtificialIntelligenceInteraction() {
        
        let greetingClousure = { (response: NSDictionary) in
            let speech = self.processAIResponse(response: response)
            SpeechManager.sharedInstance.read(text:  speech)
            let attributtedText = attriburedString(copyString: speech)
            self.textView.attributedText = attributtedText
        }
        
        // First Interaction
        NetworkManager.sharedInstance.textRequest(withText: MainViewControllerConfig.greetingMessage, completion:  greetingClousure)
    }
    
    // MARK: - UI
    
    func toggleMicButton(visible: Bool) {
        if visible {
            micButton.isHidden = false
            loadingIndicatorView.stopAnimating()
            return
        }
        micButton.isHidden = true
        loadingIndicatorView.startAnimating()
    }
    
    func createGradientLayer() {
        gradientLayer = CAGradientLayer()
        gradientLayer.frame = self.view.bounds
        gradientLayer.colors = [gradientStartColor.cgColor, gradientEndColor.cgColor]
        self.view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    // MARK: - IBActions
    
    @IBAction func startListening(_ sender: AnyObject) {
        toggleMicButton(visible: false)
        SpeechManager.sharedInstance.listen()
    }

}

// MARK: - SKTransactionDelegate

extension MainViewController {
    
    func transactionDidBeginRecording(_ transaction: SKTransaction!) {
        log(MainViewControllerConfig.didBegingRecordingResponse)
    }
    
    func transactionDidFinishRecording(_ transaction: SKTransaction!) {
        log(MainViewControllerConfig.didFinishRecordingResponse)
    }
    
    @objc(transaction:didReceiveRecognition:) func transaction(_ transaction: SKTransaction!, didReceive recognition: SKRecognition!) {
        log(MainViewControllerConfig.didReceiveRecognitionResponse + ":\([recognition.text])")
        let recognizedText = recognition.text
        let text = textView.text + "\n\n" + "> " + recognizedText!
        let attributedText = attriburedString(copyString: text)
        
        let startIndex = recognizedText?.index((recognizedText?.startIndex)!, offsetBy: 3)
        
        if recognizedText?.substring(to: startIndex!) == "For" {
            let minutes = recognizedText?.replacingOccurrences(of: "For ", with: "").replacingOccurrences(of: " minute", with: "").replacingOccurrences(of: "s", with: "")
            let formatter = NumberFormatter()
            formatter.numberStyle = .spellOut
            formatter.locale = NSLocale(localeIdentifier: "en-US") as Locale!
            showerTime = (formatter.number(from: minutes!)?.intValue)!
        }
        
        textView.attributedText = attributedText
        toggleMicButton(visible: true)
        
        if let transaction = SpeechManager.sharedInstance.transaction {
            transaction.stopRecording()
        }
        
        let iaToUIResponseClousure = { (response: NSDictionary) in
            let textToRead = self.processAIResponse(response: response)
            SpeechManager.sharedInstance.read(text:  textToRead)
            let attributtedText = attriburedString(copyString: textToRead)
            self.textView.attributedText = attributtedText
            
            if textToRead == MainViewControllerConfig.startingShowerMessage {
                self.animateProgressBar(withDuration: Double(self.showerTime * 60))
            }
        }
        
        NetworkManager.sharedInstance.textRequest(withText: recognition.text, completion:  iaToUIResponseClousure)
        
        
    }
    
    func processAIResponse(response: NSDictionary) -> String {
        let dict = response
        let resultDictionary = dict["result"] as! NSDictionary
        let fulfillment = resultDictionary["fulfillment"] as! NSDictionary
        let speech = fulfillment["speech"] as! String
        return speech
    }
    
    func transaction(_ transaction: SKTransaction!, didReceiveServiceResponse response: [AnyHashable : Any]!) {
        log(MainViewControllerConfig.didReceiveServiceResponse + ": \(response)")
    }
    
    func transaction(_ transaction: SKTransaction!, didFinishWithSuggestion suggestion: String) {
        log(MainViewControllerConfig.didFinishWithSuggestionResponse)
    }
    
    func transaction(_ transaction: SKTransaction!, didFailWithError error: Error!, suggestion: String!) {
        log(MainViewControllerConfig.didFailWithErrorMessage + ": \(error.localizedDescription)")
        SpeechManager.sharedInstance.read(text: MainViewControllerConfig.couldNotProcessMessage)
        toggleMicButton(visible: true)
        SpeechManager.sharedInstance.resetTransaction()
    }
}

// MARK: - ProgressBar

extension MainViewController {
    
    func setupEndOfShowerScreen() {
        endOfShowerView.alpha = 1.0
        
    }
    
    func setupProgressBar() {
        progressBarBorder.layer.cornerRadius = progressBarBorder.frame.size.height / 2
        progressBarBorder.layer.masksToBounds = true
        progressBarFilled.layer.cornerRadius = progressBarFilled.frame.size.height / 2
        progressBarFilled.layer.masksToBounds = true
        progressBarEmpty.layer.cornerRadius = progressBarEmpty.frame.size.height / 2
        progressBarEmpty.layer.masksToBounds = true
    }
    
    func animateProgressBar(withDuration time: TimeInterval){
        
        let progressBarAnimation = { [unowned self] in
            let finalSize = self.progressBarEmpty.frame.size
            self.progressBarFilled.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: finalSize)
        }
        
        let removeTextViewAnimations = {[unowned self] in
            self.textView.alpha = 0.0
            self.showerView.alpha = 1.0
        }
        
        
        let setupProgressBarClouser = { (finished: Bool) in
            
            NetworkManager.sharedInstance.makeOpenRequest(completion: { (array) in
                
            })
            
            self.showerTime = Int(time / 10)
            let minutes = time / 60
            self.progressBarTimeLabel.text = "\(minutes) min"
            self.progressBarLitresLabel.text = MainViewControllerConfig.initialLitresText
            let initialSize = CGSize(width: 0, height: self.progressBarFilled.frame.size.height)
            self.progressBarFilled.frame = CGRect(origin: CGPoint(x: 0, y: 0), size: initialSize)
            let timer = Timer.scheduledTimer(timeInterval: 1, target:self, selector: #selector(MainViewController.updateProgressBarLitresLabel), userInfo: nil, repeats: true)
            let bringEndOfShowerAnimations = {[unowned self] in
                self.showerView.alpha = 0.0
                self.litresUsedLabel.text = String(self.totalLitres)
                self.endOfShowerView.alpha = 1.0
                UIView.animate(withDuration: 10.0, animations: {
                    print("OK")
                    
                    }, completion: { (Bool) in
                        self.endOfShowerView.alpha = 0.0
                        self.textView.alpha = 1.0
                        
                })
            }
            let progressBarCompletionClousure = { (finished: Bool) in
                timer.invalidate()
                NetworkManager.sharedInstance.makeCloseRequest(completion: { (array) in })
                bringEndOfShowerAnimations()
            }
            UIView.animate(withDuration: time, animations: progressBarAnimation, completion : progressBarCompletionClousure)
        }
        
        UIView.animate(withDuration: 0.3, animations: removeTextViewAnimations, completion : setupProgressBarClouser)
    }
    
    func updateProgressBarLitresLabel() {
        currentLitres = currentLitres + increments
        let format = MainViewControllerConfig.litresConsumedFormat
        progressBarLitresLabel.text = String(format: format, currentLitres)
    }
}
