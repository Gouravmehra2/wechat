import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:wechat/Models/chat_user_model.dart';
import 'package:wechat/apis.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:wechat/login_screen.dart';
import 'package:wechat/snackbar.dart';

class Profile extends StatefulWidget {
  final ChatUserModel user;
  const Profile({super.key,required this. user});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  String? _image;
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.sizeOf(context).height*1;
    final width = MediaQuery.sizeOf(context).width*1;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(title: const Text('Profile'),),
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
                        _image!=null ?
                        ClipRRect(
                            borderRadius:
                            BorderRadius.circular(height * .1),
                            child: Image.file(File(_image!),
                                width: height * .2,
                                height: height * .2,
                                fit: BoxFit.cover)
                        )
                            :ClipRRect(
                          borderRadius:
                          BorderRadius.circular(height * .15),
                          child: CachedNetworkImage(
                            width: height * .23,
                            height: height * .23,
                            fit: BoxFit.cover,
                            imageUrl: widget.user.image.toString(),
                            errorWidget: (context, url, error) =>
                            const CircleAvatar(
                                child: Icon(CupertinoIcons.person)),
                          ),
                        ),
                        Positioned(
                            bottom: height * .012,
                            right: height * .025,
                            child: CircleAvatar(
                              backgroundColor: Colors.white,
                                radius: 21,
                                child: IconButton(
                                  icon: const Icon(Icons.edit),
                                  onPressed: (){
                                    _showbottomsheet();
                                  },
                                )
                            )
                        )
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
              SizedBox(height: height * 0.01,),
              TextFormField(
                onSaved: (value) => Apis.mydata.name  = value ?? '',
                validator: (val){
                  val!=null && val.isNotEmpty ? null : 'Required Field';
                  return null;
                },
                initialValue: widget.user.name,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.person),
                  label: Text('Name'),
                  border: OutlineInputBorder()
                ),
              ),
              SizedBox(height: height * 0.01,),
              TextFormField(
                initialValue: Apis.mydata.about,
                onSaved: (value) => Apis.mydata.about  = value ?? '',
                validator: (val){
                  val!=null && val.isNotEmpty ? null : 'Required Field';
                  return null;
                },
                decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.edit),
                    label: Text('About Us'),
                    border: OutlineInputBorder()
                ),
              ),
              SizedBox(height: height * 0.01,),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(style: ElevatedButton.styleFrom(
                    minimumSize: Size(width* .5, height * .05)
                  ),
                      onPressed: ()async{
                          if(_formKey.currentState!.validate()){
                            _formKey.currentState!.save();
                              await Apis.upadate().then((value) {
                                Dialogs.showSnackbar(context, "profile data updated successfully");
                              });
                          }
                      },
                      icon: const Icon(Icons.update),
                      label: const Text('Update')
                  )
                ],
              )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        shape: BeveledRectangleBorder(borderRadius: BorderRadius.circular(30),
          side: const BorderSide(
            style: BorderStyle.solid
          )
        ),
        onPressed: ()async{
          await Apis.auth.signOut();
          await GoogleSignIn().signOut().then((value){
            Navigator.push(context, MaterialPageRoute(builder: (context)=> const LoginScreen())
            );
          });
        },
        child: const Icon(Icons.logout),
      ),
    );
  }
  void _showbottomsheet(){
    showModalBottomSheet(context: context,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25),
          topRight: Radius.circular(25)
        )),
        builder: (_){
          final height = MediaQuery.sizeOf(context).height*1;
      return ListView(shrinkWrap: true,
        // shrinkWrap: true,
        children: [
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(0, 10, 0, 15),
                child: Text('Pick Profile Picture ',style: TextStyle(fontWeight: FontWeight.bold),),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              GestureDetector(
                onTap: ()async{
                  final ImagePicker picker = ImagePicker();
                  final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                  if(image!=null){
                    setState(() {
                      _image = image.path;
                    });
                  }
                  Apis.updateImage(File(_image!));
                  setState(() {

                  });
                  Navigator.pop(context);
                },
                child: CircleAvatar(
                  radius: height*0.06,
                  child: Image(height: height*0.08,
                      image: const AssetImage('images/gallery.png')),
                ),
              ),
              GestureDetector(
                onTap: ()async{
                  final ImagePicker picker = ImagePicker();
                  final XFile? image = await picker.pickImage(source: ImageSource.camera);
                  if(image!=null){
                    setState(() {
                      _image = image.path;
                    });
                  }
                  Apis.updateImage(File(_image!));
                  setState(() {

                  });
                  Navigator.pop(context);
                },
                child: CircleAvatar(
                  radius: height*0.06,
                  child: Image(height: height*0.08,
                      image: const AssetImage('images/photo-camera.png')),
                ),
              )
            ],
          )
        ],
      );
    });
  }
}
