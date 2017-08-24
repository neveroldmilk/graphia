import QtQuick 2.7
import QtQuick.Controls 1.5
import QtQuick.Layouts 1.3

import "../Constants.js" as Constants
import "../Utils.js" as Utils

import "../Controls"

Item
{
    id: root
    width: layout.width
    height: layout.height

    property var document

    property color enabledTextColor
    property color disabledTextColor
    property color heldColor

    enabled: document.idle

    CreateVisualisationDialog
    {
        id: createVisualisationDialog

        document: root.document
    }

    GradientList
    {
        id: _gradientList
    }

    ColumnLayout
    {
        id: layout
        spacing: 0

        RowLayout
        {
            Layout.alignment: Qt.AlignRight
            spacing: 0

            Text
            {
                id: visualisationSummaryText

                visible: panel.hidden && list.count > 0
                text:
                {
                    return Utils.pluralise(list.count,
                                           qsTr("visualisation"),
                                           qsTr("visualisations"));
                }
            }

            ButtonMenu
            {
                visible: !visualisationSummaryText.visible
                text: qsTr("Add Visualisation")

                textColor: enabled ? enabledTextColor : disabledTextColor
                hoverColor: heldColor

                onClicked: { createVisualisationDialog.show(); }
            }

            ToolButton
            {
                visible: list.count > 0
                iconName: panel.hidden ? "go-top" : "go-bottom"
                tooltip: panel.hidden ? qsTr("Show") : qsTr("Hide")

                Behavior on opacity { NumberAnimation { easing.type: Easing.InOutQuad } }
                opacity: visible ? 1.0 : 0.0

                onClicked:
                {
                    if(panel.hidden)
                        panel.show();
                    else
                        panel.hide();
                }
            }
        }

        SlidingPanel
        {
            id: panel

            Layout.alignment: Qt.AlignBottom
            alignment: Qt.AlignBottom

            item: DraggableList
            {
                id: list

                component: Component
                {
                    Visualisation
                    {
                        property var document: root.document
                        gradientList: _gradientList

                        Component.onCompleted:
                        {
                            enabledTextColor = Qt.binding(function() { return root.enabledTextColor; });
                            disabledTextColor = Qt.binding(function() { return root.disabledTextColor; });
                            hoverColor = Qt.binding(function() { return root.heldColor; });
                        }
                    }
                }

                model: document.visualisations
                heldColor: root.heldColor
                parentWhenDragging: root

                alignment: Qt.AlignRight

                onItemMoved: { document.moveVisualisation(from, to); }
            }
        }
    }
}
