import 'package:flutter/material.dart';

class HomeTokens {
  /// Shared corner radius for all home chrome (composer, tabs, chips, actions).
  static const radius = 6.0;

  // Aliases kept so call sites stay readable by role.
  static const radiusPill = radius;
  static const radiusComposer = radius;
  static const radiusTabBar = radius;
  static const radiusTabActive = radius;
  static const radiusControl = radius;

  static const hitTarget = 44.0;
  static const composerActionSize = 34.0;
  static const composerMinHeight = 128.0;
  static const composerMinLines = 3;
  static const composerMaxLines = 6;

  static const durationPress = Duration(milliseconds: 160);
  static const durationRelease = Duration(milliseconds: 120);
  static const durationTab = Duration(milliseconds: 200);
  static const durationUi = Duration(milliseconds: 220);

  static const easeOut = Cubic(0.23, 1, 0.32, 1);
  static const easeInOut = Cubic(0.77, 0, 0.175, 1);

  static const pressScale = 0.97;

  static const greeting = 'Hi! How can I help you?';
  static const encryptionLine1 = 'Chats are end-to-end encrypted.';
  static const encryptionLine2 = 'Your data is safe.';
  static const composerHint = 'Ask anything... @files, \$skills, /commands';
  static const modelTitle = 'Google: Gemma 4 26B A4B';
  static const speedTitle = 'Max';
  static const contextLabel = '0';

  static const stubChatTitles = <String>[
    'Draft: onboarding copy',
    'Refactor home shell',
    'Weekend ideas',
  ];

  static const stubModelTitles = <String>[
    modelTitle,
    'Google: Gemma 4 9B',
    'OpenCore: Local 7B',
  ];

  static const stubSpeedTitles = <String>[
    'Fast',
    'Balanced',
    'Max',
  ];

  static const snackbarNewChat = 'New chat';
  static const snackbarVoiceSoon = 'Voice input coming soon';
  static const snackbarContext = 'Context: 0 tokens';
  static String snackbarAttachment(String choice) => 'Added $choice';

  static const orbTint = Color(0xFF141414);
  static const orbAccent = Color(0xFF2B2B2B);
}
