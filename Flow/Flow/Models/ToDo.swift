
import Foundation

nonisolated struct ToDo: Hashable, Codable {
    let id: UUID
    var title: String
    var isCompleted: Bool
    var updatedAt: Date
    
    init(title: String) {
        self.id = UUID()
        self.title = title
        self.isCompleted = false
        self.updatedAt = Date()
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: ToDo, rhs: ToDo) -> Bool {
        lhs.id == rhs.id
    }
}
