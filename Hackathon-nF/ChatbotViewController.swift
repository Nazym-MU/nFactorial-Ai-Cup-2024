import UIKit
import AVFoundation

class SharedDataService {
    static let shared = SharedDataService()
    var audioSummaries: [AudioSummary] = []
    
    func addAudioSummary(_ summary: AudioSummary) {
        audioSummaries.append(summary)
    }
}

class ChatbotViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var queryTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!

    let apiManager = APIManager.shared
    var audioPlayer: AVAudioPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    @IBAction func sendButtonTapped(_ sender: UIButton) {
        guard let query = queryTextField.text, !query.isEmpty else {
            print("Query text field is empty.")
            return
        }
        queryTextField.text = ""
        apiManager.fetchNews(query: query) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let newsData):
                    self?.synthesizeNewsAndNavigate(newsData: newsData)
                case .failure(let error):
                    print("Failed to fetch news: \(error.localizedDescription)")
                }
            }
        }
    }

    func synthesizeNewsAndNavigate(newsData: String) {
        apiManager.synthesizeSpeech(from: newsData) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let audioURL):
                    let newSummary = AudioSummary(title: "Latest News", summary: newsData, audioURL: audioURL)
                    print(newSummary)
                    SharedDataService.shared.addAudioSummary(newSummary)
                    self?.tableView.reloadData()
                case .failure(let error):
                    print("Failed to synthesize speech: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return SharedDataService.shared.audioSummaries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AudioTableViewCell", for: indexPath)
        let summary = SharedDataService.shared.audioSummaries[indexPath.row]
        cell.textLabel?.text = summary.title
        return cell
    }
     
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let summary = SharedDataService.shared.audioSummaries[indexPath.row]
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: summary.audioURL)
            audioPlayer?.prepareToPlay()
            audioPlayer?.play()
        } catch {
            print("Error playing audio: \(error)")
        }
    }
}
