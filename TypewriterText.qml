import QtQuick

Item {
    id: root

    readonly property color matrixGreen: "#00FF41"
    property var lines: [
        "Knock, knock...",
        "Wake up...",
        "Follow the white rabbit."
    ]
    property int currentLine: 0
    property int currentChar: 0
    property string displayText: ""
    property bool typing: false
    property bool complete: false
    property bool cursorVisible: true

    property int charDelay: 60
    property int linePause: 1200
    property int humanVariance: 40

    signal typingComplete()

    function startTyping() {
        currentLine = 0
        currentChar = 0
        displayText = ""
        typing = true
        complete = false
        cursorVisible = true
        blinkTimer.start()
        typeNextChar()
    }

    function typeNextChar() {
        if (!typing) return

        if (currentLine >= lines.length) {
            typing = false
            complete = true
            cursorVisible = false
            blinkTimer.stop()
            typingComplete()
            return
        }

        var line = lines[currentLine]
        if (currentChar < line.length) {
            displayText += line[currentChar]
            currentChar++
            var variance = Math.floor(Math.random() * humanVariance * 2) - humanVariance
            charTimer.interval = Math.max(20, charDelay + variance)
            charTimer.start()
        } else {
            currentLine++
            currentChar = 0
            if (currentLine < lines.length) {
                displayText += "<br>"
                linePauseTimer.start()
            } else {
                typing = false
                complete = true
                cursorVisible = false
                blinkTimer.stop()
                typingComplete()
            }
        }
    }

    Timer {
        id: charTimer
        repeat: false
        onTriggered: root.typeNextChar()
    }

    Timer {
        id: linePauseTimer
        interval: root.linePause
        repeat: false
        onTriggered: root.typeNextChar()
    }

    Timer {
        id: blinkTimer
        interval: 500
        repeat: true
        onTriggered: root.cursorVisible = !root.cursorVisible
    }

    Text {
        anchors.left: parent.left
        anchors.leftMargin: (parent.width - 381) / 2
        anchors.verticalCenter: parent.verticalCenter
        text: root.displayText + "<span style='color:" + (root.cursorVisible ? root.matrixGreen : "#000000") + "'>█</span>"
        color: root.matrixGreen
        font.family: "monospace"
        font.pixelSize: 26
        wrapMode: Text.NoWrap
        textFormat: Text.RichText
    }

    function reset() {
        typing = false
        complete = false
        currentLine = 0
        currentChar = 0
        displayText = ""
        cursorVisible = false
        blinkTimer.stop()
        charTimer.stop()
        linePauseTimer.stop()
    }
}
