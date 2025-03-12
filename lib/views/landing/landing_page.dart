// lib/views/landing/landing_page.dart
import 'package:flutter/material.dart';
import 'package:trakr_def/core/theme/app_theme.dart';
import 'header.dart';
import 'hero_section.dart';
import 'features_section.dart';
import 'popular_games_section.dart';
import 'testimonials_section.dart';
import 'footer_section.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: AppTheme.getGlobalBackgroundGradient(),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Header(),
              HeroSection(),
              FeaturesSection(),
              PopularGamesSection(),
              TestimonialsSection(),
              FooterSection(),
            ],
          ),
        ),
      ),
    );
  }
}