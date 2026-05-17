import Quickshell
import Quickshell.Io
import QtQuick

PanelWindow {
    id: cc
    implicitWidth: 320
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

    Process { command: ["bash","-c","test -d /sys/class/power_supply/BAT0 && echo yes || echo no"]; running: true; stdout: SplitParser { onRead: function(l){ cc.hasBattery=l.trim()==="yes" } } }
    Process { command: ["bash","-c","ls /sys/class/backlight/ 2>/dev/null | head -1"]; running: true; stdout: SplitParser { onRead: function(l){ cc.hasBrightness=l.trim()!=="" } } }

    Timer {
        interval: 2000; running: Colors.ccOpen; repeat: true
        onTriggered: {
            statsProc.running=false;  statsProc.running=true
            volCcProc.running=false;  volCcProc.running=true
            wifiCcProc.running=false; wifiCcProc.running=true
            btCcProc.running=false;   btCcProc.running=true
            if (cc.hasBattery) { batProc.running=false; batProc.running=true }
        }
    }

    Process { id: statsProc; command: ["bash","-c","cpu=$(top -bn1 | grep 'Cpu(s)' | awk '{print int($2)}'); ram=$(free | awk '/Mem:/{printf \"%d\", $3/$2*100}'); disk=$(df / | awk 'NR==2{printf \"%d\", $3/$2*100}'); echo \"$cpu $ram $disk\""]; running: Colors.ccOpen; stdout: SplitParser { onRead: function(l){ var p=l.trim().split(" "); if(p.length>=3){cc.cpuVal=parseInt(p[0]);cc.ramVal=parseInt(p[1]);cc.diskVal=parseInt(p[2])} } } }
    Process { id: volCcProc;  command: ["bash","-c","wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{printf \"%d\", $2*100}'"]; running: Colors.ccOpen; stdout: SplitParser { onRead: function(l){ cc.volume=parseInt(l.trim()) } } }
    Process { id: wifiCcProc; command: ["bash","-c","nmcli radio wifi"]; running: Colors.ccOpen; stdout: SplitParser { onRead: function(l){ cc.wifiOn=l.trim()==="enabled" } } }
    Process { id: btCcProc;   command: ["bash","-c","bluetoothctl show | grep 'Powered:' | awk '{print $2}'"]; running: Colors.ccOpen; stdout: SplitParser { onRead: function(l){ cc.btOn=l.trim()==="yes" } } }
    Process { id: batProc;    command: ["bash","-c","cat /sys/class/power_supply/BAT0/capacity 2>/dev/null || echo 0"]; running: false; stdout: SplitParser { onRead: function(l){ cc.battVal=parseInt(l.trim()) } } }
    Process { id: wifiToggleProc; running: false }
    Process { id: btToggleProc;   running: false }
    Process { id: dndToggleProc;  running: false }
    Process { id: volSetProc;     running: false }
    Process { id: notifProc; command: ["bash","-c","swaync-client -t"]; running: false }
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

            // WiFi + Bluetooth
            Row {
                width: parent.width; spacing: 8
                Rectangle {
                    width: (parent.width-8)/2; height: 60; radius: 12
                    color: cc.wifiOn ? Colors.color1 : Qt.rgba(1,1,1,0.04)
                    border.color: cc.wifiOn ? Colors.color6 : Colors.color8; border.width: 1
                    Column {
                        anchors.centerIn: parent; spacing: 4
                        Text { text: cc.wifiOn?"󰤨":"󰤭"; color: cc.wifiOn?Colors.color6:Colors.color8; font.pixelSize:20; font.family:"JetBrainsMono Nerd Font"; anchors.horizontalCenter:parent.horizontalCenter }
                        Text { text: "Wi-Fi"; color: cc.wifiOn?Colors.fg:Colors.color8; font.pixelSize:11; font.family:"JetBrainsMono Nerd Font"; anchors.horizontalCenter:parent.horizontalCenter }
                    }
                    MouseArea { anchors.fill:parent; onClicked: { wifiToggleProc.command=["bash","-c",cc.wifiOn?"nmcli radio wifi off":"nmcli radio wifi on"]; wifiToggleProc.running=true; cc.wifiOn=!cc.wifiOn } }
                }
                Rectangle {
                    width: (parent.width-8)/2; height: 60; radius: 12
                    color: cc.btOn ? Colors.color1 : Qt.rgba(1,1,1,0.04)
                    border.color: cc.btOn ? Colors.color6 : Colors.color8; border.width: 1
                    Column {
                        anchors.centerIn: parent; spacing: 4
                        Text { text: cc.btOn?"󰂯":"󰂲"; color: cc.btOn?Colors.color6:Colors.color8; font.pixelSize:20; font.family:"JetBrainsMono Nerd Font"; anchors.horizontalCenter:parent.horizontalCenter }
                        Text { text: "Bluetooth"; color: cc.btOn?Colors.fg:Colors.color8; font.pixelSize:11; font.family:"JetBrainsMono Nerd Font"; anchors.horizontalCenter:parent.horizontalCenter }
                    }
                    MouseArea { anchors.fill:parent; onClicked: { btToggleProc.command=["bash","-c",cc.btOn?"bluetoothctl power off":"bluetoothctl power on"]; btToggleProc.running=true; cc.btOn=!cc.btOn } }
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

            // Notifications
            Rectangle {
                width: parent.width; height:40; radius:10
                color: Colors.color1
                border.color: Colors.color6; border.width:1
                Row {
                    anchors.centerIn: parent; spacing:10
                    Text { text:"󰂚"; color:Colors.color6; font.pixelSize:16; font.family:"JetBrainsMono Nerd Font"; anchors.verticalCenter:parent.verticalCenter }
                    Text { text:"Notifications"; color:Colors.fg; font.pixelSize:12; font.family:"JetBrainsMono Nerd Font"; anchors.verticalCenter:parent.verticalCenter }
                }
                MouseArea { anchors.fill:parent; onClicked:{ notifProc.running=false; notifProc.running=true } }
            }

            Item { height: 4 }
        }
    }
}
