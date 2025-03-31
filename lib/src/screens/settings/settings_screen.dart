import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:controller/src/controllers/desk/desk_controller.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../controllers/auth/auth_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.settings),
          centerTitle: true,
          backgroundColor: Colors.transparent,
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              const ItemAccountSettings(),
              const SizedBox(height: 20),
              ItemCustomSettings(
                title: AppLocalizations.of(context)!.preferencesButton,
                icon: Icons.settings_outlined,
                onTap: () {
                  Navigator.pushNamed(context, '/settings/preferences');
                },
              ),
              ItemCustomSettings(
                title: AppLocalizations.of(context)!.physicalSettings,
                icon: Icons.fitness_center,
                onTap: () {
                  Navigator.pushNamed(context, '/settings/deskSettings');
                },
              ),
              ItemCustomSettings(
                title: AppLocalizations.of(context)!.unitOfMeasure,
                icon: Icons.square_foot_sharp,
                onTap: () {
                  Navigator.pushNamed(context, '/settings/measurements');
                },
              ),
              ItemCustomSettings(
                title: AppLocalizations.of(context)!.healthyReminders,
                icon: Icons.access_alarm,
                onTap: () {
                  Navigator.pushNamed(context, '/settings/reminders');
                },
              ),
              // ItemCustomSettings(
              //   title: 'Tutorial',
              //   icon: Icons.help_outline,
              //   onTap: () {
              //     if (deskController.device != null &&
              //         deskController.device!.isConnected) {
              //       SharedPreferences.getInstance().then((prefs) {
              //         prefs.setBool('newUser', true);
              //       });
              //       Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home,
              //           (Route<dynamic> route) => false);
              //     } else {
              //       ToastService.showInfo(
              //           context, AppLocalizations.of(context)!.connectDesk);
              //     }
              //   },
              // ),
              ItemCustomSettings(
                title: 'About',
                icon: Icons.info_outline,
                onTap: () async {
                  if (await canLaunchUrl(
                      Uri.parse("https://www.gebesa.com/"))) {
                    launchUrl(Uri.parse("https://www.gebesa.com/"));
                  }
                },
              ),
              ItemCustomSettings(
                title: 'Sign out',
                icon: Icons.logout,
                onTap: () {
                  var authController =
                      Provider.of<AuthController>(context, listen: false);
                  var deskController =
                      Provider.of<DeskController>(context, listen: false);
                  authController.logout();
                  deskController.disconnect();
                },
              ),
              const SizedBox(height: 20),
              Text(
                'Version 1.0.0',
                style: TextStyle(color: Colors.grey.withOpacity(.5)),
              ),
            ],
          ),
        ));
  }
}

class ItemCustomSettings extends StatelessWidget {
  const ItemCustomSettings({
    super.key,
    this.title,
    this.icon,
    this.onTap,
  });

  final String? title;
  final IconData? icon;
  final Function? onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.only(left: 20, bottom: 0, top: 0),
          leading: Icon(icon, size: 20),
          title: Text(title!, style: const TextStyle(fontSize: 16)),
          trailing: const Padding(
            padding: EdgeInsets.only(right: 20),
            child: Icon(Icons.arrow_forward_ios_rounded, size: 15),
          ),
          onTap: onTap as void Function()?,
        ),
        Container(
          height: 1,
          color: Colors.grey.withOpacity(.3),
        ),
      ],
    );
  }
}

class ItemAccountSettings extends StatelessWidget {
  const ItemAccountSettings({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    var authController = Provider.of<AuthController>(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor.withOpacity(.1),
          border: Border.all(color: Colors.grey.withOpacity(.3)),
          borderRadius: BorderRadius.circular(10),
        ),
        child: ListTile(
          contentPadding: const EdgeInsets.only(left: 10),
          leading: CircleAvatar(
            radius: 25,
            backgroundColor: Theme.of(context).primaryColor.withOpacity(.1),
            child: const Icon(
              Icons.person,
              color: Colors.white,
            ),
          ),
          title: Text(
              authController.userInfo != null
                  ? authController.userInfo!.name!
                  : '',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(
              authController.userInfo != null
                  ? authController.userInfo!.email!
                  : '',
              style: const TextStyle(fontSize: 12)),
          trailing: IconButton(
            icon: const Icon(Icons.arrow_forward_ios_rounded, size: 15),
            onPressed: () {
              Navigator.pushNamed(context, '/settings/account');
            },
          ),
          onTap: () {
            Navigator.pushNamed(context, '/settings/account');
          },
        ),
      ),
    );
  }
}
