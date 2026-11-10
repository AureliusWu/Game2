extends Node
## Original synthesised ambience. No borrowed tracks or externally licensed sound files.
## Uses procedural PCM so the prototype remains self-contained and Steam-safe.

const SAMPLE_RATE := 16000
const LOOP_SECONDS := 4.0
var ambient_player: AudioStreamPlayer
var event_player: AudioStreamPlayer
var tracks: Dictionary = {}
var tape_tracks: Dictionary = {}
var zone: String = ""

func _ready() -> void:
    ambient_player = AudioStreamPlayer.new()
    ambient_player.name = "AmbientBed"
    ambient_player.volume_db = -15.0
    add_child(ambient_player)

    event_player = AudioStreamPlayer.new()
    event_player.name = "UncannySting"
    event_player.volume_db = -12.0
    add_child(event_player)

func play_zone(new_zone: String) -> void:
    if new_zone == zone and ambient_player.playing:
        return
    zone = new_zone
    if not tracks.has(zone):
        tracks[zone] = _make_clip(zone, LOOP_SECONDS, true)
    ambient_player.stop()
    ambient_player.stream = tracks[zone]
    ambient_player.volume_db = -18.0 if zone == "shrine" else -16.0
    ambient_player.play()

func play_radio_anomaly() -> void:
    event_player.stop()
    event_player.stream = _make_clip("transmission", 2.25, false)
    event_player.play()

func play_last_call() -> void:
    event_player.stop()
    event_player.stream = _make_clip("last_call", 3.0, false)
    event_player.play()

func play_tape_stage(kind: String) -> void:
    # One original non-vocal texture per narrative beat, cached across replays.
    if not kind.begins_with("tape_"):
        return
    if not tape_tracks.has(kind):
        tape_tracks[kind] = _make_clip(kind, 2.4, false)
    event_player.stop()
    event_player.stream = tape_tracks[kind]
    event_player.volume_db = -11.0
    event_player.play()

func stop_tape() -> void:
    if event_player != null:
        event_player.stop()

func _make_clip(kind: String, seconds: float, loop: bool) -> AudioStreamWAV:
    var length: int = int(SAMPLE_RATE * seconds)
    var data := PackedByteArray()
    data.resize(length * 2)
    var rng := RandomNumberGenerator.new()
    rng.seed = 20030717
    var noise_state: float = 0.0
    for i in range(length):
        var t: float = float(i) / float(SAMPLE_RATE)
        noise_state = noise_state * 0.965 + rng.randf_range(-1.0, 1.0) * 0.035
        var sound: float = 0.0
        match kind:
            "street":
                # A distant electrical mains hum and cicada-like evening shimmer.
                var cicada: float = sin(TAU * 2380.0 * t) * sin(TAU * 9.2 * t)
                var pulse: float = pow(maxf(0.0, sin(TAU * 0.37 * t)), 2.0)
                sound = 0.17 * noise_state + 0.042 * sin(TAU * 60.0 * t)
                sound += 0.075 * cicada * pulse
            "shop":
                # Rotary fan, old refrigerator and fluorescent light ballast.
                var rotary: float = 0.65 + 0.35 * sin(TAU * 4.7 * t)
                sound = 0.28 * noise_state + 0.078 * sin(TAU * 51.0 * t) * rotary
                sound += 0.035 * sin(TAU * 118.0 * t)
            "radio":
                # Low electronic room tone with irregular amplitude-modulated interference.
                var crackle: float = pow(maxf(0.0, sin(TAU * 3.7 * t)), 18.0)
                sound = 0.18 * noise_state + 0.066 * sin(TAU * 63.0 * t)
                sound += crackle * 0.12 * rng.randf_range(-1.0, 1.0)
            "shrine":
                # Distant wind and a slightly detuned low drone.
                sound = 0.45 * noise_state + 0.055 * sin(TAU * 75.5 * t)
                sound += 0.058 * sin(TAU * 76.1 * t)
            "tape_leader":
                # Mechanical spool wobble and subtle tape hiss.
                sound = 0.10 * noise_state + 0.040 * sin(TAU * 46.0 * t)
                sound += 0.025 * sin(TAU * 6.3 * t) * sin(TAU * 120.0 * t)
            "tape_line":
                # The monitor's vacant carrier: quiet ticks, not a human voice.
                var tick: float = pow(maxf(0.0, sin(TAU * 2.15 * t)), 30.0)
                sound = 0.17 * noise_state + 0.06 * sin(TAU * 117.0 * t)
                sound += tick * 0.12 * rng.randf_range(-1.0, 1.0)
            "tape_echo":
                # Detuned carrier and air between syllables; no spoken performance.
                var pulse: float = 0.6 + 0.4 * sin(TAU * 1.65 * t)
                sound = pulse * (0.18 * noise_state + 0.065 * sin(TAU * 181.0 * t))
                sound += 0.025 * sin(TAU * 182.6 * t)
            "tape_stop":
                # A click and a quickly fading motor winding down.
                var fade: float = pow(maxf(0.0, 1.0 - t / seconds), 2.5)
                sound = fade * (0.24 * noise_state + 0.09 * sin(TAU * (64.0 - 13.0 * t) * t))
            "transmission":
                # A short interrupted broadcast. Intentionally non-verbal.
                var fade: float = pow(maxf(0.0, 1.0 - t / seconds), 1.8)
                var crackle: float = rng.randf_range(-1.0, 1.0)
                sound = fade * (0.21 * crackle + 0.13 * sin(TAU * 900.0 * t) * sin(TAU * 13.0 * t))
            "last_call":
                # Unsettling radio carrier without human voice imitation.
                var envelope: float = sin(PI * t / seconds)
                sound = envelope * (0.21 * sin(TAU * (140.0 + 21.0 * t) * t))
                sound += envelope * 0.13 * noise_state
            _:
                sound = noise_state * 0.2
        var edge: float = 1.0
        if loop:
            edge = minf(1.0, minf(t, seconds - t) / 0.06)
        else:
            edge = minf(1.0, minf(t / 0.045, (seconds - t) / 0.12))
        var raw_sample: int = int(clampf(sound * edge, -1.0, 1.0) * 32767.0)
        data[i * 2] = raw_sample & 255
        data[i * 2 + 1] = (raw_sample >> 8) & 255
    var result := AudioStreamWAV.new()
    result.mix_rate = SAMPLE_RATE
    result.format = AudioStreamWAV.FORMAT_16_BITS
    result.stereo = false
    result.data = data
    if loop:
        result.loop_mode = AudioStreamWAV.LOOP_FORWARD
        result.loop_begin = 0
        result.loop_end = length
    return result
