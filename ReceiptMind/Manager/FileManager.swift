//
//  FileManager.swift
//  ReceiptMind
//
//  Created by 권정근 on 7/3/25.
//

// 영수증 이미지를 저장하고, 이미지 경로를 반환하여 core data에 저장

import Foundation
import UIKit

class ReceiptFileManager {
    
    // MARK: - Variable
    static let shared = ReceiptFileManager()
    private init() { }
    private let fileManager = FileManager.default
    
    
    // MARK: Function
    /// Documents 폴더 경로 가져오기
    private func getDocumentsDirectory() -> URL {
        guard let url = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            fatalError("❌ Document 디렉터리를 찾을 수 없습니다.")
        }
        return url
    }
    
    /// 이미지를 저장하고 경로를 반환하는 함수 (단일 이미지용)
    func saveImage(image: UIImage, receiptID: String) -> String? {
        let receiptFolder = getDocumentsDirectory().appendingPathComponent(receiptID)
        
        // 기존 폴더 삭제
        if fileManager.fileExists(atPath: receiptFolder.path) {
            try? fileManager.removeItem(at: receiptFolder)
        }
        
        do {
            try fileManager.createDirectory(at: receiptFolder,
                                            withIntermediateDirectories: true,
                                            attributes: nil)
        } catch {
            print("❌ 디렉터리 생성 실패: \(error.localizedDescription)")
            return nil
        }
        
        let fileName = "image.jpg"
        let fileURL = receiptFolder.appendingPathComponent(fileName)
        
        guard let imageData = image.jpegData(compressionQuality: 1.0) else {
            print("❌ 이미지 데이터를 JPEG로 변환 실패")
            return nil
        }
        
        do {
            try imageData.write(to: fileURL)
            return "\(receiptID)/\(fileName)"
        } catch {
            print("❌ 이미지 저장 실패: \(error.localizedDescription)")
            return nil
        }
    }
    
    /// 저장한 이미지를 불러오는 함수 (단일 이미지용)
    func loadImage(from relativePath: String) -> UIImage? {
        let fullPath = getDocumentsDirectory().appendingPathComponent(relativePath)
        return UIImage(contentsOfFile: fullPath.path)
    }
    
    /// 영수증 폴더 삭제
    func deleteFolder(for receiptID: String) {
        let folder = getDocumentsDirectory().appendingPathComponent(receiptID)
        if fileManager.fileExists(atPath: folder.path) {
            try? fileManager.removeItem(at: folder)
        }
    }
    
}


/*
class ReceiptFileManager {
    
    // MARK: - Variable
    static let shared = ReceiptFileManager()
    private init() { }
    private let fileManager = FileManager.default
    
    
    // MARK: Function
    /// Documents 폴더 경로 가져오기
    private func getDocumentsDirectory() -> URL {
        guard let url = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first else {
            fatalError("❌ Document 디렉터리를 찾을 수 없습니다.")
        }
        return url
    }
    
    /// 이미지를 저장하고 경로를 반환하는 함수
    func saveImages(images: [UIImage], receiptID: String) -> [String] {
        let receiptFolder = getDocumentsDirectory().appendingPathComponent(receiptID)
        
        // 기존 이미지 삭제
        if fileManager.fileExists(atPath: receiptFolder.path) {
            try? fileManager.removeItem(at: receiptFolder)
        }
        
        try? fileManager.createDirectory(at: receiptFolder,
                                         withIntermediateDirectories: true,
                                         attributes: nil)
        
        var savedImagesPaths: [String] = []
    
        for (index, image) in images.enumerated() {
            let fileName = "image_\(index).jpg"
            let fileURL = receiptFolder.appendingPathComponent(fileName)
            
            if let imageData = image.jpegData(compressionQuality: 1.0) {
                try? imageData.write(to: fileURL)
                savedImagesPaths.append("\(receiptID)/\(fileName)")
            }
        }
        return savedImagesPaths
    }
    
    
    /// 저장한 이미지를 상대 경로로 불러옴
    func loadImage(from relativePaths: [String]) -> [UIImage] {
        var images: [UIImage] = []
        
        for path in relativePaths {
            let fullPath = getDocumentsDirectory().appendingPathComponent(path)
            if let image = UIImage(contentsOfFile: fullPath.path) {
                images.append(image)
            }
        }
        return images
    }
    
    
    /// 저장한 이미지를 삭제하는 함수
//    func deleteImages(from relativePaths: [String]) {
//        for relativePath in relativePaths {
//            let fullPath = getDocumentsDirectory().appendingPathComponent(relativePath)
//            
//            do {
//                try fileManager.removeItem(at: fullPath)
//                print("Deleted image at: \(fullPath.path)")
//            } catch {
//                print("Failed to delete image at: \(fullPath.path). Error: \(error)")
//            }
//        }
//    }
    
    /// 영수증 폴더 삭제
    func deleteFolder(for receiptID: String) {
        let folder = getDocumentsDirectory().appendingPathComponent(receiptID)
        if fileManager.fileExists(atPath: folder.path) {
            try? fileManager.removeItem(at: folder)
        }
    }
}

*/
