import UIKit

class AudioTableViewCell: UITableViewCell {
    weak var delegate: AudioCellDelegate?

    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var pauseButton: UIButton!
    @IBOutlet weak var progressSlider: UISlider!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
 
protocol AudioCellDelegate: AnyObject {
    func didTapPlay(for cell: AudioTableViewCell)
    func didTapPause(for cell: AudioTableViewCell)
    func sliderValueChanged(to value: Float, for cell: AudioTableViewCell)
}
