import 'package:equatable/equatable.dart';

/// {@template terms}
/// Terms & Conditions model
/// {@endtemplate}
class Terms extends Equatable {
  const Terms({required this.termsAndConditions, this.updatedAt});

  factory Terms.fromJson(Map<String, dynamic> json) {
    return Terms(
      termsAndConditions: json['terms'] as String? ?? '',
      updatedAt: json['updatedAt'] as String?,
    );
  }

  final String termsAndConditions;
  final String? updatedAt;

  Map<String, dynamic> toJson() => {
        'terms': termsAndConditions,
        'updatedAt': updatedAt,
      };

  @override
  List<Object?> get props => [termsAndConditions, updatedAt];
}
