//
//  GroupViewController.swift
//  Alarmadillo
//
//  Created by Thang Le Tan on 9/13/16.
//  Copyright © 2016 Thang Le Tan. All rights reserved.
//

import UIKit

class GroupViewController: UITableViewController, UITextFieldDelegate {

    var group: Group!
    
    let playSoundTag = 1001
    let enabledTag = 1002
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addAlarm))
        self.title = group.name
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.preservesSuperviewLayoutMargins = true
        cell.contentView.preservesSuperviewLayoutMargins = true
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            return createGroupCell(for: indexPath, in: tableView)
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "RightDetail", for: indexPath)
            
            let alarm = group.alarms[indexPath.row]
            
            cell.textLabel?.text = alarm.name
            cell.detailTextLabel?.text = DateFormatter.localizedString(from: alarm.time, dateStyle: .none, timeStyle: .short)
            
            return cell
        }
    }
    func createGroupCell(for indexPath:IndexPath, in tableView: UITableView) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            // this is the first cell: editting the name of the group
            let cell = tableView.dequeueReusableCell(withIdentifier: "EditableText", for: indexPath)
            
            //look for the text field inside the cell
            if let cellTextField = cell.viewWithTag(1) as? UITextField {
                // ... then give it the group name
                cellTextField.text = group.name
            }
            return cell
        case 1:
            //this is the "play sound" cell
            let cell = tableView.dequeueReusableCell(withIdentifier: "Switch", for: indexPath)
            
            //look for both label and switch
            if let cellLabel = cell.viewWithTag(1) as? UILabel, let cellSwitch = cell.viewWithTag(2) as? UISwitch {
                //configure the cell with correct settings
                cellLabel.text = "Play Sound"
                cellSwitch.isOn = group.playSound
                
                //set the switch up with the playSoundTag tag so we know which one was changed
                cellSwitch.tag = playSoundTag
            }
            return cell
        default:
            // if we're anything else, we must be the "enabled" switch, which is basically the same as the "play sound" switch
            let cell = tableView.dequeueReusableCell(withIdentifier: "Switch", for: indexPath)
            if let cellLabel = cell.viewWithTag(1) as? UILabel, let cellSwitch = cell.viewWithTag(2) as? UISwitch {
                //configure the cell with correct settings
                cellLabel.text = "Enabled"
                cellSwitch.isOn = group.enabled
                
                //set the switch up with the playSoundTag tag so we know which one was changed
                cellSwitch.tag = enabledTag
            }
            return cell
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return nil
        }
        // still here -> mean in 2nd section
        
        if group.alarms.count > 0 {
            return "Alarms"
        }
        
        // still here -> 0 alarm
        
        return nil
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 3
        } else {
            return group.alarms.count
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.section == 1
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        group.alarms.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .automatic)
        
        save()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let alarmToEdit: Alarm
        
        if sender is Alarm {
            alarmToEdit = sender as! Alarm
        } else {
            // be called for table view cell, figure out which alarm
            guard let selectedIndexPath = tableView.indexPathForSelectedRow else { return }
            alarmToEdit = group.alarms[selectedIndexPath.row]
        }
        
        if let vc = segue.destination as? AlarmViewController {
            vc.alarm = alarmToEdit
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        group.name = textField.text!
        self.title = group.name
        
        save()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func addAlarm() {
        let newAlarm = Alarm(name: "Name this alarm", caption: "Add an option description", time: Date(), image: "")
        
        group.alarms.append(newAlarm)
        
        performSegue(withIdentifier: "EditAlarm", sender: newAlarm)
        
        save()
        
    }
    
    @IBAction func switchChanged(_ sender: UISwitch) {
        if sender.tag == playSoundTag {
            group.playSound = sender.isOn
        } else if sender.tag == enabledTag {
            group.enabled = sender.isOn
        }
        
        save()
        
    }
    
    func save() {
        NotificationCenter.default.post(name: NSNotification.Name("save"), object: nil)
    }

    
}
