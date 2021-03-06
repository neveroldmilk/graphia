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

Item
{
    id: root

    property var selectedValue
    property var selectedValues: []
    property var model

    onModelChanged: { selectedValue = undefined; }

    property bool allowMultipleSelection: false

    // Just some semi-sensible defaults
    width: 200
    height: 100

    TableView
    {
        id: tableView

        anchors.fill: root
        model: root.model

        TableViewColumn { role: "display" }

        // Hide the header
        headerDelegate: Item {}

        alternatingRowColors: false

        selectionMode: root.allowMultipleSelection ?
            SelectionMode.ExtendedSelection : SelectionMode.SingleSelection

        Connections
        {
            target: tableView.selection

            function onSelectionChanged()
            {
                root.selectedValues = [];

                if(target.count > 0)
                {
                    var newSelectedValues = [];
                    target.forEach(function(rowIndex)
                    {
                        var value;
                        if(typeof root.model.get === 'function')
                            value = root.model.get(rowIndex);
                        else
                            value = root.model[rowIndex];

                        root.selectedValue = value;
                        newSelectedValues.push(value);
                    });

                    root.selectedValue = newSelectedValues[newSelectedValues.length - 1];
                    root.selectedValues = newSelectedValues;
                }
                else
                {
                    root.selectedValue = undefined;
                    root.selectedValues = [];
                }
            }
        }
    }
}

