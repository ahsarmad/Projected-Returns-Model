import UIKit

extension UITextField {

    func addDoneButton () {
        let screenWidth = UIScreen.main.bounds.width
        let doneToolBar: UIToolBar(frame: .init(x: 0, y: 0, width: screenWidth, height: 50))
        doneToolBar.barStyle = .default
        let flexBarButtonItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBarButtonItem = UIBarButtonItem(title: "Done", style: .done, target: self, action: 
            #selector(dismissKeyboard))
        let items = [flexBarButtonItem, doneBarButtonItem]
        doneToolBar.items = items
        doneToolBar.sizeToFit()
        inputAccessoryView = doneToolBar
    }

    @objc private func dismissKeyboard() {
        resignFirstResponder()
    }   
    
}