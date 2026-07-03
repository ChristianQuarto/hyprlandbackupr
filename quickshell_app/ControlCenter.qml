import Quickshell
import Quickshell.Io
import QtQuick

PanelWindow {
    id: cc
    implicitWidth: 340
    implicitHeight: ccCol.implicitHeight + 32
    exclusionMode: ExclusionMode.Normal
    color: "transparent"
    anchors { top: true; right: true }
    visible: Colors.ccOpen

    property bool wifiOn:        true
    property bool btOn:          true
    property bool dndOn:         false
    property int  volume:        50
    property int  cpuVal:        0
    property int  ramVal:        0
    property int  diskVal:       0
    property bool hasBattery:    false
    property int  battVal:       0
    property bool hasBrightness: false
    property int  brightVal:     50
    property bool micMuted:      false
    property bool nightLightOn:  false
    property bool keepAwakeOn:   false

    // Profilo utente
    property string userName:   ""
    property string hostName:   ""
    property string uptimeStr:  ""
    property string avatarPath: ""

    // Espansione menu
    property bool wifiExpanded: false
    property bool btExpanded:   false
    property bool outExpanded:  false

    property var wifiNetworks: []
    property var btDevices:    []
    property var outputSinks:  []
    property string activeSink: ""

    // Notifiche (swaync)
    property var notifications: []

    Process { command: ["bash","-c","test -d /sys/class/power_supply/BAT0 && echo yes || echo no"]; running: true; stdout: SplitParser { onRead: function(l){ cc.hasBattery=l.trim()==="yes" } } }
    Process { command: ["bash","-c","command -v brightnessctl >/dev/null && brightnessctl -m 2>/dev/null | head -1"]; running: true; stdout: SplitParser { onRead: function(l){ cc.hasBrightness=l.trim()!=="" } } }
    Process { command: ["bash","-c","pgrep -x gammastep >/dev/null && echo yes || echo no"]; running: true; stdout: SplitParser { onRead: function(l){ cc.nightLightOn=l.trim()==="yes" } } }

    // Profilo utente: nome, host, uptime, avatar (~/.face o AccountsService)
    Process {
        id: profileProc
        command: ["bash","-c","u=$(whoami); h=$(hostname); up=$(uptime -p); a=\"\"; [ -f \"$HOME/.face\" ] && a=\"$HOME/.face\"; [ -z \"$a\" ] && [ -f \"/var/lib/AccountsService/icons/$u\" ] && a=\"/var/lib/AccountsService/icons/$u\"; echo \"$u|$h|$up|$a\""]
        running: true
        stdout: SplitParser {
            onRead: function(line) {
                var p = line.split("|")
                cc.userName  = p[0] || ""
                cc.hostName  = p[1] || ""
                cc.uptimeStr = p[2] || ""
                cc.avatarPath = (p[3] && p[3] !== "") ? "file://" + p[3] : ""
            }
        }
    }
    Timer { interval: 60000; running: true; repeat: true; onTriggered: { profileProc.running=false; profileProc.running=true } }

    Timer {
        interval: 2000; running: Colors.ccOpen; repeat: true
        onTriggered: {
            statsProc.running=false;  statsProc.running=true
            volCcProc.running=false;  volCcProc.running=true
            wifiCcProc.running=false; wifiCcProc.running=true
            btCcProc.running=false;   btCcProc.running=true
            micCcProc.running=false;  micCcProc.running=true
            notifListProc.running=false; notifListProc.running=true
            if (cc.hasBattery)    { batProc.running=false;   batProc.running=true }
            if (cc.hasBrightness) { brightCcProc.running=false; brightCcProc.running=true }
            if (cc.wifiExpanded && cc.wifiOn) { wifiListProc.running=false; wifiListProc.running=true }
            if (cc.btExpanded && cc.btOn)     { btListProc.running=false;   btListProc.running=true }
            if (cc.outExpanded) { sinkListProc.running=false; sinkListProc.running=true; defaultSinkProc.running=false; defaultSinkProc.running=true }
        }
    }

    Process { id: statsProc; command: ["bash","-c","cpu=$(top -bn1 | grep 'Cpu(s)' | awk '{print int($2)}'); ram=$(free | awk '/Mem:/{printf \"%d\", $3/$2*100}'); disk=$(df / | awk 'NR==2{printf \"%d\", $3/$2*100}'); echo \"$cpu $ram $disk\""]; running: Colors.ccOpen; stdout: SplitParser { onRead: function(l){ var p=l.trim().split(" "); if(p.length>=3){cc.cpuVal=parseInt(p[0]);cc.ramVal=parseInt(p[1]);cc.diskVal=parseInt(p[2])} } } }
    Process { id: volCcProc;  command: ["bash","-c","wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{printf \"%d\", $2*100}'"]; running: Colors.ccOpen; stdout: SplitParser { onRead: function(l){ cc.volume=parseInt(l.trim()) } } }
    Process { id: wifiCcProc; command: ["bash","-c","nmcli radio wifi"]; running: Colors.ccOpen; stdout: SplitParser { onRead: function(l){ cc.wifiOn=l.trim()==="enabled" } } }
    Process { id: btCcProc;   command: ["bash","-c","bluetoothctl show | grep 'Powered:' | awk '{print $2}'"]; running: Colors.ccOpen; stdout: SplitParser { onRead: function(l){ cc.btOn=l.trim()==="yes" } } }
    Process { id: batProc;    command: ["bash","-c","cat /sys/class/power_supply/BAT0/capacity 2>/dev/null || echo 0"]; running: false; stdout: SplitParser { onRead: function(l){ cc.battVal=parseInt(l.trim()) } } }
    Process { id: brightCcProc; command: ["bash","-c","brightnessctl -m | cut -d, -f4 | tr -d '%'"]; running: false; stdout: SplitParser { onRead: function(l){ var v=parseInt(l.trim()); if(!isNaN(v)) cc.brightVal=v } } }
    Process { id: micCcProc; command: ["bash","-c","wpctl get-volume @DEFAULT_AUDIO_SOURCE@ 2>/dev/null | grep -q MUTED && echo yes || echo no"]; running: false; stdout: SplitParser { onRead: function(l){ cc.micMuted = l.trim()==="yes" } } }

    // ── Liste Wi-Fi / Bluetooth / Output (solo quando espanse) ──
    Process {
        id: wifiListProc
        command: ["bash","-c","nmcli -t -f SSID,SECURITY,SIGNAL,ACTIVE dev wifi list | awk -F: '!seen[$1]++' | sort -t: -k3 -rn"]
        running: false
        stdout: SplitParser {
            onRead: function(line) {
                var p = line.split(":")
                if (p.length < 4 || p[0] === "") return
                var arr = cc.wifiNetworks.slice()
                arr.push({ ssid: p[0], secured: (p[1] !== "" && p[1] !== "--"), signal: parseInt(p[2]) || 0, active: p[3] === "yes" })
                cc.wifiNetworks = arr
            }
        }
    }
    Process {
        id: btListProc
        command: ["bash","-c","for d in $(bluetoothctl devices Paired | awk '{print $2}'); do n=$(bluetoothctl info \"$d\" | grep 'Name:' | cut -d' ' -f2-); c=$(bluetoothctl info \"$d\" | grep 'Connected:' | awk '{print $2}'); echo \"$d|$n|$c\"; done"]
        running: false
        stdout: SplitParser {
            onRead: function(line) {
                var p = line.split("|")
                if (p.length < 3 || p[0] === "") return
                var arr = cc.btDevices.slice()
                arr.push({ mac: p[0], name: p[1] || p[0], connected: p[2] === "yes" })
                cc.btDevices = arr
            }
        }
    }
    Process {
        id: sinkListProc
        command: ["bash","-c","pactl list sinks | awk -F': ' '/^\\tName: /{name=$2} /^\\tDescription: /{print name\"|\"$2}'"]
        running: false
        stdout: SplitParser {
            onRead: function(line) {
                var p = line.split("|")
                if (p.length < 2 || p[0] === "") return
                var arr = cc.outputSinks.slice()
                arr.push({ name: p[0], desc: p[1] })
                cc.outputSinks = arr
            }
        }
    }
    Process { id: defaultSinkProc; command: ["bash","-c","pactl get-default-sink"]; running:false; stdout: SplitParser { onRead: function(l){ cc.activeSink = l.trim() } } }

    // ── Notifiche (swaync) ──
    // Verifica i flag con `swaync-client --help`: qui uso -l (lista json), -cn (chiudi id), -C (chiudi tutte)
    Process {
        id: notifListProc
        command: ["bash","-c","swaync-client -l 2>/dev/null"]
        running: false
        stdout: SplitParser {
            onRead: function(line) {
                try {
                    var parsed = JSON.parse(line)
                    var arr = []
                    for (var k in parsed) {
                        var n = parsed[k]
                        arr.push({
                            id: (n.id !== undefined) ? n.id : k,
                            app: n.appName || n["app-name"] || n.app_name || "Notifica",
                            summary: n.summary || n.title || "",
                            body: n.body || ""
                        })
                    }
                    cc.notifications = arr
                } catch(e) { /* formato non riconosciuto: controlla `swaync-client -l` manualmente */ }
            }
        }
    }
    Process { id: notifActionProc; running: false }

    // ── Toggle/azioni ──
    Process { id: wifiToggleProc; running: false }
    Process { id: btToggleProc;   running: false }
    Process { id: dndToggleProc;  running: false }
    Process { id: volSetProc;     running: false }
    Process { id: brightSetProc;  running: false }
    Process { id: micToggleProc;  command: ["bash","-c","wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"]; running: false }
    Process { id: nightToggleProc; running: false }
    Process { id: keepAwakeProc; command: ["systemd-inhibit","--what=idle:sleep","--who=Quickshell","--why=Manual keep-awake","sleep","infinity"]; running: cc.keepAwakeOn }
    Process { id: screenshotProc; command: ["bash","-c","grim -g \"$(slurp)\" - | wl-copy"]; running: false }
    Process { id: pickerProc; command: ["bash","-c","hyprpicker -a"]; running: false }
    Process { id: wifiConnectProc; running: false }
    Process { id: btConnectProc;   running: false }
    Process { id: sinkSetProc;     running: false }
    Process { id: powerProc;  running: false }

    component RingGauge: Item {
        id: ring
        width: 80; height: 88
        property int value: 0
        property string label: ""
        property string ringColor: Colors.color6
        property int strokeWidth: 6
        onValueChanged: canvas.requestPaint()
        onRingColorChanged: canvas.requestPaint()

        Canvas {
            id: canvas
            width: 80; height: 80
            anchors.top: parent.top
            onPaint: {
                var ctx = getContext("2d")
                ctx.clearRect(0, 0, width, height)
                var cx = width/2, cy = height/2
                var r = Math.min(width,height)/2 - ring.strokeWidth
                ctx.beginPath()
                ctx.arc(cx, cy, r, 0, 2*Math.PI)
                ctx.strokeStyle = Qt.rgba(1,1,1,0.08)
                ctx.lineWidth = ring.strokeWidth
                ctx.stroke()
                ctx.beginPath()
                ctx.arc(cx, cy, r, -Math.PI/2, -Math.PI/2 + (2*Math.PI*ring.value/100))
                ctx.strokeStyle = ring.ringColor
                ctx.lineWidth = ring.strokeWidth
                ctx.lineCap = "round"
                ctx.stroke()
            }
        }
        Text {
            anchors.centerIn: canvas
            text: ring.value + "%"
            color: Colors.fg
            font.pixelSize: 13; font.bold: true
            font.family: "JetBrainsMono Nerd Font"
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.bottom: parent.bottom
            text: ring.label
            color: Colors.color8
            font.pixelSize: 11
            font.family: "JetBrainsMono Nerd Font"
        }
    }

    // Riga espandibile generica: icona, titolo, stato, toggle, chevron
    component ExpandableRow: Column {
        id: expRow
        width: parent.width
        property string icon: ""
        property string label: ""
        property string statusText: ""
        property bool on: false
        property bool expanded: false
        property color accent: Colors.color6
        signal togglePower()
        signal toggleExpand()
        spacing: 0

        Rectangle {
            width: parent.width; height: 56; radius: 12
            color: expRow.on ? Colors.color1 : Qt.rgba(1,1,1,0.04)
            border.color: expRow.on ? expRow.accent : Colors.color8; border.width: 1

            Row {
                anchors.left: parent.left; anchors.leftMargin: 14
                anchors.verticalCenter: parent.verticalCenter
                spacing: 12
                Text { text: expRow.icon; color: expRow.on ? expRow.accent : Colors.color8; font.pixelSize: 18; font.family: "JetBrainsMono Nerd Font"; anchors.verticalCenter: parent.verticalCenter }
                Column {
                    anchors.verticalCenter: parent.verticalCenter; spacing: 1
                    Text { text: expRow.label; color: expRow.on ? Colors.fg : Colors.color8; font.pixelSize: 12; font.family: "JetBrainsMono Nerd Font" }
                    Text { text: expRow.statusText; color: Colors.color8; font.pixelSize: 9; font.family: "JetBrainsMono Nerd Font"; visible: text !== "" }
                }
            }
            MouseArea { anchors.left: parent.left; anchors.top: parent.top; anchors.bottom: parent.bottom; width: parent.width - 70; onClicked: expRow.togglePower() }

            Row {
                anchors.right: parent.right; anchors.rightMargin: 12
                anchors.verticalCenter: parent.verticalCenter
                spacing: 10
                Text {
                    text: expRow.expanded ? "󰅃" : "󰅀"
                    color: Colors.color8
                    font.pixelSize: 14; font.family: "JetBrainsMono Nerd Font"
                    MouseArea { anchors.margins: -8; anchors.fill: parent; onClicked: expRow.toggleExpand() }
                }
            }
        }
    }

    Rectangle {
        anchors.fill: parent
        anchors.topMargin: 8
        anchors.rightMargin: 4
        radius: 16
        color: Colors.bg
        border.color: Colors.color6
        border.width: 2

        Column {
            id: ccCol
            anchors { top: parent.top; left: parent.left; right: parent.right }
            anchors.margins: 16
            spacing: 14

            // Header
            Item {
                width: parent.width; height: 48
                Column {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 2
                    Text {
                        id: ccClock
                        text: Qt.formatDateTime(new Date(), "HH:mm")
                        color: Colors.fg
                        font.pixelSize: 28; font.bold: true
                        font.family: "JetBrainsMono Nerd Font"
                        Timer { interval: 1000; running: true; repeat: true; onTriggered: ccClock.text = Qt.formatDateTime(new Date(), "HH:mm") }
                    }
                    Text {
                        id: ccDate
                        text: Qt.formatDateTime(new Date(), "dddd, dd MMMM")
                        color: Colors.color8
                        font.pixelSize: 11
                        font.family: "JetBrainsMono Nerd Font"
                        Timer { interval: 60000; running: true; repeat: true; onTriggered: ccDate.text = Qt.formatDateTime(new Date(), "dddd, dd MMMM") }
                    }
                }
                Row {
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 8
                    Rectangle {
                        width: 32; height: 32; radius: 8
                        color: Qt.rgba(1,1,1,0.06)
                        Text { anchors.centerIn: parent; text: "󰒓"; color: Colors.color7; font.pixelSize: 16; font.family: "JetBrainsMono Nerd Font" }
                        MouseArea { anchors.fill: parent; onClicked: { var p = Qt.createQmlObject('import Quickshell.Io; Process { command: ["bash","-c","hyprctl dispatch exec [float] nm-connection-editor"]; running: true }', cc) } }
                    }
                    Rectangle {
                        width: 32; height: 32; radius: 8
                        color: Qt.rgba(1,1,1,0.06)
                        Text { anchors.centerIn: parent; text: "󰐥"; color: Colors.color3; font.pixelSize: 16; font.family: "JetBrainsMono Nerd Font" }
                        MouseArea { anchors.fill: parent; onClicked: { powerProc.command=["bash","-c","~/.config/hypr/scripts/powermenu.sh"]; powerProc.running=true; Colors.ccOpen=false } }
                    }
                }
            }

            // ── Profilo utente ──
            Rectangle {
                width: parent.width; height: 64; radius: 12
                color: Qt.rgba(1,1,1,0.04)
                Row {
                    anchors.fill: parent; anchors.margins: 10; spacing: 12
                    Rectangle {
                        width: 44; height: 44; radius: 22
                        color: Qt.rgba(1,1,1,0.08)
                        clip: true
                        anchors.verticalCenter: parent.verticalCenter
                        Image {
                            anchors.fill: parent
                            fillMode: Image.PreserveAspectCrop
                            source: cc.avatarPath
                            visible: cc.avatarPath !== ""
                            asynchronous: true
                        }
                        Text {
                            anchors.centerIn: parent
                            visible: cc.avatarPath === ""
                            text: "󰀄"
                            color: Colors.color6
                            font.pixelSize: 22
                            font.family: "JetBrainsMono Nerd Font"
                        }
                    }
                    Column {
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 2
                        Text { text: cc.userName + "@" + cc.hostName; color: Colors.fg; font.pixelSize: 13; font.bold: true; font.family: "JetBrainsMono Nerd Font" }
                        Text { text: cc.uptimeStr !== "" ? cc.uptimeStr : "..."; color: Colors.color8; font.pixelSize: 10; font.family: "JetBrainsMono Nerd Font" }
                    }
                }
            }

            // ── Quick actions ──
            Row {
                width: parent.width; spacing: 8
                Rectangle {
                    width: (parent.width-16)/3; height: 52; radius: 12
                    color: Qt.rgba(1,1,1,0.04)
                    Column {
                        anchors.centerIn: parent; spacing: 4
                        Text { text: "󰹑"; color: Colors.color2; font.pixelSize:18; font.family:"JetBrainsMono Nerd Font"; anchors.horizontalCenter:parent.horizontalCenter }
                        Text { text: "Screenshot"; color: Colors.color8; font.pixelSize:9; font.family:"JetBrainsMono Nerd Font"; anchors.horizontalCenter:parent.horizontalCenter }
                    }
                    MouseArea { anchors.fill: parent; onClicked: { screenshotProc.running=false; screenshotProc.running=true; Colors.ccOpen=false } }
                }
                Rectangle {
                    width: (parent.width-16)/3; height: 52; radius: 12
                    color: Qt.rgba(1,1,1,0.04)
                    Column {
                        anchors.centerIn: parent; spacing: 4
                        Text { text: "󰈊"; color: Colors.color5; font.pixelSize:18; font.family:"JetBrainsMono Nerd Font"; anchors.horizontalCenter:parent.horizontalCenter }
                        Text { text: "Color Picker"; color: Colors.color8; font.pixelSize:9; font.family:"JetBrainsMono Nerd Font"; anchors.horizontalCenter:parent.horizontalCenter }
                    }
                    MouseArea { anchors.fill: parent; onClicked: { pickerProc.running=false; pickerProc.running=true; Colors.ccOpen=false } }
                }
                Rectangle {
                    width: (parent.width-16)/3; height: 52; radius: 12
                    color: cc.keepAwakeOn ? Colors.color1 : Qt.rgba(1,1,1,0.04)
                    border.color: cc.keepAwakeOn ? Colors.color4 : "transparent"; border.width: 1
                    Column {
                        anchors.centerIn: parent; spacing: 4
                        Text { text: cc.keepAwakeOn ? "󰅶" : "󰤄"; color: cc.keepAwakeOn ? Colors.color4 : Colors.color8; font.pixelSize:18; font.family:"JetBrainsMono Nerd Font"; anchors.horizontalCenter:parent.horizontalCenter }
                        Text { text: "Keep awake"; color: cc.keepAwakeOn ? Colors.fg : Colors.color8; font.pixelSize:9; font.family:"JetBrainsMono Nerd Font"; anchors.horizontalCenter:parent.horizontalCenter }
                    }
                    MouseArea { anchors.fill: parent; onClicked: cc.keepAwakeOn = !cc.keepAwakeOn }
                }
            }

            // ── Wi-Fi (con lista reti) ──
            ExpandableRow {
                icon: cc.wifiOn ? "󰤨" : "󰤭"
                label: "Wi-Fi"
                statusText: cc.wifiOn ? (cc.wifiExpanded ? "Tocca una rete per connetterti" : "Attivo") : "Disattivo"
                on: cc.wifiOn
                expanded: cc.wifiExpanded
                accent: Colors.color6
                onTogglePower: { wifiToggleProc.command=["bash","-c", cc.wifiOn ? "nmcli radio wifi off" : "nmcli radio wifi on"]; wifiToggleProc.running=true; cc.wifiOn = !cc.wifiOn }
                onToggleExpand: { cc.wifiExpanded = !cc.wifiExpanded; if (cc.wifiExpanded) { cc.wifiNetworks = []; wifiListProc.running=false; wifiListProc.running=true } }
            }
            Column {
                width: parent.width; spacing: 4
                visible: cc.wifiExpanded && cc.wifiOn
                topPadding: -6
                Repeater {
                    model: cc.wifiNetworks
                    delegate: Rectangle {
                        required property var modelData
                        width: parent.width; height: 36; radius: 8
                        color: modelData.active ? Qt.rgba(1,1,1,0.08) : "transparent"
                        Row {
                            anchors.left: parent.left; anchors.leftMargin: 12
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 8
                            Text { text: modelData.active ? "󰤨" : (modelData.secured ? "󰤪" : "󰤨"); color: modelData.active ? Colors.color6 : Colors.color8; font.pixelSize: 12; font.family: "JetBrainsMono Nerd Font" }
                            Text { text: modelData.ssid; color: Colors.fg; font.pixelSize: 11; font.family: "JetBrainsMono Nerd Font" }
                            Text { text: modelData.secured ? "󰌾" : ""; color: Colors.color8; font.pixelSize: 10; font.family: "JetBrainsMono Nerd Font" }
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: { wifiConnectProc.command=["bash","-c","nmcli dev wifi connect \"" + modelData.ssid + "\""]; wifiConnectProc.running=false; wifiConnectProc.running=true }
                        }
                    }
                }
                Text {
                    visible: cc.wifiNetworks.length === 0
                    text: "Ricerca reti..."
                    color: Colors.color8; font.pixelSize: 10; font.family: "JetBrainsMono Nerd Font"
                    leftPadding: 12
                }
                Text {
                    visible: cc.wifiNetworks.length > 0
                    text: "Le reti protette sconosciute vanno configurate da 󰒓 in alto"
                    color: Colors.color8; font.pixelSize: 9; font.family: "JetBrainsMono Nerd Font"
                    leftPadding: 12; topPadding: 2
                }
            }

            // ── Bluetooth (con lista dispositivi accoppiati) ──
            ExpandableRow {
                icon: cc.btOn ? "󰂯" : "󰂲"
                label: "Bluetooth"
                statusText: cc.btOn ? "Attivo" : "Disattivo"
                on: cc.btOn
                expanded: cc.btExpanded
                accent: Colors.color6
                onTogglePower: { btToggleProc.command=["bash","-c", cc.btOn ? "bluetoothctl power off" : "bluetoothctl power on"]; btToggleProc.running=true; cc.btOn = !cc.btOn }
                onToggleExpand: { cc.btExpanded = !cc.btExpanded; if (cc.btExpanded) { cc.btDevices = []; btListProc.running=false; btListProc.running=true } }
            }
            Column {
                width: parent.width; spacing: 4
                visible: cc.btExpanded && cc.btOn
                topPadding: -6
                Repeater {
                    model: cc.btDevices
                    delegate: Rectangle {
                        required property var modelData
                        width: parent.width; height: 36; radius: 8
                        color: modelData.connected ? Qt.rgba(1,1,1,0.08) : "transparent"
                        Row {
                            anchors.left: parent.left; anchors.leftMargin: 12
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 8
                            Text { text: modelData.connected ? "󰂱" : "󰂯"; color: modelData.connected ? Colors.color6 : Colors.color8; font.pixelSize: 12; font.family: "JetBrainsMono Nerd Font" }
                            Text { text: modelData.name; color: Colors.fg; font.pixelSize: 11; font.family: "JetBrainsMono Nerd Font" }
                        }
                        Text {
                            anchors.right: parent.right; anchors.rightMargin: 12
                            anchors.verticalCenter: parent.verticalCenter
                            text: modelData.connected ? "Disconnetti" : "Connetti"
                            color: Colors.color8; font.pixelSize: 9; font.family: "JetBrainsMono Nerd Font"
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: { btConnectProc.command=["bash","-c","bluetoothctl " + (modelData.connected ? "disconnect " : "connect ") + modelData.mac]; btConnectProc.running=false; btConnectProc.running=true }
                        }
                    }
                }
                Text {
                    visible: cc.btDevices.length === 0
                    text: "Nessun dispositivo accoppiato"
                    color: Colors.color8; font.pixelSize: 10; font.family: "JetBrainsMono Nerd Font"
                    leftPadding: 12
                }
            }

            // ── Uscita audio (con lista dispositivi) ──
            ExpandableRow {
                icon: "󰓃"
                label: "Uscita audio"
                statusText: cc.activeSink !== "" ? "" : "Tocca per scegliere il dispositivo"
                on: true
                expanded: cc.outExpanded
                accent: Colors.color5
                onTogglePower: { cc.outExpanded = !cc.outExpanded; if (cc.outExpanded) { cc.outputSinks = []; sinkListProc.running=false; sinkListProc.running=true; defaultSinkProc.running=false; defaultSinkProc.running=true } }
                onToggleExpand: { cc.outExpanded = !cc.outExpanded; if (cc.outExpanded) { cc.outputSinks = []; sinkListProc.running=false; sinkListProc.running=true; defaultSinkProc.running=false; defaultSinkProc.running=true } }
            }
            Column {
                width: parent.width; spacing: 4
                visible: cc.outExpanded
                topPadding: -6
                Repeater {
                    model: cc.outputSinks
                    delegate: Rectangle {
                        required property var modelData
                        width: parent.width; height: 36; radius: 8
                        color: modelData.name === cc.activeSink ? Qt.rgba(1,1,1,0.08) : "transparent"
                        Row {
                            anchors.left: parent.left; anchors.leftMargin: 12
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 8
                            Text { text: modelData.name === cc.activeSink ? "󰄬" : "󰓃"; color: modelData.name === cc.activeSink ? Colors.color5 : Colors.color8; font.pixelSize: 12; font.family: "JetBrainsMono Nerd Font" }
                            Text { text: modelData.desc; color: Colors.fg; font.pixelSize: 11; font.family: "JetBrainsMono Nerd Font"; width: parent.parent.width - 40; elide: Text.ElideRight }
                        }
                        MouseArea {
                            anchors.fill: parent
                            onClicked: {
                                cc.activeSink = modelData.name
                                sinkSetProc.command = ["bash","-c","pactl set-default-sink \"" + modelData.name + "\"; for i in $(pactl list short sink-inputs | cut -f1); do pactl move-sink-input \"$i\" \"" + modelData.name + "\"; done"]
                                sinkSetProc.running = false; sinkSetProc.running = true
                            }
                        }
                    }
                }
                Text {
                    visible: cc.outputSinks.length === 0
                    text: "Ricerca dispositivi..."
                    color: Colors.color8; font.pixelSize: 10; font.family: "JetBrainsMono Nerd Font"
                    leftPadding: 12
                }
            }

            // Microfono + Night Light
            Row {
                width: parent.width; spacing: 8
                Rectangle {
                    width: (parent.width-8)/2; height: 60; radius: 12
                    color: !cc.micMuted ? Colors.color1 : Qt.rgba(1,1,1,0.04)
                    border.color: !cc.micMuted ? Colors.color6 : Colors.color8; border.width: 1
                    Column {
                        anchors.centerIn: parent; spacing: 4
                        Text { text: cc.micMuted?"󰍭":"󰍬"; color: !cc.micMuted?Colors.color6:Colors.color8; font.pixelSize:20; font.family:"JetBrainsMono Nerd Font"; anchors.horizontalCenter:parent.horizontalCenter }
                        Text { text: "Microfono"; color: !cc.micMuted?Colors.fg:Colors.color8; font.pixelSize:11; font.family:"JetBrainsMono Nerd Font"; anchors.horizontalCenter:parent.horizontalCenter }
                    }
                    MouseArea { anchors.fill:parent; onClicked: { micToggleProc.running=false; micToggleProc.running=true; cc.micMuted=!cc.micMuted } }
                }
                Rectangle {
                    width: (parent.width-8)/2; height: 60; radius: 12
                    color: cc.nightLightOn ? Colors.color1 : Qt.rgba(1,1,1,0.04)
                    border.color: cc.nightLightOn ? Colors.color3 : Colors.color8; border.width: 1
                    Column {
                        anchors.centerIn: parent; spacing: 4
                        Text { text: "󰛨"; color: cc.nightLightOn?Colors.color3:Colors.color8; font.pixelSize:20; font.family:"JetBrainsMono Nerd Font"; anchors.horizontalCenter:parent.horizontalCenter }
                        Text { text: "Night Light"; color: cc.nightLightOn?Colors.fg:Colors.color8; font.pixelSize:11; font.family:"JetBrainsMono Nerd Font"; anchors.horizontalCenter:parent.horizontalCenter }
                    }
                    MouseArea {
                        anchors.fill:parent
                        onClicked: {
                            cc.nightLightOn = !cc.nightLightOn
                            nightToggleProc.command = ["bash","-c", cc.nightLightOn ? "pkill gammastep; setsid gammastep -O 4500 >/dev/null 2>&1 &" : "pkill gammastep"]
                            nightToggleProc.running = false; nightToggleProc.running = true
                        }
                    }
                }
            }

            // Do Not Disturb
            Rectangle {
                width: parent.width; height: 52; radius: 12
                color: cc.dndOn ? Colors.color1 : Qt.rgba(1,1,1,0.04)
                border.color: cc.dndOn ? Colors.color4 : Colors.color8; border.width: 1
                Row {
                    anchors.left: parent.left; anchors.leftMargin: 14
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 12
                    Text {
                        text: cc.dndOn ? "󰂛" : "󰂚"
                        color: cc.dndOn ? Colors.color4 : Colors.color8
                        font.pixelSize: 20; font.family: "JetBrainsMono Nerd Font"
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Column {
                        anchors.verticalCenter: parent.verticalCenter; spacing: 2
                        Text { text: "Do Not Disturb"; color: cc.dndOn ? Colors.fg : Colors.color8; font.pixelSize: 12; font.family: "JetBrainsMono Nerd Font" }
                        Text { text: cc.dndOn ? "On" : "Off"; color: cc.dndOn ? Colors.color4 : Colors.color8; font.pixelSize: 10; font.family: "JetBrainsMono Nerd Font" }
                    }
                }
                Rectangle {
                    anchors.right: parent.right; anchors.rightMargin: 14
                    anchors.verticalCenter: parent.verticalCenter
                    width: 40; height: 22; radius: 11
                    color: cc.dndOn ? Colors.color4 : Qt.rgba(1,1,1,0.1)
                    Behavior on color { ColorAnimation { duration: 200 } }
                    Rectangle {
                        width: 16; height: 16; radius: 8
                        anchors.verticalCenter: parent.verticalCenter
                        x: cc.dndOn ? 20 : 4
                        color: "white"
                        Behavior on x { NumberAnimation { duration: 200 } }
                    }
                }
                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        cc.dndOn = !cc.dndOn
                        dndToggleProc.command = ["bash","-c", cc.dndOn ? "swaync-client -dn" : "swaync-client -df"]
                        dndToggleProc.running = true
                    }
                }
            }

            // Volume
            Column {
                width: parent.width; spacing: 6
                Item {
                    width: parent.width; height: 16
                    Text { text: "󰕾  Volume"; color: Colors.color5; font.pixelSize:12; font.family:"JetBrainsMono Nerd Font"; anchors.left:parent.left }
                    Text { text: cc.volume+"%"; color: Colors.fg; font.pixelSize:12; font.family:"JetBrainsMono Nerd Font"; anchors.right:parent.right }
                }
                Rectangle {
                    width: parent.width; height: 8; radius: 4; color: Colors.color1
                    Rectangle { width: parent.width*cc.volume/100; height:8; radius:4; color:Colors.color5; Behavior on width{NumberAnimation{duration:150}} }
                    MouseArea {
                        anchors.fill: parent
                        onClicked:         function(m){ var p=Math.round(m.x/width*100); cc.volume=p; volSetProc.command=["bash","-c","wpctl set-volume @DEFAULT_AUDIO_SINK@ "+(p/100).toFixed(2)]; volSetProc.running=true }
                        onPositionChanged: function(m){ if(pressed){ var p=Math.max(0,Math.min(100,Math.round(m.x/width*100))); cc.volume=p; volSetProc.command=["bash","-c","wpctl set-volume @DEFAULT_AUDIO_SINK@ "+(p/100).toFixed(2)]; volSetProc.running=true } }
                    }
                }
            }

            // Brightness
            Column {
                width: parent.width; spacing: 6; visible: cc.hasBrightness
                Item {
                    width: parent.width; height: 16
                    Text { text: "󰃟  Brightness"; color: Colors.color7; font.pixelSize:12; font.family:"JetBrainsMono Nerd Font"; anchors.left:parent.left }
                    Text { text: cc.brightVal+"%"; color: Colors.fg; font.pixelSize:12; font.family:"JetBrainsMono Nerd Font"; anchors.right:parent.right }
                }
                Rectangle {
                    width: parent.width; height: 8; radius: 4; color: Colors.color1
                    Rectangle { width: parent.width*cc.brightVal/100; height:8; radius:4; color:Colors.color7; Behavior on width{NumberAnimation{duration:150}} }
                    MouseArea {
                        anchors.fill: parent
                        onClicked:         function(m){ var p=Math.max(1,Math.round(m.x/width*100)); cc.brightVal=p; brightSetProc.command=["bash","-c","brightnessctl set "+p+"%"]; brightSetProc.running=true }
                        onPositionChanged: function(m){ if(pressed){ var p=Math.max(1,Math.min(100,Math.round(m.x/width*100))); cc.brightVal=p; brightSetProc.command=["bash","-c","brightnessctl set "+p+"%"]; brightSetProc.running=true } }
                    }
                }
            }

            // Battery
            Column {
                width: parent.width; spacing: 6; visible: cc.hasBattery
                Item {
                    width: parent.width; height: 16
                    Text { text: "󰁹  Battery"; color: Colors.color3; font.pixelSize:12; font.family:"JetBrainsMono Nerd Font"; anchors.left:parent.left }
                    Text { text: cc.battVal+"%"; color: Colors.fg; font.pixelSize:12; font.family:"JetBrainsMono Nerd Font"; anchors.right:parent.right }
                }
                Rectangle {
                    width: parent.width; height:8; radius:4; color:Colors.color1
                    Rectangle { width:parent.width*cc.battVal/100; height:8; radius:4; color:cc.battVal<20?Colors.color3:Colors.color4; Behavior on width{NumberAnimation{duration:300}} }
                }
            }

            // CPU / RAM / Disk rings
            Row {
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: (parent.width - 240) / 2
                RingGauge { value: cc.cpuVal;  label: "CPU";  ringColor: Colors.color6 }
                RingGauge { value: cc.ramVal;  label: "RAM";  ringColor: Colors.color4 }
                RingGauge { value: cc.diskVal; label: "DISK"; ringColor: Colors.color2 }
            }

            // ── Notifiche integrate ──
            Column {
                width: parent.width; spacing: 8
                Item {
                    width: parent.width; height: 18
                    Text { text: "󰂚  Notifiche (" + cc.notifications.length + ")"; color: Colors.color6; font.pixelSize:12; font.family:"JetBrainsMono Nerd Font"; anchors.left:parent.left }
                    Text {
                        text: "Cancella tutte"
                        visible: cc.notifications.length > 0
                        color: Colors.color8; font.pixelSize:10; font.family:"JetBrainsMono Nerd Font"
                        anchors.right:parent.right
                        MouseArea { anchors.fill: parent; onClicked: { notifActionProc.command=["bash","-c","swaync-client -C"]; notifActionProc.running=false; notifActionProc.running=true; cc.notifications=[] } }
                    }
                }
                Text {
                    visible: cc.notifications.length === 0
                    text: "Nessuna notifica"
                    color: Colors.color8; font.pixelSize: 11; font.family: "JetBrainsMono Nerd Font"
                }
                Repeater {
                    model: cc.notifications
                    delegate: Rectangle {
                        required property var modelData
                        width: parent.width; height: 52; radius: 10
                        color: Colors.color1
                        Row {
                            anchors.left: parent.left; anchors.right: parent.right
                            anchors.leftMargin: 10; anchors.rightMargin: 10
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 8
                            Column {
                                width: parent.width - 26
                                spacing: 1
                                Text { text: modelData.app; color: Colors.color6; font.pixelSize: 10; font.bold: true; font.family: "JetBrainsMono Nerd Font" }
                                Text { text: modelData.summary; color: Colors.fg; font.pixelSize: 11; font.family: "JetBrainsMono Nerd Font"; elide: Text.ElideRight; width: parent.width }
                                Text { text: modelData.body; color: Colors.color8; font.pixelSize: 9; font.family: "JetBrainsMono Nerd Font"; elide: Text.ElideRight; width: parent.width; visible: text !== "" }
                            }
                            Text {
                                text: "󰅖"
                                color: Colors.color8; font.pixelSize: 12; font.family: "JetBrainsMono Nerd Font"
                                MouseArea {
                                    anchors.margins: -6; anchors.fill: parent
                                    onClicked: {
                                        notifActionProc.command = ["bash","-c","swaync-client -cn " + modelData.id]
                                        notifActionProc.running = false; notifActionProc.running = true
                                        var arr = cc.notifications.slice()
                                        arr.splice(arr.indexOf(modelData), 1)
                                        cc.notifications = arr
                                    }
                                }
                            }
                        }
                    }
                }
            }

            Item { height: 4 }
        }
    }
}

