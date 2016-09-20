//
//  ViewController.swift
//  Alarmadillo
//
//  Created by Thang Le Tan on 9/13/16.
//  Copyright © 2016 Thang Le Tan. All rights reserved.
//

import UIKit
import UserNotifications

class ViewController: UITableViewController, UNUserNotificationCenterDelegate {

    var groups = [Group]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //groups.append(Group(name: "Enabled Group", playSound: true, enabled: true, alarms: []))
        //groups.append(Group(name: "Disabled Group", playSound: true, enabled: false, alarms: []))

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addGroup))
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "Groups", style: UIBarButtonItemStyle.plain, target: nil, action: nil)
        
        // Do any additional setup after loading the view, typically from a nib.
        NotificationCenter.default.addObserver(self, selector: #selector(save), name: NSNotification.Name("save"), object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        load()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return groups.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Group", for: indexPath)
        let group = groups[indexPath.row]
        
        cell.textLabel?.text = group.name
        
        if group.enabled {
            cell.textLabel?.textColor = UIColor.black
        } else {
            cell.textLabel?.textColor = UIColor.red
        }
        
        if group.alarms.count == 1 {
            cell.detailTextLabel?.text = "1 alarm"
        } else  {
            cell.detailTextLabel?.text = "\(group.alarms.count) alarms"
        }
        
        return cell
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        groups.remove(at: indexPath.row)
        
        tableView.deleteRows(at: [indexPath], with: .automatic)
        save()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        //pull out the buried userInfo dictionary
        let userInfo = response.notification.request.content.userInfo
        
        if let groupID = userInfo["group"] as? String {
            switch response.actionIdentifier {
            case UNNotificationDefaultActionIdentifier:
                //user swipe to unlock, do nothing
                print("Default Identifier")
            case UNNotificationDismissActionIdentifier:
                //user dismissed the alert; do nothing
                print("Dismiss Identifier")
            case "show":
                display(group: groupID)
            case "rename":
                if let textResponse = response as? UNTextInputNotificationResponse {
                    rename(group: groupID, newName: textResponse.userText)
                }
            case "destroy":
                destroy(group: groupID)
                
            default:
                break
            }
        }
    }
    
    
    func display(group groupID: String) {
        _ = navigationController?.popToRootViewController(animated: false)
        
        for group in groups {
            if group.id == groupID {
                self.performSegue(withIdentifier: "EditGroup", sender: group)
                return
            }
        }
    }
    
    func destroy(group groupID: String) {
        _ = navigationController?.popToRootViewController(animated: false)
        
        for  (index,group) in groups.enumerated() {
            if group.id == groupID {
                groups.remove(at: index)
                save()
                load()
                return
            }
        }
    }
    
    func rename(group groupID: String, newName: String) {
        _ = navigationController?.popToRootViewController(animated: false)
        
        for group in groups {
            if group.id == groupID {
                
                group.name = newName
                save()
                load()
                return
            }
        }
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let groupToEdit: Group
        
        if sender is Group {
            groupToEdit = sender as! Group
        } else { // we were called by table view cell, figure out which group
            guard let indexPath = tableView.indexPathForSelectedRow else { return }
            groupToEdit = groups[indexPath.row]
            
        }
        
        // unwrapp destination from segue
        
        if let vc = segue.destination as? GroupViewController {
            vc.group = groupToEdit
        }
    }
    
    
    
    func addGroup() {
        let newGroup = Group(name: "Name", playSound: true, enabled: false, alarms: [])
        
        groups.append(newGroup)
        performSegue(withIdentifier: "EditGroup", sender: newGroup)
        
        save()
    }
    
    func save() {
        
        let path = Helper.getDocumentsDirectory().appendingPathComponent("groups")
        let data = NSKeyedArchiver.archivedData(withRootObject: groups)
        do {
            try data.write(to: path)
        } catch {
            print("Failed to save")
        }
        
        updateNotifications()
    }
    
    func updateNotifications() {
        let center = UNUserNotificationCenter.current()
        
        center.requestAuthorization(options: [.alert, .sound]) { (granted, error) in
            if granted {
                self.createNotifications()
            }
        }
    }
    
    func createNotifications() {
        //start by create the content for the notification
        
        
        let center = UNUserNotificationCenter.current()
        
        //1: remove any pending notifications
        center.removeAllPendingNotificationRequests()
        
        for group in groups {
            //2: ignore disabled groups
            guard group.enabled == true else { continue }
            
            for alarm in group.alarms {
            //3: create notification request for each alarm
                let notification = createNotificationRequest(group: group, alarm: alarm)
                
            //4: schechule that notification for delivery
                center.add(notification, withCompletionHandler: { (error) in
                    if let error = error {
                        print("Error scheduling notifications : \(error)")
                    }
                })
            }
            
        }
    
    }
    
    func createNotificationRequest(group: Group, alarm: Alarm) -> UNNotificationRequest {
        
        
        let content = UNMutableNotificationContent()
        
        //assign the users name and caption
        content.title = alarm.name
        content.body = alarm.caption
        
        //give it an identifier we can attach to custom buttons later on
        content.categoryIdentifier = "alarm"
        
        //attach the group ID and alarm ID for this alarm
        content.userInfo = ["group": group.id, "alarm": alarm.id]
        
        //if the user requested a sound for this group, attach their default alart sound
        
        if group.playSound {
            content.sound = UNNotificationSound.default()
        }
        
        //user createNotificationAttachments to attach a picture for this alert if there is one
        
        content.attachments = createNotificationAttachments(alarm: alarm)
        
        //get a calendar ready to pull out date components
        let cal = Calendar.current
        
        //pull out the hour and minute components from this alarm's date
        var dateComponents = DateComponents()
        dateComponents.hour = cal.component(.hour, from: alarm.time)
        dateComponents.minute = cal.component(.minute, from: alarm.time)
        
        //create a trigger matching those date components, set to repeat
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        //to test notifications, use this trigger instead
        //let trigger = UNTimeIntervalNotificationTrigger(timerInterval: 3, repeats: false)
        
        
        //combine the content and the trigger to create the notification
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        //pass the object back to the createNotifications for scheduling
        
        return request

        
        
        
    }
    
    func createNotificationAttachments(alarm: Alarm) -> [UNNotificationAttachment] {
        //1: return if there's no image to attach
        
        guard alarm.image.characters.count > 0 else { return [] }
        let fm = FileManager.default
        
        let imageURL = Helper.getDocumentsDirectory().appendingPathComponent(alarm.image)
        
        //create a temporary file name
        let copyURL = Helper.getDocumentsDirectory().appendingPathComponent(UUID().uuidString + ".jpg")
        
        //copy the alarm image to the temporary filename
        do {
            try fm.copyItem(at: imageURL, to: copyURL)
            
            //create the attachment from temp file, giving it a random identifier
            let attachment = try UNNotificationAttachment(identifier: UUID().uuidString, url: copyURL, options: [:])
            
            return [attachment]
        } catch {
            print("Failed to attach alarm image: \(error)")
            return []
        }
        
    }
    
    func load() {
        let path = Helper.getDocumentsDirectory().appendingPathComponent("groups")
        do {
            let data = try Data(contentsOf: path)
            groups = NSKeyedUnarchiver.unarchiveObject(with: data) as? [Group] ?? [Group]()
            
        } catch {
            print("Failed to load")
        }
        
        tableView.reloadData()
    }
    
}

