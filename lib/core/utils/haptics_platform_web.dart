import 'dart:js_interop';

@JS('navigator.vibrate')
external JSBoolean? _vibrate(JSNumber milliseconds);

void vibratePlatform(int milliseconds) {
  try {
    _vibrate(milliseconds.toJS);
  } catch (_) {
    // Browsers without the Vibration API, including desktop Safari, ignore this.
  }
}
