
import Foundation
import Combine

final class MainViewModel {
    
    @Published private(set) var todos: [ToDo] = []
    
    private let storageManager: StorageManager
    
    init(storageManager: StorageManager) {
        self.storageManager = storageManager
    }
    
    func fetchTodos() {
        todos = storageManager.getData()
    }
    
    func addToDo(_ title: String) {
        let toDo = ToDo(title: title)
        storageManager.addTarget(target: toDo)
        fetchTodos()
    }
    
    func deleteToDo(_ toDo: ToDo) {
        storageManager.deleteTarget(target: toDo)
        fetchTodos()
    }
    
    func updateToDo(id: UUID, title: String) {
        storageManager.updateTargetTitle(id: id, title: title)
        fetchTodos()
    }
    
    func saveReorder(_ toDo: ToDo, index: Int) {
        storageManager.reorderTarget(target: toDo, index: index)
    }
    
    func updateToDoCompletion(id: UUID, isCompleted: Bool) {
        storageManager.updateTargetCompletion(id: id, isCompleted: isCompleted)
        fetchTodos()
    }
}
