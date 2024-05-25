import UIKit

class SharedDataService {
    static let shared = SharedDataService()
    var audioURL: URL?
}


class ChatbotViewController: UIViewController {
    @IBOutlet weak var queryTextField: UITextField!

    let apiManager = APIManager.shared
    
    @IBAction func sendButtonTapped(_ sender: UIButton) {
        guard let query = queryTextField.text, !query.isEmpty else {
            print("Query text field is empty.")
            return
        }
        apiManager.fetchNews(query: query) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let newsData):
                    self?.synthesizeNewsAndNavigate(newsData: newsData)
                case .failure(let error):
                    print("Failed to fetch news: \(error.localizedDescription)")
                }
                self?.queryTextField.text = ""
            }
        }
    }

    func synthesizeNewsAndNavigate(newsData: String) {
        apiManager.synthesizeSpeech(from: newsData) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let audioURL):
                    SharedDataService.shared.audioURL = audioURL
                    self?.tabBarController?.selectedIndex = 1 
                case .failure(let error):
                    print("Failed to synthesize speech: \(error.localizedDescription)")
                }
            }
        }
    }


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showAudioLibrary",
           let destinationVC = segue.destination as? AudioLibraryViewController,
           let audioURL = sender as? URL {
            destinationVC.audioURL = audioURL
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
