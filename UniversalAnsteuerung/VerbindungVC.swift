//
//  VerbindungVC.swift
//  UniversalAnsteuerung
//
//  Created by UDLab on 13/12/2016.
//  Copyright © 2016 UDSoft. All rights reserved.
//

import UIKit
import CocoaMQTT

class VerbindungVC: UIViewController{
    
    @IBOutlet weak var ipAddressTextView: UITextField!
    @IBOutlet weak var portNummerTextView: UITextField!
    @IBOutlet weak var userNameTextView: UITextField!
    @IBOutlet weak var passwordTextView: UITextField!
    @IBOutlet weak var mqttSecureSwitch: UISwitch!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var passwordlabel: UILabel!
    @IBOutlet weak var statusLight: UIImageView!
    
    
    let appMemory = UserDefaults.standard
    
    //Variables
    var ipAddressValue : String = ""
    var port:Int = 0
    var userNameValue:String = ""
    var passwordvalue:String = ""
    var isMqttAccessSecure:Bool = true
    var mqttClient:CocoaMQTT?
    
    
/*********************************************************************/
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //check Anonymous
        isMqttAccessSecure = showUsernamePasswordTextView(appMemory.bool(forKey: Keys.Mqtt_Anonymous.rawValue))
        
        if(appMemory.value(forKey:Keys.Mqtt_Ip_Address.rawValue) != nil){
            ipAddressTextView.text = appMemory.string(forKey: Keys.Mqtt_Ip_Address.rawValue)
            ipAddressValue = ipAddressTextView.text!
        }
        if(appMemory.string(forKey: Keys.Mqtt_Port.rawValue) != nil){
            port = Int(appMemory.integer(forKey: Keys.Mqtt_Port.rawValue))
            portNummerTextView.text = String(port)
        }
        
        //To avoid crush check if the anonymousOption is not hidden
        if(isMqttAccessSecure){
            mqttSecureSwitch.setOn(true, animated: false)
            if(appMemory.string(forKey: Keys.Mqtt_UserName.rawValue) != nil){
                userNameTextView.text = appMemory.string(forKey: Keys.Mqtt_UserName.rawValue)
                userNameValue = userNameTextView.text!
            }
            if(appMemory.string(forKey: Keys.Mqtt_Password.rawValue) != nil){
                passwordTextView.text = appMemory.string(forKey: Keys.Mqtt_Password.rawValue)!
                passwordvalue = passwordTextView.text!
            }
        }else{
            mqttSecureSwitch.setOn(false, animated: false)
        }
   
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func mqttAnonymus(_ sender: UISwitch) {
        _ = showUsernamePasswordTextView(sender.isOn)

    }
    
    @IBAction func verbindenAction(_ sender: UIButton) {
        
       var validTextViewsValues:Bool = true
        
        if(ipAddressTextView.text?.isEmpty)!{
            Alert.show(title: "Ip Address Fehler", message: "Bitte geben Sie die Mqtt Server Ip Address", vc: self)
            validTextViewsValues = false
        }else{
            ipAddressValue = ipAddressTextView.text!
        }
        
        if(portNummerTextView.text?.isEmpty)!{
            Alert.show(title: "Port Nummer Fehler", message: "Bitte geben Sie ein Port Nummer von MQTT Server", vc: self)
            validTextViewsValues = false
        }else{
            if let validatePort = Int(portNummerTextView.text!){
                self.port = validatePort
            }else{
                Alert.show(title: "Port Eingabe Fehler", message: "Port können nur nummer sein.", vc: self)
            }
        }
        
        if(isMqttAccessSecure){
            if(userNameTextView.text?.isEmpty)!{
                Alert.show(title: "Der Benutzername leer", message: "Bitte geben Sie der Benutzername", vc: self)
                validTextViewsValues = false
            }else{
                self.userNameValue = userNameTextView.text!
            }
            
            if(passwordTextView.text?.isEmpty)!{
                Alert.show(title: "Der Kennwort leer", message: "Bitte geben Sie der Kennwort", vc: self)
                validTextViewsValues = false
            }else{
                self.passwordvalue = userNameTextView.text!
            }
        }
        
        if(validTextViewsValues){
            appMemory.set(ipAddressValue, forKey: Keys.Mqtt_Ip_Address.rawValue)
            appMemory.set(port, forKey: Keys.Mqtt_Port.rawValue)
            if(isMqttAccessSecure){
                appMemory.set(userNameValue, forKey: Keys.Mqtt_UserName.rawValue)
                appMemory.set(passwordvalue, forKey: Keys.Mqtt_Password.rawValue)
            }
            appMemory.set(isMqttAccessSecure, forKey: Keys.Mqtt_Anonymous.rawValue)
            let connectionStatus = mqttConnect(secure: isMqttAccessSecure)
            print(connectionStatus)
            showConnectionStatus(connectionStatus: connectionStatus)
        }
        
    }
    
