
import Foundation

protocol Storage {
    func getData() -> [ToDo]
    func addTarget(target: ToDo)
    func deleteTarget(target: ToDo)
    func updateTargetTitle(id: UUID, title: String)
    func updateTargetCompletion(id: UUID, isCompleted: Bool)
    func reorderTarget(target: ToDo, index: Int)
}

protocol ToDoCellDelegate: AnyObject {
    func didToggleSwitch(isCompleted: Bool, id: UUID)
}



