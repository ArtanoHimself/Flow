
import Foundation

final class UserDefaultsStorage: Storage {
    
    let defaults = UserDefaults.standard
    let key = "ToDoList"
    let encoder = JSONEncoder()
    let decoder = JSONDecoder()
    
    func getData() -> [ToDo] {
        guard let data = defaults.data(forKey: key) else { return [] }
        guard let decodedData = try? decoder.decode([ToDo].self, from: data) as [ToDo] else { return [] }
        return decodedData
    }
    
    func addTarget(target: ToDo) {
        var recievedData = getData()
        recievedData.append(target)
        let encodedData = try? encoder.encode(recievedData)
        defaults.setValue(encodedData, forKey: key)
        
    }
    
    func deleteTarget(target: ToDo) {
        var recievedData = getData()
        let id = target.id
        
        recievedData.removeAll { $0.id == id }
        let encodedData = try? encoder.encode(recievedData)
        defaults.setValue(encodedData, forKey: key)
    }
    
    func updateTargetTitle(id: UUID, title: String) {
        var recievedData = getData()
        guard let index = recievedData.firstIndex(where: { $0.id == id }) else { return }
        
        recievedData[index].title = title
        recievedData[index].updatedAt = Date()
        let encodedData = try? encoder.encode(recievedData)
        defaults.setValue(encodedData, forKey: key)
    }
    
    func updateTargetCompletion(id: UUID, isCompleted: Bool) {
        var recievedData = getData()
        guard let index = recievedData.firstIndex(where: { $0.id == id }) else { return }
        
        recievedData[index].isCompleted = isCompleted
        recievedData[index].updatedAt = Date()
        
        let encodedData = try? encoder.encode(recievedData)
        defaults.setValue(encodedData, forKey: key)
    }
    
    func reorderTarget(target: ToDo, index: Int) {
        var recievedData = getData()
        recievedData.removeAll { $0.id == target.id }
        if index < recievedData.count {
            recievedData.insert(target, at: index)
        } else {
            recievedData.append(target)
        }
        let encodedData = try? encoder.encode(recievedData)
        defaults.setValue(encodedData, forKey: key)
    }
}
