import UIKit

protocol AudioCellDelegate: AnyObject {
    func didTapPlayButton(in cell: AudioTableViewCell)
}

class AudioTableViewCell: UITableViewCell {
    
    weak var delegate: AudioCellDelegate?

    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBAction func playButtonTapped(_ sender: UIButton) {
        delegate?.didTapPlayButton(in: self)
        playButton.isEnabled = false
    }
    
    func setPlayButton(enabled: Bool) {
            playButton.isEnabled = enabled
        }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
