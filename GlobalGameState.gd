extends Node

class_name GlobalGameState

"""
GlobalGameState: Singleton tracking global game state variables.
Emits state changes via SignalBus for UI and system consumption.
"""

static var instance: GlobalGameState = null

var current_temperature: float = 20.0
var current_battery: float = 100.0
var current_hp: float = 100.0
var cryo_storm_active: bool = false
var cryo_storm_time_left: float = 180.0
var player_position: Vector2 = Vector2.ZERO
var _storm_timer: Timer = null
var _player_health: HealthComponent

static func get_instance() -> GlobalGameState:
	if not is_instance_valid(instance):
		instance = GlobalGameState.new()
	return instance

static func reset() -> void:
	var inst := get_instance()
	inst.current_temperature = 20.0
	inst.current_battery = 100.0
	inst.current_hp = 100.0
	if is_instance_valid(inst._player_health):
		inst._player_health.reset_health()
	inst.cryo_storm_active = true
	inst.cryo_storm_time_left = 180.0
	inst.player_position = Vector2.ZERO
	var bus := SignalBus.get_instance()
	bus.temperature_changed.emit(inst.current_temperature, 100.0)
	bus.battery_changed.emit(inst.current_battery, 100.0)
	bus.hp_changed.emit(inst.current_hp, 100.0)
	bus.cryo_storm_timer_updated.emit(inst.cryo_storm_time_left)

static func get_temperature() -> float:
	return get_instance().current_temperature

static func get_battery() -> float:
	return get_instance().current_battery

static func get_hp() -> float:
	return get_instance().current_hp

static func is_cryo_storm_active() -> bool:
	return get_instance().cryo_storm_active

static func get_cryo_storm_time_left() -> float:
	return get_instance().cryo_storm_time_left

static func get_player_position() -> Vector2:
	return get_instance().player_position

static func set_temperature(value: float) -> void:
	var inst := get_instance()
	inst.current_temperature = clampf(value, -50.0, 100.0)
	SignalBus.get_instance().temperature_changed.emit(inst.current_temperature, 100.0)

static func set_battery(value: float) -> void:
	var inst := get_instance()
	inst.current_battery = clampf(value, 0.0, 100.0)
	SignalBus.get_instance().battery_changed.emit(inst.current_battery, 100.0)

static func bind_health(health: HealthComponent) -> void:
	get_instance()._player_health = health

static func unbind_health(health: HealthComponent) -> void:
	# During SceneTree shutdown this singleton may have exited before Player;
	# do not recreate an unattached singleton from a component destructor.
	if is_instance_valid(instance) and instance._player_health == health:
		instance._player_health = null

static func set_hp(value: float) -> void:
	var inst := get_instance()
	if is_instance_valid(inst._player_health):
		inst._player_health.set_current(value)
		return
	inst.current_hp = clampf(value, 0.0, 100.0)
	var bus := SignalBus.get_instance()
	bus.hp_changed.emit(inst.current_hp, 100.0)
	if inst.current_hp <= 0.0:
		bus.player_died.emit()

static func set_cryo_storm_active(active: bool) -> void:
	var inst := get_instance()
	inst.cryo_storm_active = active
	if active:
		inst.start_cryo_storm_timer()

static func set_cryo_storm_time_left(time_sec: float) -> void:
	var inst := get_instance()
	inst.cryo_storm_time_left = maxf(0.0, time_sec)
	SignalBus.get_instance().cryo_storm_timer_updated.emit(inst.cryo_storm_time_left)

static func set_player_position(pos: Vector2) -> void:
	get_instance().player_position = pos

func _ready() -> void:
	if instance == null:
		instance = self
	start_cryo_storm_timer()

func _exit_tree() -> void:
	if instance == self:
		instance = null

func start_cryo_storm_timer() -> void:
	if _storm_timer != null and is_instance_valid(_storm_timer):
		return
	_storm_timer = Timer.new()
	_storm_timer.wait_time = 1.0
	_storm_timer.autostart = true
	_storm_timer.one_shot = false
	_storm_timer.timeout.connect(_on_cryo_storm_timer_tick)
	add_child(_storm_timer)

func _on_cryo_storm_timer_tick() -> void:
	if cryo_storm_active and cryo_storm_time_left > 0.0:
		cryo_storm_time_left = maxf(0.0, cryo_storm_time_left - 1.0)
		SignalBus.get_instance().cryo_storm_timer_updated.emit(cryo_storm_time_left)
		if cryo_storm_time_left <= 0.0:
			cryo_storm_active = false
