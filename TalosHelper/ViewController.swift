import UIKit

private let hexAttributes: [String : AnyObject] = [
    NSForegroundColorAttributeName : UIColor.blueColor()
]

class ViewController: UIViewController {

    @IBOutlet var textView: UITextView!
    @IBOutlet var buttons: [UIButton]!
    @IBOutlet var clearButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        assert(buttons.count == 16, "Invalid nib")
        buttons.sortInPlace { a, b in
            a.titleLabel!.text! < b.titleLabel!.text!
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private var decodedText = ""
    private var hexCharacters = 0
    private var currentHex = 0

    private func refreshText() {
        if hexCharacters == 2 {
            decodedText.append(UnicodeScalar(currentHex))
            currentHex = 0
            hexCharacters = 0
        }

        let hex = NSAttributedString(string: currentHex.toHex(hexCharacters), attributes: hexAttributes)
        let text = NSMutableAttributedString(string: decodedText)
        text.appendAttributedString(hex)
        textView.attributedText = text
        textView.font = UIFont.systemFontOfSize(15)
        clearButton.hidden = decodedText.characters.count == 0 && hexCharacters == 0
    }

    @IBAction func clearClick(sender: AnyObject) {
        currentHex = 0
        hexCharacters = 0
        decodedText = ""
        refreshText()
    }

    @IBAction func buttonClick(sender: UIButton) {
        guard let i = buttons.indexOf(sender) where 0...15 ~= i else {
            print("invalid sender")
            return
        }

        currentHex = (currentHex << 4) | i
        hexCharacters++
        refreshText()
    }

    @IBAction func backspaceClick(sender: AnyObject) {
        if hexCharacters == 0 {
            guard decodedText.characters.count > 0 else {
                return
            }
            let lastChar: UnicodeScalar = decodedText.unicodeScalars.last!
            decodedText = decodedText.withoutLastCharacter()
            currentHex = Int(lastChar.value)
            hexCharacters = 2
        }
        currentHex = currentHex >> 4
        hexCharacters--
        refreshText()
    }
}

private extension Int {
    func toHex(length: Int) -> String {
        let s = String(format:"%0\(length)X", self).characters.suffix(length)
        return String(s)
    }
}

private extension String {
    func withoutLastCharacter() -> String {
        guard self.characters.count > 0 else {
            return self
        }
        return self.substringToIndex(self.startIndex.advancedBy(self.characters.count-1))
    }
}

