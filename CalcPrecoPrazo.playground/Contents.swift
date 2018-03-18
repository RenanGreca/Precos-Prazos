//: Playground - noun: a place where people can play

import Foundation
import UIKit

class PrazoPrecoParser: NSObject, XMLParserDelegate {
    
    let xml:XMLParser
    var eName: String = ""
    var preco: String = ""
    var prazo: String = ""
    var erro: Int = 0
    var msgErro: String?
    
    init(origem: String, destino: String, peso: Int) {
        let url = "http://ws.correios.com.br/calculador/CalcPrecoPrazo.asmx/CalcPrecoPrazo?nCdEmpresa=%20&sDsSenha=%20&nCdServico=%2004510&sCepOrigem=\(origem)&sCepDestino=\(destino)&nVlPeso=\(peso)&nCdFormato=1&nVlComprimento=30&nVlAltura=30&nVlLargura=30&nVlDiametro=1&sCdMaoPropria=N&nVlValorDeclarado=100&sCdAvisoRecebimento=N"
        self.xml =  XMLParser(contentsOf: URL(string: url)!)!
        
        super.init()
        self.xml.delegate = self
    }
    
    func parse() -> (preco: String, prazo: String) {
        self.xml.parse()

        if self.erro != 0 {
            print("Erro \(erro): \(msgErro)")
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

//for (regiao, cep) in ceps.sorted(by: {$0.0 < $1.0}) {
//    let xmlParser = PrazoPrecoParser(origem: "81940320", destino: cep, peso: 1)
//    let pp = xmlParser.parse()
//
//    print("Região: \(regiao); preço: R$\(pp.preco); prazo: \(pp.prazo) dias")
//}
//
