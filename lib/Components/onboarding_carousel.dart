import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';

class OnboardingScreen extends StatelessWidget {
  final List<PageViewModel> pages = [
    PageViewModel(
      title: 'welcome'.tr(),
      body: 'multiple_languages_support'.tr(),
      image: const Center(child: Icon(Icons.language, size: 175.0)),
    ),
    PageViewModel(
      title: 'emi_calculator'.tr(),
      body: 'preview_emi'.tr(),
      image: const Center(child: Icon(Icons.calculate, size: 175.0)),
    ),
    PageViewModel(
      title: 'profile_management'.tr(),
      body: 'save_and_view_profiles'.tr(),
      image: const Center(child: Icon(Icons.account_box, size: 175.0)),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ),
      body: IntroductionScreen(
        pages: pages,
        onDone: () async {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('onboarding_complete', true);
          Navigator.of(context).pushReplacementNamed('/calculator');
        },
        showSkipButton: true,
        skip: Text('skip'.tr()),
        next: const Icon(Icons.arrow_forward),
        done: Text('done'.tr(), style: const TextStyle(fontWeight: FontWeight.w600)),
      ),
    );
  }
}
