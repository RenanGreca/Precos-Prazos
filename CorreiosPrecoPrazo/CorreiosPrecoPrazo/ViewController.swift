//
//  ViewController.swift
//  CorreiosPrecoPrazo
//
//  Created by Cinq Technologies on 11/04/18.
//  Copyright © 2018 renangreca. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    
    @IBOutlet weak var stateField: NSTextField!
    @IBOutlet weak var cepField: NSTextField!
    @IBOutlet weak var weightField: NSTextField!
    @IBOutlet weak var widthField: NSTextField!
    @IBOutlet weak var heightField: NSTextField!
    @IBOutlet weak var depthField: NSTextField!
    
    @IBOutlet weak var regionMenu: NSPopUpButton!
    
    @IBOutlet weak var resultsTableView: NSTableView!
    
    let ceps = NSDictionary(contentsOfFile: Bundle.main.path(forResource: "CEPs", ofType: "plist")!) as! [String:[String:String]]
    
    var results: [(state: String, region: String, price: String, deadline: String)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func confirm(_ sender: NSButton) {
        
        guard   self.weightField.integerValue != 0,
                self.widthField.integerValue != 0,
                self.heightField.integerValue != 0,
                self.depthField.integerValue != 0,
                self.cepField.stringValue != "" else {
                
                    return
        }
        
        sender.isEnabled = false
        
        var cepsToCheck: [(state: String, region: String)] = []
        results = []
        
        let state = self.stateField.stringValue
        if state != "" && ceps.keys.contains(state) {
            
            let region = self.regionMenu.selectedItem!.title
            if region == "Ambas" {
                cepsToCheck.append((state, "Capital"))
                cepsToCheck.append((state, "Interior"))
            } else {
                cepsToCheck.append((state, region))
            }
            
        } else {
            for (state, regions) in ceps {
                for (region, _) in regions {
                    cepsToCheck.append((state, region))
                }
            }
        }
        
        let downloadGroup = DispatchGroup()
        for (state, region) in cepsToCheck {
            downloadGroup.enter()
            DispatchQueue.main.async {
                let xmlParser = PriceAndDeadlineParser()
                xmlParser.weight = self.weightField.integerValue
                xmlParser.width = self.widthField.integerValue
                xmlParser.height = self.heightField.integerValue
                xmlParser.depth = self.depthField.integerValue
                xmlParser.originCEP = self.cepField.stringValue
                xmlParser.destinationCEP = self.ceps[state]![region]!
                
                if let result = xmlParser.parse() {
                    self.results.append((state, region, result.price, result.deadline))
                }
                downloadGroup.leave()
            }
        }
        
        downloadGroup.notify(queue: DispatchQueue.main) {
            self.results.sort(by: {$0.state < $1.state})
            
            self.resultsTableView.reloadData()
            sender.isEnabled = true
        }
        
    }

}

extension ViewController: NSTableViewDataSource {
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return self.results.count
    }
    
    private enum CellIdentifiers {
        static let state = NSUserInterfaceItemIdentifier("StateCell")
        static let region = NSUserInterfaceItemIdentifier("RegionCell")
        static let price = NSUserInterfaceItemIdentifier("PriceCell")
        static let deadline = NSUserInterfaceItemIdentifier("DeadlineCell")
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        
        var text: String = ""
        var cellIdentifier = NSUserInterfaceItemIdentifier("")

        if tableColumn == tableView.tableColumns[0] {
            // State
            cellIdentifier = CellIdentifiers.state
            text = self.results[row].state
        } else if tableColumn == tableView.tableColumns[1] {
            // Region
            cellIdentifier = CellIdentifiers.region
            text = self.results[row].region
        } else if tableColumn == tableView.tableColumns[2] {
            // Price
            cellIdentifier = CellIdentifiers.price
            text = "R$ "+self.results[row].price
        } else if tableColumn == tableView.tableColumns[3] {
            // Deadline
            cellIdentifier = CellIdentifiers.deadline
            text = self.results[row].deadline+" dias"
        }

        if let cell = tableView.makeView(withIdentifier: cellIdentifier, owner: nil) as? NSTableCellView {
            cell.textField?.stringValue = text
            return cell
        }
        return nil
    }

    
}

extension ViewController: NSTableViewDelegate {
    
}
