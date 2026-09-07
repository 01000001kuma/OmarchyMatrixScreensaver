import QtQuick

Item {
    id: root

    readonly property color matrixGreen: "#00FF41"
    readonly property int fieldWidth: 381
    readonly property int fieldHeight: 60
    readonly property int outlineThickness: 2

    property string password: ""
    property bool inputEnabled: false
    property bool authenticating: false
    property string failureMessage: ""
    property bool errorState: failureMessage.length > 0

    signal submitPassword(string password)
    signal passwordTextEdited(string password)
    signal clearFailureRequested()

    function randomMatrixChar() {
        var chars = "2 5 9 8 Z * ) : . \" = + - ¦ | _ ｦ ｱ ｳ ｴ ｵ ｶ ｷ ｹ ｺ ｻ ｼ ｽ ｾ ｿ ﾀ ﾂ ﾃ ﾅ ﾆ ﾇ ﾈ ﾊ ﾋ ﾎ ﾏ ﾐ ﾑ ﾒ ﾓ ﾔ ﾕ ﾗ ﾘ ﾜ"
        var arr = chars.split(" ").filter(function(c) { return c.length > 0 })
        return arr[Math.floor(Math.random() * arr.length)]
    }

    function clearPassword() {
        password = ""
        passwordTextEdited("")
    }

    Item {
        id: fieldContainer
        anchors.centerIn: parent
        width: root.fieldWidth
        height: root.fieldHeight

        Rectangle {
            id: fieldRect
            anchors.fill: parent
            color: "#CC000000"
            border.color: root.errorState ? "#FF0000" : root.matrixGreen
            border.width: root.outlineThickness

            SequentialAnimation {
                id: borderPulse
                running: root.inputEnabled && !root.authenticating && !root.errorState
                loops: Animation.Infinite
                PropertyAnimation {
                    target: fieldRect.border
                    property: "color"
                    to: "#6600FF41"
                    duration: 500
                    easing.type: Easing.InOutSine
                }
                PropertyAnimation {
                    target: fieldRect.border
                    property: "color"
                    to: root.matrixGreen
                    duration: 500
                    easing.type: Easing.InOutSine
                }
            }

            SequentialAnimation {
                id: errorFlash
                running: root.errorState
                loops: 3
                PropertyAnimation {
                    target: fieldRect.border
                    property: "color"
                    to: "#33FF0000"
                    duration: 150
                }
                PropertyAnimation {
                    target: fieldRect.border
                    property: "color"
                    to: "#FF0000"
                    duration: 150
                }
            }
        }

        Row {
            anchors.left: parent.left
            anchors.leftMargin: 12
            anchors.verticalCenter: parent.verticalCenter
            spacing: 0

            Text {
                text: "> "
                color: root.matrixGreen
                font.family: "monospace"
                font.pixelSize: 26
                font.bold: true
                anchors.verticalCenter: parent.verticalCenter
            }

            Repeater {
                model: root.password.length

                Text {
                    text: root.randomMatrixChar()
                    color: root.matrixGreen
                    font.family: "monospace"
                    font.pixelSize: 26
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            Rectangle {
                id: cursor
                width: 14
                height: 28
                color: root.matrixGreen
                anchors.verticalCenter: parent.verticalCenter
                visible: root.inputEnabled && !root.authenticating

                SequentialAnimation on opacity {
                    running: root.inputEnabled && !root.authenticating
                    loops: Animation.Infinite
                    NumberAnimation { to: 0; duration: 500; easing.type: Easing.InOutSine }
                    NumberAnimation { to: 1; duration: 500; easing.type: Easing.InOutSine }
                }
            }
        }

        Text {
            anchors.centerIn: parent
            text: root.authenticating ? "checking..." :
                  root.errorState ? root.failureMessage : ""
            color: root.errorState ? "#FF0000" : root.matrixGreen
            font.family: "monospace"
            font.pixelSize: 14
        }
    }

    TextInput {
        id: passwordInput
        anchors.fill: fieldContainer
        visible: false
        focus: root.inputEnabled
        echoMode: TextInput.Normal
        passwordCharacter: "\u25CF"
        passwordMaskDelay: 0
        onTextChanged: {
            root.password = text
            root.passwordTextEdited(text)
            if (root.errorState) root.clearFailureRequested()
        }
        onAccepted: {
            var val = text
            text = ""
            root.submitPassword(val)
        }
        Keys.onPressed: function(event) {
            if (event.key === Qt.Key_Escape || (event.key === Qt.Key_U && event.modifiers & Qt.ControlModifier)) {
                root.clearPassword()
                event.accepted = true
            }
        }
    }

    MouseArea {
        anchors.fill: fieldContainer
        onClicked: {
            if (root.inputEnabled) {
                passwordInput.forceActiveFocus()
            }
        }
    }

    onInputEnabledChanged: {
        if (inputEnabled) {
            passwordInput.forceActiveFocus()
        }
    }

    function forceFocus() {
        passwordInput.forceActiveFocus()
    }
}
