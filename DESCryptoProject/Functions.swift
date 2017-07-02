//
//  Functions.swift
//  DESCryptoProject
//
//  Created by Artem Misesin on 3/28/17.
//  Copyright © 2017 Artem Misesin. All rights reserved.
//

import Foundation

func randomString(length: Int) -> String { // формируем ключ
    
    var letters : NSString = ""
    
    var randomString = ""
    
    for index in 0 ..< length {
        if index == 0{
            letters = "01234567"
        } else {
            letters = "ABCDEF0123456789"
        }
        let len = UInt32(letters.length)
        let rand = arc4random_uniform(len)
        var nextChar = letters.character(at: Int(rand))
        randomString += NSString(characters: &nextChar, length: 1) as String
    }
    return randomString
}

func adaptForBlocks(string: inout String){ // дополняем нулями для разделения на блоки
    while string.characters.count % 16 != 0{
        string += "0"
    }
}

func slice(_ string: String, each count: Int) -> [String]{ // режем на блоки
    var blocksCount = string.characters.count / count
    var slices: [String] = []
    var i = 0
    var j = count - 1
    while (blocksCount > 0){
        let startIndex = string.index(string.startIndex, offsetBy: i)
        let sliceIndex = string.index(string.startIndex, offsetBy: j)
        slices.append(string[startIndex...sliceIndex])
        i += count
        j += count
        blocksCount -= 1
    }
    return slices
}

func adapt(string: inout String){ // дополняем нулями бинарный код
    if string.characters.count < 64{
        var i = 64 - string.characters.count
        while(i > 0){
            string = "0" + string
            i -= 1
        }
    }
}

// начальное преобразование
func initialPermutation(of string: inout String){
    let inString = Array(string.characters)
    var result: [Character] = []
    for index in 0..<64{
        result.append(inString[initialPermutationTable[index] - 1])
    }
    string = String(result)
}

func split(string: String) -> (a: String, b: String){ //
    let binaryLength = string.characters.count
    let midIndex = binaryLength / 2
    
    return (string[0..<midIndex], string[midIndex..<binaryLength])
}

 // преобразование ключа в 56 бит 
func form56(of string: String) -> (String, String){
    var lResult: [Character] = []
    var rResult: [Character] = []
    let array = Array(string.characters)

    for index in 0..<28{
        lResult.append(array[lKey28[index] - 1])
    }
    
    for index in 0..<28{
        rResult.append(array[rKey28[index] - 1])
    }
    
    return (String(lResult), String(rResult))
}

func shift(binary key: inout String, by steps: Int){
    var array = Array(key.characters)
    array = array.rotate(shift: steps)
    key = String(array)
}

func form48(from key: String) -> String {
    let string = Array(key.characters)
    var result: [Character] = []
    for index in 0..<48{
        result.append(string[key48[index] - 1])
    }
    return String(result)
}

func extArrangement(of data: inout String){
    let string = Array(data.characters)
    var result: [Character] = []
    for index in 0..<48{
        result.append(string[eSelectionTable[index] - 1])
    }
    data = String(result)
}

func performXOR(data: String, key: String)->String{
    var result: [Character] = []
    for (index, value) in data.characters.enumerated(){
        if value == key[index]{
            result.append("0")
        } else {
            result.append("1")
        }
    }
    return String(result)
}

func simplePermutation(from value: inout String){
    let string = Array(value.characters)
    var result: [Character] = []
    for index in 0..<simplePermutationTable.count{
        result.append(string[simplePermutationTable[index] - 1])
    }
    value = String(result)
}

func sTablePermutation(string: inout String){
    var result = string
    var smallBlocks = slice(result, each: 6)
    result = ""
    for (index, block) in smallBlocks.enumerated() {
        let middle = "\(block[1])\(block[2])\(block[3])\(block[4])"
        let edges = "\(block[0])\(block[5])"
        let row = Int(edges, radix: 2)!
        let column = Int(middle, radix: 2)!
        let value = tables6[index][row][column]
        var binValue = String(value, radix: 2)
        while binValue.characters.count < 4 {
            binValue.insert("0", at: binValue.startIndex)
        }
        smallBlocks[index] = binValue
        result += smallBlocks[index]
    }
    string = result
}

func finalPermutation(from value: String) -> String {
    let string = Array(value.characters)
    var result: [Character] = []
    for index in 0..<finalPermutationTable.count{
        result.append(string[finalPermutationTable[index] - 1])
    }
    return String(result)
}

