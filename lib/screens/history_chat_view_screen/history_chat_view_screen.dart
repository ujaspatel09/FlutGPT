import 'dart:io';
import 'package:chat_gpt/utils/extension.dart';
import 'package:chat_gpt_sdk/chat_gpt_sdk.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../constant/app_assets.dart';
import '../../constant/app_color.dart';
import '../../constant/app_icon.dart';
import '../../modals/message_model.dart';
import '../../utils/app_keys.dart';
import '../../utils/shared_prefs_utils.dart';
import '../../widgets/app_textfield.dart';
import '../history_pages/history_screen.dart';
import '../home_pages/home_screen.dart';
import '../home_pages/home_screen_controller.dart';
import '../premium_pages/premium_screen.dart';
import '../premium_pages/premium_screen_controller.dart';
import '../setting_pages/setting_page_controller.dart';
import 'history_chat_controller.dart';

class HistoryChatViewScreen extends StatefulWidget {
  bool historyPage = false;
  String? question;
  String? answer;
  HistoryChatViewScreen({Key? key,this.answer,this.question,required this.historyPage}) : super(key: key);

  @override
  State<HistoryChatViewScreen> createState() => _HistoryChatViewScreenState();
}

class _HistoryChatViewScreenState extends State<HistoryChatViewScreen> {

