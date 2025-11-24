extends Node

#region INIT

func _ready() -> void:
	var user_agent = JavaScriptBridge.get_interface("navigator").get("userAgent")
	print("Browser: " + user_agent)
	print("")

#endregion

#region INPUT

func _input(event : InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_F10: Main.fullscreen(DisplayServer.WINDOW_MODE_FULLSCREEN)
		if event.keycode == KEY_F11: Main.fullscreen(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
		if event.keycode == KEY_F1: Main.display_fps.call_deferred()
		
		if event.keycode == KEY_ESCAPE or event.keycode == KEY_TAB or event.keycode == KEY_PAUSE:
			state_switch()
		
	elif event is InputEventJoypadButton:
		if event.pressed and event.button_index == 6:
			state_switch()
		Main.gamepad_id = event.device
	elif event is InputEventJoypadMotion:
		Main.gamepad_id = event.device

func state_switch() -> void:
	match Main.game_state:
		Main.game_states.Active:
			Main.set_gamestate.call_deferred(Main.game_states.Paused)
		Main.game_states.Paused:
			Main.set_gamestate.call_deferred(Main.game_states.Active)

#endregion
