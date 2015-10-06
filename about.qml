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

import QtQuick 2.0
import QtQuick.Controls 1.4

import "version.js" as Version

ApplicationWindow {
    id: aboutWindow
    width: 510
    minimumWidth: 510
    height: 270
    minimumHeight: 270
    title: "About"
    visible: true

    modality: Qt.ApplicationModal
    flags: Qt.Dialog // sadly it's impossible to disable Windows help button with these flags, something's screwed up

    onClosing: {
        aboutWindow.destroy()
    }

    Rectangle {
        id: filler
        anchors.fill: parent
        color: "#EDEDED"
    }

    Text {
        id: appName

        text: Version.appName + " ver " + Version.major + "." + Version.minor
        font.pixelSize: 28
        font.bold: true

        y: 10
        width: aboutWindow.width
        horizontalAlignment: Text.Center

        anchors.left: aboutWindow.left
        anchors.right: aboutWindow.right
    }

    Text {
        id: author
        text: "\u00A9 2015 Piotr Trojanowski"
        font.pixelSize: 12

        anchors.top: appName.bottom
        anchors.topMargin: 10
        width: aboutWindow.width
        horizontalAlignment: Text.Center
    }

    Rectangle {
        anchors.fill: scroll
        color: "White"
    }

    ScrollView {
        id: scroll

        anchors.top: author.bottom
        anchors.topMargin: 10
        anchors.horizontalCenter: filler.horizontalCenter
        width: aboutWindow.width - 50;
        height: 150;

        frameVisible: true
        horizontalScrollBarPolicy: Qt.ScrollBarAsNeeded
        verticalScrollBarPolicy: Qt.ScrollBarAlwaysOn

        Text {
            id: license
            width: scroll.view
            font.pointSize: 10
            horizontalAlignment: Text.Center

            text: "This program is free software; you can redistribute it and/or modify
it under the terms of the GNU Lesser General Public License as published by
the Free Software Foundation; either version 2.1 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA"
        }
    }

    Text {
        text: "<a href='https://github.com/islander98/QtLogoPlacer'>https://github.com/islander98/QtLogoPlacer</a>"
        font.pixelSize: 12

        anchors.bottom: filler.bottom
        anchors.horizontalCenter: filler.horizontalCenter
        anchors.bottomMargin: 10

        onLinkActivated: Qt.openUrlExternally(link)

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.NoButton
            cursorShape: Qt.PointingHandCursor
        }
    }
}

