// import 'package:get/get.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../../google_ads_controller.dart';
//
// String premiumDate = "";
// // bool isPremium = true;
//
// class PremiumScreenController extends GetxController{
//   RxInt selectedI = 1.obs;
//
//
//   onChangeIndex(int index){
//     selectedI.value = index;
//     update();
//   }
//
//   storeDate(String dateTime) async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     await prefs.setString('Premium_Date', dateTime);
//     update();
//   }
//
//   bool isPremium  =  false;
//
//         getDate() async {
//     SharedPreferences prefs = await SharedPreferences.getInstance();
//     premiumDate = prefs.getString('Premium_Date') ?? "";
//     DateTime fin = DateTime.parse(premiumDate);
//     DateTime date =  DateTime.now();
//     DateTime time = DateTime(date.year, date.month, date.day);
//     if(premiumDate != ""){
//       if(time.compareTo(fin) < 0){
//         isPremium = true;
//         update();
//       }else{
//         isPremium = false;
//         update();
//       }
//     }else{
//       print("non premium");
//     }
//     print("Is Premium ----> $isPremium");
//     final googleAdsController = isPremium == true ? "" :  Get.put(GoogleAdsController());
//   }
//
//   @override
//   void onInit() {
//     getDate();
//     // TODO: implement onInit
//     super.onInit();
//   }
//
//
//
//
//
//
//
// }