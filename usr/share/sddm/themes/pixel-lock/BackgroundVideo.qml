import QtQuick 2.12
import QtQuick.Window 2.12
import QtMultimedia 5.12

Item {
    readonly property real s: Screen.height / 768
    anchors.fill: parent

    MediaPlayer {
        id: mediaplayer
        source: "bg.mp4"
        autoPlay: true
        loops: MediaPlayer.Infinite
        }

    VideoOutput {
        id: videoOutput
        source: mediaplayer
        anchors.fill: parent
        fillMode: VideoOutput.PreserveAspectCrop
    }
}

