import QtQuick

Item {
    id: root
    focus: true

    readonly property color matrixGreen: "#00FF41"
    readonly property color matrixBlack: "#000000"
    readonly property int passwordDelay: 500

    property bool isPrimaryScreen: false
    property string screenName: ""
    property bool inputEnabled: false
    property bool authenticating: false
    property string failureMessage: ""
    property string passwordText: ""
    property int failedAttempts: 0
    property string state: "idle"

    signal submitPassword(string password)
    signal passwordTextEdited(string password)
    signal clearFailureRequested()

    function startAnimation() {
        allTimersStop()
        rabbitFadeIn.stop()
        rabbitImage.opacity = 0
        typewriter.reset()
        passwordInput.clearPassword()
        state = "rain"
        rain.active = true
        root.forceActiveFocus()
    }

    function stopAnimation() {
        allTimersStop()
        rain.active = false
        typewriter.reset()
        passwordInput.clearPassword()
    }

    function resetState() {
        stopAnimation()
        state = "idle"
    }

    function allTimersStop() {
        fadeTimer.stop()
        rabbitTimer.stop()
        passwordAppearTimer.stop()
    }

    property real lastMouseX: 0
    property real lastMouseY: 0
    property real mouseThreshold: 10

    MouseArea {
        anchors.fill: parent
        cursorShape: Qt.BlankCursor
        z: 100
        hoverEnabled: true

        onClicked: function(mouse) {
            if (root.state === "rain") {
                root.state = "fading"
                rain.fadeOut()
                fadeTimer.start()
            }
        }

        onPositionChanged: function(mouse) {
            if (root.state === "rain") {
                var dx = mouse.x - root.lastMouseX
                var dy = mouse.y - root.lastMouseY
                if (Math.sqrt(dx*dx + dy*dy) > root.mouseThreshold) {
                    root.state = "fading"
                    rain.fadeOut()
                    fadeTimer.start()
                }
            }
            root.lastMouseX = mouse.x
            root.lastMouseY = mouse.y
        }

        onEntered: {
            root.lastMouseX = mouseX
            root.lastMouseY = mouseY
        }
    }

    Keys.onPressed: function(event) {
        if (root.state === "rain") {
            root.state = "fading"
            rain.fadeOut()
            fadeTimer.start()
        }
    }

    Rectangle {
        anchors.fill: parent
        color: root.matrixBlack
        z: 0
    }

    MatrixRain {
        id: rain
        anchors.fill: parent
        active: false
        visible: true
        z: 1
    }

    Image {
        id: rabbitImage
        source: Qt.resolvedUrl("assets/WhiteRabbit.png")
        width: 350
        height: 350
        fillMode: Image.PreserveAspectFit
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: -180
        z: 10
        visible: false
        opacity: 0

        NumberAnimation on opacity {
            id: rabbitFadeIn
            from: 0
            to: 1
            duration: 1500
            easing.type: Easing.InOutSine
            running: false
        }
    }

    TypewriterText {
        id: typewriter
        width: 600
        height: 150
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        anchors.verticalCenterOffset: 80
        z: 10
        visible: false
    }

    MatrixPasswordInput {
        id: passwordInput
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.top: typewriter.bottom
        anchors.topMargin: 40
        z: 10
        visible: false
        inputEnabled: root.inputEnabled
        authenticating: root.authenticating
        failureMessage: root.failureMessage

        onSubmitPassword: function(password) {
            root.submitPassword(password)
        }
        onPasswordTextEdited: function(password) {
            root.passwordTextEdited(password)
        }
        onClearFailureRequested: {
            root.clearFailureRequested()
        }
    }

    Timer {
        id: fadeTimer
        interval: 1500
        repeat: false
        onTriggered: {
            rabbitImage.visible = false
            typewriter.visible = true
            passwordInput.visible = false
            root.state = "typewriter"
            typewriter.startTyping()
        }
    }

    Timer {
        id: rabbitTimer
        interval: 300
        repeat: false
        onTriggered: {
            rabbitImage.visible = true
            rabbitFadeIn.start()
            passwordAppearTimer.start()
        }
    }

    Timer {
        id: passwordAppearTimer
        interval: root.passwordDelay
        repeat: false
        onTriggered: {
            passwordInput.visible = true
            root.state = "password"
            root.inputEnabled = true
            passwordInput.forceFocus()
        }
    }

    Connections {
        target: typewriter
        function onTypingComplete() {
            if (root.state === "typewriter") {
                root.state = "rabbit"
                rabbitTimer.start()
            }
        }
    }

    onAuthenticatingChanged: {
        if (!authenticating && state === "password") {
            passwordInput.forceFocus()
        }
    }

    onFailureMessageChanged: {
        if (failureMessage.length > 0 && state === "password") {
            passwordInput.forceFocus()
        }
    }
}
