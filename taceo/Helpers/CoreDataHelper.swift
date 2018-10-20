//
//  CoreDataHelper.swift
//  taceo
//
//  Created by Robert May on 10/18/18.
//  Copyright © 2018 Robert May. All rights reserved.
//

import Foundation
import UIKit
import CoreData

struct CoreDataHelper {
    static let context: NSManagedObjectContext = {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError()
        }
        
        let persistentContainer = appDelegate.persistentContainer
        let context = persistentContainer.viewContext
        
        return context
    }()
    
    static func newHighScore() -> HighScore {
        let hc = NSEntityDescription.insertNewObject(forEntityName: "HighScore", into: context) as! HighScore
        
        return hc
    }
    
    static func saveScore() {
        do {
            try context.save()
        } catch let error {
            print("Could not save \(error.localizedDescription)")
        }
    }
    
    static func delete(hc: HighScore) {
        context.delete(hc)
        
        saveScore()
    }
    
    static func retrieveHighScore() -> HighScore? {
        do {
            let fetchRequest = NSFetchRequest<HighScore>(entityName: "HighScore")
            let results = try context.fetch(fetchRequest)
            
            if results.count > 0 {
                return results.reversed()[0]
            } else {
                return nil
            }
        } catch let error {
            print("Could not fetch \(error.localizedDescription)")
            
            return nil
        }
    }
    
    struct HighScoreEditor {
        
        static func checkHighScore(with score: Int) -> Bool {
            
            let high = CoreDataHelper.retrieveHighScore()
            guard let hc = high else {
                saveNew(score: Int64(score))
                return true
            }
            let newHc = Int64(score)
            
            if hc.score < newHc {
                CoreDataHelper.delete(hc: hc)
                saveNew(score: newHc)
                return true
            }
            return false
        }
        
        static func saveNew(score: Int64) {
            let highScore = CoreDataHelper.newHighScore()
            highScore.score = score
            CoreDataHelper.saveScore()
        }
        
    }
    
}

