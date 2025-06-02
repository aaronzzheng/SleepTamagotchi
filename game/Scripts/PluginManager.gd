extends Node  


var MobileOS: Array = ["Android", "iOS"]

# These must match the plugin names registered via Java/Kotlin in your Android Godot plugin implementation.
const SensorsPluginName := "AndroidSensorsPlugin"
const HealthConnectPluginName := "AndroidHealthConnectPlugin"

var SensorsPlugin: JNISingleton = null
var HealthConnectPlugin: JNISingleton = null

# === Sensor Types ===
# List of sensor names the Sensors plugin will be told to track.
# These should correspond to signal names and supported sensor types on the Android side.
var Sensors: Array = ["step", "light", "heart_rate"]

# === Light Tracking Constants & Variables ===
# Light must exceed this lux value to be considered valid "light exposure."
const LIGHT_THRESHOLD := 5000.0

# Internal counter for how long the user has been exposed to light above threshold.
var light_exposure_seconds := 0.0

# Latest lux value received from the light sensor.
var current_lux := 0.0

# === Initialization Function ===
func _ready():
	# Only proceed if running on a supported mobile OS
	if OS.get_name() in MobileOS:
		print("Requesting runtime permissions...")

		# Ask user for runtime permissions
		OS.request_permissions()

		# Pause briefly to allow the permission prompt to resolve
		await get_tree().create_timer(1.0).timeout

		# Optional haptic feedback for confirmation
		Input.vibrate_handheld(300)

		# Begin setup of all detected plugins
		_setup_plugins()

		# Start a repeating timer to log health data to file every 30 seconds
		_start_logging_timer()

# === Plugin Setup ===
func _setup_plugins():
	# === Sensors Plugin Setup ===
	if Engine.has_singleton(SensorsPluginName):
		SensorsPlugin = Engine.get_singleton(SensorsPluginName)
		print("Sensors plugin loaded")

		# For each sensor type (e.g., step, light, heart_rate), initialize, connect its value_changed signal, and start tracking.
		for sensor in Sensors:
			SensorsPlugin.setupSensor(sensor)
			SensorsPlugin.connect(sensor + "_value_changed", Callable(self, sensor + "_sensor_value_changed"))
			SensorsPlugin.startSensorTracking(sensor)

		# Debug whether sensor tracking is actively working
		if SensorsPlugin.tracking():
			print("Sensors are tracking.")
		else:
			print("Sensors are NOT tracking.")
	else:
		printerr("Sensors plugin not found.")

	# === HealthConnect Plugin Setup ===
	if Engine.has_singleton(HealthConnectPluginName):
		HealthConnectPlugin = Engine.get_singleton(HealthConnectPluginName)
		print("HealthConnect plugin loaded")

		# Connect to HealthConnect's step and heart rate signals
		HealthConnectPlugin.connect("step_count_data", Callable(self, "_on_step_count_data"))
		HealthConnectPlugin.connect("heart_rate_data", Callable(self, "_on_heart_rate_data"))

		# Manually request current values from HealthConnect
		HealthConnectPlugin.requestStepCount()
		HealthConnectPlugin.requestHeartRate()
	else:
		printerr("HealthConnect plugin not found.")

# === Logging Timer Setup ===
func _start_logging_timer():
	var timer := Timer.new()
	timer.wait_time = 30.0             # Log every 30 seconds
	timer.one_shot = false             # Repeat indefinitely
	timer.autostart = true             # Begin immediately
	timer.timeout.connect(_on_log_timer_timeout)
	add_child(timer)                   # Add to scene tree so it runs
	print("Logging timer started.")

# === SensorPlugin Signal Handlers ===

# Called when the step sensor detects a new value
func step_sensor_value_changed(value):
	print("🚶 [Sensor] Steps:", value)
	GlobalData.steps_today = int(value)

# Called when the light sensor detects a new lux value
func light_sensor_value_changed(value):
	print("[Sensor] Light:", value)
	current_lux = float(value)

# Called when the heart rate sensor updates
func heart_rate_sensor_value_changed(value):
	print("[Sensor] Heart rate:", value)
	GlobalData.heart_rate = float(value)

# === HealthConnect Signal Handlers ===

# Called when HealthConnect provides a step count
func _on_step_count_data(value):
	print("[HealthConnect] Step Count:", value)
	GlobalData.steps_today = int(value)

# Called when HealthConnect provides a heart rate
func _on_heart_rate_data(value):
	print("[HealthConnect] Heart Rate:", value)
	GlobalData.heart_rate = float(value)

# === Health Data Logging ===
# This runs every 30 seconds from the timer to log the latest health data into a JSON file
func _on_log_timer_timeout():
	print("Timer triggered. Logging data...")

	var file_path = "user://health_log.json"

	# Compose a single entry from global health data
	var log_entry = {
		"timestamp": Time.get_datetime_string_from_system(),
		"steps_today": GlobalData.steps_today,
		"light_exposure_minutes": GlobalData.light_exposure_minutes,
		"heart_rate": GlobalData.heart_rate
	}

	var log_array = []

	# Read previous data from the file, if any
	if FileAccess.file_exists(file_path):
		var file = FileAccess.open(file_path, FileAccess.READ)
		if file:
			var content = file.get_as_text()
			file.close()
			var parsed = JSON.parse_string(content)
			if typeof(parsed) == TYPE_ARRAY:
				log_array = parsed

	# Avoid duplicate logging by checking if the last entry has the same timestamp
	if log_array.size() > 0 and log_array[-1]["timestamp"] == log_entry["timestamp"]:
		print("Duplicate log entry skipped.")
		return

	# Append new entry and save
	log_array.append(log_entry)

	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(log_array, "\t"))  # Pretty-print JSON
		file.close()
		print("Logged:", log_entry)
	else:
		printerr("Failed to write JSON file.")

# === Per-frame Processing ===
# This runs every frame and tracks light exposure duration (no UI logic here)
func _process(delta):
	# Increment light exposure time if brightness exceeds the threshold
	if current_lux > LIGHT_THRESHOLD:
		light_exposure_seconds += delta

	# Once 60 seconds of high light exposure accumulates, log 1 minute
	if light_exposure_seconds >= 60.0:
		var minutes_to_add = int(light_exposure_seconds / 60.0)
		GlobalData.light_exposure_minutes += minutes_to_add

		# Remove the recorded minutes from the second counter, preserving any remainder
		light_exposure_seconds -= minutes_to_add * 60.0
