import UIKit
import AVFoundation

class AudioLibraryViewController: UIViewController {
    var audioPlayer: AVAudioPlayer?
    var audioURL: URL?

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupAudioPlayer()
    }

    func setupAudioPlayer() {
        if let url = SharedDataService.shared.audioURL {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.prepareToPlay()
            } catch {
                print("Error initializing the audio player: \(error)")
            }
        }
    }

    @IBAction func playButtonTapped(_ sender: UIButton) {
        audioPlayer?.play()
    }
}
