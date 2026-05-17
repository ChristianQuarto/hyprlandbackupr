// services/SystemServices.qml
import Quickshell
import Quickshell.Io
import QtQuick

QtObject {
    // Volume
    property int volume: 0
    property bool volumeMuted: false
    
    // WiFi
    property bool wifiEnabled: false
    property string wifiSsid: ""
    
    // Bluetooth
    property bool bluetoothEnabled: false
    property string bluetoothDevice: ""
    
    // System stats
    property int cpuUsage: 0
    property int ramUsage: 0
    property int diskUsage: 0
    
    // Battery
    property bool hasBattery: false
    property int batteryPercent: 0
    
    // Brightness
    property bool hasBrightness: false
    property int brightness: 0
    
    // Time (già gestito da Qt, ma possiamo centralizzare)
    property date currentTime: new Date()
    
    // Processi per aggiornamenti
    property list<Process> _processes: [
        Process {
            id: volumeProc
            command: ["bash", "-c", "wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{printf \"%d\\n%s\", $2*100, ($3==\"[MUTED]\"?\"true\":\"false\")}'"]
            running: true
            stdout: SplitParser {
                onRead: function(line) {
                    var parts = line.trim().split('\n')
                    if (parts.length >= 2) {
                        SystemServices.volume = parseInt(parts[0]) || 0
                        SystemServices.volumeMuted = parts[1] === "true"
                    }
                }
            }
        },
        Process {
            id: wifiProc
            command: ["bash", "-c", "nmcli -t -f active,ssid dev wifi | grep '^yes' | cut -d: -f2 | head -1"]
            running: true
            stdout: SplitParser {
                onRead: function(line) {
                    SystemServices.wifiSsid = line.trim()
                    SystemServices.wifiEnabled = line.trim() !== ""
                }
            }
        }
        // Aggiungi qui gli altri Process...
    ]
    
    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: {
            // Ricarica i processi
            for (var i = 0; i < SystemServices._processes.length; i++) {
                var proc = SystemServices._processes[i]
                proc.running = false
                proc.running = true
            }
            SystemServices.currentTime = new Date()
        }
    }
    
    // Funzioni di azione
    function setVolume(value) {
        volume = Math.max(0, Math.min(100, value))
        var proc = Qt.createQmlObject(
            'import Quickshell.Io; Process { command: ["bash", "-c", "wpctl set-volume @DEFAULT_AUDIO_SINK@ ' + (value/100).toFixed(2) + '"] }',
            this
        )
        proc.running = true
    }
    
    function toggleWifi() {
        wifiEnabled = !wifiEnabled
        var proc = Qt.createQmlObject(
            'import Quickshell.Io; Process { command: ["bash", "-c", "nmcli radio wifi ' + (wifiEnabled ? 'on' : 'off') + '"] }',
            this
        )
        proc.running = true
    }
    
    function toggleBluetooth() {
        bluetoothEnabled = !bluetoothEnabled
        var proc = Qt.createQmlObject(
            'import Quickshell.Io; Process { command: ["bash", "-c", "bluetoothctl power ' + (bluetoothEnabled ? 'on' : 'off') + '"] }',
            this
        )
        proc.running = true
    }
    
    // Toggle notification center (se usi swaync)
    function toggleNotifications() {
        var proc = Qt.createQmlObject(
            'import Quickshell.Io; Process { command: ["bash", "-c", "swaync-client -t"] }',
            this
        )
        proc.running = true
    }
}
