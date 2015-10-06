// Copyright 2015 Piotr Trojanowski

// This program is free software; you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation; either version 2.1 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU Lesser General Public License for more details.

// You should have received a copy of the GNU Lesser General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA

import QtQuick 2.3
import QtQuick.Controls 1.2
import QtQuick.Dialogs 1.2

import "version.js" as Version

ApplicationWindow {
    id: mainWindow
    visible: true
    width: 640
    height: 480
    title: Version.appName

    minimumHeight: 480
    maximumHeight: 480
    minimumWidth: 640
    maximumWidth: 640

    // Holds the about window to avoid it being removed by garbage collector
    property var aboutWindow
    property var preferencesWindow

    property int defaultMaximumBgWidth: 1200
    property int defaultMaximumBgHeight: 900
    property bool defaultLogoAspectRatio: true

    signal exportImage(var window, url fileUrl)
    signal preferencesApplied(int width, int height, bool aspectRatio)

    menuBar: MenuBar {
        Menu {
            title: qsTr("File")
            MenuItem {
                id: exportMenuItem
                text: "Export image..."
                enabled: false

                onTriggered: fileDialog.open()
            }

            MenuItem {
                text: "Exit"
                onTriggered: Qt.quit();
            }
        }
        Menu {
            title: qsTr("Edit")
            MenuItem {
                text: "Reset logo position"
                onTriggered: logoImage.resetPosition();
            }
            MenuItem {
                text: "Reset all"
                enabled: false // drop area is buggy and doesn't accept files after logo and background are placed
                onTriggered: {
                    tipText.state = "BACKGROUND";

                    mainWindow.setInitialSize();
                }
            }
            MenuItem {
                text: "Preferences..."

                onTriggered: {
                    var component = Qt.createComponent("qrc:/preferences.qml");
                    preferencesWindow = component.createObject(mainWindow, {
                                                                   "preferredWidth": mainWindow.defaultMaximumBgWidth,
                                                                   "preferredHeight": mainWindow.defaultMaximumBgHeight,
                                                                   "preferedAspectRatio": mainWindow.defaultLogoAspectRatio
                                                               });

                    preferencesWindow.applied.connect(preferencesAppliedHandler);
                }
            }
        }

        Menu {
            title: qsTr("Help")
            MenuItem {
                text: qsTr("About...")
                onTriggered: {
                    var component = Qt.createComponent("qrc:/about.qml");
                    aboutWindow = component.createObject(mainWindow);
                }
            }
        }
    }

    FileDialog {
        id: fileDialog
        title: "Export image to file"

        modality: Qt.ApplicationModal
        selectExisting: false
        selectFolder: false
        selectMultiple: false

        nameFilters: [ "PNG files (*.png)", "JPG files (*.jpg)"]

        onAccepted: {
            exportImage(mainWindow, fileDialog.fileUrl)
        }

    }

    Rectangle {
        id: screenshotArea
        objectName: "screenshotArea"
        anchors.fill: parent
    }

    Image {
        id: backgroundImage
        objectName: "backgroundImage"
        mipmap: true

        signal sourceChanged()

        onSourceSizeChanged: {

            if (sourceSize.width == 0 || sourceSize.height == 0) {
                // invalid file was loaded by user
                console.log("Invalid file");
                mainWindow.width = 640;
                mainWindow.height = 480;
            } else {
                resizeImageWithAspectRatio(this, defaultMaximumBgWidth, defaultMaximumBgHeight);
                setWindowSizeWithOffset(width, height);
                tipText.state = "LOGO";
                sourceChanged();
            }
        }
    }

    // This somehow deactivates sometimes? Bug?
    DropArea {
        id: dropArea
        anchors.fill: screenshotArea

        onDropped: {
            console.log("On Dropped");

            if (tipText.state == "BACKGROUND")
            {
                backgroundImage.source = drop.urls[0]; // this causes the state to change
            }
            else if (tipText.state == "LOGO")
            {
                logoImage.source = drop.urls[0]; // this causes the state to change
            }
        }
    }

    Image {
        id: logoImage
        x: 10
        y: 10
        mipmap: true
        fillMode: Image.PreserveAspectFit

        Drag.active: true

        MouseArea {
            id: dragArea
            anchors.fill: parent
            drag.target: parent

            hoverEnabled: true

            onEntered: {
                logoImageCanvas.opacity = 1.0;
            }

            onExited: {
                logoImageCanvas.opacity = 0.0
            }

            cursorShape: Qt.SizeAllCursor
        }

        onSourceSizeChanged: {

            console.log("Source size changed");

            if (sourceSize.width > 0 && sourceSize.height > 0) {
                resizeLogoImage();
                tipText.state = "READY";
            }
        }

        Canvas {
            id: logoImageCanvas
            width: logoImage.width
            height: logoImage.height
            opacity: 0

            onPaint: {
                var ctx = getContext("2d")

                ctx.lineWidth = 2
                ctx.strokeStyle = "red"

                ctx.beginPath()
                ctx.moveTo(0,0)
                ctx.lineTo(width,0)
                ctx.lineTo(width,height)
                ctx.lineTo(0,height)
                ctx.closePath()

                ctx.stroke()
            }
        }

        Rectangle {
            color: "Red"

            opacity: logoImageCanvas.opacity
            width: 10
            height: 10
            anchors.right: logoImage.right
            anchors.bottom: logoImage.bottom
        }

        function resetPosition()
        {
            x = 10;
            y = 10;
            mainWindow.resizeLogoImage();
        }
    }

    // This rectangle is a transparent layer over the drawn red rectangle.
    // It takes care of the dragging events.
    // When it's dragged it is detached from the border's corner - that is
    // why it is used as an addition
    Rectangle {
        id: logoImageDragHandle

        color: "transparent"

        width: 20
        height: 20
        anchors.right: logoImage.right
        anchors.bottom: logoImage.bottom

        Drag.active: true

        MouseArea {
            drag.target: parent
            drag.threshold: 0
            drag.smoothed: false
            cursorShape: Qt.SizeFDiagCursor

            anchors.fill: parent

            onPressed: {
                parent.anchors.right = undefined
                parent.anchors.bottom = undefined
            }

            onReleased: {
                parent.anchors.right = Qt.binding(function() { return logoImage.right })
                parent.anchors.bottom = Qt.binding(function() { return logoImage.bottom })
            }

            onPositionChanged: {
                var mapped = mapToItem(screenshotArea, mouse.x, mouse.y);

                logoImage.height = mapped.y - logoImage.y; //we want bottom side of the logoImage to be in the place of mapped.y
                logoImage.width = mapped.x - logoImage.x; //we want right side of the logoImage to be in the place of mapped.x
            }
        }
    }

    Rectangle {
        id: tipTextBackground
        anchors.centerIn: tipText
        width: tipText.width + 20
        height: tipText.height + 20
        scale: tipText.scale

        color: "White"
        opacity: 0.8
    }

    Text {
        id: tipText
        anchors.centerIn: parent
        state: "BACKGROUND"

        opacity: 1.0
        font.pixelSize: 15
        font.bold: true
        scale: 1.0
        color: "Black"

        SequentialAnimation {
            id: tipTextAnimation
            loops: Animation.Infinite
            running: true

            // Stopped signal counter used to determine if it's
            // time to hide the whole tipText and tipTextBackground
            property int stoppedCount: 0

            onStopped: {
                stoppedCount++;

                if (stoppedCount == 2)
                {
                    tipText.state = "HIDDEN"
                }
            }
            // These meant to be smoothed animations but at this
            // duration value it was very CPU consuming. Especially
            // when dragging the application window around.
            NumberAnimation {
                target: tipText
                property: "scale"
                //velocity: 0.7
                from: 1.0
                to: 1.5
                duration: 750
            }
            NumberAnimation {
                target: tipText
                property: "scale"
                //velocity: 0.7
                from: 1.5
                to: 1.0
                duration: 750
            }
        }

        states: [
            State {
                name: "BACKGROUND"
                PropertyChanges {target: tipText; text: qsTr("Drag background here!")}
                PropertyChanges {target: logoImage; visible: false}
                PropertyChanges {target: backgroundImage; visible: false}
                StateChangeScript {
                    script: {
                        tipTextAnimation.loops = Animation.Infinite;
                        tipTextAnimation.start();
                        tipTextAnimation.stoppedCount = 0;
                    }
                }
            },
            State {
                name: "LOGO"
                PropertyChanges {target: tipText; text: qsTr("Now drag logo here!")}
                PropertyChanges {target: backgroundImage; visible: true}
            },
            State {
                name: "READY"
                PropertyChanges {target: tipText; text: qsTr("Image is ready to be exported!")}
                PropertyChanges {target: logoImage; visible: true}
                StateChangeScript {
                    script: {
                        tipTextAnimation.loops = 2;
                        tipTextAnimation.restart();
                    }
                }
            },
            State {
                name: "HIDDEN"
                PropertyChanges {target: tipText; text: qsTr("Image is ready to be exported!")}
                PropertyChanges {target: tipText; opacity: 0.0}
                PropertyChanges {target: tipTextBackground; opacity: 0.0}
                PropertyChanges {target: exportMenuItem; enabled: true}
            }
        ]

        transitions: [
            Transition {
                from: "READY"
                to: "HIDDEN"
                PropertyAnimation {
                    target: tipText
                    properties: "opacity"
                    duration: 500
                }
                PropertyAnimation {
                    target: tipTextBackground
                    properties: "opacity"
                    duration: 500
                }
            }

        ]
    }

    function getXWindowOffset() {
        return mainWindow.width - screenshotArea.width;
    }

    function getYWindowOffset() {
        return mainWindow.height - screenshotArea.height;
    }

    function setWindowSizeWithOffset(width, height) {
        var w = getXWindowOffset() + width;
        var h = getYWindowOffset() + height;

        mainWindow.minimumWidth = w
        mainWindow.maximumWidth = w
        mainWindow.width = w

        mainWindow.minimumHeight = h
        mainWindow.maximumHeight = h
        mainWindow.height = h
    }

    function resizeImageWithAspectRatio(image, maxWidth, maxHeight) {
        var width = image.sourceSize.width;
        var height = image.sourceSize.height;
        var ratio = width / height;

        if (width > height) {
            if (width > maxWidth) {
                image.width = maxWidth
                image.height = image.width / ratio
            }
        } else {
            if (height > maxHeight) {
                image.height = maxHeight
                image.width = ratio * image.height
            }
        }
    }

    function resizeLogoImage() {
        var bgWidth = backgroundImage.width;
        var bgHeight = backgroundImage.height;

        resizeImageWithAspectRatio(logoImage, bgWidth / 4, bgHeight / 4);
    }

    function setInitialSize() {
        var w = 640;
        var h = 480;

        mainWindow.minimumWidth = w;
        mainWindow.maximumWidth = w;
        mainWindow.minimumHeight = h;
        mainWindow.maximumHeight = h;

        //it causes errors - why?
        mainWindow.width = w;
        mainWindow.height = h;
    }

    // Reset size of the background taking into consideration maximum size values
    function resetBackgroundSize() {

        if (backgroundImage.sourceSize.width > mainWindow.defaultMaximumBgWidth ||
                backgroundImage.sourceSize.height > mainWindow.defaultMaximumBgHeight)
        {
            resizeImageWithAspectRatio(backgroundImage, mainWindow.defaultMaximumBgWidth, mainWindow.defaultMaximumBgHeight);
            setWindowSizeWithOffset(backgroundImage.width, backgroundImage.height);
            logoImage.resetPosition();
        }
    }

    //Preferences handling

    onDefaultLogoAspectRatioChanged: {
        if (defaultLogoAspectRatio) {
            logoImage.fillMode = Image.PreserveAspectFit;
        } else {
            logoImage.fillMode = Image.Stretch;
        }
    }

    function preferencesAppliedHandler(width, height, aspectRatio)
    {
        defaultMaximumBgWidth = width;
        defaultMaximumBgHeight = height;
        defaultLogoAspectRatio = aspectRatio;
        resetBackgroundSize();
        preferencesApplied(width, height, aspectRatio);
    }

}
