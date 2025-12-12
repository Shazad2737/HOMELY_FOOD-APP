import 'package:equatable/equatable.dart';

/// {@template signup_response}
/// Response from signup API containing customer data and OTP verification status
/// {@endtemplate}
class SignupResponse extends Equatable {
  /// {@macro signup_response}
  const SignupResponse({
    required this.customerId,
    required this.mobile,
    required this.name,
    required this.requiresOtpVerification,
    required this.redirectTo,
  });

  /// Creates a [SignupResponse] from JSON
  factory SignupResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final customer = data['customer'] as Map<String, dynamic>;

    return SignupResponse(
      customerId: customer['customerId'] as String,
      mobile: customer['mobile'] as String,
      name: customer['name'] as String,
      requiresOtpVerification: data['requiresOtpVerification'] as bool,
      redirectTo: data['redirectTo'] as String,
    );
  }

  /// The customer ID
  final String customerId;

  /// The customer's mobile number
  final String mobile;

  /// The customer's name
  final String name;

  /// Whether OTP verification is required
  final bool requiresOtpVerification;

  /// Where to redirect after signup
  final String redirectTo;

  @override
  List<Object?> get props => [
        customerId,
        mobile,
        name,
        requiresOtpVerification,
        redirectTo,
      ];
}
