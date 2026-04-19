
import Foundation
import UIKit

extension UIAlertController {
    
    static func makeNewTaskController(completion: @escaping (String) -> Void) -> UIAlertController {
        
        let alert = UIAlertController(title: "New task",
                                      message: nil,
                                      preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Enter new task"
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let addAction = UIAlertAction(title: "Add task", style: .default, handler: { _ in
            guard let textField = alert.textFields?.first,
                  let text = textField.text?.trimmingCharacters(in: .whitespaces),
                     !text.isEmpty
            else { return }
            completion(text)
        })
        
        
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        
        return alert
    }
    
    static func makeEditTaskController(titleToEdit: String, completion: @escaping (String) -> Void) -> UIAlertController {
        
        let alert = UIAlertController(title: "Edit your task", message: nil, preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.text = titleToEdit
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let confirmAction = UIAlertAction(title: "Confirm edit", style: .default) { _ in
            guard let textField = alert.textFields?.first,
                  let text = textField.text?.trimmingCharacters(in: .whitespaces),
                     !text.isEmpty
            else { return }
            completion(text)
        }
        
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        
        return alert
    }
}
