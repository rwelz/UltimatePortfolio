echo \"🧹 SwiftLint: Starte Linting Check mit Style ✨\"

cd "${SRCROOT}"
    echo "SRCROOT = ${SRCROOT}"
# Wenn auf ARM64 (M1/M2/M3 Mac), dann Homebrew Pfad setzen
if [[ "$(uname -m)" == "arm64" ]]; then
    export PATH="/opt/homebrew/bin:$PATH"
fi

CONFIG_PATH="${SRCROOT}/.swiftlint.yml"

# Prüfe, ob SwiftLint installiert ist
if ! command -v swiftlint >/dev/null 2>&1; then
    echo "⚠️ SwiftLint ist nicht installiert. Siehe: https://github.com/realm/SwiftLint#installation"
    exit 0
fi

# Prüfe, ob Konfiguration vorhanden und lesbar ist
if [[ ! -f "$CONFIG_PATH" || ! -r "$CONFIG_PATH" ]]; then
    echo "⚠️  .swiftlint.yml fehlt oder ist nicht lesbar – es wird mit der Standardkonfiguration gearbeitet"
    swiftlint lint || exit 1
else
    echo "✅ .swiftlint.yml gefunden – Linting beginnt…"
    swiftlint lint --config "$CONFIG_PATH" || exit 1
fi

echo "🎉 SwiftLint abgeschlossen! Gutes Coden, du Zauberwesen 🧚"
