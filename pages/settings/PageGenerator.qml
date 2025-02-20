/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

import QtQuick
import Victron.VenusOS

Page {
	id: root

	property bool allowDisableAutostart: true
	property string settingsBindPrefix: Global.systemSettings.serviceUid + "/Settings/Generator0"

	// The generator start/stop service is always com.victronenergy.generator.startstop0 on D-Bus,
	// and mqtt/generator/0 on MQTT.
	property string startStopBindPrefix: BackendConnection.type === BackendConnection.MqttSource
			? "mqtt/generator/0"
			: BackendConnection.uidPrefix() + "/com.victronenergy.generator.startstop0"

	readonly property alias generatorState: _generatorState
	property alias startStopModel: startStopModel
	property alias model: settingsListView.model

	readonly property var _dates: historicalData.isValid ? Object.keys(JSON.parse(historicalData.value)).reverse() : 0

	VeQuickItem {
		id: _generatorState
		uid: root.startStopBindPrefix + "/State"
	}

	VeQuickItem {
		id: activeCondition
		uid: root.startStopBindPrefix + "/RunningByConditionCode"
	}

	VeQuickItem {
		id: stopTimer
		uid: startStopBindPrefix + "/ManualStartTimer"
	}

	VeQuickItem {
		id: historicalData
		uid: root.settingsBindPrefix + "/AccumulatedDaily"
	}

	GradientListView {
		id: settingsListView

		model: startStopModel

		VeQuickItem {
			id: relayFunction
			uid: Global.systemSettings.serviceUid + "/Settings/Relay/Function"
		}
	}

	ObjectModel {
		id: startStopModel

		ListTextItem {
			id: state

			text: CommonWords.state
			secondaryText: activeCondition.isValid ? Global.generators.stateToText(generatorState.value, activeCondition.value) : '---'
			enabled: false
		}

		ListRadioButtonGroup {
			text: CommonWords.error
			optionModel: [
				{ display: CommonWords.no_error, value: 0 },
				//% "Remote switch control disabled"
				{ display: qsTrId("settings_remote_switch_control_disabled"), value: 1 },
				//% "Generator in fault condition"
				{ display: qsTrId("settings_generator_in_fault_condition"), value: 2 },
				//% "Generator not detected at AC input"
				{ display: qsTrId("settings_generator_not_detected"), value: 3 },
			]
			enabled: false
			dataItem.uid: root.startStopBindPrefix + "/Error"
		}

		ListTextItem {
			//% "Run time"
			text: qsTrId("settings_page_relay_generator_run_time")
			secondaryText: dataItem.isValid ? Utils.secondsToString(dataItem.value, false) : "0"
			dataItem.uid: root.startStopBindPrefix + "/Runtime"
			visible: generatorState.value in [1, 2, 3] // Running, Warm-up, Cool-down
		}

		ListTextItem {
			//% "Total run time"
			text: qsTrId("settings_page_relay_generator_total_run_time")
			secondaryText: Utils.secondsToString((accumulatedTotal.value || 0) - (accumulatedTotalOffset.value || 0), false)

			VeQuickItem {
				id: accumulatedTotal
				uid: root.settingsBindPrefix + "/AccumulatedTotal"
			}
			VeQuickItem {
				id: accumulatedTotalOffset
				uid: root.settingsBindPrefix + "/AccumulatedTotalOffset"
			}
		}

		ListTextItem {
			//% "Time to service"
			text: qsTrId("settings_page_relay_generator_time_to_service")
			dataItem.uid: root.startStopBindPrefix + "/ServiceCounter"
			secondaryText: Utils.secondsToString(dataItem.value, false)
			visible: defaultVisible && dataItem.isValid
		}

		ListTextItem {
			//% "Accumulated running time since last test run"
			text: qsTrId("settings_page_relay_generator_accumulated_running_time")
			showAccessLevel: VenusOS.User_AccessType_Service
			visible: defaultVisible && nextTestRun.visible
			secondaryText: Utils.secondsToString(dataItem.value, false)
			dataItem.uid: root.startStopBindPrefix + "/TestRunIntervalRuntime"
		}

		ListTextItem {
			id: nextTestRun
			//% "Time to next test run"
			text: qsTrId("settings_page_relay_generator_time_to_next_test_run")
			secondaryText: ""
			dataItem.uid: root.startStopBindPrefix + "/NextTestRun"
			visible: dataItem.isValid && dataItem.value > 0

			Timer {
				running: parent.visible && root.animationEnabled
				repeat: true
				interval: 1000
				onTriggered: {
					var now = new Date().getTime() / 1000
					var remainingTime = parent.dataItem.value - now
					if (remainingTime > 0) {
						parent.secondaryText = Utils.secondsToString(remainingTime, false)
						return
					}
					//% "Running now"
					parent.secondaryText = qsTrId("settings_page_relay_generator_running_now")
				}
			}
		}

		ListSwitch {
			//% "Auto start functionality"
			text: qsTrId("settings_page_relay_generator_auto_start_enabled")
			dataItem.uid: root.startStopBindPrefix + "/AutoStartEnabled"
			visible: allowDisableAutostart
		}

		ListNavigationItem {
			//% "Manual start"
			text: qsTrId("settings_page_relay_generator_manual_start")
			onClicked: Global.pageManager.pushPage(manualStartPageComponent, { title: text })

			Component {
				id: manualStartPageComponent

				Page {
					id: manualStartPage

					GradientListView {

						model: ObjectModel {

							ListSwitch {
								id: manualSwitch
								//% "Start generator"
								text: qsTrId("settings_page_relay_generator_start_generator")
								dataItem.uid: root.startStopBindPrefix + "/ManualStart"
								writeAccessLevel: VenusOS.User_AccessType_User
								onClicked: {
									if (manualStartPage.isCurrentPage) {
										if (!checked) {
											//% "Stopping, generator will continue running if other conditions are reached"
											Global.showToastNotification(VenusOS.Notification_Info, qsTrId("settings_page_relay_generator_stop_info"), 3000)
										}
										if (checked && stopTimer.value == 0) {
											//% "Starting, generator won't stop till user intervention"
											Global.showToastNotification(VenusOS.Notification_Info, qsTrId("settings_page_relay_generator_start_info"), 5000)
										}
										if (checked && stopTimer.value > 0) {
											//: %1 = time until generator is stopped
											//% "Starting. The generator will stop in %1, unless other conditions keep it running"
											Global.showToastNotification(VenusOS.Notification_Info, qsTrId("settings_page_relay_generator_start_timer").arg(Utils.secondsToString(stopTimer.value)), 5000)
										}
									}
								}
							}

							ListTimeSelector {
								//% "Run for (hh:mm)"
								text: qsTrId("settings_page_relay_generator_run_for_hh_mm")
								enabled: !manualSwitch.checked
								dataItem.uid: root.startStopBindPrefix + "/ManualStartTimer"
								writeAccessLevel: VenusOS.User_AccessType_User
							}
						}
					}
				}
			}
		}

		ListNavigationItem {
			//% "Daily run time"
			text: qsTrId("settings_page_relay_generator_daily_run_time")
			onClicked: Global.pageManager.pushPage(dailyRunTimePage, { title: text })

			Component {
				id: dailyRunTimePage

				Page {
					GradientListView {
						model: _dates
						delegate: ListTextItem {
							text: Qt.formatDate(new Date(parseInt(_dates[index]) * 1000), "dd-MM-yyyy") // TODO: locale-specific date format?
							secondaryText: Utils.secondsToString(JSON.parse(historicalData.value)[_dates[index]], false)
						}
					}
				}
			}
		}

		ListNavigationItem {
			text: CommonWords.settings
			onClicked: {
				Global.pageManager.pushPage("/pages/settings/PageSettingsGenerator.qml",
					{ title: text, settingsBindPrefix: root.settingsBindPrefix, startStopBindPrefix: root.startStopBindPrefix })
			}
		}
	}
}
