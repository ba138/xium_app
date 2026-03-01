import 'package:get/get.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'en_US': {
      'rewards': 'Rewards',
      "Welcome back": "Welcome back, Bas!",
      'quick_actions': 'Quick Actions',
      'missions': 'Missions',
      'invite_friend': 'Invite a friend',
      "Here's your financial snapshot": "Here's your financial snapshot",
      "Overview": "Overview",
    },
    'fr_FR': {
      'rewards': 'Récompenses',
      "Welcome back": "Bon retour, Bas!",
      'quick_actions': 'Actions Rapides',
      'missions': 'Missions',
      'invite_friend': 'Inviter un ami',
      "Here's your financial snapshot": "Voici votre aperçu financier",
      "Overview": "Aperçu",
    },
  };
}
