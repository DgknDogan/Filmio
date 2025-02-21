import 'package:auto_route/auto_route.dart';
import 'package:filmio/routes/app_router.gr.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../utils/custom/custom_button.dart';
import '../../../utils/custom/custom_text_field.dart';
import '../cubit/profile_cubit.dart';

@RoutePage()
class SetProfile extends StatefulWidget {
  const SetProfile({super.key});

  @override
  State<SetProfile> createState() => _SetProfileState();
}

class _SetProfileState extends State<SetProfile> with TickerProviderStateMixin {
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
      create: (context) => ProfileCubit(),
      child: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, state) {
          return Scaffold(
            body: SafeArea(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  children: [
                    _SetName(
                      errorAnimationController: nameErrorAnimationController,
                    ),
                    _SetPhoto(
                      errorAnimationController: photoErrorAnimationController,
                    ),
                    Spacer(),
                    _Buttons(
                      nameError: nameErrorAnimationController,
                      photoError: photoErrorAnimationController,
                    ),
                    SizedBox(height: 30.h),
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
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: 30.h),
              CustomTextField(
                hasError: state.hasError,
                maxLength: 10,
                controller: textEditingController,
                onChanged: (name) => context.read<ProfileCubit>().changeName(name: textEditingController.text),
                isObsecure: false,
                text: "Name",
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
          return SizedBox();
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
                  borderRadius: BorderRadius.circular(90.r),
                  border: state.hasError
                      ? Border.all(
                          color: Colors.red.shade600,
                          width: 2.5.r,
                        )
                      : null,
                ),
                child: CircleAvatar(
                  backgroundImage: state.selectedPhoto != null ? Image.asset(state.selectedPhoto!).image : null,
                  backgroundColor: Color(0xff2a2a2a),
                  radius: 70.r,
                ),
              ).animate(controller: widget.errorAnimationController)
                ..shakeX(
                  amount: 5,
                  hz: 5,
                  duration: 500.ms,
                  curve: Curves.easeInOut,
                ),
              SizedBox(height: 10.h),
              Text(
                "Set a profile picture",
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: 20.h),
              Stack(
                alignment: Alignment.center,
                children: [
                  GridView.builder(
                    shrinkWrap: true,
                    itemCount: 6,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 1.4,
                      crossAxisSpacing: 0,
                      mainAxisSpacing: 20,
                    ),
                    itemBuilder: (context, index) {
                      final List<String> imagePathList;
                      if (state.option) {
                        imagePathList = context.read<ProfileCubit>().getMaleImages();
                      } else {
                        imagePathList = context.read<ProfileCubit>().getFemaleImages();
                      }
                      return Align(
                        child: GestureDetector(
                          onTap: () {
                            context.read<ProfileCubit>().selectProfilePicture(image: imagePathList[index]);
                          },
                          child: CircleAvatar(
                            radius: 60.r,
                            backgroundImage: Image.asset(imagePathList[index]).image,
                          ),
                        ),
                      );
                    },
                  ),
                  GestureDetector(
                    onTap: () => context.read<ProfileCubit>().changeOption(),
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Icon(
                        Icons.arrow_back_ios_rounded,
                        size: 25.r,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.read<ProfileCubit>().changeOption(),
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 25.r,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              )
            ],
          )
              .animate(controller: photoAnimationController)
              .fadeIn(begin: 0, duration: 1000.ms, delay: 500.ms, curve: Curves.easeInOut)
              .moveY(begin: 0, end: 30, duration: 1000.ms, delay: 500.ms, curve: Curves.easeInOut);
        } else {
          return SizedBox();
        }
      },
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
              text: state.stage != 1 ? "Next" : "Finish",
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
                    context.router.push(SplashRoute());
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
