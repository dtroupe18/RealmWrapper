//
//  PersistenceManager.swift
//  RealmWrapper
//
//  Created by David Troupe on 2/6/19.
//  Copyright © 2019 HIgh Tree Development. All rights reserved.
//

import Foundation
import Realm
import RealmSwift
import Crashlytics

final class RealmWrapper {
  
  init() {
    configureRealm()
  }
  
  func configureRealm() {
    let config = RLMRealmConfiguration.default()
    config.deleteRealmIfMigrationNeeded = true
    RLMRealmConfiguration.setDefault(config)
  }
  
  func fetchObjects<T: Object>(_ type: T.Type, predicate: NSPredicate?) -> Results<T>? {
    do {
      let realm = try Realm()
      realm.refresh()
      
      guard let pred = predicate else {
        return realm.objects(type)
      }
      
      return realm.objects(type).filter(pred)
      
    } catch let err {
      Log.logError(err.localizedDescription)
      Crashlytics.sharedInstance().recordError(err)
      return nil
    }
  }
  
  func fetchObjects<T: Object>(_ type: T.Type, predicate: NSPredicate?, sortedByKey key: String, ascending: Bool) -> Results<T>? {
    do {
      let realm = try Realm()
      realm.refresh()
      
      guard let pred = predicate else {
        return realm.objects(type).sorted(byKeyPath: key, ascending: ascending)
      }
      
      return realm.objects(type).filter(pred).sorted(byKeyPath: key, ascending: ascending)
      
    } catch let err {
      Crashlytics.sharedInstance().recordError(err)
      Log.logError(err.localizedDescription)
      return nil
    }
  }
  
  func fetchObject<T: Object>(_ type: T.Type, primaryKey: String) -> T? {
    do {
      let realm = try Realm()
      realm.refresh()
      return realm.object(ofType: type, forPrimaryKey: primaryKey)
      
    } catch let err {
      Crashlytics.sharedInstance().recordError(err)
      Log.logError(err.localizedDescription)
      return nil
    }
  }
  
  func addObjects<T: Object>(_ data: [T], update: Bool = true) -> Bool {
    do {
      let realm = try Realm()
      realm.refresh()
      
      try realm.write { realm.add(data, update: update) }
      return true
    } catch let err {
      Crashlytics.sharedInstance().recordError(err)
      Log.logError(err.localizedDescription)
      return false
    }
  }
  
  func addObject<T: Object>(_ data: T, update: Bool = true) -> Bool {
    return addObjects([data], update: update)
  }
  
  func deleteObjects<T: Object>(_ data: [T]) {
    DispatchQueue.global(qos: .default).async {
      autoreleasepool {
        do {
          let realm = try Realm()
          realm.refresh()
          
          try realm.write { realm.delete(data) }
        } catch let err {
          Crashlytics.sharedInstance().recordError(err)
          Log.logError(err.localizedDescription)
        }
      }
    }
  }
  
  func deleteObject<T: Object>(_ data: T) {
    deleteObjects([data])
  }
  
  func deleteAllData() {
    DispatchQueue.global(qos: .default).async {
      autoreleasepool {
        do {
          let realm = try Realm()
          realm.refresh()
          try realm.write { realm.deleteAll() }
        } catch let err {
          Crashlytics.sharedInstance().recordError(err)
          Log.logError(err.localizedDescription)
        }
      }
    }
  }
}

