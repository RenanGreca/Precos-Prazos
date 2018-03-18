//
//  main.swift
//  PrazoPrecoCalc
//
//  Created by Renan Greca on 18/03/18.
//  Copyright © 2018 renangreca. All rights reserved.
//

import Foundation

//let outputFile = Bundle.main.path(forResource: "output", ofType: "txt")
let outputFile = "output.txt"

//FileManager.SearchPathDirectory.
//
let fileURL = URL(fileURLWithPath: FileManager.default.currentDirectoryPath.appending("output.txt"))
//let fileURL = dir.appendingPathComponent(outputFile)

var string = ""

for (regiao, cep) in ceps.sorted(by: {$0.0 < $1.0}) {
    let xmlParser = PrazoPrecoParser(regiao: regiao, origem: "81940320", destino: cep, peso: 1)
    
    do {
        let pp = try xmlParser.parse()
        
        let text = "Região: \(regiao); preço: R$\(pp.preco); prazo: \(pp.prazo) dias"
        print(text)
        string += text+"\n"
        
    } catch ParseError.invalidCEP(let regiao) {
        print("CEP inválido na região \(regiao)")
    }
    
}

do {
    try string.write(to: fileURL, atomically: false, encoding: .utf8)
//    try string.write(toFile: "./output.txt", atomically: false, encoding: .utf8)
}
catch {/* error handling here */}
