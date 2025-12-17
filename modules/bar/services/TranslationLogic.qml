pragma ComponentBehavior: Bound
import QtQuick

QtObject {
    id: translationLogic

    // Señales para comunicar estados
    signal translationStarted
    signal translationCompleted(string translatedText)
    signal translationFailed(string errorMessage)

    // Estado de la traducción
    property bool isTranslating: false
    property string lastError: ""

    // Referencias necesarias (deben ser establecidas desde el componente padre)
    property var dataModel: null
    property var languageSelector: null
    property var inputText: null
    property var outputText: null
    property var root: null

    function swapLanguages() {
        if (!root || !languageSelector)
            return;
        const tempLanguage = root.fromLanguageSelected;
        languageSelector.fromLang.setLanguageByText(root.toLanguageSelected);
        languageSelector.toLang.setLanguageByText(tempLanguage);
    }

    function translateText() {
        if (!inputText || !outputText || !languageSelector || !dataModel) {
            console.error("Referencias no inicializadas correctamente");
            return;
        }

        const text = inputText.text.trim();
        if (text === "") {
            return;
        }

        // Obtener códigos de idioma
        const fromCode = dataModel.languages[languageSelector.fromLang.currentIndex].code;
        const toCode = dataModel.languages[languageSelector.toLang.currentIndex].code;

        // Verificar si son el mismo idioma
        if (fromCode === toCode) {
            outputText.text = text;
            return;
        }

        // Iniciar traducción
        isTranslating = true;
        translationStarted();
        outputText.text = "Traduciendo...";

        // Construir URL
        const encodedText = encodeURIComponent(text);
        const url = `https://api.mymemory.translated.net/get?q=${encodedText}&langpair=${fromCode}|${toCode}`;

        console.log("Traduciendo:", text);
        console.log("De:", fromCode, "A:", toCode);
        console.log("URL:", url);

        // Crear XMLHttpRequest
        const xhr = new XMLHttpRequest();

        xhr.onreadystatechange = function () {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    handleTranslationResponse(xhr.responseText);
                } else {
                    handleTranslationError(`Error HTTP ${xhr.status}: ${xhr.statusText}`);
                }
            }
        };

        xhr.ontimeout = function () {
            handleTranslationError("Tiempo de espera agotado");
        };

        xhr.onerror = function () {
            handleTranslationError("Error de red al conectar con el servidor");
        };

        try {
            xhr.open("GET", url, true);
            xhr.timeout = 15000; // 15 segundos
            xhr.send();
        } catch (e) {
            handleTranslationError(`Error al realizar la petición: ${e.message}`);
        }
    }

    function handleTranslationResponse(responseText) {
        try {
            console.log("Respuesta recibida:", responseText);

            const response = JSON.parse(responseText);

            if (response.responseStatus === 200 && response.responseData) {
                const translatedText = response.responseData.translatedText;

                if (translatedText) {
                    outputText.text = translatedText;
                    isTranslating = false;
                    translationCompleted(translatedText);
                    console.log("Traducción exitosa:", translatedText);
                } else {
                    handleTranslationError("No se recibió traducción");
                }
            } else if (response.responseStatus === 403) {
                handleTranslationError("Límite de traducción alcanzado. Intenta más tarde.");
            } else if (response.responseStatus === 429) {
                handleTranslationError("Demasiadas peticiones. Espera un momento.");
            } else {
                const errorMsg = response.responseDetails || `Error ${response.responseStatus}`;
                handleTranslationError(errorMsg);
            }
        } catch (e) {
            handleTranslationError(`Error al procesar respuesta: ${e.message}`);
            console.error("Respuesta que causó el error:", responseText);
        }
    }

    function handleTranslationError(errorMessage) {
        console.error("Error de traducción:", errorMessage);
        lastError = errorMessage;
        outputText.text = `Error: ${errorMessage}`;
        isTranslating = false;
        translationFailed(errorMessage);
    }

    function copyToClipboard() {
        if (!outputText)
            return;
        const text = outputText.text;
        if (text === "" || text === root.defaultOutputPlaceholder || text.startsWith("Error:")) {
            console.log("No hay texto válido para copiar");
            return;
        }

        // Crear un TextEdit temporal para copiar al portapapeles
        const textEdit = Qt.createQmlObject(`
            import QtQuick
            import QtQuick.Controls
            TextEdit {
                visible: false
                text: ""
            }
        `, translationLogic, "tempTextEdit");

        textEdit.text = text;
        textEdit.selectAll();
        textEdit.copy();
        textEdit.destroy();

        console.log("Texto copiado al portapapeles");
    }

    function validateInputLength(text) {
        if (!root)
            return text;
        return text.length > root.maxCharacters ? text.substring(0, root.maxCharacters) : text;
    }
}
