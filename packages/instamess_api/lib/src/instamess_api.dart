import 'package:api_client/api_client.dart';
import 'package:instamess_api/instamess_api.dart';

abstract class IInstaMessApi {
  /// {@macro auth_facade}
  IAuthFacade get authFacade;

  /// CMS Repository
  ICmsRepository get cmsRepository;

  /// Menu Repository
  IMenuRepository get menuRepository;

  /// Session manager for authentication state
  ISessionManager get sessionManager;

  /// User Repository (orders, subscriptions, profile)
  IUserRepository get userRepository;
}

/// {@template instamess_api}
/// A Very Good Project created by Very Good CLI.
/// {@endtemplate}
class InstaMessApi implements IInstaMessApi {
  InstaMessApi({
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

    // Create User repository
    _userRepository = UserRepository(_apiClient);
  }

  final IStorageController _storageController;
  late final ISessionManager _sessionManager;
  late final ApiClient _apiClient;
  late final IAuthFacade _authFacade;
  late final ICmsRepository _cmsRepository;
  late final IMenuRepository _menuRepository;
  late final IUserRepository _userRepository;

  /// {@macro auth_facade}
  @override
  IAuthFacade get authFacade => _authFacade;

  @override
  ICmsRepository get cmsRepository => _cmsRepository;

  @override
  IMenuRepository get menuRepository => _menuRepository;

  @override
  ISessionManager get sessionManager => _sessionManager;

  @override
  IUserRepository get userRepository => _userRepository;
}

class MockInstaMessApi implements IInstaMessApi {
  MockInstaMessApi({
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
  ISessionManager get sessionManager => _sessionManager;

  @override
  IUserRepository get userRepository => throw UnimplementedError();
}
