import Quickshell
import Quickshell.Io
import Quickshell.Hyprland
import Quickshell.Services.Mpris
import QtQuick

PanelWindow {
    id: bar
    implicitHeight: 38
    exclusionMode: ExclusionMode.Auto
    color: "transparent"
    anchors { top: true; left: true; right: true }

    function wsColor(idx) {
        var cols = [Colors.color6, Colors.color2, Colors.color3, Colors.color4, Colors.color5]
        return cols[idx] || Colors.color7
    }

    function batteryIcon(pct, charging) {
        if (charging) return "󰂄"
        if (pct >= 95) return "󰁹"
        if (pct >= 80) return "󰂀"
        if (pct >= 60) return "󰂁"
        if (pct >= 40) return "󰁿"
        if (pct >= 20) return "󰁻"
        return "󰁺"
    }

    property string mediaTitle:  "Nothing playing..."
    property string mediaArtist: ""
    property bool   mediaPlaying: false
    property bool   hasPlayer:   false

    // ── Battery state ──────────────────────
    property string battDev:      ""
    property bool   hasBattery:   false
    property int    battPct:      0
    property bool   battCharging: false

    Timer {
        interval: 100; running: true; repeat: true
        onTriggered: {
            bar.hasPlayer = Mpris.players.values.length > 0
            if (bar.hasPlayer) {
                var p = Mpris.players.values[0]
                bar.mediaTitle   = p.trackTitle  || "No title"
                bar.mediaArtist  = p.trackArtist || ""
                bar.mediaPlaying = p.playbackState === MprisPlaybackState.Playing
            }
        }
    }

    // Detect a battery once at startup (BAT0, BAT1, ...)
    Process {
        command: ["bash", "-c", "ls /sys/class/power_supply/ 2>/dev/null | grep -m1 '^BAT'"]
        running: true
        stdout: SplitParser {
            onRead: function(line) {
                bar.battDev = line.trim()
                bar.hasBattery = bar.battDev !== ""
            }
        }
    }

    Process {
        id: battProc
        command: ["bash", "-c", "cat /sys/class/power_supply/" + bar.battDev + "/capacity 2>/dev/null; cat /sys/class/power_supply/" + bar.battDev + "/status 2>/dev/null"]
        running: false
        stdout: SplitParser {
            onRead: function(line) {
                var t = line.trim()
                if (/^\d+$/.test(t)) bar.battPct = parseInt(t)
                else bar.battCharging = (t === "Charging")
            }
        }
    }

    Timer {
        interval: 5000
        running: bar.hasBattery
        repeat: true
        triggeredOnStart: true
        onTriggered: { battProc.running = false; battProc.running = true }
    }

    Item {
                        anchors.fill: parent
        
                        // ── LEFT: Workspaces ──────────────────
                        Row {
                            anchors.left: parent.left
                            anchors.leftMargin: 4
                            anchors.verticalCenter: parent.verticalCenter
        
                            Rectangle {
                                height: 38
                                width: wsRow.implicitWidth + 30
                                radius: 999
                                color: Colors.bg
                                border.color: Colors.color1
                                border.width: 2
        
                                Row {
                                    id: wsRow
                                    anchors.centerIn: parent
                                    spacing: 2
        
                                    Repeater {
                                        model: [
                                            { ws: 1, icon: "󰮯" },
                                            { ws: 2, icon: "󰊠" },
                                            { ws: 3, icon: "󰊠" },
                                            { ws: 4, icon: "󰊠" },
                                            { ws: 5, icon: "󰊠" }
                                        ]
                                        delegate: Rectangle {
                                            required property var modelData
                                            required property int index
                                            property bool active: Hyprland.focusedWorkspace
                                                ? Hyprland.focusedWorkspace.id === modelData.ws : false
                                            width: 33
                                            height: 30
                                            radius: 999
                                            color: active ? Colors.color1 : "transparent"
                                            Behavior on color { ColorAnimation { duration: 150 } }
        
                                            Text {
                                                anchors.centerIn: parent
                                                text: modelData.icon
                                                color: active ? bar.wsColor(index) : bar.wsColor(index)
                                                font.pixelSize: 13
                                                font.family: "JetBrainsMono Nerd Font"
                                            }
                                            MouseArea {
                                                anchors.fill: parent
                                                onClicked: Hyprland.dispatch("workspace " + modelData.ws)
                                            }
                                        }
                                    }
                                }
                            }
                        }
        
        

        // ── CENTER: Media ─────────────────────
        Row {
            anchors.centerIn: parent

            Rectangle {
                height: 38
                width:  mediaCenterRow.implicitWidth + 28
                radius: 999
                color: Colors.bg
                border.color: Colors.color1
                border.width: 2

                MouseArea {
                    // Area cliccabile di sfondo: apre il popup del player.
                    // I bottoni sotto hanno una loro MouseArea e intercettano
                    // il click prima che arrivi qui.
                    anchors.fill: parent
                    onClicked: Colors.playerOpen = !Colors.playerOpen
                }

                Row {
                    id: mediaCenterRow
                    anchors.centerIn: parent
                    spacing: 8

                    Text {
                        text: ""
                        color: Colors.color6
                        font.pixelSize: 12
                        font.family: "DepartureMono Nerd Font Mono"
                        anchors.verticalCenter: parent.verticalCenter
                        visible: bar.hasPlayer
                        MouseArea { anchors.fill: parent; onClicked: if (bar.hasPlayer) Mpris.players.values[0].previous() }
                    }
                    Text {
                        text: bar.hasPlayer ? (bar.mediaPlaying ? "" : "") : "󰝛"
                        color: bar.hasPlayer ? Colors.color6 : Colors.color6
                        font.pixelSize: 13
                        font.family: "DepartureMono Nerd Font Mono"
                        anchors.verticalCenter: parent.verticalCenter
                        MouseArea { anchors.fill: parent; onClicked: if (bar.hasPlayer) Mpris.players.values[0].playPause() }
                    }
                    Text {
                        text: bar.hasPlayer
                              ? bar.mediaTitle + (bar.mediaArtist ? "  " + bar.mediaArtist : "")
                              : "Nothing playing..."
                        color: bar.hasPlayer ? Colors.color6 : Colors.color6
                        font.pixelSize: 13
                        font.family: " DepartureMono Nerd Font Mono"
                        anchors.verticalCenter: parent.verticalCenter
                        elide: Text.ElideRight
                        maximumLineCount: 1
                        width: Math.min(implicitWidth, 340)
                    }
                    Text {
                        text: ""
                        color: Colors.color2
                        font.pixelSize: 13
                        font.family: "DepartureMono Nerd Font Mono"
                        anchors.verticalCenter: parent.verticalCenter
                        visible: bar.hasPlayer
                        MouseArea { anchors.fill: parent; onClicked: if (bar.hasPlayer) Mpris.players.values[0].next() }
                    }
                }
            }
        }

        // ── RIGHT ─────────────────────────────
        Row {
            anchors.right: parent.right
            anchors.rightMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            spacing: 4

            Rectangle {
                height: 38
                width: sysRow.implicitWidth + 28
                radius: 999
                color: Colors.bg
                border.color: Colors.color1
                border.width: 2

                Row {
                    id: sysRow
                    anchors.centerIn: parent
                    spacing: 0

                    // ── Battery ──
                    Text {
                        id: battIcon
                        text: bar.batteryIcon(bar.battPct, bar.battCharging)
                        color: (bar.battPct < 20 && !bar.battCharging) ? Colors.color3 : Colors.color4
                        font.pixelSize: 13
                        font.family: "DepartureMono Nerd Font Mono"
                        anchors.verticalCenter: parent.verticalCenter
                        leftPadding: 8; rightPadding: 2
                        visible: bar.hasBattery
                    }
                    Text {
                        id: battLabel
                        text: bar.battPct + "%"
                        color: (bar.battPct < 20 && !bar.battCharging) ? Colors.color3 : Colors.color4
                        font.pixelSize: 13
                        font.family: "DepartureMono Nerd Font Mono"
                        visible: bar.hasBattery
                        anchors.verticalCenter: parent.verticalCenter
                        rightPadding: 8
                    }

                    Text {
                        id: btIcon
                        text: "󰂱"
                        color: Colors.color4
                        font.pixelSize: 13
                        font.family: "DepartureMono Nerd Font Mono"
                        anchors.verticalCenter: parent.verticalCenter
                        leftPadding: 8; rightPadding: 2
                    }
                    Text {
                        id: btLabel
                        text: ""
                        color: Colors.color4
                        font.pixelSize: 13
                        font.family: "DepartureMono Nerd Font Mono"
                        visible: text !== ""
                        anchors.verticalCenter: parent.verticalCenter
                        rightPadding: 8
                        Process {
                            id: btProc
                            command: ["bash", "-c", "bluetoothctl info $(bluetoothctl devices Connected | head -1 | cut -d' ' -f2) 2>/dev/null | grep Alias | cut -d' ' -f2-"]
                            running: true
                            stdout: SplitParser {
                                onRead: function(line) {
                                    btLabel.text = line.trim()
                                    btIcon.text = line.trim() !== "" ? "󰂲" : ""
                                }
                            }
                        }
                        Timer { interval: 1000; running: true; repeat: true; onTriggered: { btProc.running = false; btProc.running = true } }
                    }

                    Text {
                        id: wifiIcon
                        text: "󰤭"
                        color: Colors.color6
                        font.pixelSize: 13
                        font.family: "DepartureMono Nerd Font Mono"
                        anchors.verticalCenter: parent.verticalCenter
                        leftPadding: 8; rightPadding: 2
                    }
                    Text {
                        id: wifiLabel
                        text: ""
                        color: Colors.color6
                        font.pixelSize: 13
                        font.family: "DepartureMono Nerd Font Mono"
                        visible: text !== ""
                        anchors.verticalCenter: parent.verticalCenter
                        rightPadding: 8
                        Process {
                            id: wifiProc
                            command: ["bash", "-c", "nmcli -t -f active,ssid dev wifi 2>/dev/null | grep '^yes' | cut -d: -f2 | head -1"]
                            running: true
                            stdout: SplitParser {
                                onRead: function(line) {
                                    wifiLabel.text = line.trim()
                                    wifiIcon.text = line.trim() !== "" ? "󰤨" : "󰤭"
                                }
                            }
                        }
                        Timer { interval: 1000; running: true; repeat: true; onTriggered: { wifiProc.running = false; wifiProc.running = true } }
                    }

                    Text {
                        text: "󰕾"
                        color: Colors.color5
                        font.pixelSize: 13
                        font.family: "DepartureMono Nerd Font Mono"
                        anchors.verticalCenter: parent.verticalCenter
                        leftPadding: 8; rightPadding: 2
                    }
                    Text {
                        id: volText
                        text: "--%"
                        color: Colors.color5
                        font.pixelSize: 13
                        font.family: "DepartureMono Nerd Font Mono"
                        anchors.verticalCenter: parent.verticalCenter
                        rightPadding: 4
                        Process {
                            id: volProc
                            command: ["bash", "-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{printf \"%.0f%%\", $2*100}'"]
                            running: true
                            stdout: SplitParser { onRead: function(line) { volText.text = line.trim() } }
                        }
                        Timer { interval: 250; running: true; repeat: true; onTriggered: { volProc.running = false; volProc.running = true } }
                    }
                     Text {
                                text: "󰃰"
                                color: Colors.color7
                                font.pixelSize: 13
                                font.family: "DepartureMono Nerd Font Mono"
                                anchors.verticalCenter: parent.verticalCenter
                                leftPadding: 8; rightPadding: 5
                            }
                            Text {
                                id: clockLabel
                                text: Qt.formatDateTime(new Date(), "ddd dd MMM  HH:mm")
                                color: Colors.color7
                                font.pixelSize: 13
                                font.family: "DepartureMono Nerd Font Mono"
                                anchors.verticalCenter: parent.verticalCenter
                                Timer {
                                    interval: 1000; running: true; repeat: true
                                    onTriggered: clockLabel.text = Qt.formatDateTime(new Date(), "ddd dd MMM  HH:mm")
                                }
                            }
                            Text {
                                text: ""
                                color: Colors.color7
                                font.pixelSize: 11
                                font.family: "DepartureMono Nerd Font Mono"
                                anchors.verticalCenter: parent.verticalCenter
                                leftPadding: 8; rightPadding: 5
                            }
                        // CC Toggle
                     Rectangle {
                        width: 28; height: 24; radius: 999
                        anchors.verticalCenter: parent.verticalCenter
                        color: Colors.ccOpen ? Colors.color6 : "transparent"
                        Behavior on color { ColorAnimation { duration: 150 } }
                        Text {
                            anchors.centerIn: parent
                            text: "󰹯"
                            color: Colors.ccOpen ? Colors.bg : Colors.color7
                            font.pixelSize: 14
                            font.family: "DepartureMono Nerd Font Mono"
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: Colors.ccOpen = !Colors.ccOpen
                        }
                    }
                }
            }

            
        }
    }
}

