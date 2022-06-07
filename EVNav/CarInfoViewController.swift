//
//  CarInfoViewController.swift
//  EVNav
//
//  Created by Diego Martinez on 5/16/22.
//

import UIKit

class CarInfoViewController: UIViewController {
    static var carMake = ""
    static var carModel = ""
    static var carYear = ""
    static var milesPerGallon: Double = 0
    static var fuelType = "gasoline"
    static var avgGasMPG: Double = 24
    
    @IBAction func submitCarInfo(_ sender: Any) {
        SubmitButton.isEnabled = false
        mpgCall()
    }
    @IBOutlet weak var MakeInput: UITextField!
    
    @IBAction func saveMake(_ sender: Any) {
        CarInfoViewController.carMake = MakeInput.text!
    }
    
    @IBOutlet weak var ModelInput: UITextField!
    
    @IBAction func saveModel(_ sender: Any) {
        CarInfoViewController.carModel = ModelInput.text!
    }
    
    @IBOutlet weak var SubmitButton: UIButton!
    
    @IBOutlet weak var YearInput: UITextField!
    
    @IBAction func saveYear(_ sender: Any) {
        CarInfoViewController.carYear = YearInput.text!

    }
    
    
    
    @IBAction func changeFuelType(_ sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
        case 0:
            CarInfoViewController.fuelType = "gasoline"
        case 1:
            CarInfoViewController.fuelType = "electricity"
        default:
            print("Error")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Car Info"
        
       
        // Do any additional setup after loading the view.
    }
    
    func mpgCall(){
      
        struct CarInfo: Codable {
            let city_mpg: Int
            let `class`: String
            let combination_mpg, cylinders: Int
            let displacement: Double
            let drive, fuel_type: String
            let highway_mpg: Int
            let make, model, transmission: String
            let year: Int
        }
        
        struct EVCarInfo: Codable {
            let city_mpg: Int
            let `class`: String
            let combination_mpg: Int
            let drive, fuel_type: String
            let highway_mpg: Int
            let make, model, transmission: String
            let year: Int
        }
        
        print(CarInfoViewController.carModel)
        
        let url = URL(string: "https://api.api-ninjas.com/v1/cars?make=\(CarInfoViewController.carMake)&model=\(CarInfoViewController.carModel)")!
        var request = URLRequest(url: url)
        request.setValue("wPYbpxWrXLkm0Nq056IOBg==j8Foq187iuObYZSq", forHTTPHeaderField: "X-Api-Key")
        
        if CarInfoViewController.fuelType == "gasoline" {
            let dataTask = URLSession.shared.dataTask(with: request as URLRequest) { [self]data, response, error in
                if let data = data {
                    do {
                        print(String(data: data, encoding: .utf8)!)

                        let res = try JSONDecoder().decode([CarInfo].self, from: data)
                        print("City MPG")
                        print(res[0].city_mpg)
                        CarInfoViewController.milesPerGallon = Double(res[0].city_mpg)
                    } catch let error {
                        print(error)
                    }
                }
            }
            dataTask.resume()
        }
        else {
            let dataTask = URLSession.shared.dataTask(with: request as URLRequest) { [self]data, response, error in
                if let data = data {
                    do {
                        print(String(data: data, encoding: .utf8)!)

                        let res = try JSONDecoder().decode([EVCarInfo].self, from: data)
                        print("City MPG")
                        print(res[0].city_mpg)
                        CarInfoViewController.milesPerGallon = Double(res[0].city_mpg)
                        
                    } catch let error {
                        print(error)
                    }
                }
            }
            dataTask.resume()
        }
        
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
