import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:wechat/Models/messageModel.dart';
import 'package:wechat/apis.dart';
import 'package:wechat/dateformater.dart';
import 'package:wechat/snackbar.dart';

class MessageCard extends StatefulWidget {
  final MessagesModel message;
  const MessageCard({super.key, required this.message});

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {

  @override
  Widget build(BuildContext context) {
    bool isMe = Apis.user!.uid == widget.message.fromid;
    return InkWell(
      onLongPress: () {
        _showbottomsheet(isMe);
      },
      child: isMe ? _greencard() : _bluecard(),
    );
  }

  // our msg card
  Widget _greencard() {
    final height = MediaQuery
        .sizeOf(context)
        .height * 1;
    // return Text(widget.message.msg);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: [
              if(widget.message.read.isNotEmpty)
                const Icon(Icons.done_all_rounded, color: Colors.blue,),
              Text(
                  MyDateUtils.getlastMessageTime(context, widget.message.send)
              )
            ],
          ),
        ),
        Flexible(
          child: Container(
            margin: const EdgeInsets.fromLTRB(10, 5, 5, 0),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
                border: Border.all(
                    color: CupertinoColors.activeGreen, width: 3),
                borderRadius: const BorderRadius.only(topRight: Radius.circular(30),
                    topLeft: Radius.circular(30),
                    bottomLeft: Radius.circular(30)),
                color: Colors.green.shade50
            ),
            child: widget.message.type == Type.text ? Text(widget.message.msg) :
            ClipRRect(
              // borderRadius:
              // BorderRadius.circular(height * .1),
              child: CachedNetworkImage(
                width: height * .2,
                height: height * .2,
                fit: BoxFit.cover,
                imageUrl: widget.message.msg,
                errorWidget: (context, url, error) =>
                const CircleAvatar(
                    child: Icon(CupertinoIcons.person)),
              ),
            ),
          ),
        ),

      ],
    );
  }
  // Next person Msg
  Widget _bluecard() {
    final height = MediaQuery
        .sizeOf(context)
        .height * 1;
    if (widget.message.read.isEmpty) {
      Apis.updateReadTimeStatus(widget.message);
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Container(
            margin: const EdgeInsets.fromLTRB(10, 5, 0, 0),
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
                border: Border.all(color: CupertinoColors.activeBlue, width: 3),
                borderRadius: const BorderRadius.only(topRight: Radius.circular(30),
                    topLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30)),
                color: Colors.lightBlue.shade50
            ),
            child: widget.message.type == Type.text ? Text(widget.message.msg) :
            ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: CachedNetworkImage(
                width: height * .2,
                height: height * .2,
                fit: BoxFit.cover,
                imageUrl: widget.message.msg,
                errorWidget: (context, url, error) =>
                const CircleAvatar(
                    child: Icon(CupertinoIcons.person)),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: Row(
            children: [
              if(widget.message.read.isNotEmpty)
                const Icon(Icons.done_all_rounded, color: Colors.blue,),
              Text(
                  MyDateUtils.getlastMessageTime(context, widget.message.send)
              )
            ],
          ),
        ),
      ],
    );
  }

  void _showbottomsheet(bool isMe) {
    showModalBottomSheet(context: context,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(
            topLeft: Radius.circular(25),
            topRight: Radius.circular(25)
        )),
        builder: (_) {
          return ListView(shrinkWrap: true,
            // shrinkWrap: true,
            children: [
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    widget.message.type == Type.text ?
                    _option(optionIcons: const Icon(Icons.copy_rounded,color: Colors.blue), name: 'Copy Text', onTaps: () {
                       Clipboard.setData(ClipboardData(text: widget.message.msg)).then((value) {
                        Navigator.pop(context);
                        Dialogs.showSnackbar(context, 'Text Copied');
                      });
                    },)
                        :
                    _option(optionIcons: const Icon(Icons.download,color: Colors.blue), name: 'Save Img', onTaps: () {
                      GallerySaver.saveImage(widget.message.msg,albumName: 'WeChat').then((succeess) {
                        Navigator.pop(context);
                        if(succeess!=null && succeess){
                          Dialogs.showSnackbar(context, 'Images Saved Successfully');
                        }
                      });
                    },) ,
                    const Divider(color: Colors.black54,),
                    if(isMe)_option(optionIcons: const Icon(Icons.edit,color: Colors.blue), name: 'Edit Msg', onTaps: () {
                      _showDialogBox();
                    },),
                    if(isMe)const Divider(color: Colors.black54,),
                    if(isMe)_option(optionIcons: const Icon(Icons.delete,color: Colors.red), name: 'Delete Msg', onTaps: () {
                      Apis.deleteMessage(widget.message);
                    },),
                    if(isMe)const Divider(color: Colors.black54,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _option(optionIcons: const Icon(Icons.send,color: Colors.green), name: 'Sent At', onTaps: () {  },),

                        Text(MyDateUtils.getlastMessageTime(context, widget.message.send))
                      ],
                    ),
                    const Divider(color: Colors.black54,),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _option(optionIcons: const Icon(Icons.remove_red_eye_outlined,color: Colors.red), name: 'Seen At', onTaps: () {  },),
                        widget.message.read!='' ? Text(MyDateUtils.getlastMessageTime(context, widget.message.read)): const Text('Not Seen Yet')
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        });
  }
  void _showDialogBox(){
    var updatedMsg = widget.message.msg;
    showDialog(context: context, builder: (_)=>AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.message_sharp,color: Colors.blue,),const SizedBox(width: 10,),
          if(mounted)const Text('Update',style: TextStyle(color: Colors.blue),)
        ],
      ),
      content: TextFormField(
        initialValue: updatedMsg,
        decoration: const InputDecoration(prefixIcon: Icon(Icons.update),
          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
        ),
        onChanged: (value) {
          updatedMsg = value ;
        } ,
      ),
      actions: [
        MaterialButton(
            onPressed: (){
              Navigator.pop(context);
            },
            child: const Text('Cancel',style: TextStyle(color: Colors.blue)),
        ),
        MaterialButton(
          onPressed: (){
            Apis.editMessage(widget.message,updatedMsg).then((value) {
              Navigator.pop(context);
              Navigator.pop(context);
            });
          },
          child: const Text('Update',style: TextStyle(color: Colors.blue)),
        )
      ],
    ));
  }

}
class _option extends StatelessWidget {
  final Icon optionIcons;
  final String name;
  final VoidCallback onTaps;

  const _option({required this.optionIcons, required this.name, required this.onTaps});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onTaps();
      },
      child: Padding(
        padding: const EdgeInsets.only(left:10,top: 10,bottom: 10),
        child: Row(
          children: [
            optionIcons,
            Text('  $name',style: const TextStyle(fontSize: 15,color: Colors.black54,fontWeight: FontWeight.w500),)
          ],
        ),
      ),
    );
  }
}

