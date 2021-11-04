/*
    SPDX-FileCopyrightText: 2018 Michail Vourlakos <mvourlakos@gmail.com>
    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.7
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.0

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.plasma.plasmoid 2.0

import org.kde.latte.components 1.0 as LatteComponents

ColumnLayout {
    id: root
    Layout.fillWidth: true

    LatteComponents.SubHeader {
        text: i18nc("indicator style","Style")
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: units.smallSpacing

        PlasmaComponents.Label {
            text: i18n("Size")
            horizontalAlignment: Text.AlignLeft
        }

        LatteComponents.Slider {
            id: sizeSlider
            Layout.fillWidth: true

            value: Math.round(indicator.configuration.size * 100)
            from: 3
            to: 25
            stepSize: 1
            wheelEnabled: false

            onPressedChanged: {
                if (!pressed) {
                    indicator.configuration.size = Number(value / 100).toFixed(2);
                }
            }
        }

        PlasmaComponents.Label {
            text: i18nc("number in percentage, e.g. 85 %","%1 %", currentValue)
            horizontalAlignment: Text.AlignRight
            Layout.minimumWidth: theme.mSize(theme.defaultFont).width * 4
            Layout.maximumWidth: theme.mSize(theme.defaultFont).width * 4

            readonly property int currentValue: sizeSlider.value
        }
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: units.smallSpacing

        PlasmaComponents.Label {
            text: i18n("Position")
            horizontalAlignment: Text.AlignLeft
        }

        LatteComponents.Slider {
            id: thickMarginSlider
            Layout.fillWidth: true

            value: Math.round(indicator.configuration.thickMargin * 100)
            from: 0
            to: 30
            stepSize: 1
            wheelEnabled: false

            onPressedChanged: {
                if (!pressed) {
                    indicator.configuration.thickMargin = value / 100;
                }
            }
        }

        PlasmaComponents.Label {
            text: i18nc("number in percentage, e.g. 85 %","%1 %", currentValue)
            horizontalAlignment: Text.AlignRight
            Layout.minimumWidth: theme.mSize(theme.defaultFont).width * 4
            Layout.maximumWidth: theme.mSize(theme.defaultFont).width * 4

            readonly property int currentValue: thickMarginSlider.value
        }
    }

    RowLayout {
        Layout.fillWidth: true
        spacing: units.smallSpacing

        PlasmaComponents.Label {
            text: i18n("Corner Margin")
            horizontalAlignment: Text.AlignLeft
        }

        LatteComponents.Slider {
            id: backgroundCornerMarginSlider
            Layout.fillWidth: true

            value: Math.round(indicator.configuration.backgroundCornerMargin * 100)
            from: 0
            to: 100
            stepSize: 1
            wheelEnabled: false

            onPressedChanged: {
                if (!pressed) {
                    indicator.configuration.backgroundCornerMargin = value / 100;
                }
            }
        }

        PlasmaComponents.Label {
            text: i18nc("number in percentage, e.g. 85 %","%1 %", currentValue)
            horizontalAlignment: Text.AlignRight
            Layout.minimumWidth: theme.mSize(theme.defaultFont).width * 4
            Layout.maximumWidth: theme.mSize(theme.defaultFont).width * 4

            readonly property int currentValue: backgroundCornerMarginSlider.value
        }
    }
}
