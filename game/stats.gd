extends Node

const SAVE_PATH := "user://save.json"
const MAX_STAT := 100.0
const FOOD_DECAY_PER_SECOND := 0.35
const HEALTH_DECAY_PER_SECOND_WHEN_STARVING := 0.55
const HEALTH_RECOVERY_PER_SECOND_WHEN_FED := 0.10
const COIN_GAIN_INTERVAL_SECONDS := 30.0
const SAVE_INTERVAL_SECONDS := 10.0
const QUEST_REWARD_MULTIPLIER := 1.0
const MAX_OFFLINE_SECONDS := 43200.0 # cap catch-up simulation at 12 hours
const OFFLINE_STEP_SECONDS := 5.0
const SECONDS_PER_DAY := 86400.0

const STREAK_BASE_REWARD := 10
const STREAK_MAX_BONUS := 20

const THEME_CHANGE_COST := 15
const PET_THEME_NAMES := ["Classic", "Sakura", "Mint", "Midnight"]
const PET_THEME_COLORS := [
	Color(1, 1, 1),
	Color(1, 0.82, 0.88),
	Color(0.82, 1, 0.88),
	Color(0.82, 0.85, 1)
]

const ACHIEVEMENT_REWARD := 10

var coins := 0
var health := 100.0
var food := 80.0
var mood := "Happy"
var decay_enabled := true

var total_play_seconds := 0.0
var total_food_spent := 0.0
var total_health_recovered := 0.0
var total_coins_earned := 0
var study_interactions := 0
var bathroom_interactions := 0
var rest_interactions := 0

var last_active_day := -1
var login_streak_days := 0
var pet_theme_index := 0

var last_welcome_message := ""
var has_pending_welcome_message := false

var notification_queue: Array[String] = []
var _last_notified_mood := ""
var _last_notified_evo_stage := 0

var completed_quest_count := 0
var active_quest_index := 0
var quests := [
	{
		"id": "well_fed",
		"title": "Keep food above 60 for 2 minutes",
		"type": "food_timer",
		"goal": 120.0,
		"progress": 0.0,
		"reward": 20,
		"done": false
	},
	{
		"id": "study_habit",
		"title": "Study 5 times",
		"type": "study_count",
		"goal": 5.0,
		"progress": 0.0,
		"reward": 15,
		"done": false
	},
	{
		"id": "self_care",
		"title": "Use bathroom 3 times",
		"type": "bathroom_count",
		"goal": 3.0,
		"progress": 0.0,
		"reward": 10,
		"done": false
	},
	{
		"id": "rest_cycle",
		"title": "Rest 4 times",
		"type": "rest_count",
		"goal": 4.0,
		"progress": 0.0,
		"reward": 10,
		"done": false
	}
]

var achievements := [
	{"id": "first_evolution", "title": "First Growth Spurt", "unlocked": false},
	{"id": "fully_evolved", "title": "Fully Grown", "unlocked": false},
	{"id": "quest_master", "title": "Quest Cycle Complete", "unlocked": false},
	{"id": "coin_collector", "title": "Coin Collector (500 coins earned)", "unlocked": false},
	{"id": "dedicated_caretaker", "title": "Dedicated Caretaker (1h played)", "unlocked": false},
	{"id": "streak_starter", "title": "3-Day Streak", "unlocked": false}
]

var _coin_timer := 0.0
var _save_timer := 0.0

func _ready() -> void:
	load_game()
	_sanitize()

func _process(delta: float) -> void:
	total_play_seconds += delta
	_advance_stats(delta)

	_save_timer += delta
	if _save_timer >= SAVE_INTERVAL_SECONDS:
		save_game()
		_save_timer = 0.0

	_sanitize()

