// ignore_for_file: unrelated_type_equality_checks, use_build_context_synchronously
import 'package:chat_gpt/utils/app_keys.dart';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:flutter/services.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:chat_gpt/constant/app_assets.dart';
import 'package:chat_gpt/utils/extension.dart';
// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constant/app_color.dart';
import '../../constant/app_icon.dart';
import '../../modals/message_model.dart';
import '../../utils/shared_prefs_utils.dart';
import '../../widgets/app_textfield.dart';
import '../home_pages/home_screen.dart';
import '../home_pages/home_screen_controller.dart';
import '../premium_pages/premium_screen_controller.dart';
import '../setting_pages/setting_page_controller.dart';
import 'chat_controller.dart';
import 'dart:io';
import 'package:flutter_tts/flutter_tts.dart';


class ChatScreen extends StatefulWidget {
  String message;
  ChatScreen({Key? key,required this.message}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  ScreenshotController screenshotController = ScreenshotController();
  HomeScreenController homeScreenController = HomeScreenController();
   // int messageLimit = maxMessageLimit;




  storeVoice(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('voice', value);
    isVoiceOn = prefs.getBool('voice') ?? voiceIsOff;
    setState(() {});
  }




  @override
  void initState() {


    addMessageToMessageList(widget.message,true);
    sendMessageToAPI(widget.message);
    // TODO: implement initState
    super.initState();
  }

  final FlutterTts flutterTts = FlutterTts();


  ChatController chatController = Get.put(ChatController());
  TextEditingController messageController = TextEditingController();
  List<MessageModel> messageList = [];
  bool inProgress = true;

  //initialize openai
  final openAI = OpenAI.instance.build(
        token: openAiToken,
        baseOption: HttpSetup(receiveTimeout: const Duration(seconds: 12),
        connectTimeout: const Duration(seconds: 12),
        sendTimeout: const Duration(seconds: 12),
      ),
      isLog: true,
  );

  _speak(String value) async{
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1);
    await flutterTts.speak(value);
  }


  @override
  void dispose() {
    messageController.dispose();
    flutterTts.stop();
    super.dispose();
  }
  GlobalKey globalKey = GlobalKey();

