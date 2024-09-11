import SwiftUI

// Main view of the app
struct ContentView: View {
    // State variables to track the current state of the game
    @State private var usedWords = [String]()  // List of words already used by the player
    @State private var rootWord = ""  // The word from which players need to form new words
    @State private var newWord = ""  // The word currently being typed by the user
    @State private var errorTitle = ""  // Title of the error message to display
    @State private var errorMessage = ""  // The error message content
    @State private var showingError = false  // Bool to control if an error alert is shown
    @State private var userScore = 0  // The user's current score
    
    var body: some View {
        NavigationStack {
            List {
                // Section for user to input new words
                Section {
                    TextField("Enter your word", text: $newWord)
                        .textInputAutocapitalization(.never)  // Prevents automatic capitalization
                }
                
                // Section that shows all the words the user has entered
                Section {
                    ForEach(usedWords, id: \.self) { word in  // Iterate over used words
                        HStack {
                            Image(systemName: "\(word.count).circle")  // Display circle with word length
                            Text(word)  // Display the word
                        }
                    }
                }
            }
            .navigationTitle(rootWord)  // Sets the title to the root word
            .onSubmit(addNewWord)  // Called when the user submits a new word
            .onAppear(perform: startGame)  // Called when the view appears, starts the game
            .alert(errorTitle, isPresented: $showingError) { } message: {
                Text(errorMessage)  // Show error message if needed
            }
            .toolbar {
                Button("Reset Game", action: startGame)  // Button to reset the game
            }
            
            // Display the user's score
            VStack {
                Text("\(userScore)")
                    .font(.title)
                    .bold()
            }
            Spacer()  // Adds some spacing between the score and other content
        }
        
    }
    
    // Adds a new word to the list, if it's valid
    func addNewWord() {
        let answer = newWord.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)  // Clean up the word
        
        guard answer.count > 0 else { return }  // Ensure the word is not empty
        
        // Ensure the word hasn't been used before
        guard isOriginal(word: answer) else {
            wordError(title: "Word used already", message: "Be more original")
            return
        }
        
        // Ensure the word is at least 3 characters long
        guard isLongEnough(word: answer) else {
            wordError(title: "Word not long enough", message: "The word must be at least 3 characters")
            return
        }
        
        // Ensure the word isn't the root word
        guard isRoot(word: answer) else {
            wordError(title: "Word not possible", message: "You can't use the root word!")
            return
        }
        
        // Ensure the word can be formed from the root word
        guard isPossible(word: answer) else {
            wordError(title: "Word not possible", message: "You can't spell that word from '\(rootWord)'!")
            return
        }
        
        // Ensure the word is a valid English word
        guard isReal(word: answer) else {
            wordError(title: "Word not recognized", message: "You can't just make them up, you know!")
            return
        }
        
        withAnimation {
            usedWords.insert(answer, at: 0)  // Add the new word to the top of the list
        }
        
        userScore += (1 + answer.count)  // Increase the user's score based on word length
        newWord = ""  // Clear the input field
    }
    
    // Starts the game by loading a random root word
    func startGame() {
        // 1. Find the URL for start.txt in our app bundle
        if let startWordsURL = Bundle.main.url(forResource: "start", withExtension: "txt") {
            
            // 2. Load start.txt into a string
            if let startWords = try? String(contentsOf: startWordsURL) {
                
                // 3. Split the string into an array of words, splitting by line breaks
                let allWords = startWords.components(separatedBy: "\n")
                
                // 4. Pick a random word, or use "silkworm" as a fallback
                rootWord = allWords.randomElement() ?? "silkworm"
                
                return  // Exit as everything worked
            }
        }
        
        // If something went wrong, crash with an error message
        fatalError("Could not load start.txt from bundle")
    }
    
    // Checks if the word is original (i.e., not already used)
    func isOriginal(word: String) -> Bool {
        !usedWords.contains(word)
    }
    
    // Checks if the word is at least 3 characters long
    func isLongEnough(word: String) -> Bool {
        word.count >= 3
    }
    
    // Checks if the word is different from the root word
    func isRoot(word: String) -> Bool {
        word != rootWord
    }
    
    // Checks if the word can be formed using letters from the root word
    func isPossible(word: String) -> Bool {
        var tempWord = rootWord
        
        for letter in word {
            if let pos = tempWord.firstIndex(of: letter) {
                tempWord.remove(at: pos)  // Remove letter if it's found
            } else {
                return false  // Letter not found, so word isn't possible
            }
        }
        
        return true
    }
    
    // Checks if the word is a valid English word
    func isReal(word: String) -> Bool {
        let checker = UITextChecker()
        let range = NSRange(location: 0, length: word.utf16.count)
        let misspelledRange = checker.rangeOfMisspelledWord(in: word, range: range, startingAt: 0, wrap: false, language: "en")
            
        return misspelledRange.location == NSNotFound  // Word is valid if no misspelled range
    }
    
    // Triggers an error alert with the given title and message
    func wordError(title: String, message: String) {
        errorTitle = title
        errorMessage = message
        showingError = true  // Show the alert
    }
}

// Preview for the ContentView
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

