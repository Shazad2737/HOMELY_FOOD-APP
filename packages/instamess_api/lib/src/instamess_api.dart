import 'package:api_client/api_client.dart';
import 'package:instamess_api/instamess_api.dart';
import 'package:instamess_api/src/auth/mock_auth_facade.dart';

abstract class IInstaMessApi {
  /// {@macro auth_facade}
  IAuthFacade get authFacade;

  DashboardRepo get dashboardRepo;

  /// Session manager for authentication state
  ISessionManager get sessionManager;
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
  }

  final IStorageController _storageController;
  late final ISessionManager _sessionManager;
  late final ApiClient _apiClient;
  late final IAuthFacade _authFacade;

  /// {@macro auth_facade}
  @override
  IAuthFacade get authFacade => _authFacade;

  @override
  ISessionManager get sessionManager => _sessionManager;

  // /// Shortcut to [TransactionRepository] instance
  // late final ITransactionRepository transactionRepository =
  //     TransactionRepository(_apiClient);

  /// Shortcut to [DashboardRepo] instance
  @override
  late final DashboardRepo dashboardRepo = DashboardRepo(_apiClient);
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
  DashboardRepo get dashboardRepo => throw UnimplementedError();

  @override
  ISessionManager get sessionManager => _sessionManager;
}
