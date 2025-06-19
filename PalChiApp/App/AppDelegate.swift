import UIKit
import CoreData

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Initialize Core Data stack
        _ = CoreDataStack.shared
        
        // Override point for customization after application launch.
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
    }
    
    // MARK: - Core Data Saving Support
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Save changes in the application's managed object context before the application terminates.
        CoreDataStack.shared.save()
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Save changes when the application enters the background.
        CoreDataStack.shared.save()
    }
}