# Core per-tick simulation, shared by the live foreground loop and offline catch-up.
func _advance_stats(delta: float) -> void:
	if decay_enabled:
		food -= FOOD_DECAY_PER_SECOND * delta
		if food <= 0.0:
			health -= HEALTH_DECAY_PER_SECOND_WHEN_STARVING * delta
		elif food >= 60.0:
			add_health(HEALTH_RECOVERY_PER_SECOND_WHEN_FED * delta)

	_coin_timer += delta
	if _coin_timer >= COIN_GAIN_INTERVAL_SECONDS:
		var earned := int(_coin_timer / COIN_GAIN_INTERVAL_SECONDS)
		add_coins(earned)
		_coin_timer -= float(earned) * COIN_GAIN_INTERVAL_SECONDS

	_update_active_quest(delta)
	_check_achievements()

# Simulates time passed while the app was closed (elapsed real seconds),
# so the pet's stats/quests/coins reflect being away, not just time in-foreground.
func _apply_offline_progress(elapsed_seconds: float) -> void:
	var remaining := clampf(elapsed_seconds, 0.0, MAX_OFFLINE_SECONDS)
	while remaining > 0.0:
		var step := minf(OFFLINE_STEP_SECONDS, remaining)
		_advance_stats(step)
		remaining -= step
	_sanitize()

func perform_study() -> String:
	study_interactions += 1
	add_coins(2)
	adjust_food(-1.5)
	_register_interaction("study")
	return "Studied: +2 coins, -1 food"

func perform_bathroom() -> String:
	bathroom_interactions += 1
	add_health(8.0)
	adjust_food(-0.5)
	_register_interaction("bathroom")
	return "Bathroom: +8 health"

func perform_rest() -> String:
	rest_interactions += 1
	add_health(5.0)
	adjust_food(4.0)
	_register_interaction("rest")
	return "Rest: +5 health, +4 food"

func add_health(amount: float) -> void:
	if amount > 0.0:
		total_health_recovered += amount
	health += amount
	_sanitize()

func adjust_food(amount: float) -> void:
	if amount < 0.0:
		total_food_spent += abs(amount)
	food += amount
	_sanitize()

func add_coins(amount: int) -> void:
	if amount > 0:
		total_coins_earned += amount
	coins += amount
	_sanitize()

func spend_coins(amount: int) -> bool:
	if amount <= 0:
		return true
	if coins < amount:
		return false
	coins -= amount
	return true

func get_active_quest_text() -> String:
	if active_quest_index < 0 or active_quest_index >= quests.size():
		return "All quests complete"
	var quest: Dictionary = quests[active_quest_index]
	return "%s: %d/%d" % [quest.get("title", "Quest"), int(quest.get("progress", 0.0)), int(quest.get("goal", 0.0))]

func get_summary_text() -> String:
	return "Mood: %s\nHealth: %d  Food: %d  Coins: %d\nQuest: %s\nPlay Time: %s\nFood Used: %d  Health Recovered: %d\nCoins Earned: %d\nStudy: %d  Bathroom: %d  Rest: %d\nTotal Quests Completed: %d\nLogin Streak: %d day(s)\nAchievements (%d/%d):\n%s" % [
		mood,
		int(health),
		int(food),
		coins,
		get_active_quest_text(),
		_format_time(total_play_seconds),
		int(total_food_spent),
		int(total_health_recovered),
		total_coins_earned,
		study_interactions,
		bathroom_interactions,
		rest_interactions,
		completed_quest_count,
		login_streak_days,
		get_unlocked_achievement_count(),
		achievements.size(),
		get_achievements_text()
	]

func save_game() -> void:
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		return
	var payload := {
		"coins": coins,
		"health": health,
		"food": food,
		"mood": mood,
		"decay_enabled": decay_enabled,
		"total_play_seconds": total_play_seconds,
		"total_food_spent": total_food_spent,
		"total_health_recovered": total_health_recovered,
		"total_coins_earned": total_coins_earned,
		"study_interactions": study_interactions,
		"bathroom_interactions": bathroom_interactions,
		"rest_interactions": rest_interactions,
		"completed_quest_count": completed_quest_count,
		"active_quest_index": active_quest_index,
		"quests": quests,
		"achievements": achievements,
		"last_active_day": last_active_day,
		"login_streak_days": login_streak_days,
		"pet_theme_index": pet_theme_index,
		"last_active_unix": int(Time.get_unix_time_from_system())
	}
	file.store_string(JSON.stringify(payload))

