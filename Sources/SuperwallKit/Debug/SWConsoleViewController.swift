//
//  SWConsoleViewController.swift
//
//
//  Created by Jake Mor on 9/13/21.
//

import Foundation
import UIKit

final class SWConsoleViewController: UIViewController {
    var products: [StoreProduct] = []
    var tableViewCellData: [(String, Any)] = []

    lazy var productPicker: UIPickerView = {
        let picker = UIPickerView()
        picker.delegate = self
        picker.dataSource = self
        picker.translatesAutoresizingMaskIntoConstraints = false
        picker.tintColor = primaryColor
        picker.backgroundColor = lightBackgroundColor
        return picker
    }()

    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundView = nil
        tableView.backgroundColor = .clear
        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelection = false
        tableView.allowsMultipleSelection = false
        return tableView
    }()

    init(products: [StoreProduct]) {
        super.init(nibName: nil, bundle: nil)
        self.products = products
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = darkBackgroundColor
        title = "Template Variables"
        view.addSubview(tableView)
        view.addSubview(productPicker)

        NSLayoutConstraint.activate([
            productPicker.widthAnchor.constraint(equalTo: view.widthAnchor),
            productPicker.heightAnchor.constraint(equalTo: view.widthAnchor, multiplier: 0.618),
            productPicker.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            productPicker.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            tableView.widthAnchor.constraint(equalTo: view.widthAnchor),
            tableView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: productPicker.topAnchor),
            tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
        ])

        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = lightBackgroundColor
        appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = navigationController?.navigationBar.standardAppearance

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            title: "Done",
            style: .plain,
            target: self,
            action: #selector(addTapped)
        )
        navigationItem.rightBarButtonItem?.tintColor = primaryColor
        navigationItem.largeTitleDisplayMode = .never

        productPicker.reloadAllComponents()
        reloadTableView()
    }

    @objc func addTapped() {
        dismiss(animated: true, completion: nil)
    }

    func reloadTableView() {
        let index = productPicker.selectedRow(inComponent: 0)

        tableViewCellData = []
        guard products.count > index else { return }
        let product = products[index]
        for i in product.attributes {
            tableViewCellData.append(i)
        }

        tableViewCellData.sort { first, second in
            let (firstKey, _) = first
            let (secondKey, _) = second
            return firstKey < secondKey
        }

        tableView.reloadData()
    }
}

extension SWConsoleViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in _: UIPickerView) -> Int {
        1
    }

    func pickerView(_: UIPickerView, numberOfRowsInComponent _: Int) -> Int {
        products.count
    }

    func pickerView(_: UIPickerView, attributedTitleForRow row: Int, forComponent _: Int) -> NSAttributedString? {
        let attributedString = NSAttributedString(
            string: products[row].productIdentifier,
            attributes: [NSAttributedString.Key.foregroundColor: primaryColor]
        )
        return attributedString
    }

    func pickerView(_: UIPickerView, didSelectRow _: Int, inComponent _: Int) {
        reloadTableView()
    }
}

extension SWConsoleViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in _: UITableView) -> Int {
        return 1
    }

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return tableViewCellData.count
    }

    func tableView(_: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")

        let productLevels = ["primary", "secondary", "tertiary"]
        var selectedProduct: String?
        let row = productPicker.selectedRow(inComponent: 0)

        if row < productLevels.count {
            selectedProduct = productLevels[row]
        }

        let (key, value) = tableViewCellData[indexPath.row]
        cell.textLabel?.text = "\(value)"
        cell.textLabel?.textColor = .white
        let text: String
        if let selectedProduct = selectedProduct {
            text = "\(selectedProduct).\(key)"
        } else {
            text = key
        }
        cell.detailTextLabel?.text = "{{ \(text) }}"
        cell.detailTextLabel?.textColor = UIColor.white.withAlphaComponent(0.618)
        cell.backgroundView = nil
        cell.backgroundColor = .clear
        cell.contentView.backgroundColor = .clear

        return cell
    }
}
