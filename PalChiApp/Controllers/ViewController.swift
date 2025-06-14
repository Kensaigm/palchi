import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        // Configure the view for iPad
        view.backgroundColor = .systemBackground
        
        // Add iPad-specific UI elements here
        setupNavigationBar()
        setupConstraints()
    }
    
    private func setupNavigationBar() {
        navigationItem.title = "My iPad App"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    private func setupConstraints() {
        // Set up Auto Layout constraints optimized for iPad screen sizes
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        // Handle orientation changes for iPad
        coordinator.animate(alongsideTransition: { _ in
            // Update UI for new orientation
        }, completion: nil)
    }
}