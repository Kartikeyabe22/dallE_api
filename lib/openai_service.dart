import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gpt_me_api/home_page.dart';
import 'package:gpt_me_api/secrets.dart';
import 'package:http/http.dart' as http;
class OpenAIService {
  final List <Map<String, String>> messages = [];

  Future <String> isArtPromptAPI(String prompt) async{
    try{
     final res = await http.post(Uri.parse('https://api.openai.com/v1/chat/completions'),
       headers: {
       'Content-Type': 'application/json',
         'Authorization': 'Bearer $openAIAPIKey',
       },
       body: jsonEncode({
         "model" : "gpt-3.5-turbo",
         "messages": [
           { "role": "user",
             "content": "I want to differentiate between questions i require dall-e api for image generation or chatgpt api for text generation .So help me to differentiate if i ask you a question which requires image generation , image creation ,art or similar then just reply 'dall' else if i ask about anything to explain then reply 'chat'. Question number one ${prompt} . ONLY REPLY DALL OR CHAT one word answer nothing else accepted",
           }
         ],
       }),
     );
     print(res.body);
     if(res.statusCode == 200){
       String content = jsonDecode(res.body)['choices'][0]['message']['content'];
       content = content.trim();

       switch(content)
           {
         case 'Dall':
         case 'dall':
         case 'Dall.':
         case 'dall.':
         case 'DALL.':
         case 'DALL':

        final res =   await dallEAPI(prompt);
        return res;
         default:
           final res = await chatGPTAPI(prompt);
           return res;
       }


     }
     return 'An internal error occured';
    } catch(e){
      return e.toString();
    }

  }
  Future <String> chatGPTAPI(String prompt) async{
    messages.add({
      'role': 'user',
      'content': prompt,
    });
    try{
      final res = await http.post(Uri.parse('https://api.openai.com/v1/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $openAIAPIKey',
        },
        body: jsonEncode({
          "model" : "gpt-3.5-turbo",
          "messages": messages,
        }),
      );
     // print(res.body);
      if(res.statusCode == 200){
        String content = jsonDecode(res.body)['choices'][0]['message']['content'];
        content = content.trim();

        messages.add({
          'role': 'assistant',
          'content': content,
        });
      return content;
      }
      return 'An internal error occured';
    } catch(e){
      return e.toString();
    }

  }
  Future <String> dallEAPI(String prompt) async{
    messages.add({
      'role': 'user',
      'content': prompt,
    });
    try{
      final res = await http.post(Uri.parse('https://api.openai.com/v1/images/generations'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $openAIAPIKey',
        },
        body: jsonEncode({
          "prompt": prompt,
          "n": 1,

        }),
      );
       print(res.body);
      if(res.statusCode == 200){
        String imageUrl = jsonDecode(res.body)['data'][0]['url'];
        imageUrl = imageUrl.trim();

        messages.add({
          'role': 'assistant',
          'content': imageUrl,
        });
        return imageUrl;
      }
      return 'An internal error occured';
    } catch(e){
      return e.toString();
    }


  }
}
