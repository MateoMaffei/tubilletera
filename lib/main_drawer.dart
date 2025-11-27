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
            _buildItem(context, Icons.home_outlined, 'Inicio', '/home'),
            _buildItem(context, Icons.receipt_long_outlined, 'Gastos', '/gastos'),
            _buildItem(context, Icons.attach_money_outlined, 'Ingresos', '/ingresos'),
            _buildItem(context, Icons.people_outline, 'Deudores', '/deudores'),
            _buildItem(context, Icons.category_outlined, 'Categorías', '/categorias'),

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
    final selected = currentRoute == route;
    return ListTile(
      leading: Icon(
        icon,
        color: selected ? Theme.of(context).primaryColor : Colors.black54,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: selected ? Theme.of(context).primaryColor : Colors.black87,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
        ),
      ),
      selected: selected,
      selectedTileColor: Theme.of(context).primaryColor.withOpacity(0.08),
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
