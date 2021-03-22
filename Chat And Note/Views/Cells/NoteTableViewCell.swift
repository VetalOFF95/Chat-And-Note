//
//  NoteTableViewCell.swift
//  Chat And Note
//
//  Created by  Vitalii on 21.03.2021.
//

import UIKit

class NoteTableViewCell: UITableViewCell {
    
    static let identifier = "NoteTableViewCell"

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 21, weight: .semibold)
        return label
    }()

    private let categoryLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 19, weight: .regular)
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(titleLabel)
        contentView.addSubview(categoryLabel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        titleLabel.frame = CGRect(x: 10,
                                y: 10,
                                     width: contentView.width - 20,
                                     height: (contentView.height-30)/2)

        categoryLabel.frame = CGRect(x: 10,
                                    y: titleLabel.bottom+10,
                                     width: contentView.width - 20,
                                     height: (contentView.height-30)/2)
    }

    public func configure(with model: Note) {
        titleLabel.text = model.title
        categoryLabel.text = model.parentCategory
    }

    
}
