/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Item {
	id: root

	property alias hour: hrSpinbox.value
	property alias minute: minSpinbox.value

	property int maximumHour: 23
	property int maximumMinute: 59

	implicitWidth: hrSpinbox.width + colonLabel.width + minSpinbox.width + (2 * Theme.geometry_timeSelector_spacing)
	implicitHeight: hrSpinbox.y + hrSpinbox.height

	SpinBox {
		id: hrSpinbox
		anchors {
			right: colonLabel.left
			rightMargin: Theme.geometry_timeSelector_spacing
		}

		width: Theme.geometry_timeSelector_spinBox_width
		height: Theme.geometry_timeSelector_spinBox_height
		from: 0
		to: root.maximumHour
		label.text: Utils.pad(value, 2)
		//% "hr"
		secondaryText: qsTrId("timeselector_hr")
	}

	Label {
		id: colonLabel
		anchors {
			verticalCenter: hrSpinbox.verticalCenter
			horizontalCenter: parent.horizontalCenter
		}

		text: ":"
		color: Theme.color_font_secondary
		font.pixelSize: Theme.font_size_h3
	}

	SpinBox {
		id: minSpinbox
		anchors {
			left: colonLabel.right
			leftMargin: Theme.geometry_timeSelector_spacing
		}

		width: Theme.geometry_timeSelector_spinBox_width
		height: Theme.geometry_timeSelector_spinBox_height
		from: 0
		to: root.maximumMinute
		label.text: Utils.pad(value, 2)
		//% "min"
		secondaryText: qsTrId("timeselector_min")
	}
}
