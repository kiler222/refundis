//
//  OnboardingViewController.swift
//  BarcodeScannerExample
//
//  Created by kiler on 15/05/2019.
//  Copyright © 2019 Hyper Interaktiv AS. All rights reserved.
//

import UIKit

class OnboardingViewController: UIViewController, UIScrollViewDelegate {

  
    @IBAction func dismissButton(_ sender: Any) {
        self.dismiss(animated: true) 
    }
    
    
    @IBOutlet weak var dismissButton: UIButton!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var scrollView: UIScrollView!
    var slides:[Slide] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        
        slides = createSlides()
        setupSlideScrollView(slides: slides)
        
        pageControl.numberOfPages = slides.count
        pageControl.currentPage = 0
        view.bringSubview(toFront: pageControl)
        dismissButton.setTitle("Pomiń", for: .normal)
        view.bringSubview(toFront: dismissButton)
        
        
        //TODO - odblokować gdy skończone testy tutoriala!!!!!!!!!!!!!!
                UserDefaults.standard.set(true, forKey: "tutorialShowed")

        
    }
    
    func createSlides() -> [Slide] {
        
        let slide1:Slide = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide
        slide1.imageView.image = UIImage(named: "proces_01")
        slide1.title.text = "Ty wypełniasz zgłoszenie"
        slide1.labelDesc.text = "My informujemy Cię o wysokości możliwego odszkodowania."
        
        let slide2:Slide = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide
        slide2.imageView.image = UIImage(named: "proces_02")
        slide2.title.text = "My kontaktujemy się z Tobą"
        slide2.labelDesc.text = "Informujemy Cię o warunkach naszej współpracy. Akceptujesz umowę."
        
        let slide3:Slide = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide
        slide3.imageView.image = UIImage(named: "proces_03")
        slide3.title.text = "My zajmujemy się całą sprawą"
        slide3.labelDesc.text = "Rozpoczynamy proces odzyskiwania odszkodowania od właściwej linii lotniczej."
        
        let slide4:Slide = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide
        slide4.imageView.image = UIImage(named: "proces_04")
        slide4.title.text = "Ty otrzymujesz odszkodowanie!"
        slide4.labelDesc.text = "Pobieramy opłatę dopiero wtedy, gdy całe przyznane odszkodowanie zostaje wypłacone."
        
//
//        let slide5:Slide = Bundle.main.loadNibNamed("Slide", owner: self, options: nil)?.first as! Slide
//        slide5.imageView.image = UIImage(named: "ic_onboarding_5")
//        slide5.labelTitle.text = "A real-life bear"
//        slide5.labelDesc.text = "Did you know that Winnie the chubby little cubby was based on a real, young bear in London"
        
        return [slide1, slide2, slide3, slide4]
    }
    
    func setupSlideScrollView(slides : [Slide]) {
        scrollView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height)
        scrollView.contentSize = CGSize(width: view.frame.width * CGFloat(slides.count), height: view.frame.height)
        scrollView.isPagingEnabled = true
        
        for i in 0 ..< slides.count {
            slides[i].frame = CGRect(x: view.frame.width * CGFloat(i), y: 0, width: view.frame.width, height: view.frame.height)
            scrollView.addSubview(slides[i])
        }
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x/view.frame.width)
        pageControl.currentPage = Int(pageIndex)
        
        let maximumHorizontalOffset: CGFloat = scrollView.contentSize.width - scrollView.frame.width
        let currentHorizontalOffset: CGFloat = scrollView.contentOffset.x
        
        // vertical
        let maximumVerticalOffset: CGFloat = scrollView.contentSize.height - scrollView.frame.height
        let currentVerticalOffset: CGFloat = scrollView.contentOffset.y
        
        let percentageHorizontalOffset: CGFloat = currentHorizontalOffset / maximumHorizontalOffset
        let percentageVerticalOffset: CGFloat = currentVerticalOffset / maximumVerticalOffset
        
        
        if (pageIndex != 3 ) {
            self.dismissButton.setTitle("Pomiń", for: .normal)
        } else {
            
            self.dismissButton.setTitle("Zaczynamy", for: .normal)
        }
        
        
        /*
         * below code changes the background color of view on paging the scrollview
         */
        //        self.scrollView(scrollView, didScrollToPercentageOffset: percentageHorizontalOffset)
        
        
        /*
         * below code scales the imageview on paging the scrollview
         */
        let percentOffset: CGPoint = CGPoint(x: percentageHorizontalOffset, y: percentageVerticalOffset)
        
        if(percentOffset.x > 0 && percentOffset.x <= 0.33) {
            
            slides[0].imageView.transform = CGAffineTransform(scaleX: (0.33-percentOffset.x)/0.33, y: (0.33-percentOffset.x)/0.33)
            slides[1].imageView.transform = CGAffineTransform(scaleX: percentOffset.x/0.33, y: percentOffset.x/0.33)
            
        } else if(percentOffset.x > 0.33 && percentOffset.x <= 0.66) {
            slides[1].imageView.transform = CGAffineTransform(scaleX: (0.66-percentOffset.x)/0.33, y: (0.66-percentOffset.x)/0.33)
            slides[2].imageView.transform = CGAffineTransform(scaleX: percentOffset.x/0.66, y: percentOffset.x/0.66)
            
        } else if(percentOffset.x > 0.66 && percentOffset.x <= 1.0) {
            slides[2].imageView.transform = CGAffineTransform(scaleX: (1.0-percentOffset.x)/0.33, y: (1.0-percentOffset.x)/0.33)
            slides[3].imageView.transform = CGAffineTransform(scaleX: percentOffset.x/1.0, y: percentOffset.x/1.0)
            
        } /*else if(percentOffset.x > 0.75 && percentOffset.x <= 1) {
            slides[3].imageView.transform = CGAffineTransform(scaleX: (1-percentOffset.x)/0.25, y: (1-percentOffset.x)/0.25)
            slides[4].imageView.transform = CGAffineTransform(scaleX: percentOffset.x, y: percentOffset.x)
        }*/
    }

    
}
