// import 'dart:async';
// import 'dart:io';
//
// import 'package:chat_gpt/screens/home_pages/home_screen.dart';
// import 'package:chat_gpt/screens/premium_pages/premium_screen_controller.dart';
// import 'package:chat_gpt/utils/extension.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:in_app_purchase/in_app_purchase.dart';
// import '../../constant/app_icon.dart';
// import '../../modals/premium_modal.dart';
// import '../../utils/app_keys.dart';
// import '../../utils/iap_services.dart';
//
//
// class PremiumScreen extends StatefulWidget {
//   const PremiumScreen({Key? key}) : super(key: key);
//
//   @override
//   State<PremiumScreen> createState() => _PremiumScreenState();
// }
//
// class _PremiumScreenState extends State<PremiumScreen> {
//
//   final premiumController = Get.put(PremiumScreenController());
//   List<ProductDetails> _products = [];
//   List<PremiumModal> premiumList = [
//     PremiumModal(month: '1', price: '$inAppCurrency $perMonthPrice/', monthType: 'month'.tr, perMonth: '$inAppCurrency $perMonthPrice', priceWeek: 'perWeek'.tr, offer: 'offer1'.tr),
//     PremiumModal(month: '1', price: '$inAppCurrency $perWeekPrice/', monthType: 'week'.tr, perMonth: '$inAppCurrency $perWeekPrice', priceWeek: 'perWeek'.tr, offer: 'offer2'.tr),
//     PremiumModal(month: '1', price: '$inAppCurrency $perYearPrice/', monthType: 'year'.tr, perMonth: '$inAppCurrency $perYearPrice', priceWeek: 'perWeek'.tr, offer: 'offer3'.tr),
//   ];
//
//
//   bool isAvailable = false;
//   List<String> noFoundId = [];
//   String? uid;
//   late StreamSubscription<List<PurchaseDetails>> _subscription;
//   List<ProductDetails> productsList = [
//     ProductDetails(id: '1', title: 'title1', description: 'description1', price: '$perMonthPrice', rawPrice: perMonthPrice, currencyCode: inAppCurrency,currencySymbol: inAppCurrency),
//     ProductDetails(id: '2', title: 'title2', description: 'description2', price: '$perWeekPrice', rawPrice: perWeekPrice, currencyCode: inAppCurrency,currencySymbol: inAppCurrency),
//     ProductDetails(id: '3', title: 'title3', description: 'description3', price: '$perYearPrice', rawPrice: perYearPrice, currencyCode: inAppCurrency,currencySymbol: inAppCurrency),
//   ];
//   List<String> perWeekList = [];
//   int selectedIndex = 1;
//   @override
//   void initState() {
//     initStore();
//     _subscription = InAppPurchase.instance.purchaseStream.listen((List<PurchaseDetails> purchaseDetailsList) {
//       IapService().listenToPurchaseUpdated(purchaseDetailsList: purchaseDetailsList);
//       },
//         onDone: () {
//            _subscription.cancel();
//       },
//         onError: (Object error) {});
//
//     print('productsList -----> ${productsList.length}');
//     super.initState();
//   }
//
//   Future<void> initStore() async {
//     final bool isAvailable = await InAppPurchase.instance.isAvailable();
//     if (isAvailable) {
//       await loadProducts();
//     }
//   }
//
//   Future<void> loadProducts() async {
//
//     Set<String> ids =
//     Platform.isAndroid
//     //     ?
//     // { weekPlanAndroid , monthPlanAndroid ,yearPlanAndroid,tenAndroidImage,twoAndroidImage}
//     //     :
//     // premiumController.isPremium == true
//         ?
//     {monthPlanAndroid, weekPlanAndroid, yearPlanAndroid }
//         :
//     {monthPlanIOS, weekPlanIOS, yearPlanIOS };
//     final ProductDetailsResponse response = await InAppPurchase.instance.queryProductDetails(ids);
//     if (response.notFoundIDs.isNotEmpty) {
//       // Handle the error
//
//     }
//     if (mounted) {
//       setState(() {
//         _products = response.productDetails;
//       });
//     }
//   }
//
//   initialStore() async {
//     // productsList = await IapService().initStoreInfo( id: Platform.isAndroid ? androidList :  iosList);
//     productsList = await IapService().initStoreInfo(id: Platform.isAndroid ? androidList :  iosList,isAvailable: true);
//     setState(() {});
//   }
//
//   final InAppPurchase _connection = InAppPurchase.instance;
//
//
//   Future<void> _buyProduct(String id) async {
//
//     DateTime date =  DateTime.now();
//     DateTime yearLater = DateTime(date.year + 1, date.month, date.day);
//     DateTime monthLater = DateTime(date.year, date.month + 1, date.day);
//     DateTime weekLater = DateTime(date.year, date.month, date.day + 7);
//
//     final PurchaseParam purchaseParam = PurchaseParam(productDetails: _products.firstWhere((product) => product.id == id));
//     await InAppPurchase.instance.buyNonConsumable(purchaseParam: purchaseParam);
//     PurchaseDetails? purchaseDetails;
//     if (purchaseDetails!.status == PurchaseStatus.purchased) {
//
//       await premiumController.storeDate(yearLater.toString());
//       if(premiumController.selectedI.value == 0){
//         premiumController.storeDate(monthLater.toString());
//       }
//       if(premiumController.selectedI.value == 1){
//         premiumController.storeDate(weekLater.toString());
//         // Get.offAll(const SplashScreen());
//       }
//
//       // Get.offAll(const SplashScreen());
//
//       if(premiumController.selectedI.value == 2){
//         premiumController.storeDate(yearLater.toString());
//         // Get.offAll(const SplashScreen());
//       }
//     }
//
//
//    else {
//     // Purchase failed
//
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return WillPopScope(
//       onWillPop: () async {
//         Get.offAll(const HomeScreen());
//         return true;
//       },
//       child: Scaffold(
//         backgroundColor: context.theme.backgroundColor,
//         appBar: AppBar(
//             elevation: 0,
//             backgroundColor: context.theme.backgroundColor,
//             // titleSpacing: 40,
//             leading: IconButton(
//               onPressed: () {
//               Get.offAll(const HomeScreen());
//             }, icon:  Icon(
//                 Icons.close,
//               color: context.textTheme.headline1!.color
//             ),),
//             centerTitle: true,
//             title: appBarTitle(context).marginOnly(left: 40),
//             actions: [
//               CupertinoButton(
//                 onPressed: () async {
//                   await InAppPurchase.instance.restorePurchases();
//                   setState(() {});
//                 },
//                 child: Text("restore".tr,style: const TextStyle(fontSize: 12)),)
//             ]
//         ),
//
//         body: SingleChildScrollView(
//           child: Column(
//             children: [
//               10.0.addHSpace(),
//
//               Container(
//                 padding: const EdgeInsets.symmetric(vertical: 10),
//                 decoration: BoxDecoration(
//                     color:  context.theme.primaryColor,
//                     borderRadius: BorderRadius.circular(7)
//                 ),
//                 child: Column(
//                   children: [
//                     10.0.addHSpace(),
//                     Text("premiumAdvanced".tr, style: const TextStyle(color: Colors.white),),
//                     5.0.addHSpace(),
//                     const Divider(color: Color(0xff2F2F2F),),
//                     5.0.addHSpace(),
//                     advancedListTile(context, title: "premiumSub1".tr),
//
//                     10.0.addHSpace(),
//                     advancedListTile(context, title: 'premiumSub2'.tr),
//
//
//                     10.0.addHSpace(),
//                     advancedListTile(context, title: 'premiumSub3'.tr),
//
//                     10.0.addHSpace(),
//                     advancedListTile(context, title: 'premiumSub4'.tr),
//
//                     10.0.addHSpace(),
//                     advancedListTile(context, title: 'premiumSub5'.tr),
//
//                     10.0.addHSpace(),
//                   ],
//                 ).marginSymmetric(horizontal: 20),
//               ).marginSymmetric(horizontal: 20),
//               30.0.addHSpace(),
//
//               Obx(() {
//                 return Row(
//                   crossAxisAlignment: CrossAxisAlignment.end,
//                   children: List.generate(
//                       premiumList.length, (index){
//
//                         if(index == 0){
//                           double price = perMonthPrice / 4;
//                           perWeekList.add(price.toString());
//                         }
//                         if(index == 1){
//                           perWeekList.add(perWeekPrice.toString());
//                         }
//                         if(index == 2){
//                           double price = perYearPrice / 52;
//                           perWeekList.add(price.toString());
//                         }
//                         perWeekList.forEach((element) {
//                           print('--------> $element');
//                         });
//                         return Expanded(
//                           child: GestureDetector(
//                               onTap: () {
//                                 premiumController.onChangeIndex(index);
//                               },
//                               child: premiumController.selectedI.value == index
//                                   ?
//                               Container(
//                                 height: 275,
//                                 decoration: BoxDecoration(
//                                     color: const Color(0xff4EA37E),
//                                     borderRadius: BorderRadius.circular(12)
//                                 ),
//                                 child: Column(
//                                   children: [
//                                     5.0.addHSpace(),
//                                     Text(premiumList[index].offer,style: const TextStyle(color: Colors.white,fontSize: 15,fontWeight: FontWeight.w700),).marginOnly(top: 5),
//                                     10.0.addHSpace(),
//                                     Container(
//                                       height: 220,
//                                       width: double.infinity,
//                                       decoration: BoxDecoration(color: const Color(0xff1A2620),borderRadius: BorderRadius.circular(12)),
//                                       child: Column(
//                                         crossAxisAlignment: CrossAxisAlignment.center,
//                                         children: [
//                                           15.0.addHSpace(),
//                                           Text(premiumList[index].month,style: const TextStyle(color: Colors.white,fontWeight: FontWeight.w700,fontSize: 25),),
//                                           10.0.addHSpace(),
//                                           Text(premiumList[index].monthType,style: const TextStyle(color: Colors.white,fontWeight: FontWeight.w700,fontSize: 25),),
//                                           20.0.addHSpace(),
//                                           Row(
//                                             mainAxisAlignment: MainAxisAlignment.center,
//                                             children: [
//
//                                               Text(premiumList[index].price,style: const TextStyle(color: Color(0xff787C7A),fontWeight: FontWeight.w500,fontSize: 12),),
//                                               Text(premiumList[index].monthType,style: const TextStyle(color: Color(0xff787C7A),fontWeight: FontWeight.w500,fontSize: 12),),
//                                             ],
//                                           ),
//                                           10.0.addHSpace(),
//                                           const Divider(color: Color(0xff4EA37E),thickness: 2,),
//                                           10.0.addHSpace(),
//                                           Text('$inAppCurrency ${perWeekList[index].length > 4 ? '${perWeekList[index].substring(0, 4)}' : perWeekList[index]}',style: const TextStyle(color: Colors.white,fontWeight: FontWeight.w700,fontSize: 17),maxLines: 10,),
//                                           Text(premiumList[index].priceWeek,style: const TextStyle(color: Colors.white,fontWeight: FontWeight.w700,fontSize: 17),),
//                                         ],
//                                       ),
//                                     ).marginOnly(left: 2,right: 2)
//                                   ],
//                                 ),
//                               ).marginOnly(left: 5,right: 5)
//                                   :
//                               Container(
//                                 height: 220,
//                                 width: double.infinity,
//                                 decoration: BoxDecoration(color:  context.theme.primaryColor,borderRadius: BorderRadius.circular(12),border: Border.all(color: const Color(0xff787C7A),width: 2)),
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.center,
//                                   children: [
//                                     15.0.addHSpace(),
//                                     Text(premiumList[index].month,style: const TextStyle(color: Colors.white,fontWeight: FontWeight.w700,fontSize: 25),),
//                                     10.0.addHSpace(),
//                                     Text(premiumList[index].monthType,style: const TextStyle(color: Colors.white,fontWeight: FontWeight.w700,fontSize: 25),),
//                                     20.0.addHSpace(),
//                                     Row(
//                                       mainAxisAlignment: MainAxisAlignment.center,
//                                       children: [
//                                         Text(premiumList[index].price,style: const TextStyle(color: Color(0xff787C7A),fontWeight: FontWeight.w500,fontSize: 12),),
//                                         Text(premiumList[index].monthType,style: const TextStyle(color: Color(0xff787C7A),fontWeight: FontWeight.w500,fontSize: 12),),
//                                       ],
//                                     ),
//                                     10.0.addHSpace(),
//                                     const Divider(color: Color(0xff787C7A),thickness: 2,),
//                                     10.0.addHSpace(),
//                                     Text('$inAppCurrency ${perWeekList[index].length > 4 ? '${perWeekList[index].substring(0, 4)}' : perWeekList[index]}',style: const TextStyle(color: Colors.white,fontWeight: FontWeight.w700,fontSize: 17),),
//                                     Text(premiumList[index].priceWeek,style: const TextStyle(color: Colors.white,fontWeight: FontWeight.w700,fontSize: 17),),
//                                   ],
//                                 ),
//                               ).marginOnly(left: 5,right: 5)
//                           ),
//                         );
//                   }),
//                 );
//               }),
//               20.0.addHSpace(),
//
//               SizedBox(
//                 width: double.infinity,
//                 child: CupertinoButton(
//                   onPressed: () async {
//
//                     if(premiumController.selectedI.value == 0 ){
//                       _buyProduct(
//                           Platform.isAndroid ? monthPlanAndroid : monthPlanIOS
//                       );
//                     }
//
//                     if(premiumController.selectedI.value == 1 ){
//                       _buyProduct(
//                           Platform.isAndroid ? weekPlanAndroid : weekPlanIOS
//                       );
//                     }
//
//
//                     if(premiumController.selectedI.value == 2 ){
//                       _buyProduct(
//                           Platform.isAndroid ? yearPlanAndroid : yearPlanIOS
//                       );
//                     }
//
//
//
//
//
//                     // PurchaseParam purchaseParam;
//                     // var purchaseDetails;
//                     // purchaseParam = PurchaseParam(productDetails: productsList[premiumController.selectedI.value == 2 ? premiumController.selectedI.value - 2 : premiumController.selectedI.value], applicationUserName: "Chat GPT");
//                     // await InAppPurchase.instance.buyConsumable(purchaseParam: purchaseParam);
//                     // DateTime date =  DateTime.now();
//                     // DateTime yearLater = DateTime(date.year + 1, date.month, date.day);
//                     // DateTime monthLater = DateTime(date.year, date.month + 1, date.day);
//                     // DateTime weekLater = DateTime(date.year, date.month, date.day + 7);
//                     // premiumController.storeDate(yearLater.toString());
//                     // if (purchaseDetails.status == PurchaseStatus.purchased) {
//                     //   if(premiumController.selectedI.value == 0){
//                     //     premiumController.storeDate(monthLater.toString());
//                     //     Get.offAll(const SplashScreen());
//                     //   }
//                     //   if(premiumController.selectedI.value == 1){
//                     //     premiumController.storeDate(weekLater.toString());
//                     //     Get.offAll(const SplashScreen());
//                     //   }
//                     //   if(premiumController.selectedI.value == 2){
//                     //     premiumController.storeDate(yearLater.toString());
//                     //     Get.offAll(const SplashScreen());
//                     //   }
//                     //   Get.offAll(const SplashScreen());
//                     // }
//                   },
//                   color: const Color(0xff51A982),
//                   borderRadius: BorderRadius.circular(5),
//                   child: Text("startTrail".tr),
//                 ),
//               ).marginOnly(left: 20,right: 20),
//               20.0.addHSpace(),
//             ],
//           ),
//
//         ),
//       ),
//     );
//   }
//
//   Widget advancedListTile(BuildContext context, {required String title}) {
//     return Row(
//       children:[
//         AppIcon.checkBoxIcon(),
//         10.0.addWSpace(),
//         Expanded(
//           child: Text(title, style: const TextStyle(
//               color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700),),
//         )
//       ],
//     );
//   }
//
// }
