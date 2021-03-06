/* Copyright © 2013-2020 Graphia Technologies Ltd.
 *
 * This file is part of Graphia.
 *
 * Graphia is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * Graphia is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Graphia.  If not, see <http://www.gnu.org/licenses/>.
 */

import QtQuick 2.7
import QtQuick.Controls 1.5
import QtQuick.Layouts 1.3

import "../../../../shared/ui/qml/Constants.js" as Constants
import "../../../../shared/ui/qml/Utils.js" as Utils

import app.graphia 1.0

ColumnLayout
{
    id: root

    spacing: 10

    property var stringValues: []

    readonly property int _removeButtonSize: 24
    readonly property int _maxAutoColors: 16
    readonly property int _maxFixedColors: 16

    function setup(configuration)
    {
        var palette = JSON.parse(configuration);

        paletteAutoColorListRepeater.model = root._autoColors = [];

        if(palette.autoColors !== undefined)
        {
            var numKeys = palette.autoColors.length;

            if(root.stringValues.length > 0 && root.stringValues.length < numKeys)
                numKeys = root.stringValues.length;

            for(var key = 0; key < numKeys; key++)
                root._autoColors.push(palette.autoColors[key]);
        }

        paletteAutoColorListRepeater.model = root._autoColors;

        if(palette.defaultColor !== undefined)
        {
            defaultColorKey.color = palette.defaultColor;
            defaultColorRadioButton.checked = true;
        }
        else
        {
            defaultColorKey.color = "lightgrey";
            generateColorsRadioButton.checked = true;
        }

        paletteFixedColorListRepeater.model = root._fixedColors = [];

        if(palette.fixedColors !== undefined)
        {
            for(var stringValue in palette.fixedColors)
            {
                var o =
                {
                    "stringValue": stringValue,
                    "color": palette.fixedColors[stringValue]
                };

                root._fixedColors.push(o);
            }
        }

        paletteFixedColorListRepeater.model = root._fixedColors;
    }

    function updateRadioButtons()
    {
        if(!generateColorsRadioButton.enabled)
            defaultColorRadioButton.checked = true;
    }

    property var _autoColors: []
    property string _defaultColor: ""
    property var _fixedColors: []

    property string configuration:
    {
        var o = {};

        o.autoColors = root._autoColors;

        if(defaultColorRadioButton.checked)
            o.defaultColor = defaultColorKey.color.toString();

        if(root._fixedColors.length > 0)
        {
            var fixedColorsObject = {};

            for(var i = 0; i < root._fixedColors.length; i++)
            {
                var stringValue = root._fixedColors[i].stringValue;
                var color = root._fixedColors[i].color;

                fixedColorsObject[stringValue] = color;
            }

            o.fixedColors = fixedColorsObject;
        }

        return JSON.stringify(o);
    }

    ColumnLayout
    {
        Layout.fillWidth: true
        Layout.margins: Constants.margin

        spacing: 2

        RowLayout
        {
            Layout.fillWidth: true

            RowLayout
            {
                Layout.alignment: Qt.AlignTop

                HelpTooltip
                {
                    title: autoLabel.text

                    Text
                    {
                        text: qsTr("These are colours that are automatically assigned " +
                            "to attribute values, in whichever order is specified by the " +
                            "visualisation. Zero or more colours may be added, up to a " +
                            "maximum of ") + root._maxAutoColors + qsTr(".")
                        wrapMode: Text.WordWrap
                    }
                }

                Label
                {
                    id: autoLabel

                    font.italic: true
                    font.bold: true
                    text: qsTr("Automatic Assignments")
                }
            }

            Item { Layout.fillWidth: true }

            FloatingButton
            {
                tooltip: qsTr("Add New Colour")
                iconName: "list-add"

                enabled: root._autoColors.length < root._maxAutoColors

                onClicked:
                {
                    var colors = root._autoColors;

                    var newColor = root.stringValues.length > 0 ?
                        QmlUtils.colorForString(root.stringValues[0]) : "red";

                    if(root._autoColors.length > 0)
                    {
                        // Generate a new colour based on the last existing one
                        var lastColor = root._autoColors[root._autoColors.length - 1];
                        newColor = Utils.generateColorFrom(lastColor);
                    }

                    colors.push(newColor);

                    root._autoColors = paletteAutoColorListRepeater.model = colors;

                    root.autoColorAdded(paletteAutoColorListRepeater.itemAt(
                        paletteAutoColorListRepeater.count - 1));
                }
            }
        }

        Text
        {
            visible: paletteAutoColorListRepeater.model !== undefined ?
                paletteAutoColorListRepeater.model.length === 0 : true
            text: qsTr("<i>None</i>")
        }

        Repeater
        {
            id: paletteAutoColorListRepeater

            RowLayout
            {
                width: root.width

                Text
                {
                    Layout.fillWidth: true

                    elide: Text.ElideRight
                    text: root.stringValues[index]
                }

                Text
                {
                    visible:
                    {
                        var v = root.stringValues[index];

                        for(var i = 0; i < root._fixedColors.length; i++)
                        {
                            if(root._fixedColors[i].stringValue === v)
                                return true;
                        }

                        return false;
                    }

                    text: qsTr("<i>(overriden by fixed assignment)</i>")
                }

                ColorPickButton
                {
                    color: modelData

                    onColorChanged:
                    {
                        var colors = root._autoColors;
                        colors[index] = color;
                        root._autoColors = colors;
                    }
                }

                FloatingButton
                {
                    Layout.preferredWidth: root._removeButtonSize
                    Layout.preferredHeight: root._removeButtonSize

                    tooltip: qsTr("Remove")
                    iconName: "list-remove"

                    onClicked:
                    {
                        root.autoColorWillBeRemoved(paletteAutoColorListRepeater.itemAt(index));

                        var colors = root._autoColors;
                        colors.splice(index, 1);
                        root._autoColors = colors;
                        root.updateRadioButtons();

                        paletteAutoColorListRepeater.model = colors;
                    }
                }
            }
        }
    }

    ColumnLayout
    {
        Layout.fillWidth: true
        Layout.margins: Constants.margin

        RowLayout
        {
            HelpTooltip
            {
                title: otherLabel.text

                Text
                {
                    text: qsTr("When a value does not correspond to any automatic or fixed " +
                        "assignments, it takes the colour indicated here. A fixed colour may " +
                        "be selected, or alternatively a colour may be automatically generated " +
                        "for each value, based on the automatically assigned colours " +
                        "specified above.");
                    wrapMode: Text.WordWrap
                }
            }

            Label
            {
                id: otherLabel

                font.italic: true
                font.bold: true
                text: qsTr("Other Values")
            }
        }

        ExclusiveGroup { id: defaultColorsGroup }

        RowLayout
        {
            Layout.fillWidth: true

            RadioButton
            {
                id: defaultColorRadioButton

                Layout.fillWidth: true

                text: qsTr("Fixed")
                exclusiveGroup: defaultColorsGroup
            }

            ColorPickButton
            {
                enabled: defaultColorRadioButton.checked
                id: defaultColorKey
            }

            // Padding so that all the colours are in a column
            Item
            {
                Layout.preferredWidth: root._removeButtonSize
                Layout.preferredHeight: root._removeButtonSize
            }
        }

        RadioButton
        {
            id: generateColorsRadioButton

            enabled: root._autoColors.length > 0 ||
                root._fixedColors.length > 0

            text: qsTr("Generate")
            exclusiveGroup: defaultColorsGroup
        }
    }

    ColumnLayout
    {
        Layout.fillWidth: true
        Layout.margins: Constants.margin

        spacing: 2

        RowLayout
        {
            Layout.fillWidth: true

            RowLayout
            {
                Layout.alignment: Qt.AlignTop

                HelpTooltip
                {
                    title: fixedLabel.text

                    Text
                    {
                        text: qsTr("This is a list of values that have a fixed assignment " +
                            "to a particular colour. The value may be selected from the menu, " +
                            "or manually entered. In either case, the supplied value will " +
                            "always be shown using its respective colour. Zero or more " +
                            "colours may be added, up to a maximum of ") +
                            root._maxFixedColors + qsTr(".")
                        wrapMode: Text.WordWrap
                    }
                }

                Label
                {
                    id: fixedLabel

                    font.italic: true
                    font.bold: true
                    text: qsTr("Fixed Assignments")
                }
            }

            Item { Layout.fillWidth: true }

            FloatingButton
            {
                tooltip: qsTr("Add New Colour")
                iconName: "list-add"

                enabled: root._fixedColors.length < root._maxFixedColors

                onClicked:
                {
                    // Start with the first potentially unassigned value
                    var index = Math.min(paletteAutoColorListRepeater.count, root.stringValues.length);

                    if(index >= root.stringValues.length)
                        index = 0;

                    var initialValue = "";

                    // Find values that have no existing assignments
                    while(index < root.stringValues.length)
                    {
                        var value = root.stringValues[index];
                        var stringValueAlreadyAssigned =
                        root._fixedColors.find(function(fixedColor)
                        {
                            return fixedColor.stringValue === value;
                        });

                        if(!stringValueAlreadyAssigned)
                        {
                            initialValue = value;
                            break;
                        }

                        index++;
                    }

                    if(index >= root.stringValues.length && root.stringValues.length > 0)
                    {
                        // Everything has been assigned, so just pick the first value
                        initialValue = root.stringValues[0];
                    }

                    var colors = root._fixedColors;

                    var newColor = initialValue.length > 0 ?
                        QmlUtils.colorForString(initialValue) : "red";

                    // Use either the latest fixed colour to generate a new one, or the
                    // latest auto colour if there isn't one
                    var lastColor = "";
                    if(root._fixedColors.length > 0)
                        lastColor = root._fixedColors[root._fixedColors.length - 1].color;
                    else if(root._autoColors.length > 0)
                        lastColor = root._autoColors[root._autoColors.length - 1];

                    if(lastColor.length > 0)
                        newColor = Utils.generateColorFrom(lastColor);

                    var o =
                    {
                        "stringValue": initialValue,
                        "color": newColor
                    };
                    colors.push(o);

                    root._fixedColors = paletteFixedColorListRepeater.model = colors;

                    root.fixedColorAdded(paletteFixedColorListRepeater.itemAt(
                        paletteFixedColorListRepeater.count - 1));
                }
            }
        }

        Text
        {
            visible: paletteFixedColorListRepeater.model !== undefined ?
                paletteFixedColorListRepeater.model.length === 0 : true
            text: qsTr("<i>None</i>")
        }

        Repeater
        {
            id: paletteFixedColorListRepeater

            RowLayout
            {
                width: root.width

                ComboBox
                {
                    Layout.preferredWidth: root.width * 0.5

                    editable: true

                    model: root.stringValues

                    onCurrentTextChanged:
                    {
                        var colors = root._fixedColors;
                        colors[index].stringValue = currentText;
                        root._fixedColors = colors;
                    }

                    onEditTextChanged:
                    {
                        var colors = root._fixedColors;
                        colors[index].stringValue = editText;
                        root._fixedColors = colors;
                    }

                    Component.onCompleted:
                    {
                        var stringValueIndex = root.stringValues.indexOf(modelData.stringValue);

                        if(stringValueIndex < 0)
                        {
                            currentIndex = -1;
                            editText = modelData.stringValue;
                        }
                        else
                            currentIndex = stringValueIndex;
                    }
                }

                Item { Layout.fillWidth: true }

                ColorPickButton
                {
                    color: modelData.color

                    onColorChanged:
                    {
                        var colors = root._fixedColors;
                        colors[index].color = color;
                        root._fixedColors = colors;
                    }
                }

                FloatingButton
                {
                    Layout.preferredWidth: root._removeButtonSize
                    Layout.preferredHeight: root._removeButtonSize

                    tooltip: qsTr("Remove")
                    iconName: "list-remove"

                    onClicked:
                    {
                        root.fixedColorWillBeRemoved(paletteFixedColorListRepeater.itemAt(index));

                        var colors = root._fixedColors;
                        colors.splice(index, 1);
                        root._fixedColors = colors;
                        root.updateRadioButtons();

                        paletteFixedColorListRepeater.model = colors;
                    }
                }
            }
        }
    }

    signal autoColorAdded(var item)
    signal autoColorWillBeRemoved(var item)

    signal fixedColorAdded(var item)
    signal fixedColorWillBeRemoved(var item)
}
