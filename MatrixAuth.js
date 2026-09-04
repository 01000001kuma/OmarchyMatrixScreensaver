.pragma Library
.import Quickshell.Services.Pam 1.0 as Pam

function createPamContext(parent, user, onResult) {
    var pam = Pam.PamContext {
        config: "omarchy-lock-password"
        user: user

        onCompleted: function(result) {
            onResult(result === Pam.PamResult.Success, false)
        }

        onError: function(error) {
            onResult(false, true)
        }
    }
    return pam
}

function startAuth(pam, password) {
    if (pam.active) return false
    pam.start()
    return true
}

function respondToPam(pam, password) {
    if (pam.responseRequired) {
        pam.respond(password)
    }
}
