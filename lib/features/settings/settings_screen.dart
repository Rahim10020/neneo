import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import 'widgets/settings_section.dart';
import 'widgets/settings_item.dart';
import 'widgets/pro_card.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _historyEnabled = false;
  String _selectedLanguage = 'Francais';
  String _defaultVehicle = 'Moto';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: AppColors.textPrimary,
                          width: 1.5,
                        ),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_back,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text('Parametres', style: AppTextStyles.h2),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // PREFERENCES Section
                    SettingsSection(
                      title: 'PREFERENCES',
                      children: [
                        SettingsItem(
                          icon: Icons.language,
                          title: 'Langue',
                          trailing: _selectedLanguage,
                          onTap: () {
                            // TODO: Show language selector
                          },
                        ),
                        const SizedBox(height: 12),
                        SettingsItem(
                          icon: Icons.motorcycle,
                          iconColor: AppColors.error,
                          title: 'Vehicule par defaut',
                          trailing: _defaultVehicle,
                          onTap: () {
                            // TODO: Show vehicle selector
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // DONNEES Section
                    SettingsSection(
                      title: 'DONNEES',
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.cardBackground,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Historique des trajets',
                                style: AppTextStyles.bodyLarge.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Switch(
                                value: _historyEnabled,
                                onChanged: (value) {
                                  setState(() {
                                    _historyEnabled = value;
                                  });
                                },
                                activeColor: Colors.purple,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'L\'historique des trajets est desactive pour les\ncomptes gratuits',
                          style: AppTextStyles.bodyMedium.copyWith(
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Pro Card
                    const ProCard(),

                    const SizedBox(height: 32),

                    // A PROPOS Section
                    SettingsSection(
                      title: 'A PROPOS',
                      children: [
                        SettingsItem(
                          icon: Icons.phone_outlined,
                          title: 'Contacter le support',
                          onTap: () {
                            // TODO: Open contact
                          },
                        ),
                        const SizedBox(height: 12),
                        SettingsItem(
                          icon: Icons.share_outlined,
                          title: 'Partager l\'application',
                          onTap: () {
                            // TODO: Share app
                          },
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.cardBackground,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    color: AppColors.gray500,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Version',
                                    style: AppTextStyles.bodyLarge.copyWith(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              Text(
                                AppConstants.version,
                                style: AppTextStyles.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