func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		return
	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return

	coins = int(parsed.get("coins", coins))
	health = float(parsed.get("health", health))
	food = float(parsed.get("food", food))
	mood = str(parsed.get("mood", mood))
	decay_enabled = bool(parsed.get("decay_enabled", decay_enabled))
	total_play_seconds = float(parsed.get("total_play_seconds", total_play_seconds))
	total_food_spent = float(parsed.get("total_food_spent", total_food_spent))
	total_health_recovered = float(parsed.get("total_health_recovered", total_health_recovered))
	total_coins_earned = int(parsed.get("total_coins_earned", total_coins_earned))
	study_interactions = int(parsed.get("study_interactions", study_interactions))
	bathroom_interactions = int(parsed.get("bathroom_interactions", bathroom_interactions))
	rest_interactions = int(parsed.get("rest_interactions", rest_interactions))
	completed_quest_count = int(parsed.get("completed_quest_count", completed_quest_count))
	active_quest_index = int(parsed.get("active_quest_index", active_quest_index))

	var loaded_quests = parsed.get("quests", [])
	if typeof(loaded_quests) == TYPE_ARRAY and loaded_quests.size() == quests.size():
		quests = loaded_quests

	var loaded_achievements = parsed.get("achievements", [])
	if typeof(loaded_achievements) == TYPE_ARRAY and loaded_achievements.size() == achievements.size():
		achievements = loaded_achievements

	last_active_day = int(parsed.get("last_active_day", last_active_day))
	login_streak_days = int(parsed.get("login_streak_days", login_streak_days))
	pet_theme_index = int(parsed.get("pet_theme_index", pet_theme_index))
	if pet_theme_index < 0 or pet_theme_index >= PET_THEME_COLORS.size():
		pet_theme_index = 0

	if active_quest_index < 0 or active_quest_index >= quests.size():
		advance_quest()

	var welcome_parts: Array[String] = []

	var saved_last_active := int(parsed.get("last_active_unix", 0))
	if saved_last_active > 0:
		var elapsed := float(int(Time.get_unix_time_from_system()) - saved_last_active)
		if elapsed > 0.0:
			var before_health := health
			var before_food := food
			var before_coins := coins
			_apply_offline_progress(elapsed)
			welcome_parts.append(_format_offline_summary(elapsed, health - before_health, food - before_food, coins - before_coins))

	var current_day := int(Time.get_unix_time_from_system() / SECONDS_PER_DAY)
	var streak_message := _update_login_streak(current_day)
	if streak_message != "":
		welcome_parts.append(streak_message)

	if welcome_parts.size() > 0:
		last_welcome_message = "\n".join(welcome_parts)
		has_pending_welcome_message = true

	_sanitize()

func _register_interaction(kind: String) -> void:
	if active_quest_index < 0 or active_quest_index >= quests.size():
		return
	var quest: Dictionary = quests[active_quest_index]
	match kind:
		"study":
			if quest.get("type", "") == "study_count":
				quest["progress"] = float(quest.get("progress", 0.0)) + 1.0
		"bathroom":
			if quest.get("type", "") == "bathroom_count":
				quest["progress"] = float(quest.get("progress", 0.0)) + 1.0
		"rest":
			if quest.get("type", "") == "rest_count":
				quest["progress"] = float(quest.get("progress", 0.0)) + 1.0
	quests[active_quest_index] = quest
	_check_quest_completion()

