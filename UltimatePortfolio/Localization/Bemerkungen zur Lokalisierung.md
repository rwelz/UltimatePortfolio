//
//  Untitled.md
//  UltimatePortfolio
//
//  Created by Robert Welz on 23.06.25.
//

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



