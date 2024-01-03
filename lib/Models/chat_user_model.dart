import 'package:flutter/material.dart';

class ChatUserModel{
  String? id;
  String? name;
  String? email;
  String? about;
  String? image;
  String? createdAt;
  int? last_active;
  String? is_online;
  String? pushToken;

  ChatUserModel({
    this.id,
    this.name,
    this.email,
    this.about,
    this.image,
    this.createdAt,
    this.last_active,
    this.is_online,
    this.pushToken,
  });



  factory ChatUserModel.fromMap(Map<String, dynamic> map) {
    return ChatUserModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      about: map['about'] ?? '',
      image: map['image'] ?? '',
      createdAt: map['createdAt'] ?? '',
      last_active: map['last_active'] ?? null,
      is_online: map['is_online'] ?? '',
      pushToken: map['pushToken'] ?? '',
    );
  }

  @override
  String toString() {
    return 'ChatUserModel{id: $id, name: $name, email: $email, about: $about, image: $image, createdAt: $createdAt, last_active: $last_active, is_online: $is_online, pushToken: $pushToken}';
  }

  Map<String, dynamic> toMap() {
    return {
      'id': this.id,
      'name': this.name,
      'email': this.email,
      'about': this.about,
      'image': this.image,
      'createdAt': this.createdAt,
      'last_active': this.last_active,
      'is_online': this.is_online,
      'pushToken': this.pushToken,
    };
  }

}