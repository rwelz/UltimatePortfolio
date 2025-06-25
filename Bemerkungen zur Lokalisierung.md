//  Bemerkungen zur Lokalisierung.md

//  UltimatePortfolio

//  Created by Robert Welz on 23.06.25.



Wann benutze ich LocalizedStringKey oder NSLocalizedString 

**LocalizedStringKey:**

"welcome_message" = "Willkommen!";

"personal_greeting %@" = "Hallo, %@!";


struct ContentView: View {
    var username = "Max"

    var body: some View {
        VStack {
            Text("welcome_message") // Automatisch lokalisiert zu "Willkommen!"
            
            Text("personal_greeting \(username)") 
            // Wird zu "Hallo, Max!" lokalisiert, wenn entsprechender Key vorhanden
        }
    }
}

​	•	SwiftUI erkennt automatisch, dass "welcome_message" ein Lokalisierungsschlüssel ist.

​	•	in SwiftUI Text oder Label



**NSLocalizedString**

	let welcome = NSLocalizedString("welcome_message", comment: "Begrüßung für Startbildschirm")
	print(welcome) // Gibt "Willkommen!" zurück (sofern lokalisiert)
	
	let username = "Max"
	let template = NSLocalizedString("personal_greeting %@", comment: "Personalisierte Begrüßung")
	let personalizedGreeting = String(format: template, username)
	print(personalizedGreeting) // Gibt "Hallo, Max!" zurück


​	•	Hier Musst du String(format: ...) selbst schreiben, damit Platzhalter ersetzt werden.

​	•	NSLocalizedString  ist ein extra Funktionsaufruf

**Zusammenfassung:**

| **Kontext**                                                 | Empfohlen                           |
| ----------------------------------------------------------- | ----------------------------------- |
| SwiftUI Text oder Label                                     | LocalizedStringKey direkt verwenden |
| Hintergrund-Logik, z. B. Log-Meldungen oder Netzwerkkontext | NSLocalizedString nutzen            |
| UIKit-Label, Buttons, Alerts                                | NSLocalizedString nutzen            |

**SwiftUI-Elemente, die LocalizedStringKey direkt unterstützen**

| Element            | Beispiel                                        | Lokalisierung automatisch? |
| ------------------ | ----------------------------------------------- | -------------------------- |
| Text               | Text("welcome_message")                         | ✅ Ja                       |
| Label              | Label("settings_title", systemImage: "gear")    | ✅ Ja                       |
| Button             | Button("confirm_action") { }                    | ✅ Ja                       |
| NavigationTitle    | .navigationTitle("home_title")                  | ✅ Ja                       |
| NavigationLink     | NavigationLink("next_page", destination: ...)   | ✅ Ja                       |
| ToolbarItem        | ToolbarItem { Button("save") { } }              | ✅ Ja                       |
| Picker (Labels)    | Picker("choose_option", selection: ...) { ... } | ✅ Ja                       |
| Toggle             | Toggle("enable_feature", isOn: $toggle)         | ✅ Ja                       |
| Alert (Titel/Text) | .alert("error_title", isPresented: ...) { }     | ✅ Ja                       |
| Menu               | Menu("actions_menu") { ... }                    | ✅ Ja                       |

**String-Interpolation wird ebenfalls unterstützt:**

Text("personal_greeting \(username)") 



**SwiftUI-Elemente ohne automatische Lokalisierung:**

| Element                                | Beschreibung                                                 | Lokalisierung automatisch? |
| -------------------------------------- | ------------------------------------------------------------ | -------------------------- |
| Text(verbatim: "Text")                 | Erzwingt rohen Text, keine Lokalisierung                     | ❌ Nein                     |
| Direktzuweisung an String-Variablen    | Z. B. let text = "some_text" – das ist normaler String       | ❌ Nein                     |
| TextField (Platzhalter)                | Platzhalter im Textfeld wird nicht automatisch lokalisiert   | ❌ Nein                     |
| SecureField (Platzhalter)              | Gleiche Logik wie bei TextField                              | ❌ Nein                     |
| TextEditor (Platzhalter fehlt sowieso) | Kein direkter Platzhalter vorhanden                          | -                          |
| Direktes String-Binding in Modellen    | z. B. wenn ViewModel einen String-Key speichert              | ❌ Nein                     |
| Eigenes UI mit Strings                 | Wenn du z. B. ein Label in einer UIViewRepresentable einsetzt | ❌ Nein                     |

Beispiele:

let key = LocalizedStringKey("welcome_message")

Text(key) // Lokalisierung aktiv

oder

Text(LocalizedStringKey("welcome_message"))

