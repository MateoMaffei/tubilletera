import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class MainDrawer extends StatelessWidget {
  final String currentRoute;

  const MainDrawer({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            DrawerHeader(
              child: Center(
                child: Image.asset(
                  'assets/LogoSinEslogan_NBG.png',
                  height: 250,
                ),
              ),
            ),

            // Parte superior del menú
            _buildItem(context, Icons.home, 'Inicio', '/home'),
            _buildItem(context, Icons.list, 'Gastos', '/gastos'),
            _buildItem(context, Icons.attach_money, 'Ingresos', '/ingresos'),
            _buildItem(context, Icons.category, 'Categorías', '/categorias'),

            const Spacer(), // empuja lo de abajo

            // Parte inferior
            const Divider(),
            _buildItem(context, Icons.settings, 'Configuraciones', '/configuraciones'),
            ListTile(
              leading: const Icon(
                Icons.logout,
                color: Colors.red,
              ),
              title: const Text(
                'Cerrar sesión',
                style: TextStyle(
                  color: Colors.red
                ),
              ),
              onTap: () async {
                final box = Hive.box('usersBox');
                await box.delete('loggedUser');
                Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItem(BuildContext context, IconData icon, String title, String route) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      selected: currentRoute == route,
      onTap: () {
        if (currentRoute != route) {
          Navigator.pushReplacementNamed(context, route);
        } else {
          Navigator.pop(context); // cerrar Drawer si ya está en la página
        }
      },
    );
  }
}
