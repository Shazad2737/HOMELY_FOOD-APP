import 'package:equatable/equatable.dart';

/// {@template update_profile_request}
/// Request body for updating customer profile
/// Currently placeholder as the API spec doesn't show profile update endpoint
/// May be used for future profile update implementation
/// {@endtemplate}
class UpdateProfileRequest extends Equatable {
  /// {@macro update_profile_request}
  const UpdateProfileRequest({
    this.name,
    this.email,
  });

  /// Customer name
  final String? name;

  /// Customer email
  final String? email;

  /// Converts to JSON for API request
  Map<String, dynamic> toJson() {
    return {
      if (name != null) 'name': name,
      if (email != null) 'email': email,
    };
  }

  @override
  List<Object?> get props => [name, email];
}
