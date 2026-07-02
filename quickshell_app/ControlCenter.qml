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