func encryptDES(text: String)->([String], String){
    var data = Data()
    var blocks: [String] = []
    // Разбиваем на блоки
    data = text.data(using: String.Encoding.utf8)!
    var hexText = data.hexEncodedString()
    adaptForBlocks(string: &hexText)
    blocks = slice(hexText, each: 16)
    
    var cryptedBinaries: [String] = []
    
    // Формирование ключа
    let key = "133457799BBCDFF1" //randomString(length: 16)
    var binKey = String(Int(key, radix: 16)!, radix: 2)
    
    adapt(string: &binKey)
    //print(binKey)
    
    //Работа с первым блоком
    //for mainBlock in blocks {
    let mainBlock = "12345678"
        guard let hexInt = Int(mainBlock, radix: 16) else {
            print("Error while evaluating")
            abort()
        }
        
        var binary = String(hexInt, radix: 2) // Бинарная строка
        
        adapt(string: &binary) // добавляем нули, если надо
        initialPermutation(of: &binary) // начальная перестановка
        var (substringA, substringB) = split(string: binary) // разрезанная бинарная строка
        
        // делим ключ пополам
        
        var (lKey28, rKey28) = form56(of: binKey)
    
        print("L0: " + substringA)
        print("R0: " + substringB)
    
        var round = 1
        
        while round <= 16{
            switch round { // сдвиги ключей
            case 1, 2, 9, 16:
                shift(binary: &lKey28, by: 1)
                shift(binary: &rKey28, by: 1)
                break;
            default:
                shift(binary: &lKey28, by: 2)
                shift(binary: &rKey28, by: 2)
            }
            
            let finalKey = form48(from: lKey28 + rKey28) // сжимающая перестановка (48 бит) 
            print("Key\(round): " + finalKey)
            if round != 16 {
                var temp = substringA
                substringA = substringB
                print("L\(round): " + substringA)
                extArrangement(of: &substringB)
                print(substringB)
                substringB = performXOR(data: substringB, key: finalKey)
                sTablePermutation(string: &substringB)
                simplePermutation(from: &substringB)
                print(temp)
                substringB = performXOR(data: temp, key: substringB)
                print("R\(round): " + substringB)
            } else {
                var temp = substringB
                substringB = substringA
                print("R\(round): " + substringB)
                extArrangement(of: &temp)
                temp = performXOR(data: temp, key: finalKey)
                sTablePermutation(string: &temp)
                simplePermutation(from: &temp)
                substringA = performXOR(data: temp, key: substringA)
                print("L\(round): " + substringA)
                
            }
            round += 1;
        }
        cryptedBinaries.append(finalPermutation(from: substringA + substringB))
    //}
    return (cryptedBinaries, key)
}

func hexToString(hex: String) -> String? {
    guard hex.characters.count % 2 == 0 else {
        return nil
    }
    
    var bytes = [CChar]()
    
    var startIndex = hex.index(hex.startIndex, offsetBy: 2)
    while startIndex < hex.endIndex {
        let endIndex = hex.index(startIndex, offsetBy: 2)
        let substr = hex[startIndex..<endIndex]
        
        if let byte = Int8(substr, radix: 16) {
            bytes.append(byte)
        } else {
            return nil
        }
        
        startIndex = endIndex
    }
    bytes.append(0)
    return String(cString: bytes)
}

func decryptDES(textBlocks: [String], key: String)->[String]{
    var binKey = String(Int(key, radix: 16)!, radix: 2)
    adapt(string: &binKey)
    
    var decryptedText: [String] = []
    
    //Работа с первым блоком
    for mainBlock in textBlocks {
        
        var binary = mainBlock // Бинарная строка
        
        print(binary)
        print(binary.characters.count)
        
        adapt(string: &binary) // добавляем нули, если надо
        
        initialPermutation(of: &binary) // начальная перестановка
        
        var (substringA, substringB) = split(string: binary) // разрезанная бинарная строка
        
        // делим ключ пополам
        
        var (lKey28, rKey28) = form56(of: binKey)
        
        var round = 16
        
        while round >= 1{
            switch round { // сдвиги ключей
            case 1, 2, 9, 16:
                shift(binary: &lKey28, by: 1)
                shift(binary: &rKey28, by: 1)
                break;
            default:
                shift(binary: &lKey28, by: 2)
                shift(binary: &rKey28, by: 2)
            }
            let finalKey = form48(from: lKey28 + rKey28) // сжимающая перестановка (48 бит)
            print("K\(round) key: " + finalKey)
            if round != 1 {
                var temp = substringB
                substringB = substringA
                print("R\(round): " + substringB)
                extArrangement(of: &substringA)
                substringA = performXOR(data: substringA, key: finalKey)
                sTablePermutation(string: &substringA)
                simplePermutation(from: &substringA)
                substringA = performXOR(data: temp, key: substringA)
                print("L\(round): " + substringA)
            } else {
                var temp = substringA
                print("L\(round): " + substringA)
                extArrangement(of: &temp)
                temp = performXOR(data: temp, key: finalKey)
                sTablePermutation(string: &temp)
                simplePermutation(from: &temp)
                substringB = performXOR(data: temp, key: substringB)
                print("R\(round): " + substringB)
            }
            round -= 1;
        }
        decryptedText.append(finalPermutation(from: substringA + substringB))
    }
    return decryptedText
}

func binToHex(bin: String) -> String {
    let num = bin.withCString {strtoul($0, nil, 2)}
    let hex = String(num, radix: 16, uppercase: true)
    return hex
}



