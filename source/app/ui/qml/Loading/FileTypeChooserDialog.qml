import QtQuick 2.7
import QtQuick.Controls 1.5
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.3
import com.kajeka 1.0

import SortFilterProxyModel 0.2

import "../../../../shared/ui/qml/Constants.js" as Constants

Dialog
{
    id: fileTypeChooserDialog

    title: qsTr("File Type Ambiguous")
    width: 500

    property var application
    property var model

    property string fileUrl
    property var fileTypes: []
    property string fileType
    property bool inNewTab

    GridLayout
    {
        columns: 2

        width: parent.width
        anchors.margins: Constants.margin

        Text
        {
            text: QmlUtils.baseFileNameForUrl(fileUrl) +
                  qsTr(" may be interpreted as two or more possible formats. " +
                       "Please select how you wish to proceed below.")
            Layout.fillWidth: true
            Layout.columnSpan: 2
            wrapMode: Text.WordWrap
        }

        Text
        {
            text: qsTr("Open As:")
            Layout.alignment: Qt.AlignRight
        }

        ComboBox
        {
            id: fileTypeChoice
            Layout.alignment: Qt.AlignLeft
            implicitWidth: 200

            model: SortFilterProxyModel
            {
                id: proxyModel

                sourceModel: model
                filterRoleName: "name"
                filterPattern:
                {
                    var s = "";

                    for(var i = 0; i < fileTypeChooserDialog.fileTypes.length; i++)
                    {
                        if(i != 0) s += "|";
                        s += fileTypeChooserDialog.fileTypes[i];
                    }

                    return s;
                }

                onFilterPatternChanged:
                {
                    // Reset to first item
                    fileTypeChoice.currentIndex = -1;
                    fileTypeChoice.currentIndex = 0;
                }
            }

            property var selectedFileType:
            {
                var mappedIndex = proxyModel.mapToSource(currentIndex);
                return fileTypeChooserDialog.model.nameAtIndex(mappedIndex);
            }

            textRole: "individualDescription"
        }
    }

    standardButtons: StandardButton.Ok | StandardButton.Cancel

    onAccepted:
    {
        fileType = fileTypeChoice.selectedFileType;
    }
}
