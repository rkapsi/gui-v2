/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import QtQuick.Controls as C
import QtQuick.Controls.impl as CP
import Victron.VenusOS

Rectangle {
	id: root

	property string title

	property int leftButton: VenusOS.StatusBar_LeftButton_None
	property int rightButton: VenusOS.StatusBar_RightButton_None

	property bool animationEnabled

	signal leftButtonClicked()
	signal rightButtonClicked()

	width: parent.width
	height: Theme.geometry_statusBar_height
	opacity: 0

	SequentialAnimation {
		running: !Global.splashScreenVisible && animationEnabled

		PauseAnimation {
			duration: Theme.animation_statusBar_initialize_delayedStart_duration
		}
		OpacityAnimator {
			target: root
			from: 0.0
			to: 1.0
			duration: Theme.animation_statusBar_initialize_fade_duration
		}
	}

	Button {
		id: leftButton

		anchors {
			left: parent.left
			leftMargin: Theme.geometry_statusBar_horizontalMargin
			verticalCenter: parent.verticalCenter
		}
		width: Theme.geometry_statusBar_button_width
		height: Theme.geometry_statusBar_button_height
		icon.width: Theme.geometry_statusBar_button_icon_width
		icon.height: Theme.geometry_statusBar_button_icon_height
		display: C.AbstractButton.IconOnly
		color: Theme.color_ok
		icon.source: root.leftButton === VenusOS.StatusBar_LeftButton_ControlsInactive
					 ? "qrc:/images/icon_controls_off_32.svg"
					 : root.leftButton === VenusOS.StatusBar_LeftButton_ControlsActive
					   ? "qrc:/images/icon_controls_on_32.svg"
					   : "qrc:/images/icon_back_32.svg"

		enabled: !!Global.pageManager
				&& Global.pageManager.interactivity === VenusOS.PageManager_InteractionMode_Interactive
				&& root.leftButton != VenusOS.StatusBar_LeftButton_None
		backgroundColor: "transparent"  // don't show background when disabled
		opacity: enabled ? 1.0 : 0.0
		Behavior on opacity {
			enabled: root.animationEnabled
			OpacityAnimator { duration: Theme.animation_page_idleOpacity_duration }
		}

		onClicked: root.leftButtonClicked()
	}

	Label {
		id: clockLabel
		anchors.centerIn: parent
		font.pixelSize: 22
		text: root.title.length > 0 ? root.title : ClockTime.currentTimeText
	}

	Button {
		anchors {
			top: parent.top
			topMargin: Theme.geometry_notificationsPage_snoozeButton_topMargin
			right: parent.right
			rightMargin: Theme.geometry_notificationsPage_snoozeButton_rightMargin
		}
		enabled: !!Global.pageManager
					&& !!Global.pageManager.navBar
					&& Global.pageManager.navBar.currentUrl === "qrc:/qt/qml/Victron/VenusOS/pages/NotificationsPage.qml"
					&& Global.notifications.audibleAlarmActive
					&& !Global.notifications.snoozeAudibleAlarmActive
		opacity: enabled ? 1 : 0
		Behavior on opacity { OpacityAnimator { duration: Theme.animation_toastNotification_fade_duration} }
		border.width: Theme.geometry_button_border_width
		border.color: Theme.color_critical
		width: Theme.geometry_notificationsPage_snoozeButton_width
		height: Theme.geometry_notificationsPage_snoozeButton_height
		backgroundColor: Theme.color_darkCritical
		radius: Theme.geometry_notificationsPage_snoozeButton_radius
		contentItem: Row {
			leftPadding: Theme.geometry_notificationsPage_snoozeButton_image_leftMargin
			anchors.verticalCenter: parent.verticalCenter
			spacing: Theme.geometry_notificationsPage_snoozeButton_spacing
			CP.IconLabel {
				anchors.verticalCenter: parent.verticalCenter
				icon.source: "qrc:/images/icon_alarm_snooze_24"
			}
			Label {
				anchors.verticalCenter: parent.verticalCenter
				font.pixelSize: Theme.font_size_caption
				//% "Silence alarm"
				text: qsTrId("silence_alarm")
			}
		}
		onClicked: Global.notifications.snoozeAudibleAlarmActive = true
	}

	Button {
		id: rightButtonItem

		anchors {
			right: parent.right
			rightMargin: Theme.geometry_statusBar_horizontalMargin
			verticalCenter: parent.verticalCenter
		}

		enabled: !!Global.pageManager
				&& Global.pageManager.interactivity === VenusOS.PageManager_InteractionMode_Interactive
				&& root.rightButton != VenusOS.StatusBar_RightButton_None
		opacity: enabled ? 1.0 : 0.0
		Behavior on opacity {
			enabled: root.animationEnabled
			OpacityAnimator {
				duration: Theme.animation_page_idleOpacity_duration
			}
		}

		width: Theme.geometry_statusBar_button_width
		height: Theme.geometry_statusBar_button_height
		icon.width: Theme.geometry_statusBar_button_icon_width
		icon.height: Theme.geometry_statusBar_button_icon_height
		display: C.AbstractButton.IconOnly
		color: Theme.color_ok
		backgroundColor: "transparent"
		icon.source: root.rightButton === VenusOS.StatusBar_RightButton_SidePanelActive
				? "qrc:/images/icon_sidepanel_on_32.svg"
				: root.rightButton === VenusOS.StatusBar_RightButton_SidePanelInactive
					? "qrc:/images/icon_sidepanel_off_32.svg"
					: root.rightButton === VenusOS.StatusBar_RightButton_Add
					  ? "qrc:/images/icon_plus.svg"
					  : root.rightButton === VenusOS.StatusBar_RightButton_Refresh
						? "qrc:/images/icon_refresh_32.svg"
						: ""

		onClicked: root.rightButtonClicked()
	}
}
