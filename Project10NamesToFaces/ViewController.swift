//
//  ViewController.swift
//  Project10NamesToFaces
//
//  Created by Tai Chin Huang on 2021/9/2.
//

import UIKit

class ViewController: UICollectionViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var people = [Person]()

    override func viewDidLoad() {
        super.viewDidLoad()
        // load saved data
        let defaults = UserDefaults.standard
        if let savedData = defaults.object(forKey: "people") as? Data {
            let decoder = JSONDecoder()
            do {
                let decodedPeople = try decoder.decode([Person].self, from: savedData)
                people = decodedPeople
            } catch {
                print("fail to load people")
            }
        }

        // add photos button
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addNewPerson))
    }
    
    func save() {
        let encoder = JSONEncoder()
        if let savedData = try? encoder.encode(people) {
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: "people")
        } else {
            print("fail to save people")
        }
    }
    // left bar button item use UIImagePickerController
    @objc func addNewPerson() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let alertController = UIAlertController(title: "Choose input", message: nil, preferredStyle: .alert)
            let cameraAction = UIAlertAction(title: "Camera", style: .default) { [weak self] _ in
                self?.getNewImage(.camera)
                print("use camera")
            }
            let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default) { [weak self] _ in
                self?.getNewImage()
                print("use photo library")
            }
            alertController.addAction(cameraAction)
            alertController.addAction(photoLibraryAction)
            present(alertController, animated: true, completion: nil)
            print("done with source select")
        } else {
            getNewImage()
        }
    }
    func getNewImage(_ imageSource: UIImagePickerController.SourceType = .photoLibrary) {
        let picker = UIImagePickerController()
        picker.sourceType = imageSource
        picker.allowsEditing = true
        picker.delegate = self
        present(picker, animated: true, completion: nil)
    }

    //MARK: - CollectionViewDataSource
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return people.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Person", for: indexPath) as? PersonCell else {
            fatalError("Unable dequeue PersonCell")
        }
        
        let person = people[indexPath.item]
        cell.nameLabel.text = person.name
        
        let path = getDocumentsDirectory().appendingPathComponent(person.image)
        cell.imageView.image = UIImage(contentsOfFile: path.path)
        
        cell.imageView.backgroundColor = UIColor(white: 0, alpha: 0.1)
        cell.imageView.layer.borderColor = UIColor(white: 0, alpha: 0.3).cgColor
        cell.imageView.layer.borderWidth = 2
        cell.imageView.layer.cornerRadius = 3
        cell.layer.cornerRadius = 7
        
        return cell
    }
    //MARK: - CollectionViewDelegate
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let person = people[indexPath.item]
        let alertController = UIAlertController(title: "Action", message: nil, preferredStyle: .alert)
        
        let renameAction = UIAlertAction(title: "Rename", style: .default) { [weak self, weak person] _ in
            self?.renameImage(person: person!)
        }
        let removeAction = UIAlertAction(title: "Remove", style: .default) { [weak self] _ in
            self?.people.remove(at: indexPath.item)
            self?.collectionView.reloadData()
            self?.save()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(renameAction)
        alertController.addAction(removeAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
        
    }
    // rename image
    func renameImage(person: Person) {
        let alertController = UIAlertController(title: "Rename person", message: nil, preferredStyle: .alert)
        alertController.addTextField()
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self, weak alertController] _ in
            guard let newName = alertController?.textFields?.first!.text else { return }
            person.name = newName
            self?.collectionView.reloadData()
            self?.save()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    //MARK: - UIImagePickerControllerDelegate
    // save images imported by user
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // 要使用編輯過的照片所以用.editedImage
        guard let image = info[.editedImage] as? UIImage else { return }
        
        let imageName = UUID().uuidString
        let imagePath = getDocumentsDirectory().appendingPathComponent(imageName)
        // convert image to data
        if let jpegData = image.jpegData(compressionQuality: 0.8) {
            try? jpegData.write(to: imagePath)
        }
        // save new person information
        let person = Person(name: "Unknown", image: imageName)
        people.append(person)
        collectionView.reloadData()
        save()
        dismiss(animated: true, completion: nil)
    }
    
    func getDocumentsDirectory() -> URL {
        // 找尋使用的者資料夾位置
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return path[0]
    }
}
