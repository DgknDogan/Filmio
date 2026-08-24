import 'package:auto_route/auto_route.dart';
import '../../../../config/routes/app_router.gr.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../../core/extensions/context_extension.dart';

import '../../../../core/custom/custom_button.dart';
import '../../../../core/custom/custom_text_field.dart';
import '../../../../injection_container.dart';
import '../cubit/profile_cubit.dart';
import '../../../../config/theme/app_spacing.dart';

@RoutePage()
class SetProfilePage extends StatefulWidget {
  const SetProfilePage({super.key});

  @override
  State<SetProfilePage> createState() => _SetProfilePageState();
}

class _SetProfilePageState extends State<SetProfilePage> with TickerProviderStateMixin {
  late final AnimationController nameErrorAnimationController;
  late final AnimationController photoErrorAnimationController;

  @override
  void initState() {
    nameErrorAnimationController = AnimationController(
      vsync: this,
      duration: 1000.ms,
      reverseDuration: 0.ms,
    );
    photoErrorAnimationController = AnimationController(
      vsync: this,
      duration: 1000.ms,
      reverseDuration: 0.ms,
    );
    super.initState();
  }

  @override
  void dispose() {
    nameErrorAnimationController.dispose();
    photoErrorAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileCubit(getIt(), getIt()),
      child: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          return Scaffold(
            resizeToAvoidBottomInset: false,
            body: SafeArea(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: AppSpacing.xl),
                child: Column(
                  children: [
                    _SetName(
                      errorAnimationController: nameErrorAnimationController,
                    ),
                    _SetPhoto(
                      errorAnimationController: photoErrorAnimationController,
                    ),
                    const Spacer(),
                    _Buttons(
                      nameError: nameErrorAnimationController,
                      photoError: photoErrorAnimationController,
                    ),
                    AppGap.vertical(AppSpacing.xxxl),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SetName extends StatefulWidget {
  final AnimationController errorAnimationController;
  const _SetName({
    required this.errorAnimationController,
  });

  @override
  State<_SetName> createState() => _SetNameState();
}

class _SetNameState extends State<_SetName> with TickerProviderStateMixin {
  late final AnimationController nameAnimationController;
  late final TextEditingController textEditingController;

  @override
  void initState() {
    nameAnimationController = AnimationController(vsync: this, duration: 1000.ms, reverseDuration: 0.ms);
    textEditingController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    nameAnimationController.dispose();
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state is ProfileSetName) {
          nameAnimationController.forward();
        }
      },
      builder: (context, state) {
        if (state is ProfileSetName) {
          return Column(
            children: [
              Text(
                "Your name is ${state.currentName ?? ""}",
                style: context.textTheme.titleLarge,
              ),
              AppGap.vertical(AppSpacing.xxxl),
              CustomTextField(
                hintText: "Name",
                hasError: state.hasError,
                maxLength: 10,
                controller: textEditingController,
                onChanged: (name) => context.read<ProfileCubit>().changeName(name: textEditingController.text),
                isObsecure: false,
                text: context.l10n.authName,
              ).animate(controller: widget.errorAnimationController)
                ..shakeX(
                  amount: 5,
                  hz: 5,
                  duration: 500.ms,
                  curve: Curves.easeInOut,
                ),
            ],
          ).animate(
            controller: nameAnimationController,
          )
            ..fadeIn(begin: 0, duration: 1000.ms, delay: 500.ms, curve: Curves.easeInOut)
            ..moveY(begin: 150, end: 200, duration: 1000.ms, delay: 500.ms, curve: Curves.easeInOut);
        } else {
          return const SizedBox();
        }
      },
    );
  }
}

class _SetPhoto extends StatefulWidget {
  final AnimationController errorAnimationController;
  const _SetPhoto({
    required this.errorAnimationController,
  });

  @override
  State<_SetPhoto> createState() => _SetPhotoState();
}

class _SetPhotoState extends State<_SetPhoto> with TickerProviderStateMixin {
  late final AnimationController photoAnimationController;

  @override
  void initState() {
    photoAnimationController = AnimationController(vsync: this, duration: 1000.ms, reverseDuration: 0.ms);

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      listener: (context, state) {
        if (state is ProfileSetPhoto) {
          photoAnimationController.forward();
        }
      },
      builder: (context, state) {
        if (state is ProfileSetPhoto) {
          return Column(
            children: [
              AnimatedContainer(
                duration: 500.ms,
                decoration: BoxDecoration(
                  borderRadius: AppRadius.pillAll,
                  border: state.hasError
                      ? Border.all(
                          color: context.palette.danger,
                          width: 2.5.r,
                        )
                      : null,
                ),
                child: CircleAvatar(
                  backgroundImage: state.selectedPhoto != null ? AssetImage(state.selectedPhoto!) : null,
                  backgroundColor: context.palette.avatarBackground,
                  radius: 70.r,
                ),
              ).animate(controller: widget.errorAnimationController)
                ..shakeX(
                  amount: 5,
                  hz: 5,
                  duration: 500.ms,
                  curve: Curves.easeInOut,
                ),
              AppGap.vertical(AppSpacing.sm),
              Text(
                context.l10n.authSetProfilePicture,
                style: context.textTheme.titleLarge,
              ),
              AppGap.vertical(AppSpacing.xl),
              _AvatarPicker(showMale: state.option)
            ],
          )
              .animate(controller: photoAnimationController)
              .fadeIn(begin: 0, duration: 1000.ms, delay: 500.ms, curve: Curves.easeInOut)
              .moveY(begin: 0, end: 30, duration: 1000.ms, delay: 500.ms, curve: Curves.easeInOut);
        } else {
          return const SizedBox();
        }
      },
    );
  }
}

/// The six avatars for one gender, with the arrows that switch between them.
class _AvatarPicker extends StatelessWidget {
  final bool showMale;

