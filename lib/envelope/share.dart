import 'package:family_budgeter/model/family.dart';
import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';

Future<String> inviteToFamily(Family family) async {
  final DynamicLinkParameters parameters = DynamicLinkParameters(
    uriPrefix: 'https://familybudget.page.link',
    link: Uri.parse('https://familybudget.page.link/invite?family=${family.id}'),
    androidParameters: AndroidParameters(
      packageName: 'com.bytebreakstudios.familybudget',
    ),
    iosParameters: IosParameters(
      bundleId: 'com.bytebreakstudios.familybudget',
      appStoreId: '1580153331',
    ),
  );
  Uri uri = await parameters.buildUrl();
  return uri.toString();
}