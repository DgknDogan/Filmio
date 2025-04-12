import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

final darkTheme = ThemeData(
  brightness: Brightness.dark,
  textTheme: TextTheme(
    headlineLarge: TextStyle(
      fontSize: 24.sp,
      color: Colors.white,
      fontWeight: FontWeight.bold,
    ),
    headlineMedium: TextStyle(
      fontSize: 20.sp,
      color: Colors.white,
      fontWeight: FontWeight.bold,
    ),
    headlineSmall: TextStyle(
      fontSize: 18.sp,
      color: Colors.white,
    ),
    titleLarge: TextStyle(
      fontSize: 20.sp,
      color: Colors.white,
      fontWeight: FontWeight.bold,
    ),
    titleMedium: TextStyle(
      fontSize: 18.sp,
      color: Colors.white,
    ),
    titleSmall: TextStyle(
      fontSize: 16.sp,
      color: Colors.white,
    ),
    bodyMedium: TextStyle(
      fontSize: 15.sp,
      color: Colors.white,
    ),
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    elevation: 0,
    unselectedItemColor: Colors.grey,
    selectedItemColor: Colors.white,
    backgroundColor: Color(0xff1c1c1c),
  ),
  scaffoldBackgroundColor: Color(0xff101010),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      textStyle: WidgetStatePropertyAll(TextStyle(fontSize: 20.sp)),
      foregroundColor: WidgetStatePropertyAll(Colors.white),
      elevation: WidgetStatePropertyAll(0),
      shape: WidgetStatePropertyAll<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r))),
      padding: WidgetStatePropertyAll(EdgeInsets.zero),
      backgroundColor: WidgetStatePropertyAll(Color(0xff252525)),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Color(0xff252525),
    hintStyle: TextStyle(color: Colors.grey),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide.none,
      borderRadius: BorderRadius.circular(15.r),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15.r),
      borderSide: BorderSide.none,
    ),
  ),
  appBarTheme: AppBarTheme(
    elevation: 0,
    scrolledUnderElevation: 0,
    toolbarHeight: 70.h,
    backgroundColor: Colors.black,
  ),
  dropdownMenuTheme: DropdownMenuThemeData(
    textStyle: TextStyle(
      fontSize: 16.sp,
      color: Colors.white,
    ),
    menuStyle: MenuStyle(
      backgroundColor: WidgetStatePropertyAll(Color(0xff252525)),
      shape: WidgetStatePropertyAll<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r))),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Color(0xff252525),
      iconColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15.r),
      ),
    ),
  ),
  checkboxTheme: CheckboxThemeData(
    visualDensity: VisualDensity(horizontal: -4, vertical: -4),
    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    splashRadius: 0,
  ),
);

final lightTheme = ThemeData(
  brightness: Brightness.light,
  textTheme: TextTheme(
    headlineLarge: TextStyle(
      fontSize: 24.sp,
      color: Color(0xff3700b3),
      fontWeight: FontWeight.bold,
    ),
    headlineMedium: TextStyle(
      fontSize: 20.sp,
      color: Color(0xff3700b3),
      fontWeight: FontWeight.bold,
    ),
    headlineSmall: TextStyle(
      fontSize: 18.sp,
      color: Color(0xff3700b3),
    ),
    titleLarge: TextStyle(
      fontSize: 20.sp,
      color: Colors.black,
      fontWeight: FontWeight.bold,
    ),
    titleMedium: TextStyle(
      fontSize: 18.sp,
      color: Colors.black,
    ),
    titleSmall: TextStyle(
      fontSize: 16.sp,
      color: Colors.black,
    ),
    bodyMedium: TextStyle(
      fontSize: 15.sp,
      color: Colors.black,
    ),
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    elevation: 0,
    unselectedItemColor: Colors.grey,
    selectedItemColor: Color(0xff6a5acd),
    backgroundColor: Colors.white,
  ),
  scaffoldBackgroundColor: Color(0xffFAFAFA),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      textStyle: WidgetStatePropertyAll(TextStyle(fontSize: 20.sp)),
      foregroundColor: WidgetStatePropertyAll(Colors.white),
      elevation: WidgetStatePropertyAll(0),
      shape: WidgetStatePropertyAll<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r))),
      padding: WidgetStatePropertyAll(EdgeInsets.zero),
      backgroundColor: WidgetStatePropertyAll(Color(0xff3700b3)),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Color(0xffd3d3d3),
    hintStyle: TextStyle(color: Colors.grey),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide.none,
      borderRadius: BorderRadius.circular(15.r),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(15.r),
      borderSide: BorderSide.none,
    ),
  ),
  appBarTheme: AppBarTheme(
    elevation: 0,
    scrolledUnderElevation: 0,
    titleTextStyle: TextStyle(
      fontSize: 24.sp,
      color: Color(0xff3700b3),
      fontWeight: FontWeight.bold,
    ),
    toolbarHeight: 70.h,
    backgroundColor: Color(0xff6a5acd),
  ),
  dropdownMenuTheme: DropdownMenuThemeData(
    textStyle: TextStyle(
      fontSize: 16.sp,
      color: Colors.black,
    ),
    menuStyle: MenuStyle(
      backgroundColor: WidgetStatePropertyAll(Color(0xffd3d3d3)),
      shape: WidgetStatePropertyAll<RoundedRectangleBorder>(RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.r))),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Color(0xffd3d3d3),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15.r),
      ),
    ),
  ),
  checkboxTheme: CheckboxThemeData(
    visualDensity: VisualDensity(horizontal: -4, vertical: -4),
    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    splashRadius: 0,
  ),
);