    private func mqttConnect(secure:Bool)-> Bool{
        mqttSetup(secure: secure)
        let connectionStatus = mqttClient?.connect()
        return connectionStatus!
    }
    
    private func mqttSetup(secure:Bool){
        let clientID = "IPAD " + "Dev"
        mqttClient = CocoaMQTT(clientID: clientID, host: ipAddressValue, port: UInt16(port))
        
        mqttClient?.willMessage = CocoaMQTTWill(topic: "will", message:"IPAD DEV Offline")
        mqttClient?.keepAlive = 90
        mqttClient?.delegate = self
        
        if(secure){
            mqttClient?.username = userNameValue
            mqttClient?.password = passwordvalue
        }
    }
    
     private func showConnectionStatus(connectionStatus:Bool){
        let title:String = "Verbindung Status"
        var message:String = "Error Connection Status is Unknown"
        
        if(connectionStatus ){
            message = "Erfolgreiche Verbindung"
            statusLight.image = #imageLiteral(resourceName: "GreenLight")
        }else{
            message = "Nicht erfolgreiche Verbindung"
            statusLight.image = #imageLiteral(resourceName: "RedLight")
        }
        Alert.show(title: title, message: message, vc: self)
    }
    
    
    private func showUsernamePasswordTextView(_ state:Bool) -> Bool{
        if(state){
            userNameTextView.isHidden = false
            passwordTextView.isHidden = false
            userNameLabel.isHidden = false
            passwordlabel.isHidden = false
            isMqttAccessSecure = true
            return true
        }else{
            userNameTextView.isHidden = true
            passwordTextView.isHidden = true
            userNameLabel.isHidden = true
            passwordlabel.isHidden = true
            isMqttAccessSecure = false
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
    
    
    extension VerbindungVC : CocoaMQTTDelegate{
        
        func mqtt(_ mqtt: CocoaMQTT, didConnect host: String, port: Int) {
            consoleDisplayTest(info: "Connect Success to \(host):\(port)")
        }
        
        func mqtt(_ mqtt: CocoaMQTT, didPublishMessage message: CocoaMQTTMessage, id: UInt16) {
            consoleDisplayTest(info: "Publish Message -> \(message.string) with id \(id)")
        }
        
        func mqtt(_ mqtt: CocoaMQTT, didPublishAck id: UInt16) {
            consoleDisplayTest(info: "didPublishAck with id: \(id)")
        }
        
        func mqttDidReceivePong(_ mqtt: CocoaMQTT) {
            consoleDisplayTest(info: "didRecievePong")
        }
        
        func mqtt(_ mqtt: CocoaMQTT, didSubscribeTopic topic: String) {
            consoleDisplayTest(info: "didSubcribeTopic to \(topic)")
        }
        
        func mqtt(_ mqtt: CocoaMQTT, didUnsubscribeTopic topic: String) {
            consoleDisplayTest(info: "didUnsubscribeTopic to \(topic)")
        }
        
        func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?) {
            consoleDisplayTest(info: "didDisconnect with \(err.debugDescription)")
        }
        
        func mqttDidPing(_ mqtt: CocoaMQTT) {
            consoleDisplayTest(info: "didPing")
        }
        
        func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16) {
            consoleDisplayTest(info: "didReceiveMessage with \(message.string)")
        }
        
        func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
            consoleDisplayTest(info: "didConnectAck with ack of \(ack.rawValue)")
        }
        
        func consoleDisplayTest (info:String){
            print("Delegate : \(info)")
        }
    }


