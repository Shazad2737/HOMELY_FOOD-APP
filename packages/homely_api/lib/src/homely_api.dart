import 'package:api_client/api_client.dart';
import 'package:homely_api/homely_api.dart';

abstract class IHomelyApi {
  /// {@macro auth_facade}
  IAuthFacade get authFacade;

  /// CMS Repository
  ICmsRepository get cmsRepository;

  /// Menu Repository
  IMenuRepository get menuRepository;

  /// Notification Repository
  INotificationRepository get notificationRepository;

  /// Session manager for authentication state
  ISessionManager get sessionManager;

  /// User Repository (orders, subscriptions, profile)
  IUserRepository get userRepository;

  /// Onboarding Repository
  IOnboardingRepository get onboardingRepository;
}

/// {@template homely_api}
/// A Very Good Project created by Very Good CLI.
/// {@endtemplate}
class HomelyApi implements IHomelyApi {
  HomelyApi({
    required String baseUrl,
  }) : _storageController = SecureStorageController.instance() {
    // Create session manager
    _sessionManager = SessionManagerImpl(
      storageController: _storageController,
    );

    // Create auth token provider adapter
    final authTokenProvider = SessionAuthTokenProvider(
      sessionManager: _sessionManager,
    );

    // Create API client with auth integration
    _apiClient = ApiClient(
      baseUrl: baseUrl,
      authTokenProvider: authTokenProvider,
    );

    // Create auth facade with session manager
    _authFacade = AuthFacade(
      apiClient: _apiClient,
      sessionManager: _sessionManager,
    );

    // Create CMS repository
    _cmsRepository = CmsRepository(
      apiClient: _apiClient,
    );

    // Create Menu repository
    _menuRepository = MenuRepository(
      apiClient: _apiClient,
    );

    // Create Notification repository
    _notificationRepository = NotificationRepository(
      apiClient: _apiClient,
    );

    // Create User repository
    _userRepository = UserRepository(_apiClient);

    // Create Onboarding repository
    _onboardingRepository = OnboardingRepository(
      storageController: _storageController,
    );
  }

  final IStorageController _storageController;
  late final ISessionManager _sessionManager;
  late final ApiClient _apiClient;
  late final IAuthFacade _authFacade;
  late final ICmsRepository _cmsRepository;
  late final IMenuRepository _menuRepository;
  late final INotificationRepository _notificationRepository;
  late final IUserRepository _userRepository;
  late final IOnboardingRepository _onboardingRepository;

  /// {@macro auth_facade}
  @override
  IAuthFacade get authFacade => _authFacade;

  @override
  ICmsRepository get cmsRepository => _cmsRepository;

  @override
  IMenuRepository get menuRepository => _menuRepository;

  @override
  INotificationRepository get notificationRepository => _notificationRepository;

  @override
  ISessionManager get sessionManager => _sessionManager;

  @override
  IUserRepository get userRepository => _userRepository;

  @override
  IOnboardingRepository get onboardingRepository => _onboardingRepository;
}

class MockHomelyApi implements IHomelyApi {
  MockHomelyApi({
    bool clearStorage = false,
  }) {
    final storageController = SecureStorageController();
    if (clearStorage) {
      storageController.clear(); // Clear any existing data
    }
    _sessionManager = SessionManagerImpl(
      storageController: storageController,
    );
    _authFacade = MockAuthFacade(sessionManager: _sessionManager);
  }

  late final ISessionManager _sessionManager;
  late final IAuthFacade _authFacade;

  @override
  IAuthFacade get authFacade => _authFacade;

  @override
  ICmsRepository get cmsRepository => throw UnimplementedError();

  @override
  IMenuRepository get menuRepository => throw UnimplementedError();

  @override
  INotificationRepository get notificationRepository =>
      throw UnimplementedError();

  @override
  ISessionManager get sessionManager => _sessionManager;

  @override
  IUserRepository get userRepository => throw UnimplementedError();

  @override
  IOnboardingRepository get onboardingRepository => throw UnimplementedError();
}
