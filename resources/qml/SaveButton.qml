// Copyright (c) 2015 Ultimaker B.V.
// Cura is released under the terms of the AGPLv3 or higher.

import QtQuick 2.2
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Layouts 1.1

import UM 1.1 as UM

Rectangle {
    id: base;
    UM.I18nCatalog { id: catalog; name:"cura"}

    property real progress: UM.Backend.progress;
    property bool activity: Printer.getPlatformActivity;
    //Behavior on progress { NumberAnimation { duration: 250; } }
    property int totalHeight: childrenRect.height + UM.Theme.sizes.default_margin.height
    property string fileBaseName
    property string statusText: {
        if(progress == 0) {
            if(!activity) {
                return catalog.i18nc("@label:PrintjobStatus","Please load a 3d model");
            } else {
                return catalog.i18nc("@label:PrintjobStatus","Preparing to slice...");
            }
        } else if(base.progress < 0.99) {
            return catalog.i18nc("@label:PrintjobStatus","Slicing...");
        } else {
            return catalog.i18nc("@label:PrintjobStatus","Ready to ") + UM.OutputDeviceManager.activeDeviceShortDescription;
        }
    }

    Label {
        id: statusLabel
        width: parent.width - 2 * UM.Theme.sizes.default_margin.width
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.leftMargin: UM.Theme.sizes.default_margin.width

        color: UM.Theme.colors.text
        font: UM.Theme.fonts.large
        text: statusText;
    }

    Rectangle{
        id: progressBar
        width: parent.width - 2 * UM.Theme.sizes.default_margin.width
        height: UM.Theme.sizes.progressbar.height
        anchors.top: statusLabel.bottom
        anchors.topMargin: UM.Theme.sizes.default_margin.height/4
        anchors.left: parent.left
        anchors.leftMargin: UM.Theme.sizes.default_margin.width
        radius: UM.Theme.sizes.progressbar_radius.width
        color: UM.Theme.colors.progressbar_background

        Rectangle{
            width: Math.max(parent.width * base.progress)
            height: parent.height
            color: UM.Theme.colors.progressbar_control
            radius: UM.Theme.sizes.progressbar_radius.width
            visible: base.progress > 0.99 ? false : true
        }
    }

    Rectangle{
        id: saveRow
        width: base.width
        height: saveToButton.height
        anchors.top: progressBar.bottom
        anchors.topMargin: UM.Theme.sizes.default_margin.height
        anchors.left: parent.left

        Button {
            id: saveToButton
            property int resizedWidth
            x: base.width - saveToButton.resizedWidth - UM.Theme.sizes.default_margin.width - UM.Theme.sizes.save_button_save_to_button.height + 3
            tooltip: UM.OutputDeviceManager.activeDeviceDescription;
            enabled: base.progress > 0.99 && base.activity == true
            height: UM.Theme.sizes.save_button_save_to_button.height
            width: 150
            anchors.top:parent.top
            text: UM.OutputDeviceManager.activeDeviceShortDescription
            onClicked:
            {
                UM.OutputDeviceManager.requestWriteToDevice(UM.OutputDeviceManager.activeDevice, Printer.jobName)
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                acceptedButtons: Qt.NoButton
            }

            style: ButtonStyle {
                background: Rectangle {
                    //opacity: control.enabled ? 1.0 : 0.5
                    //Behavior on opacity { NumberAnimation { duration: 50; } }
                    border.color: !control.enabled ? UM.Theme.colors.action_button_disabled_border : 
                                      control.pressed ? UM.Theme.colors.action_button_active_border :
                                      control.hovered ? UM.Theme.colors.action_button_hovered_border : UM.Theme.colors.action_button_border
                    color: !control.enabled ? UM.Theme.colors.action_button_disabled : 
                               control.pressed ? UM.Theme.colors.action_button_active :
                               control.hovered ? UM.Theme.colors.action_button_hovered : UM.Theme.colors.action_button
                    Behavior on color { ColorAnimation { duration: 50; } }
                    width: {
                        saveToButton.resizedWidth = actualLabel.width + (UM.Theme.sizes.default_margin.width * 2)
                        return saveToButton.resizedWidth
                    }
                    Label {
                        id: actualLabel
                        //Behavior on opacity { NumberAnimation { duration: 50; } }
                        anchors.centerIn: parent
                        color: !control.enabled ? UM.Theme.colors.action_button_disabled_text : 
                                   control.pressed ? UM.Theme.colors.action_button_active_text :
                                   control.hovered ? UM.Theme.colors.action_button_hovered_text : UM.Theme.colors.action_button_text
                        font: UM.Theme.fonts.action_button
                        text: control.text;
                    }
                }
            label: Item { }
            }
        }

        Button {
            id: deviceSelectionMenu
            tooltip: catalog.i18nc("@info:tooltip","Select the active output device");
            anchors.top:parent.top
            anchors.right: parent.right
            anchors.rightMargin: UM.Theme.sizes.default_margin.width
            width: UM.Theme.sizes.save_button_save_to_button.height
            height: UM.Theme.sizes.save_button_save_to_button.height
            enabled: base.progress > 0.99 && base.activity == true
            //iconSource: UM.Theme.icons[UM.OutputDeviceManager.activeDeviceIconName];

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                acceptedButtons: Qt.NoButton
            }

            style: ButtonStyle {
                background: Rectangle {
                    id: deviceSelectionIcon
                    border.color: !control.enabled ? UM.Theme.colors.action_button_disabled_border : 
                                      control.pressed ? UM.Theme.colors.action_button_active_border :
                                      control.hovered ? UM.Theme.colors.action_button_hovered_border : UM.Theme.colors.action_button_border
                    color: !control.enabled ? UM.Theme.colors.action_button_disabled : 
                               control.pressed ? UM.Theme.colors.action_button_active :
                               control.hovered ? UM.Theme.colors.action_button_hovered : UM.Theme.colors.action_button
                    Behavior on color { ColorAnimation { duration: 50; } }
                    anchors.left: parent.left
                    anchors.leftMargin: UM.Theme.sizes.save_button_text_margin.width / 2;
                    width: parent.height
                    height: parent.height

                    UM.RecolorImage {
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.horizontalCenter: parent.horizontalCenter
                        width: UM.Theme.sizes.standard_arrow.width
                        height: UM.Theme.sizes.standard_arrow.height
                        sourceSize.width: width
                        sourceSize.height: height
                        color: !control.enabled ? UM.Theme.colors.action_button_disabled_text : 
                                   control.pressed ? UM.Theme.colors.action_button_active_text :
                                   control.hovered ? UM.Theme.colors.action_button_hovered_text : UM.Theme.colors.action_button_text;
                        source: UM.Theme.icons.arrow_bottom;
                    }
                }
                label: Label{ }
            }

            menu: Menu {
                id: devicesMenu;
                Instantiator {
                    model: devicesModel;
                    MenuItem {
                        text: model.description
                        checkable: true;
                        checked: model.id == UM.OutputDeviceManager.activeDevice;
                        exclusiveGroup: devicesMenuGroup;
                        onTriggered: {
                            UM.OutputDeviceManager.setActiveDevice(model.id);
                        }
                    }
                    onObjectAdded: devicesMenu.insertItem(index, object)
                    onObjectRemoved: devicesMenu.removeItem(object)
                }
                ExclusiveGroup { id: devicesMenuGroup; }
            }
        }
        UM.OutputDevicesModel { id: devicesModel; }
    }
}
