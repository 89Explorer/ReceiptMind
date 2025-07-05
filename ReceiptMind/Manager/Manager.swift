//
//  Manager.swift
//  ReceiptMind
//
//  Created by 권정근 on 6/29/25.
//

import Foundation
import AVFoundation
import Photos
import UIKit


// 카메라 및 앨범 접근권한 설정
enum MediaPermissionType {
    case camera
    case album
}

// 권한 선택 설정
enum PermissionStatus {
    case granted
    case denied
    case notDetermined
}


// 카메라, 앨범 접근권한 설정
final class MediaPermissionManager {
    
    static let shared = MediaPermissionManager()
    
    private init() { }
    
    func request(_ type: MediaPermissionType, completion: @escaping (Bool) -> Void ) {
        switch type {
        case .camera:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    completion(granted)
                }
            }
        case .album:
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                DispatchQueue.main.async {
                    switch status {
                    case .authorized, .limited:
                        completion(true)
                    default:
                        completion(false)
                    }
                }
            }
        }
    }
    
    func checkStatus(_ type: MediaPermissionType) -> Bool {
        switch type {
        case .camera:
            return AVCaptureDevice.authorizationStatus(for: .video) == .authorized
        case .album:
            return getAlbumStatus() == .granted
        }
    }
    
    func getAlbumStatus() -> PermissionStatus {
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        switch status {
        case .authorized, .limited:
            return .granted
        case .notDetermined:
            return .notDetermined
        default:
            return .denied
        }
    }
    
    // 권한 상태 확인 후 필요 시 요청까지 수행하는 통합 메서드
    func checkAndRequestIfNeeded(_ type: MediaPermissionType, completion: @escaping (Bool) -> Void) {
        if checkStatus(type) {
            completion(true)
            return
        }
        
        request(type) { granted in
            completion(granted)
        }
    }
    
}
