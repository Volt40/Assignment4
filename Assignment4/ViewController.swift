//
//  ViewController.swift
//  Assignment4
//
//  Created by Michael Baljet on 2/4/24.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var timeRemainingLabel: UILabel!
    @IBOutlet weak var button: UIButton!
    
    var countdownTimer: Timer?
    var player: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set the initial date label to the current date
        updateDateLabel(date: Date())
        
        // Start a timer to update the clock every second
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            self?.updateDateLabel(date: Date())
        }
    }

    @IBAction func onButton(_ sender: Any) {
        // Reset button if nessesary
        if (button.titleLabel?.text == "Stop Music") {
            button.setTitle("Start Timer", for: .normal)
            stopMusic()
            return
        }
        if countdownTimer == nil {
            startTimer()
        } else {
            stopTimer()
            stopMusic()
        }
    }
    
    func startTimer() {
        countdownTimer?.invalidate()
        button.isEnabled = false;
        
        // Start a new timer
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            self?.updateTimeRemaining()
        }
        
        // Update the initial time
        updateTimeRemaining()
        
        // Start playing music when the timer is done
        let timeInterval = datePicker.date.timeIntervalSince(Date())
        DispatchQueue.main.asyncAfter(deadline: .now() + timeInterval) { [weak self] in
            self?.stopTimer()
            self?.playMusic()
        }
    }
    
    func stopTimer() {
        // Stop the countdown timer
        countdownTimer?.invalidate()
        countdownTimer = nil
        
        // Reset the time remaining label
        timeRemainingLabel.text = "Time Remaining: 00:00:00:00"
        button.setTitle("Stop Music", for: .normal)
        button.isEnabled = true;
    }
    
    func playMusic() {
        if let path = Bundle.main.path(forResource: "alarm", ofType: "mp3") {
            let url = URL(fileURLWithPath: path)
            do {
                player = try AVAudioPlayer(contentsOf: url)
                player?.play()
            } catch {
                print("Error playing music: \(error.localizedDescription)")
            }
        } else {
            print("alarm.mp3 not found")
        }
    }
    
    func stopMusic() {
        player?.stop()
    }
    
    func updateDateLabel(date: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, dd MMM yyyy HH:mm:ss"
        dateLabel.text = dateFormatter.string(from: date)
    }
    
    func updateTimeRemaining() {
        let currentDate = Date()
        let selectedDate = datePicker.date
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.day, .hour, .minute, .second], from: currentDate, to: selectedDate)
        
        guard let days = components.day, let hours = components.hour, let minutes = components.minute, let seconds = components.second else {
            return
        }
        let timeRemainingString = String(format: "%02d:%02d:%02d:%02d", days, hours, minutes, seconds)
        timeRemainingLabel.text = "Time Remaining: \(timeRemainingString)"
    }
}


