# Matrix Screensaver for Omarchy

[![License: MIT](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Omarchy Plugin](https://img.shields.io/badge/Omarchy-Plugin-blue.svg)](https://plugins.omarchy.org)

A Matrix-themed screensaver/lock screen plugin for [Omarchy](https://github.com/omacom/omarchy) (Wayland compositor) featuring Matrix rain, white rabbit image, typewriter text, and terminal-style password input.

![Matrix Screensaver Demo](assets/matrix-demo.gif)

## Features

- **Matrix Rain Effect** - Animated green characters falling like in The Matrix
- **White Rabbit** - Fades in after the typewriter text
- **Typewriter Text** - "Knock, knock...", "Wake up...", "Follow the white rabbit." with blinking cursor
- **Terminal-style Password Input** - Monospace font with `> ` prompt
- **Multi-monitor Support** - Works with multiple monitors
- **Human-like Typing** - Random variation in typing speed for realism

## Requirements

- [Omarchy](https://github.com/omacom/omarchy) (Quattro or later)
- Quickshell

## Install

```sh
omarchy plugin add https://github.com/01000001kuma/OmarchyMatrixScreensaver.git --enable
```

## Usage

The screensaver activates automatically when you lock the screen:

```sh
omarchy system lock
```

### Interacting with the Screensaver

1. **Matrix rain** appears on screen
2. **Any input** (mouse movement, click, or key press) triggers the animation sequence
3. **Typewriter text** appears with blinking cursor
4. **White rabbit** fades in
5. **Password input** appears - enter your password to unlock

## Configuration

Edit `TypewriterText.qml` to customize the typing effect:

| Property | Default | Description |
|----------|---------|-------------|
| `lines` | `["Knock, knock...", "Wake up...", "Follow the white rabbit."]` | Array of phrases to display |
| `charDelay` | `60` | Base typing speed in milliseconds |
| `humanVariance` | `40` | Random variation in typing speed |
| `linePause` | `1200` | Pause between lines in milliseconds |

## Files

| File | Description |
|------|-------------|
| `Service.qml` | Main service, IPC handler, lock/unlock logic |
| `MatrixLockView.qml` | Main lock view with animation sequence |
| `MatrixRain.qml` | Matrix rain effect |
| `TypewriterText.qml` | Typewriter text effect |
| `MatrixPasswordInput.qml` | Terminal-style password input |
| `assets/WhiteRabbit.png` | White rabbit image |
| `assets/matrix-demo.gif` | Demo animation |

## Uninstall

```sh
omarchy plugin remove akuma.matrix-screensaver
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## Security

This plugin does not handle authentication or security directly. All security mechanisms, including password validation and session management, are handled by [Omarchy](https://github.com/omacom/omarchy) and the underlying Wayland compositor. This plugin only provides a visual interface for the lock screen.

## Support

- **Issues**: [GitHub Issues](https://github.com/01000001kuma/OmarchyMatrixScreensaver/issues)
- **Omarchy**: [Documentation](https://github.com/omacom/omarchy/blob/quattro/README.md)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- Inspired by [The Matrix](https://www.imdb.com/title/tt0133093/) (1999)
- Built for [Omarchy](https://github.com/omacom/omarchy) community
- I hope you like it
