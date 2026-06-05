import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The fixed meaning/UI ("gloss") language for now. A user-facing UI-language
/// axis is intentionally deferred.
const String glossLanguage = 'en';

/// The language currently being taught. A future settings screen can change it;
/// this provider is the seam that makes vocabulary language-agnostic.
final learningLanguageProvider = StateProvider<String>((ref) => 'mn');
