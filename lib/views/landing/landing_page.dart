// lib/views/landing/landing_page.dart
import 'package:flutter/material.dart';
import 'package:trakr_def/core/theme/app_theme.dart';
import 'header.dart';
import 'hero_section.dart';
import 'features_section.dart';
import 'popular_games_section.dart';
import 'testimonials_section.dart';
import 'footer_section.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../viewmodels/auth_viewmodel.dart';
import '../../widgets/custom_app_bar.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryDark,
      appBar: const Header(),
      body: Container(
        decoration: AppTheme.getGlobalBackgroundGradient(),
        child: SingleChildScrollView(
          child: Column(
            children: [
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