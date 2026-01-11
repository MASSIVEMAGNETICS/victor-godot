# Victor Avatar Architecture

## System Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│                          Main Application                            │
│                         (main.tscn/main.gd)                          │
│                                                                       │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐              │
│  │  Start Btn   │  │   Stop Btn   │  │ Status Label │              │
│  └──────────────┘  └──────────────┘  └──────────────┘              │
│                                                                       │
│  ┌─────────────────────────────────────────────────────────┐       │
│  │         Audio Setup (AudioStreamMicrophone)             │       │
│  │              AudioEffectCapture on Record Bus           │       │
│  └─────────────────────────────────────────────────────────┘       │
└───────────────────────────────┬─────────────────────────────────────┘
                                │
                                │ Contains Instance
                                ▼
┌─────────────────────────────────────────────────────────────────────┐
│                        Victor Avatar                                 │
│                   (victor_avatar.tscn/.gd)                          │
│                                                                       │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │                Visual Components (2D Polygons)               │  │
│  │  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │  │
│  │  │   Head   │  │  Mouth   │  │ Left Eye │  │Right Eye │   │  │
│  │  └──────────┘  └──────────┘  └──────────┘  └──────────┘   │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                                                                       │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │              Animation System                                │  │
│  │  • Mouth shape morphing (lerp between visemes)              │  │
│  │  • Blink animation timer                                     │  │
│  │  • Smooth transitions                                        │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                                                                       │
│                              │                                        │
│                              │ Contains Child Node                   │
│                              ▼                                        │
│  ┌──────────────────────────────────────────────────────────────┐  │
│  │                  Lip Sync Analyzer                           │  │
│  │               (lip_sync_analyzer.gd)                         │  │
│  │                                                               │  │
│  │  ┌────────────────────────────────────────────────────────┐ │  │
│  │  │         Audio Capture & Processing                     │ │  │
│  │  │  • Get frames from AudioEffectCapture                  │ │  │
│  │  │  • Convert stereo to mono                              │ │  │
│  │  │  • Calculate RMS amplitude                             │ │  │
│  │  │  • Analyze frequency distribution                      │ │  │
│  │  └────────────────────────────────────────────────────────┘ │  │
│  │                                                               │  │
│  │  ┌────────────────────────────────────────────────────────┐ │  │
│  │  │         Viseme Detection Logic                         │ │  │
│  │  │  • Map amplitude → mouth open amount                   │ │  │
│  │  │  • Map frequency bands → specific visemes              │ │  │
│  │  │  • Emit viseme_changed signal                          │ │  │
│  │  └────────────────────────────────────────────────────────┘ │  │
│  └──────────────────────────────────────────────────────────────┘  │
│                          │                                            │
│                          │ Signal: viseme_changed                    │
│                          ▼                                            │
│               Update target_mouth_shape                              │
└─────────────────────────────────────────────────────────────────────┘
```

## Data Flow

```
1. User Input
   ↓
┌─────────────────────┐
│   Microphone        │
│   Audio Input       │
└─────────────────────┘
   ↓
┌─────────────────────┐
│ AudioStreamMicrophone│
│ (plays to Record bus)│
└─────────────────────┘
   ↓
┌─────────────────────┐
│ AudioEffectCapture  │
│ (buffers audio data)│
└─────────────────────┘
   ↓
┌─────────────────────┐
│ LipSyncAnalyzer     │
│ _process() loop     │
│ - get_buffer()      │
│ - analyze_audio()   │
└─────────────────────┘
   ↓
┌─────────────────────┐
│ Audio Analysis      │
│ - RMS amplitude     │
│ - Frequency bands   │
└─────────────────────┘
   ↓
┌─────────────────────┐
│ Viseme Detection    │
│ determine_viseme()  │
└─────────────────────┘
   ↓
┌─────────────────────┐
│ Signal Emission     │
│ viseme_changed()    │
└─────────────────────┘
   ↓
