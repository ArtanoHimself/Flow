
import UIKit
import Combine

nonisolated enum ToDoSection: Hashable {
    case main
}

final class MainViewController: UIViewController {
    
    private let viewModel: MainViewModel
    private var cancellables = Set<AnyCancellable>()
    
    init(viewModel: MainViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private lazy var dataSource: UITableViewDiffableDataSource<ToDoSection, ToDo> = {
        let dataSource = UITableViewDiffableDataSource<ToDoSection, ToDo>( tableView: tableView)
        { tableView, indexPath, itemIdentifier in
            let cell = tableView.dequeueReusableCell(withIdentifier: ToDoCell.identifier, for: indexPath) as! ToDoCell
            cell.configure(with: itemIdentifier)
            cell.delegate = self
            return cell
        }
        return dataSource
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(ToDoCell.self, forCellReuseIdentifier: ToDoCell.identifier)
        return tableView
    }()
    
    private lazy var addToDoButton: UIBarButtonItem = {
        let button = UIBarButtonItem()
        button.image = UIImage(systemName: "plus.app")
        button.addSymbolEffect(.bounce.up.byLayer, options: .nonRepeating)
        button.isSymbolAnimationEnabled = true
        button.target = self
        button.action = #selector(addButtonTapped)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        tableView.delegate = self
        tableView.dragDelegate = self
        tableView.dropDelegate = self
        tableView.dragInteractionEnabled = true
        setupConstraints()
        setupNavigationBar()
        bindViewModel()
    }
    
    private func setupConstraints() {
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupNavigationBar() {
        title = "ToDo List"
        navigationItem.rightBarButtonItems = [addToDoButton]
    }
    
    private func bindViewModel() {
        viewModel.$todos
            .receive(on: DispatchQueue.main)
            .sink { [ weak self ] todos in
                guard let self = self else { return }
                self.applySnapshot(todos: todos)
            }
            .store(in: &cancellables)
        
        viewModel.fetchTodos()
    }
    
    private func applySnapshot(todos: [ToDo]) {
        var snapshot = NSDiffableDataSourceSnapshot<ToDoSection, ToDo>()
        snapshot.appendSections([.main])
        snapshot.appendItems(todos)
        snapshot.reconfigureItems(todos)
        dataSource.apply(snapshot, animatingDifferences: true)
    }
    
// MARK: Add ToDo
    
    @objc private func addButtonTapped() {
        
        let newTaskAlertVC = UIAlertController.makeNewTaskController { [weak self] taskTitle in
            guard let self = self else { return }
            self.viewModel.addToDo(taskTitle)
        }
        
        present(newTaskAlertVC, animated: true)
    }
}

// MARK: Delete ToDo

extension MainViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let toDo = dataSource.itemIdentifier(for: indexPath) else { return nil }
        
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completion in
            guard let self = self else { return }
            self.viewModel.deleteToDo(toDo)
            completion(true)
        }
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }

// MARK: Update ToDo
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        guard let title = dataSource.itemIdentifier(for: indexPath)?.title,
              let id = dataSource.itemIdentifier(for: indexPath)?.id else { return }
        
        let editAlertVC = UIAlertController.makeEditTaskController(titleToEdit: title) { [weak self] taskTitle in
            guard let self = self else { return }
            self.viewModel.updateToDo(id: id, title: taskTitle)
        }
        
        present(editAlertVC, animated: true)
    }
}

// MARK: Reorder ToDo

extension MainViewController: UITableViewDragDelegate {
    func tableView(_ tableView: UITableView, itemsForBeginning session: any UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        guard let toDoToDrag = dataSource.itemIdentifier(for: indexPath) else { return [] }
        let itemProvider = NSItemProvider(object: toDoToDrag.title as NSString)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = toDoToDrag
        return [dragItem]
    }
}

extension MainViewController: UITableViewDropDelegate {
    
    func tableView(_ tableView: UITableView, dropSessionDidUpdate session: UIDropSession,
                   withDestinationIndexPath destinationIndexPath: IndexPath?) -> UITableViewDropProposal {
        return UITableViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
    }
    
    func tableView(_ tableView: UITableView, performDropWith coordinator: UITableViewDropCoordinator) {
        guard let destinationIndexPath = coordinator.destinationIndexPath else { return }
        
        for item in coordinator.items {
            guard let sourceIndexPath = item.sourceIndexPath,
                  let toDo = item.dragItem.localObject as? ToDo,
                  sourceIndexPath != destinationIndexPath else { continue }
            
            var snapshot = dataSource.snapshot()
            snapshot.deleteItems([toDo])
            let allItems = snapshot.itemIdentifiers(inSection: .main)
            if destinationIndexPath.row < allItems.count {
                snapshot.insertItems([toDo], beforeItem: allItems[destinationIndexPath.row])
            } else {
                snapshot.appendItems([toDo])
            }
            dataSource.apply(snapshot, animatingDifferences: true)
            coordinator.drop(item.dragItem, toRowAt: destinationIndexPath)
            viewModel.saveReorder(toDo, index: destinationIndexPath.row)
        }
    }
}

extension MainViewController: ToDoCellDelegate {
    func didToggleSwitch(isCompleted: Bool, id: UUID) {
        viewModel.updateToDoCompletion(id: id, isCompleted: isCompleted)
    }
}
