#!/bin/bash

echo "🧹 SwiftLint Rettungsscript wird ausgeführt…"

# 1. Sicherstellen, dass du im Projektverzeichnis bist
cd "$(dirname "$0")"

# 2. Check: Gibt es eine .swiftlint.yml?
if [ ! -f ".swiftlint.yml" ]; then
    echo "⚠️  .swiftlint.yml nicht gefunden – erstelle neue Konfigurationsdatei…"
    cat > .swiftlint.yml <<EOL
opt_in_rules:
  - force_unwrapping
  - sorted_imports

disabled_rules:
  - file_length
  - identifier_name

line_length:
  warning: 120
  error: 160
  ignores_comments: true
  ignores_urls: true

excluded:
  - Pods
  - Carthage
  - fastlane
  - node_modules

reporter: xcode
EOL
    echo "✅ Neue .swiftlint.yml wurde erstellt."
fi

# 3. Berechtigungen reparieren
echo "🔧 Berechtigungen setzen…"
chmod 644 .swiftlint.yml
chown $(whoami) .swiftlint.yml 2>/dev/null || echo "🔸 Keine Änderung am Besitzer nötig."

# 4. Test: Kann SwiftLint gelesen & ausgeführt werden?
echo "🧪 Teste SwiftLint Zugriff auf Konfiguration:"
swiftlint lint --config .swiftlint.yml || echo "❌ Fehler beim Linten – prüfe .swift-Dateien oder Konfiguration!"

echo "🎉 Fertig! SwiftLint ist jetzt wieder startklar."

