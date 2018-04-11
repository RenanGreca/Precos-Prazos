//
//  PriceAndDeadlineParser.swift
//  CorreiosPriceAndDeadline
//
//  Created by Renan Greca on 11/04/18.
//  Copyright © 2018 renangreca. All rights reserved.
//

import Foundation

class PriceAndDeadlineParser: NSObject, XMLParserDelegate {
    
    private var elementName: String = ""
    private var price: String = ""
    private var deadline: String = ""
    private var error: Int = 0
    private var errorMessage: String?
    
    var originCEP: String?
    var destinationCEP: String?
    var weight: Int?
    var width: Int?
    var height: Int?
    var depth: Int?
    
    override init() {
        super.init()
    }

    private func prepareURL() -> URL? {
        
        guard   let originCEP = self.originCEP,
                let destinationCEP = self.destinationCEP,
                let weight = self.weight,
                let width = self.width,
                let height = self.height,
                let depth = self.depth else {
                return nil
        }
        
        
        let url = """
                    http://ws.correios.com.br/calculador/CalcPrecoPrazo.asmx/CalcPrecoPrazo
                    ?nCdEmpresa=%20
                    &sDsSenha=%20
                    &nCdServico=%2004510
                    &sCepOrigem=\(originCEP)
                    &sCepDestino=\(destinationCEP)
                    &nVlPeso=\(weight)
                    &nCdFormato=1
                    &nVlComprimento=\(depth)
                    &nVlAltura=\(height)
                    &nVlLargura=\(width)
                    &nVlDiametro=1
                    &sCdMaoPropria=N
                    &nVlValorDeclarado=100
                    &sCdAvisoRecebimento=N
                  """
        
        return URL(string: url)
    }
    
    func parse() -> (price: String, deadline: String)? {
        guard let url = self.prepareURL() else {
            return nil
        }
        
        if let xml = XMLParser(contentsOf: url) {
            xml.delegate = self
            xml.parse()
            
            if self.error != 0 {
                print("Erro \(error): \(errorMessage!)")
                return nil
            }
            
            return (price: self.price, deadline: self.deadline)
        }
        
        return nil
    }
    
    // 1
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        self.elementName = elementName
    }
    
    // 3
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let data = string.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if (!data.isEmpty) {
            if elementName == "Valor" {
                self.price = data
            } else if elementName == "PrazoEntrega" {
                self.deadline = data
            } else if elementName == "Erro" {
                self.error = Int(data)!
            } else if elementName == "MsgErro" {
                self.errorMessage = data
            }
        }
    }
}
