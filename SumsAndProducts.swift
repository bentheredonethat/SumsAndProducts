//: Playground - noun: a place where people can play

import UIKit

// given set of 10 integers, find smallest R(A) of set A where R(A) is | {A+A} union {AxA} |


// proposed method -- 
// make 8 random sequences of positive integers that are multiples of 42
//   compare each 2 adjacent sets, of the worse one of the two do the following:
//          permute 1 integer in set
//          repeat for 50 iterations




let seed = 42
// generate random number that is multiple of 42 and less than 1000
func generateRandomNumber(range: Range<Int> = 1...1000 ) -> Int {
    let min = range.startIndex
    let max = range.endIndex
    return Int(arc4random_uniform(UInt32(max-min))) + min
}

var eightArrays = [[Int]]()
var eightRScores = [Int]()

// populate 8 arrays
for _ in 0...7 { // make 8 arrays
    var newRow = [Int]() // make new array of int
    for _ in 1...seed { // append 'seed' random numbers to array
        newRow.append(generateRandomNumber())
    }
    eightArrays.append(newRow)
    eightRScores.append(9999)
}


// create score for each array

// index into array and generate 'addition' score
func generateRplusScore(index: Int) -> Int {
    var allSums = [Int]()
    
    // get all sums
    for i in eightArrays[index] {
        for j in eightArrays[index] {
            allSums.append(i + j)
        }
    }

    let unique = Set(allSums)
    return unique.count
    
}

// index into array and generate 'multiply' score
func generateRmultiplyScore(index: Int) -> Int {
    var allSums = [Int]()
    
    // get all sums
    for i in eightArrays[index] {
        for j in eightArrays[index] {
            allSums.append(i * j)
        }
    }
    
    let unique = Set(allSums)
    return unique.count
    
}

func generateRScore(index: Int) -> Int {
    return generateRplusScore(index) + generateRmultiplyScore(index)
}


// given index of bad set, replace one random element with randomly generated new number
func updateBadArray(index: Int) {
    while true {
        let newNum = generateRandomNumber() // generate new number
        let inSet = eightArrays[index].indexOf(newNum) // repeat until new number is disjoint
        if inSet == nil {
            // randomly select and permute one element in array
            let lower : UInt32 = 0
            let upper : UInt32 = 9
            let randomNumber = Int(arc4random_uniform(upper - lower) + lower)
            eightArrays[index][randomNumber] = newNum
            return
        }
    
    }
}


struct midtermObject {
    var rScore: Int
    var set: [Int]
    var time: NSTimeInterval
}


// 50 generations of each best R-score along with its corresponding set
var generationsOfRScores = [midtermObject]()
// hold best score and set for given generation

// for 50 iterations
for i in 1...50 {
var start = NSDate()
    // hold best score and set for given generation
var bestRScore: Int = 99999
var bestSet = [Int]()
var fourWorseIndices = [Int]()
    // pick worse of each pair of sequences (1 and 2, 3 and 4, etc...)
    for i in 0...eightArrays.count-1 {
        if (i%2 != 0 ){ continue }
        else {
            // generate two r scores for each of the two sets
            var firstRScore = generateRScore(i)// get even rscore
            var secondRScore = generateRScore(i+1) // get odd score

            // for that worse sequence, randomly select and permute one element
            var betterIndex = (firstRScore > secondRScore) ? i+1 : i
            var betterScore = firstRScore > secondRScore ? secondRScore : firstRScore
            // compare current best of generation against this comparison's result
            if betterScore < bestRScore {
                    // if better then update generation's best set and score
                    bestRScore = betterScore
                    bestSet = eightArrays[betterIndex]
            }
            
            // update current comparison's worse set
            fourWorseIndices.append( (firstRScore < secondRScore) ? i+1 :  i )
        }
    }
    var currentGen = midtermObject(rScore: bestRScore, set: bestSet, time: -start.timeIntervalSinceNow)
    generationsOfRScores.append(currentGen)
    fourWorseIndices.forEach{ updateBadArray($0) } // update four worse sets
    
}
var minGeneration = generationsOfRScores.minElement{ $0.rScore < $1.rScore }

print("best R score : \(minGeneration?.rScore)")
print("best set : \(minGeneration?.set)")