  final historyController = Get.put(HistoryChatController());
  // PremiumScreenController premiumScreenController = Get.put(PremiumScreenController());
  int messageLimit = maxMessageLimit;
  getLocalData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    messageLimit = prefs.getInt('messageLimit') ?? maxMessageLimit;
    isVoiceOn = prefs.getBool('voice') ?? voiceIsOff;
    print('MessageLimit -----> $messageLimit');
    setState(() {});
  }
  storeMessage(int value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('messageLimit', value);
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getLocalData();
  }

  final homeScreenController = Get.put(HomeScreenController());
  final FlutterTts flutterTts = FlutterTts();
  _speak(String value) async{
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1);
    await flutterTts.speak(value);
  }

  TextEditingController messageController = TextEditingController();
  List<MessageModel> messageList = [];
  bool inProgress = false;

  final openAI = OpenAI.instance.build(token: openAiToken, baseOption: HttpSetup( receiveTimeout: const Duration(seconds: 6), connectTimeout: const Duration(seconds: 6), sendTimeout: const Duration(seconds: 6)), isLog: true);

  @override
  void dispose() {
    messageController.dispose();
    flutterTts.stop();
    super.dispose();
  }

  storeVoice(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('voice', value);
    isVoiceOn = prefs.getBool('voice') ?? voiceIsOff;
    setState(() {});
  }



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
        widget.historyPage == false ? Get.offAll( const HomeScreen(),transition: Transition.leftToRight)  : Get.offAll( const HistoryScreen(), transition: Transition.leftToRight);
        return true;
      },
      child: Scaffold(
        backgroundColor: context.theme.backgroundColor,
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          backgroundColor: context.theme.backgroundColor,
          title: appBarTitle(context).marginOnly(left: 50),
          leading: IconButton(
              onPressed: (){
               widget.historyPage == false ? Get.offAll( const HomeScreen(), transition: Transition.leftToRight)  : Get.offAll( const HistoryScreen(), transition: Transition.leftToRight);
              } ,
              icon: Icon(Icons.arrow_back_rounded,color: context.textTheme.headline1!.color,)
          ),
          actions: [
            IconButton(
              onPressed: () async {
                isVoiceOn = !isVoiceOn;
                await storeVoice(isVoiceOn);
                getLocalData();
                setState(() {});
                await flutterTts.stop();
                isVoiceOn == true ? showToast(text: "voiceIsOn".tr) :  showToast(text: "voiceIsOff".tr);
                setState(() {});
              },
              icon: isVoiceOn == false ? AppIcon.speakerOffIcon(context) : AppIcon.speakerIcon(context),
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    10.0.addHSpace(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.only(left: 50),
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20),bottomLeft: Radius.circular(20)),
                              color:AppColor.greenColor,
                            ),
                            padding: const EdgeInsets.all(10),
                            child: Text(
                              widget.question ?? "",
                              style: const TextStyle(fontSize: 16, color: Colors.white),
                            ),
                          ),
                        ),
                        5.0.addWSpace(),
                        CircleAvatar(radius: 16,backgroundColor: const Color(0xffD8F4E5),child: Center(child: Text("me".tr,style: TextStyle(color: AppColor.greenColor,fontWeight: FontWeight.w700,fontSize: 10))),)

                      ],
                    ).paddingAll(10),
                    10.0.addHSpace(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(radius: 16,backgroundColor: const Color(0xffB2E7CA),child: Center(child: Image.asset(AppAssets.botImage)),) ,
                        5.0.addWSpace(),
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.only(right: 50),
                            decoration: BoxDecoration(borderRadius: const BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20),bottomRight: Radius.circular(20)), color:  context.theme.primaryColor),
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              children: [
                                Text(
                                  widget.answer ?? "",
                                  style: const TextStyle(fontSize: 16, color: Colors.white),
                                ),
                                5.0.addHSpace(),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    GestureDetector(
                                      onTap : () async {
                                        showToast(text: 'copy'.tr);
                                        await Clipboard.setData(ClipboardData(text: widget.answer ?? "Null"));
                                      },
                                      child: const  SizedBox(height: 30, width: 30, child: Center(child: Icon(Icons.copy,color: Colors.white,)),
                                      ),
                                    ),

                                  ],
                                )
                              ],
                            ),
                          ),
                        ),
                        5.0.addWSpace(),
                        Container(),
                      ],
                    ).paddingAll(10),
                    buildMessageListWidget()
                  ],
                ),
              ),
            ),
            Stack(
              alignment: Alignment.bottomCenter,
              children: [
                buildSendWidget(),
                adContainer,

              ],
            ),
          ],
        ),


      ),
    );
  }


  Widget appButton(){
    return GestureDetector(
      onTap: (){
        historyController.onchangeTextField(true);
      },
      child: Container(
        height: 50,
        width: double.infinity,
        decoration: BoxDecoration(color: AppColor.greenColor,borderRadius: BorderRadius.circular(12),),
        child: Center(child: Text("askNewQuestion".tr,style: const TextStyle(color: Colors.white,fontWeight: FontWeight.w600,fontSize: 16),)),
      ).marginOnly(left: 15,right: 15,bottom: 15),
    );
  }

  Widget buildMessageListWidget() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        ListView.builder(
          itemCount: messageList.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            return Container(
              padding: const EdgeInsets.all(10), margin: messageList[index].sentByMe ? const EdgeInsets.only(left: 50) : const EdgeInsets.only(right: 50),
              child: Align(alignment: messageList[index].sentByMe ? Alignment.topRight : Alignment.topLeft,
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
                              )
                                  :

                              Column(
                                children: [
                                  Text(
                                    messageList[index].answer,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),),
                                  5.0.addHSpace(),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      GestureDetector(
                                        onTap : ()async{
                                          showToast(text: 'copy'.tr);
                                          await Clipboard.setData(ClipboardData(text: messageList[index].answer));
                                        },
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
        ),
        if(inProgress) Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(radius: 16,backgroundColor: const Color(0xffB2E7CA),child: Center(child: Image.asset(AppAssets.botImage)),) ,
            5.0.addWSpace(),
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(right: 50),
                decoration:  BoxDecoration(
                  borderRadius: const BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20),bottomRight: Radius.circular(20)),
                  color: context.theme.primaryColor,
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
    );
  }

  Widget buildSingleMessageRow(MessageModel messageModel) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: messageModel.sentByMe ? const EdgeInsets.only(left: 150) : const EdgeInsets.only(right: 50),
      child: Align(
        alignment: messageModel.sentByMe ? Alignment.topRight : Alignment.topLeft,
        child: Column(
          children: [
            Row(
              mainAxisAlignment: messageModel.sentByMe? MainAxisAlignment.end : MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                messageModel.sentByMe ?  Container()  :  CircleAvatar(radius: 16,backgroundColor: const Color(0xffB2E7CA),child: Center(child: Image.asset(AppAssets.botImage)),) ,
                5.0.addWSpace(),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: messageModel.sentByMe
                          ?
                      const BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20),bottomLeft: Radius.circular(20))
                          :
                      const BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20),bottomRight: Radius.circular(20)),
                      color: messageModel.sentByMe
                          ? AppColor.greenColor
                          : const Color(0xff434554),
                    ),
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      messageModel.message,
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                5.0.addWSpace(),
                messageModel.sentByMe
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
  }

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

                  await getLocalData();
                  await flutterTts.stop();
                  messageLimit == -1 ? null :  messageLimit--;
                  setState(() {});
                  storeMessage(messageLimit);
               {
                    hideKeyboard(context);
                    String question = messageController.text.toString();
                    if (question.isEmpty) return;
                    addMessageToMessageList(question, true);
                    sendMessageToAPI(question);
                    setState(() {});
                    messageController.clear();
                  }

                    hideKeyboard(context);
                    String question = messageController.text.toString();
                    if (question.isEmpty) return;
                    addMessageToMessageList(question, true);
                    sendMessageToAPI(question);
                    setState(() {});
                    messageController.clear();



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

  // dynamic chatComplete(String question) async {
  //   String data = "";
  //   try{
  //     final request = ChatCompleteText(messages: [
  //       Map.of({"role": "user", "content": question.trim()})
  //     ],
  //         maxToken: token,
  //         model: ChatModel.chatGptTurbo0301Model);
  //     final response = await openAI.onChatCompletion(request: request);
  //     for (var element in response!.choices) {
  //       print("data -> ${element.message?.content}");
  //       data = element.message?.content.toString() ?? "";
  //     }
  //   }catch(e){
  //     final request = CompleteText(prompt: question,   model: Model.kTextDavinci3, maxTokens: token);
  //     final response = await openAI.onCompletion(request: request);
  //     String answer = response?.choices.last.text.trim() ?? "";
  //     data = answer;
  //     setState(() {});
  //   }
  //   return data;
  // }


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
      await SharedPrefsUtils.storeChat(chat:  question, sentByMe: false,dateTime: "$day/$month/$year",answer: answer);
      addMessageToMessageList(answer, false);
      isVoiceOn == true ? _speak(answer) : null;
    } catch (e) {
      await SharedPrefsUtils.storeChat(chat:  question, sentByMe: false,dateTime: "$day/$month/$year",answer: 'Failed to get response please try again');
      addMessageToMessageList("Failed to get response please try again", false);
      isVoiceOn == true ? _speak("Failed to get response please try again") : null;
    }

    setState(() {
      inProgress = false;
    });

  }

  // void sendMessageToAPI(String question) async {
  //
  //   setState(() {
  //     inProgress = true;
  //   });
  //
  //   String day = DateTime.now().day.toString();
  //   String month = DateTime.now().month.toString();
  //   String year = DateTime.now().year.toString();
  //   try {
  //     String answer = await chatComplete(question);
  //     await SharedPrefsUtils.storeChat(chat: messageController.text , sentByMe: false,dateTime: "$day/$month/$year",answer: answer);
  //     addMessageToMessageList(answer, false);
  //     isVoiceOn == false ? null : _speak(answer);
  //   } catch (e) {
  //     await SharedPrefsUtils.storeChat(chat: messageController.text , sentByMe: false,dateTime: "$day/$month/$year",answer: 'Failed to get response please try again');
  //     addMessageToMessageList("Failed to get response please try again", false);
  //   }
  //
  //   setState(() {
  //     inProgress = false;
  //   });
  //
  // }



  void addMessageToMessageList(String message, bool sentByMe) {

    String day = DateTime.now().day.toString();
    String month = DateTime.now().month.toString();
    String year = DateTime.now().year.toString();

    setState(() {
      messageList.insert(0, MessageModel(message: message, sentByMe: sentByMe,dateTime: "$day/$month/$year",answer: message));
    });
  }

  // void addMessageToMessageList(String message, bool sentByMe) {
  //
  //   String day = DateTime.now().day.toString();
  //   String month = DateTime.now().month.toString();
  //   String year = DateTime.now().year.toString();
  //
  //   setState(() {
  //     messageList.insert(0, MessageModel(message: message, sentByMe: sentByMe,dateTime: "$day/$month/$year",answer: message));
  //   });
  // }

}
