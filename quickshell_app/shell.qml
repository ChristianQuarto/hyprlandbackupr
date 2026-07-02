import Quickshell
import Quickshell.Io
import QtQuick
ShellRoot {
    FileView {
        id: walFile
        path: "/home/chris/.cache/wal/colors.json"
        onLoadedChanged: {
            if (loaded) {
                try {
                    var d = JSON.parse(walFile.text())
                    Colors.fg     = d.special.foreground
                    Colors.bg     = d.colors.color0
                    Colors.color0 = d.colors.color0
                    Colors.color1 = d.colors.color1
                    Colors.color2 = d.colors.color2
                    Colors.color3 = d.colors.color3
                    Colors.color4 = d.colors.color4
                    Colors.color5 = d.colors.color5
                    Colors.color6 = d.colors.color6
                    Colors.color7 = d.colors.color7
                    Colors.color8 = d.colors.color8
                } catch(e) { console.log("wal parse error:", e) }
            }
        }
    }
    IpcHandler {
        target: "reload"
        function colors(): void { walFile.reload() }
    }
    Variants {
        model: Quickshell.screens
        Bar { required property var modelData; screen: modelData }
    }
    Variants {
        model: Quickshell.screens
        ControlCenter { required property var modelData; screen: modelData }
    }
  Variants {
        model: Quickshell.screens
        MediaPlayer { required property var modelData; screen: modelData }
      }
      
}

