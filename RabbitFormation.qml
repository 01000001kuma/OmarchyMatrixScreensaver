import QtQuick

Item {
    id: root

    readonly property string templatePath: "assets/rabbit.txt"
    property var grid: []
    property int gridWidth: 0
    property int gridHeight: 0
    property bool loaded: false

    function load() {
        var xhr = new XMLHttpRequest()
        xhr.open("GET", Qt.resolvedUrl(templatePath), false)
        xhr.send()
        var lines = xhr.responseText.split("\n")
        var result = []
        var maxWidth = 0

        for (var i = 0; i < lines.length; i++) {
            var line = lines[i]
            if (line.trim().length === 0) continue
            if (line.indexOf("#") === -1) continue

            var row = []
            for (var j = 0; j < line.length; j++) {
                row.push(line[j] === "#")
            }
            if (row.length > maxWidth) maxWidth = row.length
            result.push(row)
        }

        for (var k = 0; k < result.length; k++) {
            while (result[k].length < maxWidth) {
                result[k].push(false)
            }
        }

        grid = result
        gridWidth = maxWidth
        gridHeight = result.length
        loaded = true
    }

    function getScreenPosition(col, row, screenCols, screenRows, centerX, centerY) {
        var startX = Math.floor(centerX - gridWidth / 2)
        var startY = Math.floor(centerY - gridHeight / 2)
        return {
            x: startX + col,
            y: startY + row
        }
    }

    function isRabbitCell(col, row) {
        if (row < 0 || row >= gridHeight || col < 0 || col >= gridWidth) return false
        return grid[row][col]
    }

    Component.onCompleted: load()
}