  const _AvatarPicker({required this.showMale});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ProfileCubit>();
    final avatars = showMale ? cubit.getMaleImages() : cubit.getFemaleImages();

    return Stack(
      alignment: Alignment.center,
      children: [
        GridView.builder(
          shrinkWrap: true,
          itemCount: avatars.length,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.4,
            crossAxisSpacing: 0,
            mainAxisSpacing: 20,
          ),
          itemBuilder: (context, index) => Align(
            child: GestureDetector(
              onTap: () => cubit.selectProfilePicture(image: avatars[index].path),
              child: CircleAvatar(radius: 60.r, backgroundImage: avatars[index].provider()),
            ),
          ),
        ),
        const _SwitchGenderArrow(alignment: Alignment.centerLeft, icon: Icons.arrow_back_ios_rounded),
        const _SwitchGenderArrow(alignment: Alignment.centerRight, icon: Icons.arrow_forward_ios_rounded),
      ],
    );
  }
}

class _SwitchGenderArrow extends StatelessWidget {
  final Alignment alignment;
  final IconData icon;

  const _SwitchGenderArrow({required this.alignment, required this.icon});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.read<ProfileCubit>().changeOption(),
      child: Align(
        alignment: alignment,
        child: Icon(icon, size: 25.r, color: context.palette.icon),
      ),
    );
  }
}

class _Buttons extends StatelessWidget {
  final AnimationController nameError;
  final AnimationController photoError;

  const _Buttons({required this.nameError, required this.photoError});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            CustomButton(
              text: state.stage != 1 ? context.l10n.next : context.l10n.finish,
              width: 100.w,
              onPressed: () async {
                if (state is ProfileSetName) {
                  final isUsernameSelected = await context.read<ProfileCubit>().setUsername();
                  if (!isUsernameSelected) {
                    nameError.repeat(count: 1);
                    return;
                  }
                  if (context.mounted) {
                    context.read<ProfileCubit>().next();
                  }
                } else if (state is ProfileSetPhoto) {
                  final isPhotoSelected = await context.read<ProfileCubit>().setProfilePicture();
                  if (!isPhotoSelected) {
                    photoError.repeat(count: 1);
                    return;
                  }
                  if (context.mounted) {
                    context.router.push(const WrapperRoute());
                  }
                }
              },
            )
          ],
        );
      },
    );
  }
}
