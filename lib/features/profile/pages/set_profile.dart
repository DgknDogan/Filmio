import 'package:auto_route/auto_route.dart';
import 'package:filmio/features/profile/cubit/profile_cubit.dart';
import 'package:filmio/routes/app_router.gr.dart';
import 'package:filmio/utils/custom/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../../utils/custom/custom_text_field.dart';

@RoutePage()
class SetProfile extends StatefulWidget {
  const SetProfile({super.key});

  @override
  State<SetProfile> createState() => _SetProfileState();
}

class _SetProfileState extends State<SetProfile> with TickerProviderStateMixin {
  late final AnimationController nameAnimationController;
  late final AnimationController photoAnimationController;

  @override
  void initState() {
    nameAnimationController = AnimationController(vsync: this, duration: 1000.ms, reverseDuration: 0.ms);
    photoAnimationController = AnimationController(vsync: this, duration: 1000.ms, reverseDuration: 0.ms);
    super.initState();
  }

  @override
  void dispose() {
    nameAnimationController.dispose();
    photoAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ProfileCubit(),
      child: BlocConsumer<ProfileCubit, ProfileState>(
        listener: (context, state) {
          if (state is ProfileInitial) {
            nameAnimationController.reverse();
          }
          if (state is ProfileSetName) {
            nameAnimationController.forward();
            photoAnimationController.reverse();
          }
          if (state is ProfileSetPhoto) {
            photoAnimationController.forward();
            nameAnimationController.reverse();
          }
        },
        builder: (context, state) {
          return Scaffold(
            body: SafeArea(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 20.w),
                child: Column(
                  children: [
                    _SetName(
                      nameAnimationController: nameAnimationController,
                    ),
                    _SetPhoto(
                      photoAnimationController: photoAnimationController,
                    ),
                    Spacer(),
                    _Buttons(),
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
  final AnimationController nameAnimationController;
  const _SetName({required this.nameAnimationController});

  @override
  State<_SetName> createState() => _SetNameState();
}

class _SetNameState extends State<_SetName> {
  late final TextEditingController textEditingController;
  @override
  void initState() {
    textEditingController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    textEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        if (state is ProfileSetName) {
          return Column(
            children: [
              Text(
                "Your name is ${state.currentName ?? ""}",
                style: TextStyle(
                  color: Color(0xff283618),
                  fontSize: 24.sp,
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 30.h),
              CustomTextField(
                maxLength: 10,
                controller: textEditingController,
                onChanged: (name) => context.read<ProfileCubit>().changeName(name: textEditingController.text),
                isObsecure: false,
                text: "Name",
              ),
            ],
          ).animate(controller: widget.nameAnimationController)
            ..fadeIn(begin: 0, duration: 1000.ms, delay: 500.ms, curve: Curves.easeInOut)
            ..moveY(begin: 150, end: 200, duration: 1000.ms, delay: 500.ms, curve: Curves.easeInOut);
        } else {
          return SizedBox();
        }
      },
    );
  }
}

class _SetPhoto extends StatelessWidget {
  final AnimationController photoAnimationController;
  const _SetPhoto({required this.photoAnimationController});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        if (state is ProfileSetPhoto) {
          return Column(
            children: [
              CircleAvatar(
                backgroundImage: state.selectedPhoto != null ? Image.asset(state.selectedPhoto!).image : null,
                backgroundColor: Color(0xff606c38),
                radius: 70.r,
              ),
              Text(
                "Set a profile picture",
                style: TextStyle(
                  color: Color(0xff283618),
                  fontSize: 24.sp,
                  letterSpacing: 2,
                  fontWeight: FontWeight.bold,
                ),
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
                        color: Color(0xff283618),
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
                        color: Color(0xff283618),
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
  const _Buttons();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            state.stage != 0
                ? CustomButton(
                    text: "Previous",
                    width: 100.w,
                    onPressed: () {
                      context.read<ProfileCubit>().previous();
                    },
                  )
                : SizedBox(),
            CustomButton(
              text: state.stage != 2 ? "Next" : "Finish",
              width: 100.w,
              onPressed: () async {
                if (state is ProfileSetName) {
                  await context.read<ProfileCubit>().setUsername();
                } else if (state is ProfileSetPhoto) {
                  await context.read<ProfileCubit>().setProfilePicture();
                  if (context.mounted) {
                    context.router.push(FilmHomeRoute());
                  }
                }
                if (context.mounted) {
                  context.read<ProfileCubit>().next();
                }
              },
            )
          ],
        );
      },
    );
  }
}
