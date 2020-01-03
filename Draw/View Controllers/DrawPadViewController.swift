//
//  ViewController.swift
//  Draw
//
//  Created by Nate Madera on 1/1/20.
//  Copyright © 2020 Nate Madera. All rights reserved.
//

import UIKit

class DrawPadViewController: UIViewController {
    
    // MARK: UI Elements
    private var backgroundImageView: UIImageView!
    private var colorCollectionView: UICollectionView!
    private var canvas: CanvasProtocol!
    
    // MARK: Properties
    private var viewModel: DrawPadViewModelProtocol
    
    // MARK: Constants
    private enum Constants {
        enum ColorCollectionView {
            static let identifier = "colorCell"
            static let spacing = CGFloat(10.0)
            static let itemSize = CGSize(width: 50.0, height: 50.0)
            static let insets = UIEdgeInsets(top: 0.0, left: 15.0, bottom: 0.0, right: 15.0)
        }
    }

    // MARK: Initializers
    init(viewModel: DrawPadViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        selectInitialColor()
    }
}

// MARK: - Actions
extension DrawPadViewController {
    @objc func tappedPaintBrush() {
        canvas.setDrawTool(.paintBrush)
                
        updateToolBarItems(for: .paintBrush)
        
        showColorCollectionView(true)
    }
    
    @objc func tappedEraser() {
        canvas.setDrawTool(.eraser)
        
        updateToolBarItems(for: .eraser)
        
        showColorCollectionView(false)
    }
    
    @objc func tappedCamera() {
        showImageAlert()
    }
    
    @objc func tappedUndo() {
        canvas.undo()
    }
    
    @objc func tappedClear() {
        if canvas.hasStartedDrawing || backgroundImageView.image != nil {
            showDeleteAlert()
        }
    }
}

// MARK: - UICollectionViewDataSource
extension DrawPadViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return viewModel.numberOfItems()
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Constants.ColorCollectionView.identifier,
                                                            for: indexPath) as? ColorCell else {
            fatalError("Could not initialize ColorCell")
        }
        
        cell.set(color: viewModel.color(at: indexPath))
        
        return cell
    }
}

// MARK: - UICollectionViewDelegate
extension DrawPadViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        guard let color = viewModel.color(at: indexPath) else { return }
        
        canvas.setStrokeColor(color)
    }
}

// MARK: - UIImagePickerControllerDelegate
extension DrawPadViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            setBackgroundImage(pickedImage)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - Private Helpers
private extension DrawPadViewController {
    // MARK: Alerts
    func showDeleteAlert() {
        present(getDeleteAlertController(), animated: true, completion: nil)
    }
    
    func showImageAlert() {
        present(getImageAlertController(), animated: true, completion: nil)
    }
    
