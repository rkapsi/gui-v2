/*
** Copyright (C) 2023 Victron Energy B.V.
** See LICENSE.txt for license information.
*/

pragma Singleton

import QtQml
import Victron.VenusOS

QtObject {
	property var main
	property var pageManager
	property var mainView
	property var mockDataSimulator    // only valid when mock mode is active
	property var dataManager
	property var locale: Qt.locale()  // TODO: read from settings
	property VeQItemTableModel dataServiceModel: null
	property var firmwareUpdate

	property var fontLoader
	property var inputPanel
	property var dialogLayer
	property var notificationLayer

	// data sources
	property var acInputs
	property var chargers
	property var batteries
	property var dcInputs
	property var dcLoads
	property var dcSystems
	property var digitalInputs
	property var environmentInputs
	property var ess
	property var evChargers
	property var generators
	property var inverterChargers
	property var meteoDevices
	property var motorDrives
	property var multiRsDevices
	property var notifications
	property var pulseMeters
	property var pvInverters
	property var relays
	property var solarChargers
	property var system
	property var systemSettings
	property var tanks
	property var unsupportedDevices

	property var venusPlatform
	property bool splashScreenVisible: true
	property bool dataManagerLoaded
	property bool allPagesLoaded
	property bool changingLanguage

	signal aboutToFocusTextField(var textField, int toTextFieldY, var flickable)
	signal keyPressed(var event)

	function appUrl(urlPath) {
		let url = urlPath
		if (!url.startsWith("qrc:")) {
			if (url.startsWith("/")) {
				url = "qrc:/qt/qml/Victron/VenusOS" + url
			} else {
				console.warn("appUrl(): relative paths are not supported!")
			}
		}
		return url
	}

	function showToastNotification(category, text, autoCloseInterval = 0) {
		notificationLayer.showToastNotification(category, text, autoCloseInterval)
	}

	function deviceModelsForClass(deviceClass) {
		if (deviceClass === "com.victronenergy.battery") {
			return [batteries.model]
		} else if (deviceClass === "com.victronenergy.solarcharger" || deviceClass === "solarcharger") {
			return [solarChargers.model]
		} else if (deviceClass === "analog") {
			return Global.tanks.allTankModels.concat([Global.environmentInputs.model])
		}
		return []
	}

	function reset() {
		// note: we don't reset `main` or `changingLanguage`
		// as main will never be destroyed during the ui rebuild,
		// and we handle changingLanguage specially.
		pageManager = null
		mainView = null
		mockDataSimulator = null
		dataManager = null
		locale = Qt.locale()
		dataServiceModel = null
		firmwareUpdate = null
		inputPanel = null
		dialogLayer = null
		notificationLayer = null

		acInputs = null
		chargers = null
		batteries = null
		dcInputs = null
		dcLoads = null
		dcSystems = null
		digitalInputs = null
		environmentInputs = null
		ess = null
		evChargers = null
		generators = null
		inverterChargers = null
		meteoDevices = null
		motorDrives = null
		multiRsDevices = null
		notifications = null
		pulseMeters = null
		pvInverters = null
		relays = null
		solarChargers = null
		system = null
		systemSettings = null
		tanks = null
		unsupportedDevices = null
		venusPlatform = null

		// The last thing we do is set the splash screen visible.
		allPagesLoaded = false
		dataManagerLoaded = false
		splashScreenVisible = true
	}
}

