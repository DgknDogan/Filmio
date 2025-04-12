import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../config/routes/app_router.gr.dart';
import '../../../../config/theme/cubit/theme_cubit.dart';
import '../../../../core/enums/device_theme.dart';
import '../../../../core/utils/custom/custom_button.dart';
import '../../../../injection_container.dart';
import '../cubit/settings_cubit.dart';

@RoutePage()
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: context.read<ThemeCubit>(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Settings",
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          centerTitle: true,
          automaticallyImplyLeading: false,
          leading: GestureDetector(
            onTap: () => context.router.maybePop(),
            child: Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: 26.r,
            ),
          ),
        ),
        body: Container(
          margin: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          child: const Column(
            children: [
              _SelectTheme(),
              Spacer(),
              _LogOutButton(),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectTheme extends StatelessWidget {
  const _SelectTheme();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          "Select Theme",
          style: Theme.of(context).textTheme.titleMedium,
        ),
        BlocBuilder<ThemeCubit, ThemeState>(
          builder: (context, state) {
            return DropdownMenu(
              width: 160.w,
              leadingIcon: state.deviceTheme.icon,
              initialSelection: state.deviceTheme,
              alignmentOffset: Offset(0, 10.h),
              onSelected: (value) {
                context.read<ThemeCubit>().changeTheme(value!);
              },
              dropdownMenuEntries: [
                ...DeviceTheme.values.map(
                  (theme) {
                    return DropdownMenuEntry(
                      value: theme,
                      label: theme.label,
                      leadingIcon: theme.icon,
                    );
                  },
                ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _LogOutButton extends StatelessWidget {
  const _LogOutButton();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SettingsCubit(getIt()),
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          return CustomButton(
            text: "Log Out",
            onPressed: () {
              context.read<SettingsCubit>().logout();
              context.router.replaceAll([LoginRoute()]);
            },
            width: double.infinity,
          );
        },
      ),
    );
  }
}