    // MARK: Pickers
    func showCameraPicker() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            present(getCameraImagePicker(), animated: true, completion: nil)
        }
    }
    
    func showGalleryPicker() {
        present(getGalleryImagePicker(), animated: true, completion: nil)
    }
    
    // MARK: Update UI
    func selectInitialColor() {
        let initialIndexPath = viewModel.indexPathForSelectedColor() ?? IndexPath(item: 0, section: 0)
        colorCollectionView.selectItem(at: initialIndexPath, animated: true, scrollPosition: .centeredHorizontally)
    }
    
    func setBackgroundImage(_ image: UIImage) {
        canvas.clear()
        
        backgroundImageView.image = image
    }
    
    func showColorCollectionView(_ show: Bool, animated: Bool = true) {
        UIView.animate(withDuration: 0.2) {
            self.colorCollectionView.alpha = show ? 1.0 : 0.0
        }
    }
    
    func updateToolBarItems(for drawTool: DrawTool) {
        let baseItems = [
            UIBarButtonItem(image: UIImage.Icons.photoGallery, style: .plain, target: self, action: #selector(tappedCamera)),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(image: UIImage.Icons.undo, style: .plain, target: self, action: #selector(tappedUndo)),
            UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(tappedClear))
        ]
        
        var drawItems: [UIBarButtonItem]
        
        switch drawTool {
        case .paintBrush:
            drawItems = [
                UIBarButtonItem(image: UIImage.Icons.paintBrushSelected, style: .plain, target: self, action: #selector(tappedPaintBrush)),
                UIBarButtonItem(image: UIImage.Icons.eraser, style: .plain, target: self, action: #selector(tappedEraser)),
            ]
        case .eraser:
            drawItems = [
                UIBarButtonItem(image: UIImage.Icons.paintBrush, style: .plain, target: self, action: #selector(tappedPaintBrush)),
                UIBarButtonItem(image: UIImage.Icons.eraserSelected, style: .plain, target: self, action: #selector(tappedEraser)),
            ]
        }
        
        toolbarItems = drawItems + baseItems
    }
}

// MARK: - Private Setup
private extension DrawPadViewController {
    // MARK: View Setup
    func setupView() {
        navigationController?.isNavigationBarHidden = true
        view.backgroundColor = .white
        
        // Add Views
        setupBackgroundImageView()
        setupCanvas()
        setupToolBar()
        setupColorCollectionView()
        
        // Add Constraints
        addConstraintsForBackgroundImageView()
        addConstraintsForCanvas()
        addConstraintsForColorCollectionView()
    }
    
    func setupBackgroundImageView() {
        let anImageView = UIImageView()
        anImageView.contentMode = .scaleAspectFit
        
        backgroundImageView = anImageView
        
        view.addSubview(backgroundImageView)
    }
    
    func setupCanvas() {
        let aView = Canvas()
        aView.backgroundColor = .clear
        
        canvas = aView
    
        view.addSubview(canvas)
    }
    
    func setupToolBar() {
        navigationController?.isToolbarHidden = false
        
        updateToolBarItems(for: .paintBrush)
    }
    
    func setupColorCollectionView() {
        let aLayout = UICollectionViewFlowLayout()
        aLayout.scrollDirection = .horizontal
        aLayout.itemSize = Constants.ColorCollectionView.itemSize
        aLayout.minimumLineSpacing = Constants.ColorCollectionView.spacing
        aLayout.minimumInteritemSpacing = Constants.ColorCollectionView.spacing
        aLayout.sectionInset = Constants.ColorCollectionView.insets
        
        let aCollectionView = UICollectionView(frame: .zero, collectionViewLayout: aLayout)
        aCollectionView.register(ColorCell.self, forCellWithReuseIdentifier: Constants.ColorCollectionView.identifier)
        aCollectionView.dataSource = self
        aCollectionView.delegate = self
        aCollectionView.backgroundColor = UIColor.lightGray.withAlphaComponent(0.3)
        
        colorCollectionView = aCollectionView
        
        view.addSubview(colorCollectionView)
    }
    
    // MARK: Factory Functions
    func getDeleteAlertController() -> UIAlertController {
        let alertController = UIAlertController(title: "Delete",
                                                message: "Are you sure you want to start over?",
                                                preferredStyle: .alert)
        
        let yesAction = UIAlertAction(title: "Yes", style: .default) { [weak self] (action) in
            self?.backgroundImageView.image = nil
            self?.canvas.clear()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(yesAction)
        alertController.addAction(cancelAction)
        
        return alertController
    }
    
    func getImageAlertController() -> UIAlertController {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { [weak self] (action) in
            self?.showCameraPicker()
        }
        
        let galleryAction = UIAlertAction(title: "Gallery", style: .default) { [weak self] (action) in
            self?.showGalleryPicker()
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(cameraAction)
        alertController.addAction(galleryAction)
        alertController.addAction(cancelAction)
        
        return alertController
    }
    
    func getCameraImagePicker() -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = false
        picker.sourceType = .camera
        
        return picker
    }
    
    func getGalleryImagePicker() -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = false
        picker.sourceType = .photoLibrary
        
        return picker
    }
    
    // MARK: Constraints
    func addConstraintsForBackgroundImageView() {
        backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    func addConstraintsForCanvas() {
        canvas.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            canvas.topAnchor.constraint(equalTo: view.topAnchor),
            canvas.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            canvas.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            canvas.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    func addConstraintsForColorCollectionView() {
        colorCollectionView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            colorCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0.0),
            colorCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            colorCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            colorCollectionView.heightAnchor.constraint(equalToConstant: 60.0)
        ])
    }
}
