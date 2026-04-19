
import UIKit

final class ToDoCell: UITableViewCell {
    
    private enum Constants {
        static let stackTop: CGFloat = 10
        static let stackLeading: CGFloat = 10
        static let stackTrailing: CGFloat = -10
        static let stackBot: CGFloat = -10
        static let stackSpacing: CGFloat = 10
    }
    
    static let identifier = "ToDoCell"
    private var id: UUID?
    weak var delegate: ToDoCellDelegate?
    
    private let taskLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        
        return label
    }()
    
    private let taskSwitch: UISwitch = {
        let switchControl = UISwitch()
        return switchControl
    }()
    
    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .equalSpacing
        stack.spacing = Constants.stackSpacing
        return stack
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        stackView.addArrangedSubview(taskLabel)
        stackView.addArrangedSubview(taskSwitch)
        taskSwitch.addTarget(self, action: #selector(switchToggled), for: .valueChanged)
        setupConstraints()
    }
    
    private func setupConstraints() {
        contentView.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: Constants.stackTop),
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: Constants.stackLeading),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: Constants.stackTrailing),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: Constants.stackBot)
        ])
    }
    
    func configure(with task: ToDo) {
        taskLabel.text = task.title
        taskSwitch.isOn = task.isCompleted
        id = task.id
    }
    
    @objc private func switchToggled() {
        guard let id = id else { return }
        delegate?.didToggleSwitch(isCompleted: taskSwitch.isOn, id: id)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        taskLabel.text = nil
        id = nil
    }
}
