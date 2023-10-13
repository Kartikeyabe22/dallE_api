import 'package:flutter/material.dart';
import 'package:gpt_me_api/feature_box.dart';
import 'package:gpt_me_api/openai_service.dart';
import 'package:gpt_me_api/pallete.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:animate_do/animate_do.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  TextEditingController chatx = TextEditingController();
  final speechToText = SpeechToText();
  final flutterTts = FlutterTts();
  String lastWords = '';
  final OpenAIService openAIService = OpenAIService();
  String? generatedContent;
  String? generatedImageUrl;
  int start= 200;
  int delay = 200;

  @override
  void initState()  {
    // TODO: implement initState
    super.initState();
    initSpeechToText();
    initTextToSpeech();

  }

  Future<void> initTextToSpeech()async{
    await flutterTts.setSharedInstance(true);
  setState(() {});
  }

  Future<void>initSpeechToText()async{
  await speechToText.initialize();
  setState(() {
  });
  }

 Future <void> startListening() async {
    await speechToText.listen(onResult: onSpeechResult);
    setState(() {});
  }

 Future <void>  stopListening() async {
    await speechToText.stop();
    setState(() {});
  }

  void onSpeechResult(SpeechRecognitionResult result) {
    setState(() {
      lastWords = result.recognizedWords;
      print(lastWords);
    });
  }

  Future <void> systemSpeak(String content) async{
  await flutterTts.speak(content);
  }
@override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    speechToText.stop();
    flutterTts.stop();
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: BounceInDown(child: Text('Allen')),
        leading: Icon(Icons.menu),
        centerTitle: true,
        actions:<Widget>[
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Pallete.firstSuggestionBoxColor,
            ),
            onPressed:()async{
              final speech =  await openAIService.isArtPromptAPI(lastWords);
              if(speech.contains('https'))
              {
                generatedImageUrl=speech;
                generatedContent=null;
                setState(() {

                });
              }
              else{
                generatedImageUrl=null;
                generatedContent=speech;
                setState(() {

                });
                await systemSpeak(speech);
              }

              print(speech);
            },
            child:  Icon(

              Icons.anchor_sharp ,
              size: 25,

            ),
          ),
        ],

      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ZoomIn(
              child: Stack(
                children: [
                  Center(
                    child: Container(
                      height: 120,
                      width: 120,
                      margin: const EdgeInsets.only(top: 4),
                      decoration: const BoxDecoration(
                        color: Pallete.assistantCircleColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                  Container(
                    height: 123,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(image: AssetImage('assets/images/virtualAssistant.png')),
                    ),
                  )
                ],
              ),
            ),
            FadeInRight(child:
            Visibility(
              visible: generatedImageUrl == null,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                margin: const EdgeInsets.symmetric(horizontal: 40).copyWith(
                  top: 30,
                ),
                decoration: BoxDecoration(
                  border:Border.all(
                    color: Pallete.borderColor,
                  ),
               borderRadius: BorderRadius.circular(20).copyWith(
                 topLeft: Radius.zero,
               )
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Text( generatedContent==null?'Good Morning How can i help you?': generatedContent!,
                  style:TextStyle(
                    fontFamily: 'Cera Pro',
                    color: Pallete.mainFontColor,
                    fontSize:generatedContent == null? 25:18,
                  ),
                  ),
                ),
              ),
            ),
            ),
           if(generatedImageUrl!=null)
           Padding(
             padding: const EdgeInsets.all(10.0),
             child: ClipRRect(
               borderRadius: BorderRadius.circular(20),
                 child: Image.network(generatedImageUrl!),

             ),
           ),
           SlideInLeft(child:
           Visibility(
             visible: generatedContent == null && generatedImageUrl == null,
             child: Container(
               padding: const EdgeInsets.all(10),
               margin: EdgeInsets.only(
                 top: 10,
                 left: 22,
               ),
               child: Align(
                 alignment: Alignment.centerLeft,
                 child: const Text('Here are a few features',
                  style: TextStyle(
                    fontFamily: 'Cera Pro',
                    color: Pallete.mainFontColor,
                    fontSize:20,
                    fontWeight: FontWeight.bold,
                  ),),
               ),
             ),
           ),
           ),
            //suugestions list
           Visibility(
             visible: generatedContent == null && generatedImageUrl == null,
             child: Column(
               children: [

                 SlideInLeft(
                   delay:Duration(milliseconds:start ),
                     child: const FeatureBox(color: Pallete.firstSuggestionBoxColor, headerText:'Chat Gpt',descriptionText: 'A smarter way to organise your stuff ',)),
                 SlideInLeft(
                     delay: Duration(milliseconds: start+delay),
                     child:const FeatureBox(color: Pallete.secondSuggestionBoxColor, headerText:'Dall-E',descriptionText: 'Get inspired and stay creative and innovative with your personal assistant ',)),
                 SlideInLeft(
                   delay: Duration(milliseconds: start + 2*delay),
                     child:const FeatureBox(color: Pallete.thirdSuggestionBoxColor, headerText:'Smart Voice Assistant',descriptionText: 'Get the best of both worlds and shape the future ',)),

               ],
             ),
           ),
          ],
        ),
      ),
      floatingActionButton: ZoomIn(
        delay: Duration(milliseconds: start + 3*delay),
        child: FloatingActionButton(
          backgroundColor: Pallete.firstSuggestionBoxColor,
            onPressed: () async{
            if(await speechToText.hasPermission && speechToText.isNotListening )
            {
              await startListening();
            }
            else if(speechToText.isListening)
            {
              await stopListening();
            }
            else
              {
                initSpeechToText();
              }
            },
         child: Icon(speechToText.isListening?Icons.stop:Icons.mic),
        ),
      ),
      bottomSheet:Padding(
        padding: const EdgeInsets.only(bottom: 8.0),
        child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Pallete.firstSuggestionBoxColor,
            ),
          onPressed: () {

        //  Navigator.push(context,MaterialPageRoute(builder: (context)=>BottomSheetExample(),));
          showModalBottomSheet<void>(
            context: context,
            builder: (BuildContext context) {
              return SingleChildScrollView(
                child: Container(
                  height: 350,

                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                //      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[

                      Container(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: TextField(

                            controller: chatx,
                            decoration: InputDecoration(hintText: '     Ask Your Doubt'),
                            keyboardType: TextInputType.multiline,

                          ),
                        ),
                      ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Pallete.firstSuggestionBoxColor
                          ),
                          onPressed:()async{
                            final speech =  await openAIService.isArtPromptAPI(chatx.text);
                            if(speech.contains('https'))
                            {
                              generatedImageUrl=speech;
                              generatedContent=null;
                              setState(() {

                              });
                            }
                            else{
                              generatedImageUrl=null;
                              generatedContent=speech;
                              setState(() {

                              });

                            }

                            print(speech);
                          },
                          child:  Icon(

                            Icons.anchor_sharp ,
                            size: 25,

                          ),
                        ),

                      ],
                    ),
                  ),
                ),
              );
            },
          );
           },
        child: Icon(Icons.border_bottom_outlined),
        ),
      ) ,
    );
  }
}
