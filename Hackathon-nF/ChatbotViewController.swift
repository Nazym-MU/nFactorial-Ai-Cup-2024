import UIKit
import AVFoundation

struct NewsSummary {
    var title: String
    var summary: String
}


class ChatbotViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, AudioCellDelegate, AVAudioPlayerDelegate {

    @IBOutlet weak var queryTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    private var summaries: [NewsSummary] = []
    var audioPlayer: AVAudioPlayer?
    weak var activeCell: AudioTableViewCell?
    
    let apiManager = APIManager.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.dataSource = self
        tableView.delegate = self

        // Register keyboard notifications
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default,  options: [.mixWithOthers, .allowAirPlay])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            print("Failed to set up audio session: \(error)")
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return summaries.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AudioTableViewCell", for: indexPath) as? AudioTableViewCell else {
            fatalError("Could not dequeue AudioTableViewCell")
        }
        let summary = summaries[indexPath.row]
        cell.titleLabel.text = summary.title
        cell.delegate = self
        return cell
    }
    
    func didTapPlayButton(in cell: AudioTableViewCell) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        let summary = summaries[indexPath.row]
        activeCell = cell
        playSpeech(from: summary.summary)
    }

    func playSpeech(from text: String) {
        APIManager.shared.synthesizeSpeech(from: text) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let data):
                    self?.playAudio(from: data)
                case .failure(let error):
                    print("Error synthesizing speech: \(error.localizedDescription)")
                    self?.activeCell?.setPlayButton(enabled: true)
                }
            }
        }
    }

    func playAudio(from data: Data) {
        do {
            audioPlayer = try AVAudioPlayer(data: data)
            audioPlayer?.delegate = self
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("Failed to play audio: \(error)")
            activeCell?.setPlayButton(enabled: true)
        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("Playback finished successfully: \(flag)")
        activeCell?.setPlayButton(enabled: true)
    }

    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print("Decode error occurred: \(String(describing: error))")
        activeCell?.setPlayButton(enabled: true)
    }


    @IBAction func sendButtonTapped(_ sender: UIButton) {
        guard let query = queryTextField.text, !query.isEmpty else {
            print("Query text field is empty.")
            return
        }
        queryTextField.resignFirstResponder()
        queryTextField.text = ""

        apiManager.fetchNews(query: query) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let summary):
                    let newsSummary = NewsSummary(title: query, summary: summary)
                    self?.summaries.append(newsSummary)
                    self?.tableView.reloadData()
                case .failure(let error):
                    print("Failed to fetch news: \(error.localizedDescription)")
                }
            }
        }
    }
}
