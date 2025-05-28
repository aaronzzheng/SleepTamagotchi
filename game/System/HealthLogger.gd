extends Node

func _ready():
	var data = {}

	# Simulate data collected from the plugins
	data["steps_today"] = 8423
	data["light_exposure_minutes"] = 72
	data["sleep_duration_hours"] = 7.5
	data["timestamp"] = Time.get_datetime_string_from_system()

	# Save to file
	var file_path = "user://health_log.json"
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(data, "\t"))  # pretty-print JSON
		file.close()
		print("Data written to JSON at: ", file_path)
		print(FileAccess.get_file_as_string(file_path))
	else:
		print("Could not open file for writing.")
		
func read_logged_data():
	var file_path = "user://health_log.json"
	if FileAccess.file_exists(file_path):
		var file = FileAccess.open(file_path, FileAccess.READ)
		var text = file.get_as_text()
		file.close()

		var result = JSON.parse_string(text)
		if result:
			print("JSON Loaded:", result)
			return result
		else:
			print("Failed to parse JSON")
	else:
		print("File not found")
	return null
