/*
** Copyright (C) 2021 Victron Energy B.V.
*/

import QtQuick
import QtQuick.Window
import QtQuick.Controls.impl
import Victron.VenusOS

Item {
	id: gauges

	enum ValueType {
		RisingPercentage,
		FallingPercentage
	}

	property var model
	readonly property real step: Math.round(height * 0.18)
	readonly property real strokeWidth: Math.round(step * 0.3)

	function statusFromRisingValue(value) {
		if (value >= 85) return Theme.Critical
		if (value >= 60) return Theme.Warning
		return Theme.Ok
	}

	function statusFromFallingValue(value) {
		if (value <= 15) return Theme.Critical
		if (value <= 40) return Theme.Warning
		return Theme.Ok
	}

	function getValueStatus(value, valueType) {
		if (valueType === CircularMultiGauge.RisingPercentage) {
			return statusFromRisingValue(value)
		}
		if (valueType === CircularMultiGauge.FallingPercentage) {
			return statusFromFallingValue(value)
		}
		return Theme.Ok
	}

	Item {
		// Antialiasing
		anchors.fill: parent
		layer.enabled: true
		layer.samples: 4

		Repeater {
			model: gauges.model
			delegate: ProgressArc {
				property int status: getValueStatus(model.value, model.valueType)
				
				width: gauges.width - (strokeWidth + index*step)
				height: width
				anchors.centerIn: parent
				w: width
				value: model.value
				progressColor: Theme.statusColorValue(status)
				remainderColor: Theme.statusColorValue(status, true)
				strokeWidth: gauges.strokeWidth
			}
		}
	}

	Item {
		id: textCol

		anchors.top: parent.top
		anchors.left: parent.left
		anchors.right: parent.horizontalCenter
		anchors.rightMargin: 20

		Repeater {
			model: gauges.model
			delegate: Item {
				anchors.right: textCol.right
				anchors.left: textCol.left
				height: strokeWidth

				Label {
					anchors.top: parent.top
					anchors.topMargin: index * step/2
					anchors.right: parent.right
					anchors.rightMargin: 40
					anchors.left: parent.left
					horizontalAlignment: Text.AlignRight
					font.pixelSize: Math.ceil(strokeWidth * 0.85)
					color: Theme.primaryFontColor
					text: qsTrId(model.textId)

					ColorImage {
						anchors.left: parent.right
						anchors.leftMargin: 10
						anchors.verticalCenter: parent.verticalCenter
						source: model.icon
						color: Theme.primaryFontColor
						fillMode: Image.PreserveAspectFit
						smooth: true
					}
				}
			}
		}
	}
}
