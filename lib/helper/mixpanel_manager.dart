import 'package:FlipNSort/core/custom_debug_print.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';

class MixpanelManager {
  static Mixpanel? _mixpanel;

  Future<void> init() async {
    _mixpanel = await Mixpanel.init("5640c516755be188fc40083d7e0ec585",
        optOutTrackingDefault: false, trackAutomaticEvents: true);
  }

  setExternalId(String propertyName, String? value) async {
    _mixpanel?.getPeople().set(propertyName, value);
  }

  resetUserInfoBecauseLogout() {
    _mixpanel?.reset();
  }

  sendAnalyticToMixPanel(String eventName, {Map<String, dynamic>? properties}) {
    customDebugPrint(
        "sendAnalyticToMixPanel: $eventName, properties: $properties");
    _mixpanel?.track(eventName, properties: properties);
  }
}
