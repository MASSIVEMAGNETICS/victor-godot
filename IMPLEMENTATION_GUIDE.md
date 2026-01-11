# Victor Avatar Lip Sync - Implementation Guide

## Overview

This project implements a real-time lip-sync system for a Godot avatar named Victor. The avatar's mouth animates naturally in response to live audio input from a microphone, creating the illusion of a living, speaking character.

## System Architecture

### Components

1. **LipSyncAnalyzer** (`lip_sync_analyzer.gd`)
   - Captures audio from microphone via AudioEffectCapture
   - Analyzes audio amplitude and frequency characteristics
   - Determines appropriate viseme (mouth shape) based on audio
   - Emits signals when viseme changes

2. **VictorAvatar** (`victor_avatar.gd`)
   - Visual representation of Victor character
   - Manages mouth shape animations
   - Smoothly interpolates between visemes
   - Handles blinking animations for realism

3. **Main Scene** (`main.tscn`, `main.gd`)
   - User interface with controls
   - Manages audio recording state
   - Displays current viseme and status

## How Lip Sync Works

### Audio Analysis Process

1. **Capture**: Audio is captured from the microphone using `AudioStreamMicrophone` and stored in an `AudioEffectCapture` effect on the Record bus.

2. **Analysis**: Each frame, the analyzer retrieves available audio samples and calculates:
   - RMS (Root Mean Square) amplitude - overall volume
   - Frequency distribution - rough characterization of sound type

3. **Viseme Selection**: Based on the audio characteristics:
   - **Low amplitude** → SILENT (mouth closed)
   - **High amplitude + low frequencies** → AA ("ah" - wide open)
   - **High frequencies** → SS (sibilant sounds)
   - **Mid frequencies** → EE or OH (vowel sounds)
   - **Low-mid amplitude** → MM (closed sounds)

4. **Animation**: The mouth shape smoothly morphs from current to target viseme using linear interpolation.

### Viseme Types

The system supports 9 viseme types:

| Viseme | Description | Example Sounds | Mouth Shape |
|--------|-------------|----------------|-------------|
| SILENT | No sound | Silence | Closed |
| AA | Open vowel | "ah", "father" | Wide open |
| EE | Front vowel | "ee", "see" | Wide smile |
| OH | Back vowel | "oh", "go" | Rounded |
| UW | Close back vowel | "oo", "blue" | Small round |
| MM | Bilabial | "mm", "mom" | Lips together |
| FF | Labiodental | "ff", "five" | Teeth on lip |
| TH | Dental | "th", "think" | Tongue visible |
| SS | Sibilant | "ss", "see" | Tight smile |

## Setup Instructions

### Prerequisites

- Godot Engine 4.2 or later
- A working microphone
- Microphone permissions granted to Godot

### Running the Project

1. Open Godot Engine
2. Import the project by selecting the `project.godot` file
3. Press F5 or click the Run button
4. Click "Start Microphone" in the UI
5. Grant microphone permissions if prompted
6. Speak into your microphone

### Audio Settings

The project automatically configures audio settings, but you can adjust them in `main.gd`:

```gdscript
# In setup_audio_buses()
capture_effect.buffer_length = 0.1  # Buffer size in seconds (default: 100ms)
```

### Lip Sync Sensitivity

Adjust sensitivity in `lip_sync_analyzer.gd`:

```gdscript
var viseme_threshold: float = 0.02  # Minimum amplitude to trigger mouth movement
var smoothing: float = 0.3          # Animation smoothing factor
```

## Customization

### Adding New Visemes

To add a new mouth shape:

1. Define the polygon in `victor_avatar.gd`:
```gdscript
var mouth_shapes = {
    "new_shape": PackedVector2Array([
        Vector2(-15, 0), Vector2(15, 0), 
        Vector2(10, 10), Vector2(-10, 10)
    ])
}
```

2. Add detection logic in `lip_sync_analyzer.gd`:
```gdscript
# In determine_viseme()
if some_condition:
    return Viseme.NEW_SHAPE
```

### Changing Visual Style

Modify the character appearance in `victor_avatar.gd`:

```gdscript
# Change colors
head.color = Color(0.95, 0.8, 0.7)  # Skin tone
mouth.color = Color(0.8, 0.3, 0.3)  # Mouth color

# Change sizes
var radius = 80  # Head radius
```

### Using with Pre-recorded Audio

To use with an audio file instead of microphone:

1. Load an AudioStream:
```gdscript
var audio = load("res://audio/speech.ogg")
playback.stream = audio
playback.play()
```

2. The lip sync will automatically analyze the audio

## Performance Considerations

- **Buffer Size**: Smaller buffers reduce latency but increase CPU usage
- **Analysis Frequency**: Processing happens every frame; consider throttling for low-end devices
- **Smoothing**: Higher smoothing values create smoother but less responsive animations

## Troubleshooting

### No mouth movement
- Check microphone permissions
- Verify audio input is working (check system settings)
- Try adjusting `viseme_threshold` lower
- Ensure "Start Microphone" button was clicked

### Choppy animations
- Increase `smoothing` value in `victor_avatar.gd`
- Reduce project frame rate fluctuations
- Check system performance

### Wrong visemes detected
- Adjust frequency analysis logic in `determine_viseme()`
- Modify threshold values
- Consider using FFT for better frequency analysis

## Technical Limitations

1. **Simplified Frequency Analysis**: The current implementation uses a basic frequency band approach rather than proper FFT, which limits accuracy
2. **No Machine Learning**: Viseme detection is rule-based, not learned from data
3. **2D Only**: Current implementation is 2D; 3D models would require different animation approach
4. **Limited Phoneme Set**: Only 9 visemes; real speech has more variations

## Future Enhancements

Possible improvements include:

- **FFT Analysis**: Use `AudioEffectSpectrumAnalyzer` for accurate frequency analysis
- **ML-Based Detection**: Train a model to recognize phonemes from audio
- **3D Support**: Adapt for 3D character models with blend shapes
- **Pre-processing**: Add noise reduction and audio preprocessing
- **Synchronization**: Better sync with pre-recorded audio using timing data
- **Expression System**: Add emotions and facial expressions
- **Multi-character**: Support multiple characters speaking simultaneously

## API Reference

### LipSyncAnalyzer

**Signals:**
- `viseme_changed(viseme: String)` - Emitted when detected viseme changes

**Methods:**
- `get_current_viseme() -> String` - Returns current viseme name
- `get_viseme_name(viseme: Viseme) -> String` - Converts viseme enum to name

**Properties:**
- `viseme_threshold: float` - Minimum amplitude for mouth movement
- `smoothing: float` - Animation smoothing factor

### VictorAvatar

**Methods:**
- `set_viseme(viseme: String)` - Manually set mouth shape

**Properties:**
- `morph_speed: float` - Speed of mouth shape transitions
- `blink_interval: float` - Average time between blinks

## License

This is a demonstration project for educational purposes.
