import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Services.Pam
import qs.Commons

Item {
    id: root

    property var shell: null

    readonly property string userName: Quickshell.env("USER") || Quickshell.env("LOGNAME")
    readonly property string lockConfig: "omarchy-lock-password"

    property bool lockRequested: false
    property bool pendingSessionLock: false
    property bool authenticatingPassword: false
    property string pendingPassword: ""
    property int failedAttempts: 0
    property string failureMessage: ""
    property string enteredPassword: ""
    property bool inputEnabled: true

    readonly property bool locked: lockRequested || sessionLock.locked || sessionLock.secure

    property var lockViews: []

    function beginLock() {
        if (lockRequested) return
        resetAuthenticationState()
        lockViews = []
        lockRequested = true
        queueSessionLock()
    }

    function resetAuthenticationState() {
        authenticatingPassword = false
        pendingPassword = ""
        failedAttempts = 0
        failureMessage = ""
        enteredPassword = ""
        inputEnabled = true
    }

    function queueSessionLock() {
        pendingSessionLock = true
        sessionLockStabilizeTimer.start()
        pendingSessionLockTimer.start()
    }

    function requestSessionLock() {
        if (!lockRequested) return
        if (sessionLock.locked || sessionLock.secure) return
        if (sessionLockStabilizeTimer.running) return
        if (!hasRealScreen()) return

        sessionLock.locked = true
        pendingSessionLock = false
    }

    function activateLockViews() {
        for (var i = 0; i < lockViews.length; i++) {
            lockViews[i].startAnimation()
        }
    }

    function hasRealScreen() {
        var screens = Quickshell.screens || []
        for (var i = 0; i < screens.length; i++) {
            var s = screens[i]
            if (s && s.name && s.width > 0 && s.height > 0) return true
        }
        return false
    }

    function getPrimaryScreen() {
        var screens = Quickshell.screens || []
        for (var i = 0; i < screens.length; i++) {
            if (screens[i].name === "HDMI-A-1") return screens[i]
        }
        if (screens.length === 1) return screens[0]
        var best = screens[0]
        for (var j = 1; j < screens.length; j++) {
            if (screens[j].width > best.width) best = screens[j]
        }
        return best
    }

    function submitPassword(password) {
        if (authenticatingPassword || !lockRequested) return
        if (password.length === 0) return

        authenticatingPassword = true
        pendingPassword = password
        failureMessage = ""
        inputEnabled = false
        passwordPam.start()
    }

    function respondToPasswordPrompt() {
        if (passwordPam.responseRequired) {
            passwordPam.respond(pendingPassword)
        }
    }

    function handlePasswordFailure() {
        authenticatingPassword = false
        failedAttempts++
        failureMessage = "Authentication failed (" + failedAttempts + ")"
        pendingPassword = ""
        inputEnabled = true
    }

    function finishUnlock() {
        lockRequested = false
        authenticatingPassword = false
        pendingPassword = ""
        failedAttempts = 0
        failureMessage = ""
        enteredPassword = ""
        for (var i = 0; i < lockViews.length; i++) {
            lockViews[i].resetState()
        }
        lockViews = []
        sessionLock.locked = false
    }

    Timer {
        id: sessionLockStabilizeTimer
        interval: 500
        repeat: false
        onTriggered: root.requestSessionLock()
    }

    Timer {
        id: pendingSessionLockTimer
        interval: 100
        repeat: true
        running: pendingSessionLock
        onTriggered: root.requestSessionLock()
    }

    PamContext {
        id: passwordPam
        config: root.lockConfig
        user: root.userName

        onResponseRequiredChanged: root.respondToPasswordPrompt()
        onPamMessage: root.respondToPasswordPrompt()

        onCompleted: function(result) {
            root.authenticatingPassword = false
            root.pendingPassword = ""
            if (!root.lockRequested) return
            if (result === PamResult.Success) {
                root.finishUnlock()
            } else {
                root.handlePasswordFailure()
            }
        }

        onError: function(error) {
            root.handlePasswordFailure()
        }
    }

    WlSessionLock {
        id: sessionLock

        onSecureStateChanged: {
            if (sessionLock.secure) {
                root.activateLockViews()
            }
        }

        onLockStateChanged: {
            if (!sessionLock.locked && lockRequested) {
                root.resetAuthenticationState()
            }
        }

        WlSessionLockSurface {
            id: lockSurface
            color: Color.background

            MatrixLockView {
                id: lockView
                anchors.fill: parent

                isPrimaryScreen: true
                screenName: lockSurface.output ? lockSurface.output.name : "unknown"
                authenticating: root.authenticatingPassword
                failureMessage: root.failureMessage
                inputEnabled: root.inputEnabled

                onSubmitPassword: function(password) {
                    root.submitPassword(password)
                }
                onPasswordTextEdited: function(password) {
                    root.enteredPassword = password
                }
                onClearFailureRequested: {
                    root.failureMessage = ""
                }
                onEmergencyUnlock: {
                    root.finishUnlock()
                }

                Component.onCompleted: {
                    root.lockViews.push(lockView)
                }
            }
        }
    }

    IpcHandler {
        target: "lock"

        function lock(): string {
            root.beginLock()
            return "ok"
        }

        function isLocked(): string {
            return root.locked ? "true" : "false"
        }

        function status(): string {
            return JSON.stringify({
                locked: root.locked,
                lockRequested: root.lockRequested,
                authenticating: root.authenticatingPassword,
                failedAttempts: root.failedAttempts,
                failureMessage: root.failureMessage
            })
        }
    }

    Connections {
        target: Quickshell
        function onScreensChanged() {
            if (lockRequested && !sessionLock.secure) {
                sessionLockStabilizeTimer.restart()
            }
        }
    }
}