  @override
  Widget build(BuildContext context) {

    final BannerAd myBanner = BannerAd(
      adUnitId: Platform.isAndroid ? bannerAndroidID : bannerIOSID,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: const BannerAdListener(),
    );
    myBanner.load();
    final AdWidget adWidget = AdWidget(ad: myBanner);
    final Container adContainer = Container(
      alignment: Alignment.center,
      width: myBanner.size.width.toDouble(),
      height: myBanner.size.height.toDouble(),
      child: adWidget, // myBanner.size.height.toDouble(),
    );

    return WillPopScope(
      onWillPop: () async {
        Get.offAll(const HomeScreen(), transition: Transition.rightToLeft);
        return true;
      },
      child: GestureDetector(
        onTap: (){
          hideKeyboard(context);
        },
        child: Screenshot(
          controller: screenshotController,
          child: Scaffold(
            backgroundColor: context.theme.backgroundColor,
            appBar: AppBar(
              centerTitle: true,
              title: appBarTitle(context),
              backgroundColor: context.theme.backgroundColor,
              elevation: 0,
              actions: [

              GestureDetector(
                  onTap: (){
                    showModalBottomSheet(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        backgroundColor: Colors.white,
                      context: context, builder: (BuildContext context) {
                          return Container(
                            height: 170,
                            color: Colors.white,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                15.0.addHSpace(),
                                AppIcon.infoIcon(),
                                20.0.addHSpace(),
                                Text("Messages function as the credit system for Message. One request to Message deducts one message from your balance. You will be granted $maxMessageLimit wishes daily",style: TextStyle(color: Colors.black,fontWeight: FontWeight.w500,fontSize: 15),).marginSymmetric(horizontal: 12),
                                // Text("",style: TextStyle(color: Colors.black,fontWeight: FontWeight.w500,fontSize: 15),),
                                // Text("Messages function as the credit system for Message.",style: TextStyle(color: Colors.black,fontWeight: FontWeight.w500,fontSize: 15),),
                              ],
                            ),
                          );
                    },

                    );
                  },
                  child: Container(
                    height: 30,
                    width: 50,
                    // decoration: BoxDecoration(color: AppColor.greenColor,borderRadius: BorderRadius.circular(75)),
                    // child: Row(
                    //   mainAxisAlignment: MainAxisAlignment.center,
                    //   crossAxisAlignment: CrossAxisAlignment.center,
                    //   children: [
                    //     Text("$messageLimit",style: TextStyle(color: Colors.white),),
                    //     AppIcon.starIcon()
                    //   ],
                    // ),
                  ).marginSymmetric(vertical: 10),
                ),

                IconButton(
                  onPressed: () async {
                    isVoiceOn = !isVoiceOn;
                    await storeVoice(isVoiceOn);

                    setState(() {});
                    await flutterTts.stop();
                    isVoiceOn == true ? showToast(text: "voiceIsOn".tr) :  showToast(text: "voiceIsOff".tr);
                    setState(() {});
                  },
                  icon: isVoiceOn == false ? AppIcon.speakerOffIcon(context) : AppIcon.speakerIcon(context),
                ),
                IconButton(
                  onPressed: () async {
                  await screenshotController.capture(delay: const Duration(milliseconds: 10)).then((image) async {
                    if (image != null) {
                      final directory = await getApplicationDocumentsDirectory();
                      final imagePath = await File('${directory.path}/image.png').create();
                      await imagePath.writeAsBytes(image);
                      /// Share Plugin
                      await Share.shareFiles([imagePath.path]);
                    }
                  });
                },
                  icon: AppIcon.shareIcon(context),
                ),
              ],
              leading: IconButton(
                  onPressed: (){
                    Get.offAll(const HomeScreen(), transition: Transition.rightToLeft);
                   },
                  icon: Icon(Icons.arrow_back_rounded,color: context.textTheme.headline1!.color,)),
            ),

            body: Stack(
              alignment: Alignment.bottomCenter,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Expanded(
                        child: messageList.isEmpty
                            ? const Center(
                          child: Text(
                            "",
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 28),
                          ),
                        )
                            : buildMessageListWidget()),
                  ],
                ),
                Stack(
                  alignment: Alignment.bottomCenter,
                  children: [
                    buildSendWidget(),
                    adContainer,
                  ],
                ),
                // Obx(() => chatController.textField.value == true ? buildSendWidget() :  appButton() ),

              ],
            )
          ),
        ),
      ),
    );
  }

  // Widget appButton(){
  //   return GestureDetector(
  //     onTap: (){
  //       chatController.onchangeTextField(true);
  //     },
  //     child: Container(
  //       height: 50,
  //       width: double.infinity,
  //       decoration: BoxDecoration(color: AppColor.greenColor,borderRadius: BorderRadius.circular(12),),
  //       child:  Center(child: Text("continueChat".tr,style: const TextStyle(color: Colors.white,fontWeight: FontWeight.w600,fontSize: 16),)),
  //     ).marginOnly(bottom:15,left: 15,right: 15),
  //   );
  // }
  final dataKey = GlobalKey();

  Widget buildSendWidget() {
    return  Container(
        height: 55,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: context.isDarkMode == false ?  const  Color(0xffEDEDED) : Colors.white,
        ),
        child: Row(
          children: [
            Expanded(
                child: AppTextField(controller: messageController,)
            ),
            IconButton(
                onPressed: () async {

                  await flutterTts.stop();
                  hideKeyboard(context);
                  String question = messageController.text.toString();
                  if (question.isEmpty) return;
                  addMessageToMessageList(question, true);
                  sendMessageToAPI(question);
                  setState(() {});
                  messageController.clear();
                  // {
                  //   hideKeyboard(context);
                  //   String question = messageController.text.toString();
                  //   if (question.isEmpty) return;
                  //   addMessageToMessageList(question, true);
                  //   sendMessageToAPI(question);
                  //   setState(() {});
                  //   messageController.clear();
                  // }



                  // await getLocalData();
                  // await flutterTts.stop();
                  // messageLimit == -1 ? null :  messageLimit--;
                  // storeMessage(messageLimit);
                  //
                  // if(premiumScreenController.isPremium == true) {
                  //   hideKeyboard(context);
                  //   String question = messageController.text.toString();
                  //   if (question.isEmpty) return;
                  //   addMessageToMessageList(question, true);
                  //   sendMessageToAPI(question);
                  //   setState(() {});
                  //   messageController.clear();
                  // }
                  // else
                  // if(messageLimit ==  -1 ){
                  //   Get.to(const PremiumScreen(), transition: Transition.rightToLeft
                  //   );
                  // }else{
                  //   hideKeyboard(context);
                  //   String question = messageController.text.toString();
                  //   if (question.isEmpty) return;
                  //   addMessageToMessageList(messageController.text, true);
                  //   sendMessageToAPI(question);
                  //   setState(() {});
                  //   messageController.clear();
                  // }
                },
                icon: const Icon(Icons.send,color: Color(0xffABAABA),))
          ],
        )
    ).marginOnly(left: 15,right: 15,bottom: 50);
  }



  // Widget buildSendWidget() {
  //   return  Container(
  //     color: Colors.white,
  //     child: Container(
  //       // height: 50,
  //         decoration: BoxDecoration(
  //           borderRadius: BorderRadius.circular(15),
  //           color: context.isDarkMode == false ?  Color(0xffEDEDED) : Colors.white,
  //         ),
  //         child: Row(
  //           children: [
  //             Expanded(
  //                 flex: 5,
  //                 child: AppTextField(
  //                   controller: messageController,
  //                   onTap: (){},
  //                   onChanged: (value){
  //                     value.isEmpty ? isColor = false : isColor = true;
  //                     setState(() {});
  //                   },
  //                   maxLines: messageController.text.length < 10 ? messageController.text.length < 20 ? 3 :  1 : 2,
  //                 )
  //             ),
  //             IconButton(
  //                 onPressed: () async {
  //
  //                   await flutterTts.stop();
  //
  //
  //
  //
  //                     hideKeyboard(context);
  //                     String question = messageController.text.toString();
  //                     if (question.isEmpty) return;
  //                     addMessageToMessageList(question, true);
  //                     sendMessageToAPI(question);
  //                     setState(() {});
  //                     messageController.clear();
  //
  //
  //                   {
  //                     hideKeyboard(context);
  //                     String question = messageController.text.toString();
  //                     if (question.isEmpty) return;
  //                     addMessageToMessageList(question, true);
  //                     sendMessageToAPI(question);
  //                     setState(() {});
  //                     messageController.clear();
  //                   }
  //                 }, icon: Icon(Icons.send,color:   isColor  ? Colors.green : const Color(0xffABAABA),))
  //           ],
  //         )
  //     ).marginOnly(bottom:  15,left: 15,right: 15),
  //   ).marginOnly(bottom: 50);
  //
  //
  // }


  Widget buildMessageListWidget() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      scrollDirection: Axis.vertical,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (context, index) {
              return Container(
                padding: const EdgeInsets.all(10), margin: messageList[index].sentByMe
                  ?
              const EdgeInsets.only(left: 50)
                  :
              const EdgeInsets.only(right: 50),
                child: Align(
                  alignment: messageList[index].sentByMe
                      ?
                  Alignment.topRight
                      :
                  Alignment.topLeft,
                  child: Column(
                    children: [
                  Row(
                    mainAxisAlignment: messageList[index].sentByMe
                        ?
                    MainAxisAlignment.end
                        :
                    MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      messageList[index].sentByMe
                        ?
                    Container()
                        :
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: const Color(0xffB2E7CA),
                      child: Center(child: Image.asset(AppAssets.botImage)),) ,
                      5.0.addWSpace(),
                      Expanded(
                        child: Container(
                            decoration: BoxDecoration(
                              borderRadius: messageList[index].sentByMe
                                  ?
                              const BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20),bottomLeft: Radius.circular(20))
                                  :
                              const BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20),bottomRight: Radius.circular(20)),
                              color: messageList[index].sentByMe ? AppColor.greenColor : context.theme.primaryColor,),
                            padding: const EdgeInsets.all(10),
                            child:  messageList[index].sentByMe
                                ?
                            Text(
                                messageList[index].message,
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                )
                            ) :
                            Column(
                              children: [
                                Text(messageList[index].answer, style: const TextStyle(fontSize: 16, color: Colors.white,)),
                                5.0.addHSpace(),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    GestureDetector(
                                      onTap : ()  async {
                                        showToast(text: 'copy'.tr);
                                        await Clipboard.setData(ClipboardData(text: messageList[index].answer));},
                                      child: const  SizedBox(
                                        height: 30,
                                        width: 30,
                                        child: Center(child: Icon(Icons.copy,color: Colors.white,)),
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            )
                        ),
                      ),

                      5.0.addWSpace(),

                      messageList[index].sentByMe
                              ?
                      CircleAvatar(radius: 16,backgroundColor: const Color(0xffD8F4E5),child: Center(child: Text("me".tr,style: TextStyle(color: AppColor.greenColor,fontWeight: FontWeight.w700,fontSize: 10))),)
                              :
                      Container(),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
            reverse: true,
            itemCount: messageList.length,
          ),

          if(inProgress) Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(radius: 16,backgroundColor: const Color(0xffB2E7CA),child: Center(child: AppIcon.robotIcon()),) ,
              5.0.addWSpace(),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.only(right: 50),
                  decoration:  BoxDecoration(
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20),bottomRight: Radius.circular(20)),
                    color:  context.theme.primaryColor,
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Lottie.asset(AppAssets.loadingFile,height: 20),
                    ],
                  ),
                ),
              ),
              5.0.addWSpace(),
              Container(),
            ],
          ).paddingAll(10),


          100.0.addHSpace(),

        ],
      ),
    );
  }

  bool isColor =  false;

  dynamic chatComplete(String question) async {
    String data = "";
    try{
      final request = ChatCompleteText(messages: [
        Map.of({"role": "user", "content": question.trim()})
      ],
          maxToken: token,
          model: ChatModel.gptTurbo); /// 3.5 CHAT GPT TURBO
      final response = await openAI.onChatCompletion(request: request);
      for (var element in response!.choices) {
        data = element.message?.content.toString() ?? "";
      }
    }catch(e){
      final request = CompleteText(prompt: question,   model: Model.textDavinci3, maxTokens: token);
      final response = await openAI.onCompletion(request: request);
      String answer = response?.choices.last.text.trim() ?? "";
      data = answer;
      setState(() {});
    }
    return data;
  }


  void sendMessageToAPI(String question) async {

    setState(() {
      inProgress = true;
    });

    String day = DateTime.now().day.toString();
    String month = DateTime.now().month.toString();
    String year = DateTime.now().year.toString();
    try {
      String answer = await chatComplete(question);
      await SharedPrefsUtils.storeChat(chat: messageController.text.isEmpty ? widget.message:   messageController.text , sentByMe: false,dateTime: "$day/$month/$year",answer: answer);
      addMessageToMessageList(answer, false);
      isVoiceOn == true ? _speak(answer) : null;
    } catch (e) {
      await SharedPrefsUtils.storeChat(chat: messageController.text.isEmpty ? widget.message:  messageController.text , sentByMe: false,dateTime: "$day/$month/$year",answer: 'Failed to get response please try again');
      addMessageToMessageList("Failed to get response please try again", false);
      isVoiceOn == true ? _speak("Failed to get response please try again") : null;
    }

    setState(() {
      inProgress = false;
    });

  }



  void addMessageToMessageList(String message, bool sentByMe) {

    String day = DateTime.now().day.toString();
    String month = DateTime.now().month.toString();
    String year = DateTime.now().year.toString();

    setState(() {
      messageList.insert(0, MessageModel(message: message, sentByMe: sentByMe,dateTime: "$day/$month/$year",answer: message));
    });
  }

  List<Map> chatMessages = [];







}

List<String> answerList = [];
