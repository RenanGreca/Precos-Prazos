//
//  PrazoPrecoParser.swift
//  PrazoPrecoCalc
//
//  Created by Renan Greca on 18/03/18.
//  Copyright © 2018 renangreca. All rights reserved.
//

import Foundation

enum ParseError: Error {
    case invalidCEP(region: String)
}

class PrazoPrecoParser: NSObject, XMLParserDelegate {
    
    let xml:XMLParser
    let regiao: String
    var eName: String = ""
    var preco: String = ""
    var prazo: String = ""
    var erro: Int = 0
    var msgErro: String?
    
    init(regiao: String, origem: String, destino: String, peso: Int) {
        self.regiao = regiao
        
        let url = "http://ws.correios.com.br/calculador/CalcPrecoPrazo.asmx/CalcPrecoPrazo?nCdEmpresa=%20&sDsSenha=%20&nCdServico=%2004510&sCepOrigem=\(origem)&sCepDestino=\(destino)&nVlPeso=\(peso)&nCdFormato=1&nVlComprimento=30&nVlAltura=30&nVlLargura=30&nVlDiametro=1&sCdMaoPropria=N&nVlValorDeclarado=100&sCdAvisoRecebimento=N"
        self.xml =  XMLParser(contentsOf: URL(string: url)!)!
        
        super.init()
        self.xml.delegate = self
    }
    
    func parse() throws-> (preco: String, prazo: String) {
        self.xml.parse()
        
        if self.erro != 0 {
            throw(ParseError.invalidCEP(region: self.regiao))
        }
        
        return (preco: self.preco, prazo: self.prazo)
    }
    
    // 1
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        eName = elementName
    }
    
    // 3
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let data = string.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if (!data.isEmpty) {
            if eName == "Valor" {
                self.preco = data
            } else if eName == "PrazoEntrega" {
                self.prazo = data
            } else if eName == "Erro" {
                self.erro = Int(data)!
            } else if eName == "MsgErro" {
                self.msgErro = data
            }
        }
    }
}
