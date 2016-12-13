//
//  VerbindungVC.swift
//  UniversalAnsteuerung
//
//  Created by UDLab on 13/12/2016.
//  Copyright © 2016 UDSoft. All rights reserved.
//

import UIKit
import Moscapsule

class VerbindungVC: UIViewController {
    
    @IBOutlet weak var ipAddress: UITextField!
    @IBOutlet weak var portNummer: UITextField!
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var anonymousOption: UISwitch!
    
    let appMemory = UserDefaults.standard
    
    /*
     True = if Broker accepts anonymous client.
     False = if Broker do not accept anonymous client.
    */
    var anonymous:Bool = false
    
    
    //Variables
    var ipAddressValue : String = ""
    var port:Int32 = 0
    var usernameValue:String = ""
    var passwordvalue:String = ""
    
    
/*********************************************************************/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //check Anonymous
        anonymous = hide_UserPass(appMemory.bool(forKey: Keys.Mqtt_Anonymous.rawValue))
        
        if(appMemory.value(forKey:Keys.Mqtt_Ip_Address.rawValue) != nil){
            ipAddress.text = appMemory.string(forKey: Keys.Mqtt_Ip_Address.rawValue)
            ipAddressValue = ipAddress.text!
        }
        if(appMemory.string(forKey: Keys.Mqtt_Port.rawValue) != nil){
            port = Int32(appMemory.integer(forKey: Keys.Mqtt_Port.rawValue))
            portNummer.text = String(port)
        }
        
        //To avoid crush check if the anonymousOption is not hidden
        if(!anonymous){
            if(appMemory.string(forKey: Keys.Mqtt_UserName.rawValue) != nil){
                userName.text = appMemory.string(forKey: Keys.Mqtt_UserName.rawValue)
                usernameValue = userName.text!
            }
            if(appMemory.string(forKey: Keys.Mqtt_Password.rawValue) != nil){
                password.text = appMemory.string(forKey: Keys.Mqtt_Password.rawValue)!
                passwordvalue = password.text!
            }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func mqttAnonymus(_ sender: UISwitch) {
        hide_UserPass(sender.isOn)

    }
    
    @IBAction func verbindenAction(_ sender: UIButton) {
        //Save All new Update to AppMemory
        ipAddressValue = ipAddress.text!
        port = Int32(portNummer.text!)!
        appMemory.set(ipAddressValue, forKey: Keys.Mqtt_Ip_Address.rawValue)
        appMemory.set(port, forKey: Keys.Mqtt_Port.rawValue)
        appMemory.set(anonymous, forKey: Keys.Mqtt_Anonymous.rawValue)
        if(!anonymous){
        usernameValue = userName.text!
        passwordvalue = password.text!
        appMemory.set(passwordvalue, forKey: Keys.Mqtt_Password.rawValue)
        appMemory.set(usernameValue, forKey: Keys.Mqtt_UserName.rawValue)
        }
        var config = MQTTConfig.init(clientId: "Ipad", host: ipAddressValue, port: Int32(port), keepAlive: 20)
        config.onConnectCallback = {ReturnCode in NSLog("Return Code is \(ReturnCode.description)")}
        config.onMessageCallback = {mosquitto_message in NSLog("MQTT Message recieved : payload=\(mqttMessage.payloadString)")}
        
        var client = MQTT.newConnection(config)
        testUD()

    }
    
    
    func testUD(){
        print("The saved IP Address is : ")
        print(appMemory.string(forKey: Keys.Mqtt_Ip_Address.rawValue) as Any)
        print("The saved port is : ")
        print(appMemory.value(forKey: Keys.Mqtt_Port.rawValue) as Any)
        print("The saved anonymous state is : ")
        print(appMemory.bool(forKey: Keys.Mqtt_Anonymous.rawValue))
        print("The saved username is : ")
        print(appMemory.string(forKey: Keys.Mqtt_UserName.rawValue) as Any)
        print("The saved Mqtt password is : ")
        print(appMemory.string(forKey:Keys.Mqtt_Password.rawValue) as Any)
        
    }
    
    
    func hide_UserPass(_ state:Bool) -> Bool{
        if(state){
            userName.isHidden = true
            password.isHidden = true
            anonymous = true
            return true
        }else{
            userName.isHidden = false
            password.isHidden = false
            anonymous = false
            return false
        }
    }


    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
