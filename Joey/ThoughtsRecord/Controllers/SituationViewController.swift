//
//  SituationViewController.swift
//  Joey
//
//  Created by Setiawan Joddy on 26/10/20.
//

import UIKit

class SituationViewController: UIViewController, UITextViewDelegate {
    
    @IBOutlet weak var navBar: NavigationBar!
    
    var data = ThoughtsRecordTemp()
    
    var imageView: UIImageView = {
        let imageView = UIImageView(frame: .zero)
        imageView.image = UIImage(named: "page_background3")
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    @IBOutlet weak var textViewSituationAnswer: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        textViewPlaceholder()
        dismissKeyboardOnScreen()
        
        // Do any additional setup after loading the view.
    }
    
    @IBAction func onClickContinueButton(_ sender: Any) {
        if textViewSituationAnswer.text == "Type your answer here" {
            //textViewSituationAnswer.text = ""
            let alert = AlertHelper.createAlert(title: "Oops!", message: "Please tell me what's on your mind before we go on", onComplete: nil)
            alert.view.tintColor = #colorLiteral(red: 0.3529411765, green: 0.7607843137, blue: 0.7411764706, alpha: 1)
            present(alert, animated: true, completion: nil)
        }
        guard let answer = textViewSituationAnswer?.text else { return }
        data.situation = answer
        performSegue(withIdentifier: "toMoods", sender: nil)
    }
    
    func setupUI(){
        
        navBar.delegate = self
        navBar.labelIndicator.text = "1/7"
        self.view.insertSubview(imageView, at: 0)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.topAnchor),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func dismissKeyboardOnScreen() {
        let tapOnScreen: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        
        tapOnScreen.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tapOnScreen)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func textViewPlaceholder() {
        textViewSituationAnswer.delegate = self
        textViewSituationAnswer.text = "Type your answer here"
        textViewSituationAnswer.textColor = UIColor.lightGray
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textViewSituationAnswer.textColor == UIColor.lightGray {
            textViewSituationAnswer.text = nil
            textViewSituationAnswer.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textViewSituationAnswer.text.isEmpty {
            textViewSituationAnswer.text = "Type your answer here"
            textViewSituationAnswer.textColor = UIColor.lightGray
        }
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if ((notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue) != nil {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= 175
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? MoodsViewController {
            vc.data = data
        }
    }
    

}
