import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wechat/Models/chat_user_model.dart';
import 'package:wechat/Models/messageModel.dart';
import 'package:wechat/dateformater.dart';
import 'package:wechat/message.dart';
import 'package:wechat/view_profile_screen.dart';

import 'apis.dart';

class ChatScreen extends StatefulWidget {
  final ChatUserModel user;
  const ChatScreen({super.key,required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  bool _isuploading = false;
  bool _showEmoji = false;
  List<MessagesModel> _list =[];
  final _textcontroller =TextEditingController();
  @override
  void initState() {
  //   // TODO: implement initState
    super.initState();
    Timer(const Duration(seconds:1), () {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(systemNavigationBarColor: Colors.white,statusBarColor: Colors.white));
    });

  }
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height*0.02;
    final width = MediaQuery.sizeOf(context).width*0.02;

    return GestureDetector(
      onTap: (){
        FocusScope.of(context).unfocus();
      },
      child: SafeArea(
        child: WillPopScope(
          onWillPop: (){
            if(_showEmoji){
              setState(() {
                _showEmoji =!_showEmoji;
              });
              return Future.value(false);
            }else{
              return Future.value(false);
            }

          },
          child: Scaffold(
            backgroundColor: Colors.lightBlue.shade50,
            appBar: AppBar(
              automaticallyImplyLeading: false,
              flexibleSpace: _appBar(height*1.8,width*0.02),
            ),
            body: Column(
              children: [
                Expanded(
                  child: StreamBuilder(
                    stream: Apis.getAllMessage(widget.user),
                    builder: (context, snapshot) {
                      switch(snapshot.connectionState){
                        case ConnectionState.waiting:
                        case ConnectionState.none:
                          return const SizedBox();
                        case ConnectionState.active:
                        case ConnectionState.done:
                          final data = snapshot.data?.docs;
                          _list = data?.map((e) => MessagesModel.fromJson(e.data())).toList() ?? [];
                          if(_list.isNotEmpty){
                            return  ListView.builder(
                                reverse: true,
                                itemCount: _list.length,
                                // itemCount: _issearch?_searchList.length:list.length,
                                itemBuilder: (context,index){
                                  return MessageCard(message : _list[index]);
                                }
                            );
                          }else{
                            return const Center(
                              child: Text("Say Hi..!👋",style: TextStyle(fontWeight: FontWeight.bold,fontSize: 25),)
                            );
                          }
                      }
          
                      //
                    },
                  ),
                ),
                SizedBox(height: height * 0.22,),
                if(_isuploading)
                  const Align(
                    alignment: Alignment.bottomRight,
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(strokeWidth: 2,),
                    ),
                  ),
                _chatInput(),
                if(_showEmoji)
                  SizedBox(
                  height: height * 15.5,
                    child: EmojiPicker(
                      textEditingController: _textcontroller,
                      config: Config(
                        bgColor: Colors.white,
                        columns: 8,
                        emojiSizeMax: 32 * (Platform.isAndroid? 1.30 : 1.0),
                    )
                 )
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
  Widget _appBar(final height,final width){
    return InkWell(
      onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: (context)=> ViewProfile(user: widget.user)));
      },
      child:StreamBuilder(
        stream: Apis.getUserInfo(widget.user),
        builder: (context,snapshot){
          final data =snapshot.data!.docs;
          final list = data.map((e) => ChatUserModel.fromMap(e.data())).toList();

          return  Row(
            children: [
              IconButton(
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.arrow_back_sharp)
              ),const SizedBox(width: 0,),
              CircleAvatar(
                radius: height,
                backgroundImage:NetworkImage(list.isNotEmpty ? list[0].image.toString():  widget.user.image.toString()),
              ),
              const SizedBox(width: 10,),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text( widget.user.name.toString(),style: const TextStyle(fontWeight: FontWeight.bold,color: Colors.black,fontSize: 16),),
                  Text( list.isNotEmpty ?
                      list[0].is_online != "false" ? 'online':
                 MyDateUtils.getLastActiveTime(context: context, lastactive: list[0].last_active.toString()):
                  MyDateUtils.getLastActiveTime(context: context, lastactive: widget.user.last_active.toString()),style: const TextStyle(color: CupertinoColors.activeGreen),)
                ],
              )
            ],
          );
        },
      )

    );
  }
  Widget _chatInput(){
    return Row(
      children: [
        Expanded(
          child: Card(color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25)
            ),
            child: Row(
              children: [
                IconButton(
                    onPressed: (){
                      setState(() {
                        FocusScope.of(context).unfocus();
                        _showEmoji = !_showEmoji;
                      });
                    },
                    icon: const Icon(Icons.emoji_emotions)
                ),
                Expanded(
                  child: TextFormField(
                    controller: _textcontroller,
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Message...!'
                    ),
                    onTap: (){
                      if(_showEmoji){
                        setState(() {
                          _showEmoji = !_showEmoji;
                        });
                      }
                    },
                  ),
                ),
                IconButton(
                    onPressed: ()async{
                      final ImagePicker picker = ImagePicker();
                      final List<XFile> images = await picker.pickMultiImage(imageQuality: 70);
                      for(var i in images){
                        setState(()  {
                          _isuploading = true;
                        });
                          await Apis.sendChatImage(widget.user, File(i.path));
                          setState(() {
                            _isuploading = false;
                        });
                      }
                    },
                    icon: const Icon(Icons.image)
                ),
                IconButton(
                    onPressed: ()async{
                      final ImagePicker picker = ImagePicker();
                      final XFile? image = await picker.pickImage(source: ImageSource.camera,imageQuality: 70);
                      if(image!=null){
                        log(image.path);
                      }
                      setState(()  {
                        _isuploading = true;
                      });
                      await Apis.sendChatImage(widget.user, File(image!.path));
                      setState(()  {
                        _isuploading = false;
                      });
                    },
                    icon: const Icon(Icons.camera_alt_sharp)
                )
              ],
            ),
          ),
        ),
        MaterialButton(height: 47,
          minWidth: 0,
          shape: const CircleBorder(),
          color: Colors.green,
            onPressed: ()async{
              if(_textcontroller.text.isNotEmpty){
                if(_list.isEmpty){
                  Apis.sendFirstMessage(widget.user,_textcontroller.text,Type.text);
                }else{
                  await Apis.sendMessage(widget.user,_textcontroller.text,Type.text);
                }

                _textcontroller.text = '';
              }
            },
            child:const Icon(Icons.send) ,
        )
      ],
    );
  }

}
