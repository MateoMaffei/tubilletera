import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';
import 'package:tubilletera/theme/app_colors.dart';

enum AppSection { home, gastos, ingresos, terceros, categorias }

class AppShell extends StatelessWidget {
  final Widget body;
  final AppSection section;
  final Widget? floatingActionButton;
  final String title;
  final EdgeInsetsGeometry contentPadding;

  const AppShell({
    super.key,
    required this.body,
    required this.section,
    this.floatingActionButton,
    this.title = '',
    this.contentPadding = const EdgeInsets.symmetric(horizontal: 20),
  });

  @override
  Widget build(BuildContext context) {
    final usersBox = Hive.box('usersBox');
    final email = usersBox.get('loggedUser');
    final user = email != null ? usersBox.get(email) : null;
    final nombre = (user?['nombre'] ?? 'Usuario') as String;
    final inicial = nombre.isNotEmpty ? nombre.characters.first.toUpperCase() : '?';
    final hoy = DateFormat('EEEE d MMM', 'es_AR').format(DateTime.now());

    return Scaffold(
      backgroundColor: AppColors.background,
      extendBody: true,
      floatingActionButton: floatingActionButton,
      body: Stack(
        children: [
          Positioned(
            top: -120,
            left: -80,
            child: Container(
              width: 320,
              height: 320,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [AppColors.gradientStart, AppColors.gradientEnd],
                  radius: 0.8,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hola, $nombre',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textPrimary,
                                  ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceAlt,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(color: AppColors.border),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.blur_on, size: 16, color: AppColors.primary.withOpacity(0.9)),
                                      const SizedBox(width: 6),
                                      Text(
                                        title.isNotEmpty ? title : 'Panel',
                                        style: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  hoy,
                                  style: const TextStyle(color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/configuraciones'),
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [AppColors.primary, AppColors.accent],
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 22,
                            backgroundColor: AppColors.surface,
                            child: Text(
                              inicial,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: contentPadding,
                    child: body,
                  ),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _FloatingNavBar(current: section),
    );
  }
}

class _FloatingNavBar extends StatelessWidget {
  final AppSection current;

  const _FloatingNavBar({required this.current});

  int get _index => AppSection.values.indexOf(current);

  void _navigate(BuildContext context, int index) {
    final target = AppSection.values[index];
    if (target == current) return;
    switch (target) {
      case AppSection.home:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case AppSection.gastos:
        Navigator.pushReplacementNamed(context, '/gastos');
        break;
      case AppSection.ingresos:
        Navigator.pushReplacementNamed(context, '/ingresos');
        break;
      case AppSection.terceros:
        Navigator.pushReplacementNamed(context, '/gastos_terceros');
        break;
      case AppSection.categorias:
        Navigator.pushReplacementNamed(context, '/categorias');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppColors.border),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 18,
              offset: Offset(0, 8),
            )
          ],
        ),
        child: NavigationBar(
          height: 70,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedIndex: _index,
          indicatorColor: AppColors.primary.withOpacity(0.15),
          onDestinationSelected: (i) => _navigate(context, i),
          destinations: const [
            NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Inicio'),
            NavigationDestination(icon: Icon(Icons.receipt_long_outlined), selectedIcon: Icon(Icons.receipt_long), label: 'Gastos'),
            NavigationDestination(icon: Icon(Icons.moving_outlined), selectedIcon: Icon(Icons.moving), label: 'Ingresos'),
            NavigationDestination(icon: Icon(Icons.people_alt_outlined), selectedIcon: Icon(Icons.people_alt), label: 'Terceros'),
            NavigationDestination(icon: Icon(Icons.category_outlined), selectedIcon: Icon(Icons.category), label: 'Categorías'),
          ],
        ),
      ),
    );
  }
}
