import 'package:flutter/material.dart';

class OnboardingPageModel {
  final String title;
  final String description;
  final IconData icon; // 실제로는 이미지 경로(String)를 사용하는 것이 일반적입니다.
  final Color backgroundColor;

  OnboardingPageModel({
    required this.title,
    required this.description,
    required this.icon,
    required this.backgroundColor,
  });
}