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
import QtQuick.Controls.Styles 1.4
import app.graphia 1.0

import "../../../shared/ui/qml/Constants.js" as Constants

import "Controls"

Rectangle
{
    id: root

    property bool validValues: preferences.permission !== "unresolved"

    Image
    {
        anchors.right: root.right
        anchors.top: root.top

        source: "tracking-background.png"
    }

    color: "#575757"

    Preferences
    {
        id: preferences
        section: "tracking"
        property alias emailAddress: emailField.text
        property string permission: "unresolved"
    }

    ColumnLayout
    {
        anchors.centerIn: parent
        width: 400
        spacing: Constants.spacing

        RowLayout
        {
            Layout.fillWidth: true

            TextField
            {
                Layout.fillWidth: true

                id: emailField

                placeholderText: qsTr("Email Address")
                validator: RegExpValidator
                {
                    // Check it's a valid email address
                    regExp: /\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*/
                }
            }

            Button
            {
                text: qsTr("Submit")
                enabled: emailField.acceptableInput

                onClicked:
                {
                    preferences.permission = "given";
                    trackingDataEntered();
                }
            }
        }

        Text
        {
            id: messageText

            Layout.fillWidth: true
            Layout.topMargin: 16

            text: qsTr("We want to continue improving ") + application.name +
                qsTr(", and one of the ways in which this is possible is " +
                "through demonstrating its usage to funding bodies. Leaving us " +
                "your valid institutional email address helps us do this. " +
                "You may of course also choose to <a href=\"anonymous\" " +
                "style=\"color: lightgrey; text-decoration:none\">use ") +
                application.name + qsTr(" anonymously</a>.")

            color: "white"
            textFormat: Text.RichText
            font.underline: false
            wrapMode: Text.WordWrap

            PointingCursorOnHoverLink {}

            onLinkActivated:
            {
                preferences.emailAddress = "";
                preferences.permission = "anonymous";
                trackingDataEntered();
            }
        }

        Keys.onPressed:
        {
            if(!emailField.acceptableInput)
                return;

            switch(event.key)
            {
            case Qt.Key_Enter:
            case Qt.Key_Return:
                event.accepted = true;
                preferences.permission = "given";
                trackingDataEntered();
                break;

            default:
                event.accepted = false;
            }
        }
    }

    onVisibleChanged:
    {
        if(visible)
            emailField.forceActiveFocus();
        else
        {
            // If not visible, remove focus from any text fields
            root.forceActiveFocus();
        }
    }

    signal trackingDataEntered()
}
