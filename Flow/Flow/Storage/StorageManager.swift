
import Foundation

final class StorageManager {
    
    let storage: Storage
    
    init(storage: Storage) {
        self.storage = storage
    }
    
    func getData() -> [ToDo] {
        storage.getData()
    }
    
    func addTarget(target: ToDo) {
        storage.addTarget(target: target)
    }
    
    func deleteTarget(target: ToDo) {
        storage.deleteTarget(target: target)
    }
    
    func updateTargetTitle(id: UUID, title: String) {
        storage.updateTargetTitle(id: id, title: title)
    }
    
    func updateTargetCompletion(id: UUID, isCompleted: Bool) {
        storage.updateTargetCompletion(id: id, isCompleted: isCompleted)
    }
    
    func reorderTarget(target: ToDo, index: Int) {
        storage.reorderTarget(target: target, index: index)
    }
}
