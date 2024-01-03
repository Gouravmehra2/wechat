import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:wechat/Chat_screen.dart';
import 'package:wechat/Models/chat_user_model.dart';
import 'package:wechat/Models/messageModel.dart';
import 'package:wechat/apis.dart';
import 'package:wechat/dateformater.dart';

class ChatBox extends StatefulWidget {
  final ChatUserModel user;
  const ChatBox({super.key, required this.user});

  @override
  State<ChatBox> createState() => _ChatBoxState();
}

class _ChatBoxState extends State<ChatBox> {

  MessagesModel? _message;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: (){
        Navigator.push(context, MaterialPageRoute(builder: (context)=> ChatScreen(user: widget.user))
        );
      },
      child: Card(
        child: StreamBuilder(
          stream: Apis.getLastMessage(widget.user),
          builder: (context,snapshot){
            if(snapshot.data!=null){
              final data = snapshot.data?.docs;
              final list = data?.map((e) => MessagesModel.fromJson(e.data())).toList() ?? [];
              if(list.isNotEmpty) _message=list[0];
            }else{

            }
            return ListTile(
                leading: ClipRRect(borderRadius:const BorderRadius.all(Radius.circular(30)),
                    child: CachedNetworkImage(width: 50,fit: BoxFit.cover,imageUrl: widget.user.image.toString(),)),
                title: Text(widget.user.name.toString()),
                subtitle: Text(
                    _message!=null ?
                    _message!.type == Type.image ? '📎 Sent Attachement' :
                    _message!.msg
                        :   widget.user.email.toString()),
                trailing: _message == null
                    ? null //show nothing when no message is sent
                    : _message!.read.isEmpty &&
                    _message!.fromid != Apis.user!.uid
                    ?
                //show for unread message
                Container(
                  width: 15,
                  height: 15,
                  decoration: BoxDecoration(
                      color: Colors.greenAccent.shade400,
                      borderRadius: BorderRadius.circular(10)),
                )
                    :
                //message sent time
                Text(
                  MyDateUtils.getlastMessageTime(
                      context, _message!.send),
                  style: const TextStyle(color: Colors.black54),
                ),
            );

          },
        )
      ),
    );
  }

}
