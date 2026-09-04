import QtQuick

Item {
    id: root

    readonly property color matrixGreen: "#00FF41"
    readonly property int cellSize: 20

    property int gridCols: width > 0 ? Math.floor(width / cellSize) : 80
    property int gridRows: height > 0 ? Math.floor(height / cellSize) : 50
    property bool active: false
    property bool formingRabbit: false

    property var grid: []
    property var waves: []
    property var rabbitCells: []

    property var matrixChars: "2 5 9 8 Z * ) : . \" = + - ¦ | _ ｦ ｱ ｳ ｴ ｵ ｶ ｷ ｹ ｺ ｻ ｼ ｽ ｾ ｿ ﾀ ﾂ ﾃ ﾅ ﾆ ﾇ ﾈ ﾊ ﾋ ﾎ ﾏ ﾐ ﾑ ﾒ ﾓ ﾔ ﾕ ﾗ ﾘ ﾜ".split(" ").filter(function(c) { return c.length > 0 })

    function initGrid() {
        grid = []
        for (var col = 0; col < gridCols; col++) {
            var column = []
            for (var row = 0; row < gridRows; row++) {
                column.push({
                    char: randomChar(),
                    brightness: 0,
                    changeTimer: Math.floor(Math.random() * 20)
                })
            }
            grid.push(column)
        }
    }

    function initWaves() {
        waves = []
        for (var col = 0; col < gridCols; col++) {
            spawnWave(col)
        }
    }

    function spawnWave(col) {
        var headRow = -Math.floor(Math.random() * 15)
        var speed = 0.8 + Math.random() * 1.5
        var length = 10 + Math.floor(Math.random() * 20)
        waves.push({
            col: col,
            headRow: headRow,
            speed: speed,
            length: length
        })
    }

    function randomChar() {
        return matrixChars[Math.floor(Math.random() * matrixChars.length)]
    }

    function updateGrid() {
        for (var col = 0; col < gridCols; col++) {
            for (var row = 0; row < gridRows; row++) {
                var cell = grid[col][row]
                cell.brightness = 0
                cell.changeTimer--
                if (cell.changeTimer <= 0) {
                    cell.char = randomChar()
                    cell.changeTimer = 5 + Math.floor(Math.random() * 20)
                }
            }
        }

        var newWaves = []
        for (var i = 0; i < waves.length; i++) {
            var wave = waves[i]
            wave.headRow += wave.speed

            for (var j = 0; j < wave.length; j++) {
                var checkRow = Math.floor(wave.headRow) - j
                if (checkRow >= 0 && checkRow < gridRows) {
                    var brightness = 1.0 - (j / wave.length)
                    if (j === 0) brightness = 1.5
                    else if (j < 3) brightness = 1.0
                    else brightness = Math.max(0.1, 1.0 - (j / wave.length))

                    var cell = grid[wave.col][checkRow]
                    if (brightness > cell.brightness) {
                        cell.brightness = brightness
                    }
                }
            }

            if (wave.headRow - wave.length < gridRows) {
                newWaves.push(wave)
            } else {
                spawnWave(wave.col)
            }
        }
        waves = newWaves

        for (var col2 = 0; col2 < gridCols; col2++) {
            for (var row2 = 0; row2 < gridRows; row2++) {
                grid[col2][row2].brightness *= 0.93
            }
        }
    }

    Canvas {
        id: canvas
        anchors.fill: parent
        visible: true
        z: 1

        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()

        onPaint: {
            var ctx = getContext("2d")
            if (!ctx) return

            ctx.fillStyle = "#000000"
            ctx.fillRect(0, 0, width, height)

            if (root.gridCols <= 0 || root.gridRows <= 0) return
            if (!root.grid || root.grid.length === 0) return

            ctx.font = root.cellSize + "px monospace"
            ctx.textAlign = "center"
            ctx.textBaseline = "top"

            for (var col = 0; col < root.gridCols; col++) {
                if (!root.grid[col]) continue
                for (var row = 0; row < root.gridRows; row++) {
                    var cell = root.grid[col][row]
                    if (!cell || cell.brightness < 0.1) continue

                    var b = Math.min(1.0, cell.brightness)
                    var r = 0
                    var g = Math.floor(255 * b)
                    var gb = 0

                    if (cell.brightness > 1.2) {
                        r = Math.floor(200 * (cell.brightness - 1.2))
                        g = 255
                        gb = Math.floor(200 * (cell.brightness - 1.2))
                    }

                    ctx.fillStyle = "rgb(" + r + "," + g + "," + gb + ")"
                    ctx.fillText(
                        cell.char,
                        col * root.cellSize + root.cellSize / 2,
                        row * root.cellSize
                    )
                }
            }

            if (root.formingRabbit) {
                for (var k = 0; k < root.rabbitCells.length; k++) {
                    var rc = root.rabbitCells[k]
                    ctx.fillStyle = root.matrixGreen
                    ctx.fillText(
                        rc.char,
                        rc.col * root.cellSize + root.cellSize / 2,
                        rc.row * root.cellSize
                    )
                }
            }
        }
    }

    Timer {
        id: animTimer
        interval: 30
        running: root.active
        repeat: true
        onTriggered: {
            root.updateGrid()
            canvas.requestPaint()
        }
    }

    onActiveChanged: {
        if (active) {
            initGrid()
            initWaves()
            canvas.requestPaint()
        }
    }

    function startFormation() {
        formingRabbit = true
        rabbitCells = []
        var template = loadRabbitTemplate()
        var rabbitCols = template.width
        var rabbitRows = template.height
        var startX = Math.floor((gridCols - rabbitCols) / 2)
        var startY = Math.floor((gridRows - rabbitRows) / 2)

        for (var col = 0; col < rabbitCols; col++) {
            for (var row = 0; row < rabbitRows; row++) {
                if (template.grid[row][col]) {
                    rabbitCells.push({
                        col: startX + col,
                        row: startY + row,
                        char: randomChar()
                    })
                }
            }
        }
    }

    function loadRabbitTemplate() {
        var text = "                  ====                 \n                 =====      ======        \n                 ====    =========        \n                ====  =========          \n               ====+==========           \n               ================          \n            ==============                \n       ==============                     \n      ============                        \n      ============                        \n      ==============                      \n     ==================================== \n     ======================================\n     ====================================\n      ====================================\n          == =============================\n            ==============================\n            ==============================\n            ==============================="
        var lines = text.split("\n")
        var grid = []
        var maxWidth = 0
        for (var i = 0; i < lines.length; i++) {
            var line = lines[i]
            var row = []
            for (var j = 0; j < line.length; j++) {
                row.push(line[j] === "=")
            }
            if (row.length > maxWidth) maxWidth = row.length
            grid.push(row)
        }
        for (var k = 0; k < grid.length; k++) {
            while (grid[k].length < maxWidth) grid[k].push(false)
        }
        return { grid: grid, width: maxWidth, height: grid.length }
    }

    function stopRain() {
        active = false
    }

    function fadeOut() {
        active = false
        for (var col = 0; col < gridCols; col++) {
            for (var row = 0; row < gridRows; row++) {
                grid[col][row].brightness = 0
            }
        }
        canvas.requestPaint()
    }

    function resumeRain() {
        active = true
        formingRabbit = false
        rabbitCells = []
        initGrid()
        initWaves()
        canvas.requestPaint()
    }
}
