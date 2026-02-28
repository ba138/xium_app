import 'package:get/get.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
    'en_US': {
      'rewards': 'Rewards',
      'quick_actions': 'Quick Actions',
      'missions': 'Missions',
      'invite_friend': 'Invite a friend',
    },
    'fr_FR': {
      'rewards': 'Récompenses',
      'quick_actions': 'Actions Rapides',
      'missions': 'Missions',
      'invite_friend': 'Inviter un ami',
    },
  };
}
