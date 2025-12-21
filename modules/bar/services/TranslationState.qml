pragma Singleton
import QtQuick

QtObject {
    id: translateState

    // Estado persistente en memoria
    property string inputText: ""
    property int fromLanguageIndex: 0
    property int toLanguageIndex: 1
    property string outputText: ""

    // Función para resetear
    function reset() {
        inputText = "";
        fromLanguageIndex = 0;
        toLanguageIndex = 1;
        outputText = "";
    }
}
