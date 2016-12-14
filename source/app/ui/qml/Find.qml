import QtQuick 2.0
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.1

Item
{
    id: root

    property var document

    property var selectPreviousAction: _selectPreviousAction
    property var selectNextAction: _selectNextAction

    width: row.width
    height: row.height

    Action
    {
        id: selectAllAction
        text: qsTr("Select All")
        iconName: "weather-clear"
        enabled: document.numNodesFound > 0
        onTriggered: { document.selectAllFound(); }
    }

    Action
    {
        id: _selectPreviousAction
        text: qsTr("Find Previous")
        iconName: "go-previous"
        shortcut: "Ctrl+Shift+G"
        enabled: document.numNodesFound > 0
        onTriggered: { document.selectPrevFound(); }
    }

    Action
    {
        id: _selectNextAction
        text: qsTr("Find Next")
        iconName: "go-next"
        shortcut: "Ctrl+G"
        enabled: document.numNodesFound > 0
        onTriggered: { document.selectNextFound(); }
    }

    Action
    {
        id: closeAction
        text: qsTr("Close")
        iconName: "emblem-unreadable"
        shortcut: visible ? "Esc" : ""
        onTriggered:
        {
            findField.focus = false;
            findField.text = "";
            visible = false;
        }
    }

    RowLayout
    {
        id: row

        TextField
        {
            id: findField
            width: 150

            onTextChanged: document.find(text);
            onAccepted: { selectAllAction.trigger(); }
        }

        ToolButton { action: _selectPreviousAction }
        ToolButton { action: _selectNextAction }
        ToolButton { action: selectAllAction }
        ToolButton { action: closeAction }

        Text
        {
            visible: findField.length > 0
            text:
            {
                var index = document.foundIndex + 1;

                if(index > 0)
                    return index + qsTr(" of ") + document.numNodesFound;
                else if(document.numNodesFound > 0)
                    return document.numNodesFound + qsTr(" found");
                else
                    return qsTr("Not Found");
            }
            color: document.contrastingColor
        }
    }

    function show()
    {
        root.visible = true;
        findField.forceActiveFocus();
        findField.selectAll();
    }
}
