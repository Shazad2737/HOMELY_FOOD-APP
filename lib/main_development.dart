import 'package:instamess_api/instamess_api.dart';
import 'package:instamess_app/app/app.dart';
import 'package:instamess_app/bootstrap.dart';

Future<void> main() async {
  await bootstrap(
    () {
      // final api = InstaMessApi(baseUrl: 'http://localhost:4000');
      final api = InstaMessApi(baseUrl: 'http://192.168.1.5:5000');
      return App(
        api: api,
        releaseMode: ReleaseMode.development,
      );
    },
  );
}
