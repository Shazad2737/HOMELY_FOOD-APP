import 'package:homely_api/homely_api.dart';
import 'package:homely_app/app/app.dart';
import 'package:homely_app/bootstrap.dart';

Future<void> main() async {
  await bootstrap(() {
    // final api = HomelyApi(baseUrl: 'http://localhost:4000');
    // final api = HomelyApi(baseUrl: 'http://192.168.1.5:5000');
    final api = HomelyApi(baseUrl: 'https://homely-app.chappan.me');
    return App(api: api, releaseMode: ReleaseMode.development);
  });
}
