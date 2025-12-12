import 'package:homely_api/homely_api.dart';
import 'package:homely_app/app/app.dart';
import 'package:homely_app/bootstrap.dart';

Future<void> main() async {
  await bootstrap(
    () {
      final api = HomelyApi(baseUrl: 'https://homely-app.iotics.me/');
      return App(
        api: api,
        releaseMode: ReleaseMode.staging,
      );
    },
  );
}