func _update_active_quest(delta: float) -> void:
	if active_quest_index < 0 or active_quest_index >= quests.size():
		return
	var quest: Dictionary = quests[active_quest_index]
	if quest.get("done", false):
		advance_quest()
		return
	if quest.get("type", "") == "food_timer":
		if food >= 60.0:
			quest["progress"] = float(quest.get("progress", 0.0)) + delta
	quests[active_quest_index] = quest
	_check_quest_completion()

func _check_quest_completion() -> void:
	if active_quest_index < 0 or active_quest_index >= quests.size():
		return
	var quest: Dictionary = quests[active_quest_index]
	var progress := float(quest.get("progress", 0.0))
	var goal := float(quest.get("goal", 1.0))
	if progress < goal or bool(quest.get("done", false)):
		return

	quest["done"] = true
	quest["progress"] = goal
	quests[active_quest_index] = quest

	completed_quest_count += 1
	var reward := int(float(quest.get("reward", 0)) * QUEST_REWARD_MULTIPLIER)
	add_coins(reward)
	notification_queue.append("Quest complete: %s! +%d coins" % [quest.get("title", "Quest"), reward])

	var new_evo_stage := clampi(completed_quest_count, 0, 3)
	if new_evo_stage > _last_notified_evo_stage:
		notification_queue.append("Your pet evolved!")
		_last_notified_evo_stage = new_evo_stage

	advance_quest()

func advance_quest() -> void:
	for i in range(quests.size()):
		if not bool(quests[i].get("done", false)):
			active_quest_index = i
			return
	_reset_quest_cycle()

# Once every quest is done, loop the list back to the start instead of
# leaving the player with a permanent "all quests complete" dead end.
func _reset_quest_cycle() -> void:
	for i in range(quests.size()):
		var quest: Dictionary = quests[i]
		quest["done"] = false
		quest["progress"] = 0.0
		quests[i] = quest
	active_quest_index = 0

func _check_achievements() -> void:
	_maybe_unlock_achievement("first_evolution", completed_quest_count >= 1)
	_maybe_unlock_achievement("fully_evolved", completed_quest_count >= 3)
	_maybe_unlock_achievement("quest_master", completed_quest_count >= 4)
	_maybe_unlock_achievement("coin_collector", total_coins_earned >= 500)
	_maybe_unlock_achievement("dedicated_caretaker", total_play_seconds >= 3600.0)
	_maybe_unlock_achievement("streak_starter", login_streak_days >= 3)

func _maybe_unlock_achievement(id: String, condition_met: bool) -> void:
	if not condition_met:
		return
	for i in range(achievements.size()):
		var achievement: Dictionary = achievements[i]
		if achievement.get("id", "") != id or bool(achievement.get("unlocked", false)):
			continue
		achievement["unlocked"] = true
		achievements[i] = achievement
		add_coins(ACHIEVEMENT_REWARD)
		notification_queue.append("Achievement unlocked: %s! +%d coins" % [achievement.get("title", "Achievement"), ACHIEVEMENT_REWARD])
		return

func get_unlocked_achievement_count() -> int:
	var count := 0
	for achievement in achievements:
		if bool(achievement.get("unlocked", false)):
			count += 1
	return count

func get_achievements_text() -> String:
	var lines: Array[String] = []
	for achievement in achievements:
		var mark := "[x]" if bool(achievement.get("unlocked", false)) else "[ ]"
		lines.append("%s %s" % [mark, achievement.get("title", "Achievement")])
	return "\n".join(lines)

func get_pet_theme_color() -> Color:
	return PET_THEME_COLORS[pet_theme_index]

func get_pet_theme_name() -> String:
	return PET_THEME_NAMES[pet_theme_index]

func cycle_pet_theme() -> String:
	if not spend_coins(THEME_CHANGE_COST):
		return "Need %d coins to re-theme" % THEME_CHANGE_COST
	pet_theme_index = (pet_theme_index + 1) % PET_THEME_COLORS.size()
	return "Pet theme: %s" % get_pet_theme_name()

