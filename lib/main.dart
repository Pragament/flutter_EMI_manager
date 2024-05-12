import 'package:emi_calculator/Components/profile_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:emi_calculator/Components/calculator_interface.dart';
import 'package:emi_calculator/controller/language_change_controller.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences sp = await SharedPreferences.getInstance();
  final String languageCode = sp.getString('language_code') ?? 'en';
  runApp(MyApp(
    locale: languageCode,
  ));
}

class MyApp extends StatelessWidget {
  final String? locale;
  const MyApp({super.key, this.locale});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageChangeController())
      ],
      child: Consumer<LanguageChangeController>(
        builder: (context, provider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            locale: locale == ""
                ? const Locale('en')
                : provider.applocale ?? Locale(locale!),
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'), // English
              Locale('hi'), // hindi
              Locale('te') // telegu
            ],
            routes: {
              "/": (context) => const HomePage(),
              "/calculator": (context) => const CalculatorInterface(),
              "/profiles": (context) => const ProfileList()
            },
          );
        },
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late SharedPreferences sp;

  void redirect() async {
    sp = await SharedPreferences.getInstance();
    final bool isSet = sp.getBool('isSet') ?? false;

    if (isSet) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const CalculatorInterface()));
    }
  }

  @override
  void initState() {
    redirect();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: true,
        body: Consumer<LanguageChangeController>(
            builder: (context, provide, child) {
          return Center(
            child:
                Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  "Select a language",
                  style: TextStyle(fontSize: 20),
                ),
              ),
              Container(
                width: double.infinity,
                margin:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 50),
                height: 50,
                child: ElevatedButton(
                    onPressed: () {
                      provide.changeLanguage(const Locale('en'));
                      Navigator.pushNamed(context, "/calculator");
                    },
                    child: const Text(
                      "English",
                      style: TextStyle(fontSize: 18),
                    )),
              ),
              Container(
                width: double.infinity,
                margin:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 50),
                height: 50,
                child: ElevatedButton(
                    onPressed: () {
                      provide.changeLanguage(const Locale('hi'));
                      Navigator.pushNamed(context, "/calculator");
                    },
                    child: const Text(
                      "हिंदी",
                      style: TextStyle(fontSize: 20),
                    )),
              ),
              Container(
                width: double.infinity,
                margin:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 50),
                height: 50,
                child: ElevatedButton(
                    onPressed: () {
                      provide.changeLanguage(const Locale('te'));
                      Navigator.pushNamed(context, "/calculator");
                    },
                    child: const Text(
                      "టెలిగు",
                      style: TextStyle(fontSize: 20),
                    )),
              )
            ]),
          );
        }));
  }
}
