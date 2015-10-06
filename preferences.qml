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

ApplicationWindow {
    id: preferencesWindow
    width: 380
    minimumWidth: 380
    height: 165
    minimumHeight: 165
    title: "Preferences"
    visible: true

    modality: Qt.ApplicationModal
    flags: Qt.Dialog // sadly it's impossible to disable Windows help button with these flags, something's screwed up

    property int preferredWidth
    property int preferredHeight
    property bool preferedAspectRatio

    signal applied(int width, int height, bool aspectRatio)

    onClosing: {
        preferencesWindow.destroy()
    }

    Rectangle {
        id: filler
        anchors.fill: parent
        color: "#EDEDED"
    }

    GroupBox {
        id: imageEditorGroup
        title: "Image editor"

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 10

        Label {
            id: bgSizeLabel
            text: "Maximum background size:"
            verticalAlignment: Text.AlignVCenter

            anchors.top: parent.top
            anchors.left: parent.left
            anchors.bottom: bgSizeHeightLabel.bottom

            anchors.margins: 10
        }

        Label {
            id: bgSizeWidthLabel
            text: "Width"
            width: 25
            height: bgSizeWidth.height
            verticalAlignment: Text.AlignVCenter

            anchors.left: bgSizeLabel.right

            anchors.margins: 10
            anchors.leftMargin: 30
        }
        TextField {
            id: bgSizeWidth
            text: preferencesWindow.preferredWidth.toString()

            anchors.left: bgSizeWidthLabel.right

            anchors.margins: 10
        }

        Label {
            id: bgSizeHeightLabel
            text: "Height"
            width: bgSizeWidthLabel.width
            height: bgSizeHeight.height
            verticalAlignment: Text.AlignVCenter

            anchors.top: bgSizeWidth.bottom
            anchors.left: bgSizeLabel.right

            anchors.margins: 10
            anchors.leftMargin: 30
        }
        TextField {
            id: bgSizeHeight
            text: preferencesWindow.preferredHeight.toString()

            anchors.top: bgSizeWidth.bottom
            anchors.left: bgSizeHeightLabel.right

            anchors.margins: 10
        }

        CheckBox {
                id: aspectRatioCheckbox
                text: "Keep logo image aspect ratio"
                checked: preferencesWindow.preferedAspectRatio

                anchors.top: bgSizeLabel.bottom
                anchors.left: parent.left

                anchors.margins: 10
                anchors.topMargin: 20
            }
    }

    Button {
        id: okButton
        text: "OK"

        anchors.top: imageEditorGroup.bottom
        anchors.right: parent.right
        anchors.margins: 20

        onClicked: {
            applied(parseInt(bgSizeWidth.text), parseInt(bgSizeHeight.text), aspectRatioCheckbox.checked);
            preferencesWindow.close();
        }
    }
}