┌─────────────────────┐
│ VictorAvatar        │
│ _on_viseme_changed()│
│ - Set target shape  │
└─────────────────────┘
   ↓
┌─────────────────────┐
│ Animation Loop      │
│ _process() loop     │
│ - Lerp mouth shape  │
│ - Update polygon    │
└─────────────────────┘
   ↓
┌─────────────────────┐
│ Visual Output       │
│ Victor's animated   │
│ mouth on screen     │
└─────────────────────┘
```

## Viseme State Machine

```
              Audio Input
                  │
                  ▼
        ┌─────────────────┐
        │  Analyze Audio  │
        │  • Amplitude    │
        │  • Frequency    │
        └─────────────────┘
                  │
                  ▼
        ┌─────────────────────────────┐
        │    Amplitude Check          │
        │  Is > threshold?            │
        └─────────────────────────────┘
           │                      │
           │ No                   │ Yes
           ▼                      ▼
      ┌─────────┐    ┌──────────────────────────┐
      │ SILENT  │    │  Frequency Analysis      │
      │ (mouth  │    │  • High freq → SS        │
      │ closed) │    │  • Mid freq → EE/OH      │
      └─────────┘    │  • Low freq → AA         │
                     │  • Low amp → MM          │
                     └──────────────────────────┘
                                │
                                ▼
                     ┌─────────────────────────┐
                     │  Select Viseme:         │
                     │  • AA (ah - wide open)  │
                     │  • EE (ee - smile)      │
                     │  • OH (oh - round)      │
                     │  • UW (oo - small)      │
                     │  • MM (mm - closed)     │
                     │  • FF (ff - teeth)      │
                     │  • TH (th - tongue)     │
                     │  • SS (ss - tight)      │
                     └─────────────────────────┘
                                │
                                ▼
                     ┌─────────────────────────┐
                     │  Emit Signal            │
                     │  viseme_changed()       │
                     └─────────────────────────┘
                                │
                                ▼
                     ┌─────────────────────────┐
                     │  Smooth Animation       │
                     │  (lerp to target)       │
                     └─────────────────────────┘
```

## Component Responsibilities

### Main Scene (`main.gd`)
**Purpose**: User interface and audio setup
- Create AudioStreamMicrophone for recording
- Setup AudioEffectCapture on Record bus
- Handle start/stop button events
- Display status and current viseme
- Show FPS and instructions

### Victor Avatar (`victor_avatar.gd`)
**Purpose**: Visual character representation and animation
- Create visual components (head, eyes, mouth)
- Define mouth shapes for each viseme
- Animate smooth transitions between shapes
- Handle automatic blinking
- Respond to viseme_changed signals

### Lip Sync Analyzer (`lip_sync_analyzer.gd`)
**Purpose**: Audio analysis and viseme detection
- Access AudioEffectCapture buffer
- Calculate audio amplitude (RMS)
- Analyze frequency distribution
- Map audio characteristics to visemes
- Emit signals when viseme changes

## Performance Characteristics

| Component | Frequency | Cost |
|-----------|-----------|------|
| Audio Capture | Every frame | Low (built-in) |
| Audio Analysis | Every frame | Medium (math) |
| Viseme Detection | Every frame | Low (conditionals) |
| Animation Update | Every frame | Low (lerp) |
| Visual Rendering | Every frame | Low (2D polygons) |

**Overall**: Designed for real-time 60 FPS performance

## Extension Points

1. **Better Frequency Analysis**: Replace simple grouping with FFT via AudioEffectSpectrumAnalyzer
2. **Machine Learning**: Train model to recognize phonemes from mel spectrograms
3. **3D Support**: Use blend shapes instead of 2D polygons
4. **Timeline Sync**: Add support for pre-recorded audio with timing metadata
5. **Multiple Characters**: Extend to support multiple speakers
6. **Emotion System**: Add facial expressions beyond lip sync
