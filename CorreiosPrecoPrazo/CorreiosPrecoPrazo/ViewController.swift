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
    @IBOutlet weak var weightField: NSTextField!
    @IBOutlet weak var widthField: NSTextField!
    @IBOutlet weak var heightField: NSTextField!
    @IBOutlet weak var depthField: NSTextField!
    
    @IBOutlet weak var regionMenu: NSPopUpButton!
    
    @IBOutlet weak var resultsTableView: NSTableView!
    
    let ceps = NSDictionary(contentsOfFile: Bundle.main.path(forResource: "CEPs", ofType: "plist")!) as! [String:[String:String]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func confirm(_ sender: Any) {
        
        guard   self.weightField.integerValue != 0,
                self.widthField.integerValue != 0,
                self.heightField.integerValue != 0,
                self.depthField.integerValue != 0 else {
                
                    return
        }
        
        var cepsToCheck: [String] = []
        
        let state = self.stateField.stringValue
        if state != "" && ceps.keys.contains(state) {
            
            let region = self.regionMenu.selectedItem!.title
            if region == "Ambas" {
                cepsToCheck.append(ceps[state]!["Capital"]!)
                cepsToCheck.append(ceps[state]!["Interior"]!)
            } else {
                cepsToCheck.append(ceps[state]![region]!)
            }
            
        } else {
            
            for (state, regions) in ceps {
                for (region, cep) in regions {
                    cepsToCheck.append(cep)
                }
            }
        }
        
        let xmlParser = PriceAndDeadlineParser()
        xmlParser.weight = self.weightField.integerValue
        xmlParser.width = self.widthField.integerValue
        xmlParser.height = self.heightField.integerValue
        xmlParser.depth = self.depthField.integerValue
        
        
        
        //        for (state, regions) in ceps {
        //            print(state)
        //            for (region, cep) in regions {
        //                print("Region \(region) has CEP \(cep)")
        //            }
        
        
        //            let xmlParser = PrazoPrecoParser(origem: "81940320", destino: cep, peso: 1)
        //            let pp = xmlParser.parse()
        //
        //            print("Região: \(regiao); preço: R$\(pp.preco); prazo: \(pp.prazo) dias")
        //        }
        
    }

}

extension ViewController: NSTableViewDataSource {
    
}

extension ViewController: NSTableViewDelegate {
    
}
