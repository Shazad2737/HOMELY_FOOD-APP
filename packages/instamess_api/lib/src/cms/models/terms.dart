import 'package:equatable/equatable.dart';

/// {@template terms}
/// Terms & Conditions model
/// {@endtemplate}
class Terms extends Equatable {
  const Terms({
    this.termsAndConditions,
    this.updatedAt,
    this.privacyPolicy,
  });

  factory Terms.fromJson(Map<String, dynamic> json) {
    return Terms(
      termsAndConditions: json['termsAndConditions'] as String? ?? '',
      updatedAt: json['updatedAt'] as String?,
      privacyPolicy: json['privacyPolicy'] as String?,
    );
  }

  final String? termsAndConditions;
  final String? privacyPolicy;
  final String? updatedAt;

  Map<String, dynamic> toJson() => {
        'terms': termsAndConditions,
        'updatedAt': updatedAt,
        'privacyPolicy': privacyPolicy,
      };

  @override
  List<Object?> get props => [termsAndConditions, updatedAt];
}
