//
//  Utils.swift
//  Zhytnetskyi-App
//
//  Created by Oleksiy Zhytnetsky on 12.03.2025.
//

import Foundation
import UIKit

final class Utils {
    
    static func formatTimeSincePost(_ timestamp: TimeInterval) -> String {
        let seconds = Int(Date().timeIntervalSince1970 - timestamp)
        if seconds < 60 {
            return "\(seconds)s"
        }
        
        let minutes = seconds / 60
        if minutes < 60 {
            return "\(minutes)m"
        }
        
        let hours = minutes / 60
        if hours < 24 {
            return "\(hours)h"
        }
        
        let days = hours / 24
        if days < 30 {
            return "\(days)d"
        }
        
        let months = days / 30
        if months < 12 {
            return "\(months)M"
        }
        
        let years = months / 12
        return "\(years)y"
    }
    
    static func formatNumCount(_ count: Int) -> String {
        if count < 1000 {
            return " \(count)"
        }
        
        if count < 10_000 {
            return String(format: " %.1fk", Double(count) / 1_000)
        }
        
        if count < 1_000_000 {
            return " \(count / 1_000)k"
        }
        
        if count < 1_000_000_000 {
            return " \(count / 1_000_000)M"
        }
        
        return " \(count / 1_000_000_000)B"
    }
    
    static func toggleBtnFill(
        _ btn: UIButton,
        imgName body: String
    ) {
        var btnImgName = body
        if (btn.isSelected) {
            btnImgName.append(".fill")
        }
        btn.setImage(
            UIImage(systemName: btnImgName),
            for: .normal
        )
    }
    
}
