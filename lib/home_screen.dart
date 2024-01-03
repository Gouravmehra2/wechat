
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:wechat/Models/chat_user_model.dart';
import 'package:wechat/apis.dart';
import 'package:wechat/profile_screen.dart';
import 'package:wechat/snackbar.dart';
import 'package:wechat/widgets/chat_box.dart';
import 'login_screen.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<ChatUserModel> list =[];
  final List<ChatUserModel> _searchList=[];
  bool _issearch = false;
  @override
  void initState() {
    super.initState();
    Apis.getSelfInfo();
    Apis.getFirebaseToken();
    Apis.getFirebaseMessaging();
    SystemChannels.lifecycle.setMessageHandler((message) {
      if(Apis.auth.currentUser!=null){
        if(message.toString().contains('resumed')) Apis.updateActiveStatus("true");
        if(message.toString().contains('paused')) Apis.updateActiveStatus("false");
      }

      // if(message.toString().contains('inactive')) Apis.updateActiveStatus('false');

      return Future.value(message);
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        FocusScope.of(context).unfocus();
      },
      child: WillPopScope(
        onWillPop: (){
          if(_issearch){
            setState(() {
              _issearch = !_issearch;
            });
            return Future.value(false);
          }else{
            return Future.value(false);
          }
        },
        child: Scaffold(backgroundColor: Colors.white,
          appBar: AppBar(
            leading: IconButton(
                onPressed: ()async{},
                icon: const Icon(Icons.home)
            ),
            automaticallyImplyLeading: false,
            centerTitle: false,
            title: _issearch ?TextField(
              decoration: const InputDecoration(
                border: InputBorder.none,
              ),
              autofocus: true,
              onChanged: (value){
                _searchList.clear();
                for(var i in list){
                  if(i.name!.toLowerCase().contains(value.toLowerCase()) && _searchList.contains(value)!=i.name){
                    _searchList.add(i);
                  }
                }
                setState(() {
                  _searchList;
                });
              },
            ) :const Text('We Chat',style: TextStyle(fontWeight: FontWeight.bold),),
            actions: [
              IconButton(
                  onPressed: (){
                    setState(() {
                      _issearch = !_issearch;
                    });
                  },
                  icon: Icon(_issearch ? CupertinoIcons.clear_circled_solid:Icons.search)
              ),
              IconButton(
                  onPressed: ()async{
                    Apis.updateActiveStatus('false');
                    await FirebaseAuth.instance.signOut();
                    await GoogleSignIn().signOut().then((value) => {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()))
                    });
        
                  },
                  icon: const Icon(Icons.logout)
              ),
              IconButton(
                  onPressed: ()async{
                    Navigator.push(context, MaterialPageRoute(builder: (context) => Profile(
                      user : Apis.mydata
                    )));
                  },
                  icon: const Icon(Icons.more_vert)
              ),
            ],
          ),
          body:
          StreamBuilder(
            stream: Apis.getUserId(),
            builder: (context,snapshot){
                  if(snapshot.connectionState == ConnectionState.waiting){
                    return const Text('no found');
                  }else if(snapshot.hasData){
                    if(snapshot.data!.docs.isEmpty){
                      return Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Container(padding: const EdgeInsets.all(10),
                          color: Colors.grey,
                        ),
                      );
                    }else{
                      return StreamBuilder(
                        stream: Apis.getAllUser(snapshot.data?.docs.map((e) => e.id).toList() ?? []),
                        builder: (context, snapshot){
                          switch(snapshot.connectionState){
                            case ConnectionState.waiting:
                            case ConnectionState.none:
                            // return Center(child: CircularProgressIndicator(color: Colors.red,));
                            case ConnectionState.active:
                            case ConnectionState.done:
                              final data = snapshot.data?.docs;
                              list = data?.map((e) => ChatUserModel.fromMap(e.data())).toList() ?? [];
                              if(list.isNotEmpty)
                              {
                                return  ListView.builder(
                                    itemCount: _issearch?_searchList.length:list.length,
                                    itemBuilder: (context,index){

                                      // print('list[index]:- ${list[index]}');
                                      return ChatBox(user : _issearch?_searchList[index]:list[index]);
                                    }
                                );
                              } else {
                                return const Center(
                                  child: Text('No Connections Found!😉',
                                      style: TextStyle(fontSize: 20)),
                                );
                              }
                          }
                          //
                        },
                      );
                    }
                  }else{
                    return const Text('SomeThing Went Wrong');
                  }
              }
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: (){
              _addChatUserDialogBox();
            },
            child: const Icon(Icons.person_add_alt_1,color: Colors.blue,),
          ),
        ),
      ),
    );
  }
  void _addChatUserDialogBox(){
    String email ='';
    showDialog(context: context, builder: (_)=>AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.person_add_alt_1,color: Colors.blue,),const SizedBox(width: 10,),
          if(mounted)const Text('Add Users',style: TextStyle(color: Colors.blue),)
        ],
      ),
      content: TextFormField(
        maxLines: null,
        // initialValue: updatedMsg,
        decoration: const InputDecoration(
          hintText: 'Enter Email-Id',
          prefixIcon: Icon(Icons.email),
          border: OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(15))),
        ),
        onChanged: (value) {
          email = value ;
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
          onPressed: () async {
            Navigator.pop(context);
            if(email.isNotEmpty){
              await Apis.addChatUser(email).then((value) {
                if(!value) {
                  Dialogs.showSnackbar(context, 'User not exist');
                }else{
                  Dialogs.showSnackbar(context, 'Successfully added users',);
                }
              });
            }


          },
          child: const Text('Add',style: TextStyle(color: Colors.blue)),
        )
      ],
    ));
  }

}

