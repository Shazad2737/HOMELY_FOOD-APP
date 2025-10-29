// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:core/core.dart';

class User extends Model {
  User({
    required this.id,
    this.name,
    this.mobile,
    this.active,
    this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String?,
      name: json['name'] as String?,
      mobile: json['mobile'] as String?,
      active: json['active'] as bool?,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );
  }

  factory User.fromJsonString(String jsonString) =>
      User.fromJson(jsonDecode(jsonString) as Map<String, dynamic>);

  final bool? active;
  final DateTime? createdAt;
  final String? mobile;
  final String? id;
  final String? name;

  @override
  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'mobile': mobile,
      'active': active,
      'created_at': createdAt?.toIso8601String(),
    };
  }

  @override
  String toString() => jsonEncode(toJson());

  /// Returns a [User] object based on the provided JSON data.
  ///
  ///
  /// If the [json] parameter is a [Map<String, dynamic>], it will be parsed
  /// using the [User.fromJson] method and the resulting [User] object will be
  /// returned.
  ///
  ///
  /// If the [json] parameter is a [String], a new [User] object will be created
  /// with the provided [json] as the ID.
  ///
  ///
  /// If the [json] parameter is neither a [Map<String, dynamic>] nor a [String],
  /// null will be returned.
  static User? parseUser(dynamic json) {
    if (json is Map<String, dynamic>) {
      return User.fromJson(json);
    } else if (json is String) {
      return User(id: json);
    }
    return null;
  }
}
