import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_constants.dart';
import '../../providers/user_provider.dart';
import '../../providers/trip_provider.dart';
import 'widgets/settings_section.dart';
import 'widgets/settings_item.dart';
import 'widgets/pro_card.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _digitsOnly(String input) {
    return input.replaceAll(RegExp(r'[^0-9]'), '');
  }

  Future<void> _contactSupportOnWhatsApp() async {
    final phoneDigits = _digitsOnly(AppConstants.supportWhatsApp);
    if (phoneDigits.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Numéro WhatsApp indisponible'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final uri = Uri.parse('https://wa.me/$phoneDigits');

    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Impossible d’ouvrir WhatsApp'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _showLanguageSelector() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Choisir une langue', style: AppTextStyles.h3),
              const SizedBox(height: 20),
              _LanguageOption(
                language: 'Français',
                isSelected: userProvider.user.preferredLanguage == 'fr',
                onTap: () {
                  userProvider.updateLanguage('fr');
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 12),
              _LanguageOption(
                language: 'Ewe',
                isSelected: userProvider.user.preferredLanguage == 'ewe',
                onTap: () {
                  userProvider.updateLanguage('ewe');
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Traduction Ewe disponible bientôt !'),
                      backgroundColor: AppColors.warning,
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _showVehicleSelector() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Véhicule par défaut', style: AppTextStyles.h3),
              const SizedBox(height: 20),
              _VehicleOption(
                icon: Icons.motorcycle,
                label: 'Zémidjan (Moto)',
                isSelected: userProvider.user.defaultVehicle == 'moto',
                onTap: () {
                  userProvider.updateDefaultVehicle('moto');
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 12),
              _VehicleOption(
                icon: Icons.local_taxi,
                label: 'Taxi',
                isSelected: userProvider.user.defaultVehicle == 'taxi',
                onTap: () {
                  userProvider.updateDefaultVehicle('taxi');
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _clearHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Effacer l\'historique', style: AppTextStyles.h3),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer tout votre historique ?',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Annuler',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.gray500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final tripProvider = Provider.of<TripProvider>(
                context,
                listen: false,
              );
              await tripProvider.clearHistory();
              if (!context.mounted) return;
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Historique effacé'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Effacer'),
          ),
        ],
      ),
    );
  }

  void _shareApp() {
    // TODO: Implement share app with actual Play Store link
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fonctionnalité disponible après publication'),
        backgroundColor: AppColors.warning,
      ),
    );
  }

  void _contactSupport() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Contacter le support', style: AppTextStyles.h3),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ContactRow(
              icon: Icons.email_outlined,
              label: AppConstants.supportEmail,
            ),
            const SizedBox(height: 12),
            _ContactRow(
              icon: Icons.phone_outlined,
              label: AppConstants.supportPhone,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _contactSupportOnWhatsApp,
                icon: const Icon(Icons.chat_outlined),
                label: const Text('Contacter via WhatsApp'),
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Déconnexion', style: AppTextStyles.h3),
        content: Text(
          'Voulez-vous vraiment vous déconnecter ?',
          style: AppTextStyles.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Annuler',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.gray500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final userProvider = Provider.of<UserProvider>(
                context,
                listen: false,
              );
              await userProvider.logout();
              if (!context.mounted) return;
              Navigator.pop(context);
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppConstants.routeHome,
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, child) {
        final user = userProvider.user;
        final isGuest = !userProvider.isLoggedIn;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: AppColors.textPrimary,
                              width: 0.8,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.arrow_back,
                            color: AppColors.textPrimary,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text('Paramètres', style: AppTextStyles.h3),
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
                              trailing: user.preferredLanguage == 'fr'
                                  ? 'Français'
                                  : 'Ewe',
                              onTap: _showLanguageSelector,
                            ),
                            const SizedBox(height: 12),
                            SettingsItem(
                              icon: Icons.motorcycle,
                              title: 'Véhicule par défaut',
                              trailing: user.defaultVehicle == 'moto'
                                  ? 'Moto'
                                  : 'Taxi',
                              onTap: _showVehicleSelector,
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Historique des trajets',
                                      style: AppTextStyles.bodyLarge.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  Switch(
                                    value: user.historyEnabled,
                                    onChanged: userProvider.isPro
                                        ? (value) {
                                            userProvider.updateHistoryEnabled(
                                              value,
                                            );
                                          }
                                        : null,
                                    activeThumbColor: Colors.purple,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              userProvider.isPro
                                  ? 'L\'historique est activé pour votre compte Pro'
                                  : 'L\'historique des trajets est désactivé pour les\ncomptes gratuits.\nAbonnez-vous pour enregistrer vos futurs trajets.',
                              style: AppTextStyles.bodyMedium.copyWith(
                                fontSize: 12,
                                color: AppColors.gray500,
                              ),
                            ),
                            Consumer<TripProvider>(
                              builder: (context, tripProvider, child) {
                                final hasHistory =
                                    tripProvider.history.isNotEmpty;
                                final canSeeHistory =
                                    (userProvider.isPro &&
                                        user.historyEnabled) ||
                                    hasHistory;

                                if (!canSeeHistory) {
                                  return const SizedBox.shrink();
                                }

                                final isReadOnly =
                                    !userProvider.isPro && hasHistory;

                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: OutlinedButton.icon(
                                            onPressed: () =>
                                                Navigator.pushNamed(
                                                  context,
                                                  AppConstants.routeHistory,
                                                ),
                                            icon: Icon(
                                              Icons.history,
                                              size: 18,
                                              color: AppColors.textPrimary,
                                            ),
                                            label: Text(
                                              isReadOnly
                                                  ? 'Voir les anciens trajets'
                                                  : 'Voir l\'historique',
                                              style: AppTextStyles.bodyMedium
                                                  .copyWith(
                                                    color:
                                                        AppColors.textPrimary,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                            ),
                                            style: OutlinedButton.styleFrom(
                                              side: BorderSide(
                                                color: AppColors.gray300,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                          ),
                                        ),
                                        if (userProvider.isPro &&
                                            user.historyEnabled) ...[
                                          const SizedBox(width: 12),
                                          OutlinedButton.icon(
                                            onPressed: _clearHistory,
                                            icon: Icon(
                                              Icons.delete_outline,
                                              size: 18,
                                              color: AppColors.error,
                                            ),
                                            label: Text(
                                              'Effacer',
                                              style: AppTextStyles.bodyMedium
                                                  .copyWith(
                                                    color: AppColors.error,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                            ),
                                            style: OutlinedButton.styleFrom(
                                              side: BorderSide(
                                                color: AppColors.error,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    if (isReadOnly) ...[
                                      const SizedBox(height: 8),
                                      Text(
                                        'Votre abonnement Pro est expiré.\nVous pouvez toujours consulter vos anciens trajets.',
                                        style: AppTextStyles.bodyMedium
                                            .copyWith(
                                              fontSize: 12,
                                              color: AppColors.gray500,
                                            ),
                                      ),
                                    ],
                                  ],
                                );
                              },
                            ),
                          ],
                        ),

                        const SizedBox(height: 24),

                        // Pro Card (only if not Pro)
                        if (!userProvider.isPro) const ProCard(),

                        // Pro Status (if Pro)
                        if (userProvider.isPro) ...[
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFFFFEB3B), Color(0xFFFDD835)],
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.star,
                                      color: AppColors.textPrimary,
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Text(
                                        'Vous êtes membre Pro',
                                        style: AppTextStyles.h3.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'Expire le ${user.proExpiresAt != null ? "${user.proExpiresAt!.day}/${user.proExpiresAt!.month}/${user.proExpiresAt!.year}" : "—"}',
                                  style: AppTextStyles.bodyMedium,
                                ),
                                if (user.proRemainingDays <= 7) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    'Plus que ${user.proRemainingDays} jour${user.proRemainingDays > 1 ? "s" : ""}',
                                    style: AppTextStyles.bodyMedium.copyWith(
                                      color: AppColors.error,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],

                        const SizedBox(height: 32),

                        // A PROPOS Section
                        SettingsSection(
                          title: 'A PROPOS',
                          children: [
                            SettingsItem(
                              icon: Icons.phone_outlined,
                              title: 'Contacter le support',
                              onTap: _contactSupport,
                            ),
                            const SizedBox(height: 12),
                            SettingsItem(
                              icon: Icons.share_outlined,
                              title: 'Partager l\'application',
                              onTap: _shareApp,
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.cardBackground,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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

                        // Logout button (if logged in)
                        if (!isGuest) ...[
                          const SizedBox(height: 32),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: _logout,
                              icon: Icon(Icons.logout, color: AppColors.error),
                              label: Text(
                                'Déconnexion',
                                style: AppTextStyles.button.copyWith(
                                  color: AppColors.error,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                              ),
                            ),
                          ),
                        ],

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Language option widget
class _LanguageOption extends StatelessWidget {
  final String language;
  final bool isSelected;
  final VoidCallback onTap;

  const _LanguageOption({
    required this.language,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : null,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.gray300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              language,
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            if (isSelected) Icon(Icons.check_circle, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}

// Vehicle option widget
class _VehicleOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _VehicleOption({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.1) : null,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.gray300,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textPrimary),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            if (isSelected) Icon(Icons.check_circle, color: AppColors.primary),
          ],
        ),
      ),
    );
  }
}

// Contact row widget
class _ContactRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ContactRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.textPrimary, size: 20),
        const SizedBox(width: 12),
        Expanded(child: Text(label, style: AppTextStyles.bodyMedium)),
      ],
    );
  }
}
