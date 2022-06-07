//
//  ProfileViewController.swift
//  EVNav
//
//  Created by Diego Martinez on 5/17/22.
//

import UIKit


class ProfileViewController: UIViewController {
    
    @IBOutlet weak var profileMake: UILabel!
    
    @IBOutlet weak var profileModel: UILabel!
    
    @IBOutlet weak var profileYear: UILabel!
    
    @IBOutlet weak var profileMPG: UILabel!
    
    @IBOutlet weak var profileFuelType: UILabel!
    
    @IBOutlet weak var MPG: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        profileMake.text = CarInfoViewController.carMake
        profileModel.text = CarInfoViewController.carModel
        profileYear.text = CarInfoViewController.carYear
        print(CarInfoViewController.carYear)

        profileMPG.text = String(CarInfoViewController.milesPerGallon)
        print(CarInfoViewController.fuelType)
        profileFuelType.text = CarInfoViewController.fuelType
        if CarInfoViewController.fuelType == "gasoline"
        {
            MPG.text = "MPG"
        }
        else
        {
            MPG.text = "MPGe"
        }
        
        //print(CarInfoViewController.fuelType)
        print("YEWWWW")
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
