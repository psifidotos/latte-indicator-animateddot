/*
    SPDX-FileCopyrightText: 2019 Michail Vourlakos <mvourlakos@gmail.com>
    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.7
import QtQuick.Layouts 1.1
import QtGraphicalEffects 1.0

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

import org.kde.latte.core 0.2 as LatteCore
import org.kde.latte.components 1.0 as LatteComponents

LatteComponents.IndicatorItem{
    id: root

    backgroundCornerMargin: indicator && indicator.configuration ? indicator.configuration.backgroundCornerMargin : 0.50

    providesInAttentionAnimation: true
    providesTaskLauncherAnimation: true
    providesGroupedWindowAddedAnimation: true
    providesGroupedWindowRemovedAnimation: true

    readonly property bool vertical: plasmoid.formFactor === PlasmaCore.Types.Vertical

    readonly property real factor: indicator.configuration.size
    readonly property int size: factor * indicator.currentIconSize
    readonly property int thickLocalMargin: indicator.configuration.thickMargin * indicator.currentIconSize

    readonly property int screenEdgeMargin: indicator.screenEdgeMargin

    readonly property int thicknessMargin: screenEdgeMargin + thickLocalMargin

    /*Rectangle{
        anchors.fill: parent
        border.width: 1
        border.color: "blue"
        color: "transparent"
    }*/

    Binding{
        target: level.requested
        property: "isTaskLauncherAnimationRunning" //this is needed in order to inform latte when the animation has ended
        when: level && level.requested && level.requested.hasOwnProperty("isTaskLauncherAnimationRunning")
        value: launcherAnimation.running
    }

    LatteComponents.GlowPoint{
        id: dot
        width: root.size
        height: root.size
        opacity: {
            if (indicator.isEmptySpace) {
                return 0;
            }

            if (indicator.isTask) {
                return ((indicator.isLauncher || indicator.inRemoving) ? 0 : 1)
            }

            if (indicator.isApplet) {
                return (indicator.isActive ? 1 : 0)
            }
        }

        basicColor: indicator.palette.buttonFocusColor
        contrastColor: indicator.shadowColor

        size: root.size
        glow3D: true
        animation: Math.max(1.65*3*LatteCore.Environment.longDuration,indicator.durationTime*3*LatteCore.Environment.longDuration)
        location: plasmoid.location
        attentionColor: indicator.palette.negativeTextColor
        roundCorners: true
        showAttention: indicator.inAttention
        showGlow: false
        showBorder: true
    }

    //! Animations - Connections
    Connections {
        target: level
        enabled: indicator.animationsEnabled && indicator.isLauncher && level.isBackground
        onTaskLauncherActivated: {
            if (!launcherAnimation.running) {
                launcherAnimation.loops = 1;
                launcherAnimation.start();
            }
        }
    }

    Connections {
        target: indicator
        enabled: indicator && indicator.isApplet
        onIsActiveChanged: {
            if (indicator.isApplet && !launcherAnimation.running) {
                launcherAnimation.loops = 1;
                launcherAnimation.start();
            }
        }
    }

    Connections {
        target: indicator
        enabled: indicator
        onInAttentionChanged: {
            if (indicator.inAttention) {
                launcherAnimation.loops = 20;
                launcherAnimation.start();
            } else {
                launcherAnimation.stop();
                launcherAnimation.loops = 1;
            }
        }
    }

    Connections {
        target: level
        enabled: indicator.animationsEnabled && indicator.isTask && level.isBackground
        onTaskGroupedWindowAdded: {
            if (!windowAddedAnimation.running) {
                windowAddedAnimation.start();
            }
        }

        onTaskGroupedWindowRemoved: {
            if (!windowRemovedAnimation.running) {
                windowRemovedAnimation.start();
            }
        }
    }

    //! Animations
    SequentialAnimation {
        id: launcherAnimation
        alwaysRunToEnd: true

        readonly property int animationStep: 130

        ScriptAction {
            script: {
                if (level) {
                    if (plasmoid.location === PlasmaCore.Types.TopEdge) {
                        level.requested.iconTransformOrigin = Item.Top;
                    } else if (plasmoid.location === PlasmaCore.Types.LeftEdge) {
                            level.requested.iconTransformOrigin = Item.Left;
                    } else if (plasmoid.location === PlasmaCore.Types.RightEdge) {
                            level.requested.iconTransformOrigin = Item.Right;
                    } else {
                        level.requested.iconTransformOrigin = Item.Bottom;
                    }
                }
            }
        }

        PropertyAnimation {
            target: level ? level.requested : null
            property: "iconRotation"
            to: -14
            duration: indicator.durationTime * launcherAnimation.animationStep
            easing.type: Easing.Linear
        }

        PropertyAnimation {
            target: level ? level.requested : null
            property: "iconRotation"
            to: 14
            duration:  2 * indicator.durationTime * launcherAnimation.animationStep
            easing.type: Easing.Linear
        }

        PropertyAnimation {
            target: level ? level.requested : null
            property: "iconRotation"
            to: 0
            duration:  indicator.durationTime * launcherAnimation.animationStep
            easing.type: Easing.Linear
        }

        ScriptAction {
            script: {
                if (level) {
                    level.requested.iconTransformOrigin = Item.Center;
                }
            }
        }
    }

    SequentialAnimation {
        id: windowAddedAnimation
        alwaysRunToEnd: true
        readonly property int animationStep: 160
        readonly property string toproperty: !root.vertical ? "iconOffsetY" : "iconOffsetX"

        PropertyAnimation {
            target: level ? level.requested : null
            property: windowAddedAnimation.toproperty
            to: (plasmoid.location === PlasmaCore.Types.TopEdge || plasmoid.location === PlasmaCore.Types.LeftEdge) ? Math.max(6, indicator.currentIconSize / 3) :
                                                                                                                      -Math.max(6, indicator.currentIconSize / 3)
            duration: indicator.durationTime * windowAddedAnimation.animationStep
            easing.type: Easing.Linear
        }

        PropertyAnimation {
            target: level ? level.requested : null
            property: windowAddedAnimation.toproperty
            to: 0
            duration: 2.7 * indicator.durationTime * windowAddedAnimation.animationStep
            easing.type: Easing.OutBounce
        }
    }

    SequentialAnimation {
        id: windowRemovedAnimation
        alwaysRunToEnd: true
        readonly property int animationStep: 100
        readonly property string toproperty: !root.vertical ? "iconOffsetX" : "iconOffsetY"

        PropertyAnimation {
            target: level ? level.requested : null
            property: windowRemovedAnimation.toproperty
            to: -7
            duration: indicator.durationTime * windowRemovedAnimation.animationStep
            easing.type: Easing.Linear
        }

        PropertyAnimation {
            target: level ? level.requested : null
            property: windowRemovedAnimation.toproperty
            to: 0
            duration: 9 * indicator.durationTime * windowRemovedAnimation.animationStep
            easing.type: Easing.OutInElastic
        }
    }

    //! States
    states: [
        State {
            name: "left"
            when: plasmoid.location === PlasmaCore.Types.LeftEdge

            AnchorChanges {
                target: dot
                anchors{ verticalCenter:parent.verticalCenter; horizontalCenter:undefined;
                    top:undefined; bottom:undefined; left:parent.left; right:undefined;}
            }
            PropertyChanges{
                target: dot
                anchors.leftMargin: root.thicknessMargin;    anchors.rightMargin: 0;     anchors.topMargin:0;    anchors.bottomMargin:0;
                anchors.horizontalCenterOffset: 0; anchors.verticalCenterOffset: 0;
            }
        },
        State {
            name: "bottom"
            when: (plasmoid.location === PlasmaCore.Types.Floating || plasmoid.location === PlasmaCore.Types.BottomEdge )

            AnchorChanges {
                target: dot
                anchors{ verticalCenter:undefined; horizontalCenter:parent.horizontalCenter;
                    top:undefined; bottom:parent.bottom; left:undefined; right:undefined;}
            }
            PropertyChanges{
                target: dot
                anchors.leftMargin: 0;    anchors.rightMargin: 0;     anchors.topMargin:0;    anchors.bottomMargin: root.thicknessMargin;
                anchors.horizontalCenterOffset: 0; anchors.verticalCenterOffset: 0;
            }
        },
        State {
            name: "top"
            when: plasmoid.location === PlasmaCore.Types.TopEdge

            AnchorChanges {
                target: dot
                anchors{ verticalCenter:undefined; horizontalCenter:parent.horizontalCenter;
                    top:parent.top; bottom:undefined; left:undefined; right:undefined;}
            }
            PropertyChanges{
                target: dot
                anchors.leftMargin: 0;    anchors.rightMargin: 0;     anchors.topMargin: root.thicknessMargin;    anchors.bottomMargin:0;
                anchors.horizontalCenterOffset: 0; anchors.verticalCenterOffset: 0;
            }
        },
        State {
            name: "right"
            when: plasmoid.location === PlasmaCore.Types.RightEdge

            AnchorChanges {
                target: dot
                anchors{ verticalCenter:parent.verticalCenter; horizontalCenter:undefined;
                    top:undefined; bottom:undefined; left:undefined; right:parent.right;}
            }
            PropertyChanges{
                target: dot
                anchors.leftMargin: 0;    anchors.rightMargin: root.thicknessMargin;     anchors.topMargin:0;    anchors.bottomMargin:0;
                anchors.horizontalCenterOffset: 0; anchors.verticalCenterOffset: 0;
            }
        }
    ]
}// number of windows indicator

