import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart';
import 'package:wechat/Models/chat_user_model.dart';
import 'package:wechat/Models/messageModel.dart';

class Apis{
  static ChatUserModel mydata =ChatUserModel(
    image: user!.photoURL.toString(),
    id: user!.uid,
    last_active: null,
    is_online: '',
    about: '',
    createdAt: '',
    name: user!.displayName.toString(),
    email: user!.email.toString(),
    pushToken: '',
  );

  static User? get user => auth.currentUser;
  //cloud_firestore storage to store the data of particular users
  static  FirebaseFirestore firestore = FirebaseFirestore.instance;
  //creating firebase instance
  static FirebaseAuth auth =  FirebaseAuth.instance;
  //if user_already login
  static Future<bool> userexist()async{
    return(await firestore.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).get()).exists;
  }
  //firebase storage for storing images

  static FirebaseStorage storage = FirebaseStorage.instance;
  //created new users in firebase
  static Future<void> createUser()async{
    final user = ChatUserModel(
        id:auth.currentUser!.uid,
        email: auth.currentUser!.email,
        name: auth.currentUser!.displayName,
        createdAt: DateTime.now().toString(),
        image: auth.currentUser!.photoURL,
        about: 'Demo Users',
        is_online: 'False',
        last_active: 6,
        pushToken: 'false'

    );
    return await firestore.collection('users').doc(auth.currentUser!.uid).set(user.toMap());
  }
  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllUser(List<String>userIds){
    return firestore.collection('users').where('id',whereIn: userIds).snapshots();
  }
  static Future<void>getSelfInfo()async{
    await firestore.collection('users').doc(auth.currentUser!.uid).get().then((user) async {
      // getFirebaseToken();
      // Apis.updateActiveStatus('true');
      mydata = ChatUserModel.fromMap(user.data()!);
        });

  }
  static Future<void>upadate()async{
    await Apis.firestore.collection('users').doc(Apis.auth.currentUser!.uid).update({
      'name': Apis.mydata.name,
      'about':Apis.mydata.about,
      'image':Apis.mydata.image
    });
  }
  static Future<void>updateImage(File? file)async{
      final extension = file!.path.split('.').last;
      final ref = storage.ref().child('ProfilePicture / ${auth.currentUser!.uid}.$extension');
      ref.putFile(file, SettableMetadata(contentType: 'image/$extension')).then((p0) {
      });
       mydata.image = await ref.getDownloadURL();
      await Apis.firestore.collection('users').doc(Apis.auth.currentUser!.uid).update({
        'image':Apis.mydata.image
      });
      Apis.mydata.image = mydata.image;
  }

  static String getConverationId(String? id) => user!.uid.hashCode <=id.hashCode ? '${user?.uid}_$id': '${id}_${user?.uid}';

  static Stream<QuerySnapshot<Map<String, dynamic>>> getAllMessage(ChatUserModel chatuser){
    // print(chatuser);
    return firestore.collection('chat/${getConverationId(chatuser.id.toString())}/messages').orderBy('send',descending: true).
    snapshots();
  }

  static Future<void> sendMessage(ChatUserModel chatuser, String msg,Type type)async{
    final time = DateTime.now().millisecondsSinceEpoch.toString();
    final MessagesModel message = MessagesModel(
        msg: msg,
        toid: chatuser.id.toString(),
        read: '',
        type: type,
        fromid: user!.uid,
        send: time
    );
    final ref = firestore.collection('chat/${getConverationId(chatuser.id.toString())}/messages');
    await ref.doc(time).set(message.toJson()).then((value) {
      sendnotification(chatuser, type==Type.text ? msg : 'images');
    });
  }

  static Future<void> sendFirstMessage(ChatUserModel chatuser, String msg,Type type)async{
    await firestore.collection('users').doc(chatuser.id).collection('my_users').doc(user!.uid).set({}).then((value) => sendMessage(chatuser,msg,type));
  }

  static Future<void>updateReadTimeStatus(MessagesModel message)async{
    firestore.collection('chat/${getConverationId(message.fromid)}/messages').
    doc(message.send).update({'read': DateTime.now().millisecondsSinceEpoch.toString()});
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getLastMessage(ChatUserModel chatuser){
    return firestore.collection('chat/${getConverationId(chatuser.id.toString())}/messages').orderBy('send',descending: true).limit(1).snapshots();
  }
  static Future<void> sendChatImage(ChatUserModel chatUser, File file) async {
    //getting image file extension
    final ext = file.path.split('.').last;

    //storage file ref with path
    final ref = storage.ref().child(
        'images/${getConverationId(chatUser.id.toString())}/${DateTime.now().millisecondsSinceEpoch}.$ext');

    //uploading image
    await ref
        .putFile(file, SettableMetadata(contentType: 'image/$ext'))
        .then((p0) {
      log('Data Transferred: ${p0.bytesTransferred / 1000} kb');
    });

    //updating image in firestore database
    final imageUrl = await ref.getDownloadURL();
    await sendMessage(chatUser, imageUrl, Type.image);
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserInfo(ChatUserModel chatuser){
    return
      firestore.collection('users').where('id',isEqualTo: chatuser.id).snapshots();
  }
  static Future<void> updateActiveStatus(String isonline) async {
    firestore.collection('users').
    doc(auth.currentUser!.uid).
    update({
      'is_online' : isonline,
      'last_active':DateTime.now().millisecondsSinceEpoch,
      'pushToken' : mydata.pushToken
    });
  }
  //Push notification message in firebase
  static FirebaseMessaging fmessaging = FirebaseMessaging.instance;

  //getting firebase messaging token
  static Future<void> getFirebaseToken()async{
    await fmessaging.requestPermission();
     await fmessaging.getToken().then((t){
       if(t!=null){
         mydata.pushToken = t;
       }
     });
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {

      if (message.notification != null) {
      }
    });

  }
  static Future<void> getFirebaseMessaging()async{
  }

  static Future<void> sendnotification(
      ChatUserModel chatUser, String msg) async {
    try {
      final body = {
        "to": chatUser.pushToken,
        "notification": {
          "title": mydata.name, //our name should be send
          "body": msg,
          "android_channel_id": "chats"
        },
        // "data": {
        //   "some_data": "User ID: ${me.id}",
        // },
      };

      var res = await post(Uri.parse('https://fcm.googleapis.com/fcm/send'),
          headers: {
            HttpHeaders.contentTypeHeader: 'application/json',
            HttpHeaders.authorizationHeader:
            'key=AAAAsuBB6ZM:APA91bE-eRP7zTk0jiaLk9JmXJvsLCgH8hffWQ1QCVtRh_gFPkQHqk-YwNsYqGC2Mr8PVOcrH1sYJYZX4stASQC0IPxFT4qFJ2jIwtN89MOELcUO3binam-vQEdZDSaD9D91WgTaz4qi'
          },
          body: jsonEncode(body));
      log('Response status: ${res.statusCode}');
      log('Response body: ${res.body}');
    } catch (e) {
      log('\nsendPushNotificationE: $e');
    }
  }
  static Future<void> deleteMessage(MessagesModel message)async {
    await  firestore.collection('chat/${getConverationId(message.toid)}/messages').doc(message.send).delete();

    if(message.type == Type.image){
      await storage.refFromURL(message.send).delete();
    }
  }

  static Future<void> editMessage(MessagesModel message,String updatedmsg)async {
    await  firestore.collection('chat/${getConverationId(message.toid)}/messages').doc(message.send).update({
      'msg': updatedmsg
    });

    if(message.type == Type.image){
      await storage.refFromURL(message.send).delete();
    }
  }

  static Future<bool>addChatUser(String email)async{
    final data =  await firestore.collection('users').where('email',isEqualTo: email).get();
    if(data.docs.isNotEmpty && data.docs.first.id!=user!.uid){
      await firestore.collection('users').doc(user!.uid).collection('my_users').doc(data.docs.first.id).set({});
      return true;
    }else{
      return false;
    }
  }

  static Stream<QuerySnapshot<Map<String, dynamic>>> getUserId(){
    return firestore.collection('users').
    doc(user?.uid).collection('my_users').
    snapshots();
  }

}