func reset_game() -> void:
	coins = 0
	health = 100.0
	food = 80.0
	decay_enabled = true
	total_play_seconds = 0.0
	total_food_spent = 0.0
	total_health_recovered = 0.0
	total_coins_earned = 0
	study_interactions = 0
	bathroom_interactions = 0
	rest_interactions = 0
	completed_quest_count = 0
	pet_theme_index = 0
	login_streak_days = 0
	last_active_day = -1
	for i in range(achievements.size()):
		var achievement: Dictionary = achievements[i]
		achievement["unlocked"] = false
		achievements[i] = achievement
	_reset_quest_cycle()
	_sanitize()
	save_game()

func _sanitize() -> void:
	coins = max(coins, 0)
	health = clampf(health, 0.0, MAX_STAT)
	food = clampf(food, 0.0, MAX_STAT)
	mood = _compute_mood()
	_notify_on_mood_change()

func _notify_on_mood_change() -> void:
	if mood == _last_notified_mood:
		return
	if mood == "Sick":
		notification_queue.append("Your pet is sick! It needs care now.")
	elif mood == "Hungry":
		notification_queue.append("Your pet is getting hungry.")
	_last_notified_mood = mood

func consume_notifications() -> Array[String]:
	var messages := notification_queue.duplicate()
	notification_queue.clear()
	return messages

func _compute_mood() -> String:
	if health <= 20.0 or food <= 15.0:
		return "Sick"
	if food <= 35.0:
		return "Hungry"
	if health <= 45.0:
		return "Tired"
	if decay_enabled == false:
		return "Calm"
	return "Happy"

func _update_login_streak(current_day: int) -> String:
	if last_active_day < 0:
		login_streak_days = 1
		last_active_day = current_day
		return ""
	if current_day == last_active_day:
		return ""
	if current_day == last_active_day + 1:
		login_streak_days += 1
		var reward := mini(STREAK_BASE_REWARD + login_streak_days, STREAK_BASE_REWARD + STREAK_MAX_BONUS)
		add_coins(reward)
		last_active_day = current_day
		return "%d-day streak! +%d coins" % [login_streak_days, reward]
	login_streak_days = 1
	last_active_day = current_day
	return "Streak reset — welcome back!"

func consume_welcome_message() -> String:
	has_pending_welcome_message = false
	var message := last_welcome_message
	last_welcome_message = ""
	return message

func _format_offline_summary(elapsed_seconds: float, health_delta: float, food_delta: float, coin_delta: int) -> String:
	var capped := elapsed_seconds >= MAX_OFFLINE_SECONDS
	var duration_text := _format_duration_human(minf(elapsed_seconds, MAX_OFFLINE_SECONDS))
	var text := "While you were away for %s:\nHealth %s, Food %s, Coins %s" % [
		duration_text,
		_format_signed_int(int(round(health_delta))),
		_format_signed_int(int(round(food_delta))),
		_format_signed_int(coin_delta)
	]
	if capped:
		text += "\n(catch-up capped at 12h)"
	return text

func _format_signed_int(value: int) -> String:
	return "+%d" % value if value >= 0 else str(value)

func _format_duration_human(seconds: float) -> String:
	var total_minutes := int(seconds) / 60
	var hours := total_minutes / 60
	var minutes := total_minutes % 60
	if hours > 0:
		return "%dh %dm" % [hours, minutes]
	return "%dm" % minutes

func _format_time(seconds: float) -> String:
	var total := int(seconds)
	var hours := total / 3600
	var minutes := (total % 3600) / 60
	var secs := total % 60
	return "%02d:%02d:%02d" % [hours, minutes, secs]

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_WM_CLOSE_REQUEST, NOTIFICATION_PREDELETE, NOTIFICATION_APPLICATION_PAUSED, NOTIFICATION_APPLICATION_FOCUS_OUT:
			save_game()
