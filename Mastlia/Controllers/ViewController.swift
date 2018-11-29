import UIKit

class ViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    let idList: [String] = ["HomeTimeLine", "PublicTimeLine"]
    
    var pageViewController: UIPageViewController!
    var viewControllers: [UIViewController] = []
    
    @IBOutlet weak var selectTab: UISegmentedControl!
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "embedPageViewController" {
            pageViewController = segue.destination as! UIPageViewController
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for id in idList {
            viewControllers.append((storyboard?.instantiateViewController(withIdentifier: id))!)
        }
        pageViewController.setViewControllers([viewControllers[0]], direction: .forward, animated: true, completion: nil)
        pageViewController.dataSource = self
        pageViewController.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        let index = idList.index(of: viewController.restorationIdentifier!)!
        if (index > 0) {
            return storyboard!.instantiateViewController(withIdentifier: idList[index - 1])
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        let index = idList.index(of: viewController.restorationIdentifier!)!
        if (index < idList.count - 1) {
            return storyboard!.instantiateViewController(withIdentifier: idList[index + 1])
        }
        return nil
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        let index = idList.index(of: (pageViewController.viewControllers?.first!.restorationIdentifier)!)
        self.selectTab.selectedSegmentIndex = index!
    }
    
    @IBAction func selectedTab(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            pageViewController.setViewControllers([viewControllers[0]], direction: .reverse, animated: true, completion: nil)
            break
        case 1:
            pageViewController.setViewControllers([viewControllers[1]], direction: .forward, animated: true, completion: nil)
            break
        default:
            return
        }
    }
    
}
