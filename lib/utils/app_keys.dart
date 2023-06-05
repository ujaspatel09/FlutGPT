import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// CHAT GPT ID
String openAiToken = "OPEN YOUR OPEN AI KEY";

/// GOOGLE ADS ID (ANDROID)
String bannerAndroidID = "ca-app-pub-3940256099942544/6300978111";
String appOpenAndroidId =  "ca-app-pub-3940256099942544/3419835294";
String interstitialAndroidId = "ca-app-pub-3940256099942544/1033173712";

/// GOOGLE ADS ID (IOS)
String bannerIOSID = "ca-app-pub-3940256099942544/2934735716";
String appOpenIosId =  "ca-app-pub-3940256099942544/3419835294";
String interstitialIosId = "ca-app-pub-3940256099942544/4411468910";

/// GOOGLE ADS SHOW/DISABLE
bool showAds = false;

/// SHOW IMAGE
bool showImage = true;

/// show dark mode
bool showDarkMode = true;

/// voice is off
bool voiceIsOff = false;

// /// PREMIUM SHOW/DISABLE
// bool isPremium = false;

/// Max Token Limit is 4096
int token = 500;

///  DARK MODE SHOW (TRUE/FALSE)
bool isDarkMode = true;
bool isLightMode = true;

/// MESSAGE LIMIT
int maxMessageLimit = 5;

/// SHOW GENERATE IMAGE
bool showImageGeneration = true;


/// ONBOARDING SCREEN 1 TEXT
String Onboarding_Title1 = '''Your AI Assistance''';
String Onboarding_Description1 = '''Using This App, You can Ask Your questions and recieve articles using artificial assistance''';

/// ONBOARDING SCREEN 2 TEXT
String Onboarding_Title2 = '''Your AI Assistance''';
String Onboarding_Description2= '''Using This App, You can Ask Your questions and recieve articles using artificial assistance''';


/// ONBOARDING SCREEN 3 TEXT
String Onboarding_Title3 = '''Your AI Assistance''';
String Onboarding_Description3 = '''Using This App, You can Ask Your questions and recieve articles using artificial assistance''';


/// IMAGE GENERTATE LIMIT
int imageGenerateLimit = 3;

/// IN APP PURCHASE ID(ANDROID)
const String monthPlanAndroid = 'android.test.purchased'; /// ENTER YOUR ONE MONTH PLAN ID
const String weekPlanAndroid = 'android.test.purchased'; /// ENTER YOUR ONE WEEK  PLAN ID
const String yearPlanAndroid = 'android.test.purchased'; /// ENTER YOUR ONE YEAR PLAN ID

/// IN APP PURCHASE ID(IOS)
const String monthPlanIOS = 'storeKeySubscription'; /// ENTER YOUR ONE MONTH PLAN ID
const String weekPlanIOS = 'storeKeySubscription'; /// ENTER YOUR ONE  WEEK PLAN ID
const String yearPlanIOS = 'storeKeySubscription'; /// ENTER YOUR ONE YEAR PLAN ID

///  TERMS PRIVACY LINK
const String termsLink = 'ENTER YOUR TERMS AND CONDITIONS LINK HERE';
const String privacyLink = 'ENTER YOUR PRIVACY POLICY LINK HERE';

/// SHARE APP LINK FOR ANDROID
const String shareAppLinkAndroid = "SHARE APP LINK ANDROID";

/// SHARE APP LINK FOR  IOS
const String shareAppLinkIOSid = "SHARE APP LINK IOS";


/// IN APP PURCHASE PRICES :-
double perMonthPrice = 30; /// PER MONTH
double perWeekPrice = 10; /// PER WEEK
double perYearPrice = 149; /// PER YEAR



/// CURRENCY NAME
const String inAppCurrency = "\$";

Widget appBarTitle(BuildContext context){
  return Row(
    crossAxisAlignment: CrossAxisAlignment.center,
    mainAxisAlignment: MainAxisAlignment.start,
    children:  [
      Text("Flut",style: TextStyle(color: context.textTheme.headline1!.color,fontSize: 30,fontWeight: FontWeight.w700),),
      const Text("GPT",style: TextStyle(color: Color(0xff62A193),fontSize: 35,fontWeight: FontWeight.w700),),
    ],
  );
}
