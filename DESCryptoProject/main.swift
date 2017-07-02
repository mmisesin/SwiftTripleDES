//
//  main.swift
//  DESCryptoProject
//
//  Created by Artem Misesin on 3/28/17.
//  Copyright © 2017 Artem Misesin. All rights reserved.
//

import Foundation

while true {
    print("Enter your text: ")
    guard var text = readLine() else {
        print("Try again")
        continue
    }
    if text == "" {continue}
    if text == "q" {break}
    let finalResult = encryptDES(text: text)
    for result in finalResult.0{
        print("Encrypted block: " + binToHex(bin: result))
    }
    
    let decrypted = decryptDES(textBlocks: ["85E813540F0AB405"], key: finalResult.1)
    
    for result in decrypted{
        print("Decrypted binary: " + binToHex(bin: result))
    }
    
    print("Encryption key: " + finalResult.1)
    
}



