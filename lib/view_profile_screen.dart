import 'dart:io';
import 'package:flutter/material.dart';
import 'package:wechat/Models/chat_user_model.dart';


class ViewProfile extends StatefulWidget {
  final ChatUserModel user;
  const ViewProfile({super.key,required this. user});

  @override
  State<ViewProfile> createState() => _ViewProfileState();
}

class _ViewProfileState extends State<ViewProfile> {
  String? _image;
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height*1;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: Text(widget.user.name.toString()),),
      body:Padding(
        padding: const EdgeInsets.all(10.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 5, 0, 5),
                    child: Stack(
                      children: [
                        _image!=null ?CircleAvatar(
                            radius: height * .15,
                            child:Image.file(File(_image!),fit: BoxFit.fill,)
                        ):CircleAvatar(
                            radius: height * .15,
                            backgroundImage:NetworkImage(widget.user.image.toString())
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: height * 0.01,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(widget.user.email.toString(),
                    style: const TextStyle(color: Colors.grey,fontWeight: FontWeight.bold,fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  )
                ],
              ),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('About :',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),
                  Text('Feeling Amazing 😊',style: TextStyle(fontSize: 14),)
                ],
              )
            ],
          ),
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('Joined on :',style: TextStyle(fontWeight: FontWeight.bold,fontSize: 16),),
          Text(widget.user.createdAt!.toString())
        ],
      )
    );
  }
}
