//
//  ContentView.swift
//  WordScramble
//
//  Created by Jeffri Lieca H on 23/12/24.
//

import SwiftUI

//struct ContentView: View {
//    let people = ["Finn", "Leia", "Luke", "Rey"]
//    
//
//    var body: some View {
//        let input = """
//                    a
//                    b
//                    c
//                    """
//        let letters = input.components(separatedBy: "\n")
//        let letter = letters.randomElement()
//        let trimmed = letter?.trimmingCharacters(in: .whitespacesAndNewlines)
//        let word = "swift"
//        let checker = UITextChecker()
//        let range = NSRange(location: 0, length: word.utf16.count)
//        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
//        let allGood = misspelledRange.location == NSNotFound
//
//        List {
//            Text("Static Row")
//
//            ForEach(people, id: \.self) {
//                Text($0)
//            }
//            ForEach(letters, id: \.self) {
//                Text($0)
//            }
//
//            Text("Static Row")
//        }
//    }
//}

struct ContentView : View {
    @State private var usedWords = [String]()
    @State private var rootWord = ""
    @State private var newWord = ""
    static private var dictionaryWord : [String] = [String]()
    @State private var errorTitle = ""
    @State private var errorMessage = ""
    @State private var showingError = false
    @State private var score = 0
    @State private var firstTimeCool = true
    
    var body: some View {
        NavigationStack {
            VStack (alignment: .trailing){
                    //                    Spacer()
                    
                Text("Score: \(String(format: score > 9999 ? "%04d+" : "%04d", score > 9999 ? 9999 : score))")
                        .font(.title3.bold())
                        .foregroundStyle(.purple)
                    
                        .frame(maxWidth: 130, alignment: .leading)
                        .padding()
                    //                            .background(.red)
                    
                    
                List {
                    Section {
                        TextField("Enter your word", text: $newWord)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                    }
                    
                    Section {
                        ForEach(usedWords, id: \.self) { word in
                            HStack {
                                Image(systemName: "\(word.count).circle")
                                Text(word)
                            }
                        }
                    }
                }
            }
//            .background(.red)
            .listStyle(.insetGrouped)
            .navigationTitle(rootWord)
            .toolbar{
                Button("New Game"){
                    newGame()
                }
            }
            .onSubmit(addNewWord)
            .onAppear(perform: startGame)
                
        }
        .alert(errorTitle, isPresented: $showingError) {} message: {
            Text(errorMessage)
        }
    }
    
    func calculateScore(for word: String) -> Int {
        
        switch word.count {
        case 8 :
            firstTimeCool = false
            wordError(title: "You are Amazing!!!", message: "You can found the hidden word")
            return 9999
        case let count where count >= 6: return 2000
        case let count where count >= 4 : return 1000
        default : return 500
        }
        
    }
    
    func addNewWord() {
        // lowercase and trim the word, to make sure we don't add duplicate words with case differences
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)

        // exit if the remaining string is empty
        
        guard answer != rootWord else {
            wordError(title: "Word is similar", message: "Dont you dare answering with the given word!")
            return
        }
        
        guard answer.count >= 3 else {
            wordError(title: "Word too short", message: "Try make more than 2 character's word")
            return
        }

        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original")
            return
        }

        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "You can't spell that word from '\(rootWord)'!")
            return
        }

        guard isReal(word: answer) else {
            wordError(title: "Word not recognized", message: "You can't just make them up, you know!")
            return
        }

        withAnimation {
            usedWords.insert(answer, at: 0)
            score += calculateScore(for: answer)
            if firstTimeCool && score > 9999 {
                firstTimeCool = false
                wordError(title: "Big Win!!!", message: "You are the best among the best")
            }
        }
        newWord = ""
    }
    
    func startGame() {
        // 1. Find the URL for start.txt in our app bundle
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            // 2. Load start.txt into a string
            if let startWords = try? String(contentsOf: startWordsURL,encoding: .ascii) {
                // 3. Split the string up into an array of strings, splitting on line breaks
                let allWords = startWords.components(separatedBy: "\n")

                Self.dictionaryWord = allWords
                // 4. Pick one random word, or use "silkworm" as a sensible default
                rootWord = allWords.randomElement() ?? "silkworm"

                // If we are here everything has worked, so we can exit
                return
            }
        }

        // If were are *here* then there was a problem – trigger a crash and report the error
        fatalError("Could not load start.txt from bundle.")
    }
    
    func newGame() {
        withAnimation{
            newWord = ""
            rootWord = Self.dictionaryWord.randomElement() ?? "silkworm"
            score = 0
            usedWords.removeAll()
            firstTimeCool = true
        }
    }
    
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord

        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)
            } else {
                return false
            }
        }

        return true
    }
    
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")

        return misspelledRange.location == NSNotFound
    }
    
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true
    }
}

#Preview {
    ContentView()
}
