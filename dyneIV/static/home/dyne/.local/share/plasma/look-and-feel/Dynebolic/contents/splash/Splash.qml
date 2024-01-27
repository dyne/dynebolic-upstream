    import QtQuick 2.5
    import QtQuick.Window 2.2

    Rectangle {
        id: root
        width: 1920
        height: 1200
        color: "#000000"

        AnimatedImage {
            id: dynebolicsplash
            source: "images/DynebolicSplash.gif"
            width: 512
            height: 512
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
        }

    }
