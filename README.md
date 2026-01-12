# Victor Avatar - Real-Time Lip Sync

A Godot 4 project featuring Victor, an animated avatar with real-time lip-sync capabilities that responds to live audio input.

## Features

- **Real-Time Lip Sync**: Victor's mouth moves naturally in response to your voice
- **Microphone Input**: Captures live audio from your microphone
- **Viseme-Based Animation**: Uses phoneme/viseme analysis to determine mouth shapes
- **Smooth Animations**: Morphs between different mouth shapes for natural movement
- **Eye Blinking**: Automatic blinking animation for more lifelike appearance

## How It Works

1. **Audio Capture**: The system uses Godot's `AudioStreamMicrophone` and `AudioEffectCapture` to record audio in real-time
2. **Audio Analysis**: The `LipSyncAnalyzer` processes the audio stream, analyzing amplitude and frequency distribution
3. **Viseme Detection**: Based on the audio characteristics, the system determines which viseme (mouth shape) to display:
   - **SILENT**: Mouth closed (no audio)
   - **AA**: Wide open ("ah" sound)
   - **EE**: Wide smile ("ee" sound)
   - **OH**: Rounded mouth ("oh" sound)
   - **UW**: Small rounded ("oo" sound)
   - **MM**: Lips together ("mm" sound)
   - **SS**: Tight smile (sibilants)
4. **Animation**: The mouth shape smoothly morphs between visemes for natural-looking speech

## Usage

1. Open the project in Godot 4.2 or later
2. Run the project (F5)
3. Click "Start Microphone" button
4. Allow microphone permissions when prompted
5. Speak into your microphone and watch Victor's lips sync to your voice!

## Project Structure

- `main.tscn` / `main.gd` - Main scene with UI controls
- `victor_avatar.tscn` / `victor_avatar.gd` - Victor character with visual components
- `lip_sync_analyzer.gd` - Real-time audio analysis and viseme detection

## Requirements

- Godot 4.2 or later
- Microphone access
- Audio input enabled in project settings

## Technical Details

The lip-sync system uses a simplified approach based on:
- RMS amplitude calculation for volume detection
- Frequency band analysis for sound characterization
- Smooth interpolation between mouth shapes
- Real-time processing with minimal latency

## Future Improvements

Potential enhancements could include:
- More sophisticated phoneme detection using FFT
- Pre-recorded audio playback with lip sync
- 3D character support
- Multiple character expressions
- Machine learning-based viseme prediction
