// lib/presentation/screens/common/settings_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:koa_app/presentation/providers/auth_provider.dart';
import 'package:koa_app/presentation/providers/ai_provider.dart';
import 'package:koa_app/presentation/providers/theme_provider.dart';
import 'package:koa_app/core/services/local_storage.dart';
import 'package:koa_app/core/utils/helpers.dart';
import 'package:koa_app/core/utils/formatters.dart';
import 'package:koa_app/core/constants/constants/app_constants.dart';
import 'package:koa_app/data/models/user_model.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final LocalStorage _localStorage = LocalStorage();
  bool _notificationsEnabled = true;
  bool _aiSuggestionsEnabled = true;
  bool _weeklyReportsEnabled = true;
  bool _progressAlertsEnabled = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    _notificationsEnabled = await _localStorage.getBoolSetting(
      'notifications',
      defaultValue: true,
    );
    _aiSuggestionsEnabled = await _localStorage.getBoolSetting(
      'aiSuggestions',
      defaultValue: true,
    );
    _weeklyReportsEnabled = await _localStorage.getBoolSetting(
      'weeklyReports',
      defaultValue: true,
    );
    _progressAlertsEnabled = await _localStorage.getBoolSetting(
      'progressAlerts',
      defaultValue: true,
    );
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final aiProvider = Provider.of<AIProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final currentUser = authProvider.currentUser;

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        title: const Text(
          'Configuración',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con info del usuario
            _buildUserHeader(currentUser),

            const SizedBox(height: 24),

            // Preferencias de Interfaz y Accesibilidad
            _buildSectionTitle(
              'Preferencias de Interfaz y Accesibilidad',
              Icons.accessibility_new,
            ),
            _buildSettingCard(
              children: [
                _buildSwitchSetting(
                  title: 'Modo Oscuro',
                  subtitle: 'Activar tema oscuro',
                  value: themeProvider.isDarkMode,
                  onChanged: (value) => themeProvider.toggleDarkMode(value),
                ),
                _buildDivider(),
                _buildSwitchSetting(
                  title: 'Fuente OpenDyslexic',
                  subtitle: 'Fuente para dislexia',
                  value: themeProvider.isDyslexicFont,
                  onChanged: (value) => themeProvider.toggleDyslexicFont(value),
                ),
                _buildDivider(),
                _buildSwitchSetting(
                  title: 'Reducir Animaciones',
                  subtitle: 'Menos efectos visuales',
                  value: themeProvider.reduceAnimations,
                  onChanged: (value) =>
                      themeProvider.toggleReduceAnimations(value),
                ),
                _buildDivider(),
                _buildSwitchSetting(
                  title: 'Desactivar Sonidos Fuertes',
                  subtitle: 'Sonidos suaves para sensibilidad',
                  value: themeProvider.disableLoudSounds,
                  onChanged: (value) =>
                      themeProvider.toggleDisableLoudSounds(value),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Notificaciones y Alertas
            _buildSectionTitle('Notificaciones y Alertas', Icons.notifications),
            _buildSettingCard(
              children: [
                _buildSwitchSetting(
                  title: 'Notificaciones de Rutinas',
                  subtitle: 'Recordatorios diarios',
                  value: _notificationsEnabled,
                  onChanged: (value) => _updateSetting('notifications', value),
                ),
                _buildDivider(),
                _buildSwitchSetting(
                  title: 'Sugerencias de IA',
                  subtitle: 'Recomendaciones personalizadas',
                  value: _aiSuggestionsEnabled,
                  onChanged: (value) => _updateSetting('aiSuggestions', value),
                ),
                _buildDivider(),
                _buildSwitchSetting(
                  title: 'Reportes Semanales',
                  subtitle: 'Resumen de progreso semanal',
                  value: _weeklyReportsEnabled,
                  onChanged: (value) => _updateSetting('weeklyReports', value),
                ),
                _buildDivider(),
                _buildSwitchSetting(
                  title: 'Alertas de Progreso',
                  subtitle: 'Logros y mejoras',
                  value: _progressAlertsEnabled,
                  onChanged: (value) => _updateSetting('progressAlerts', value),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Suscripción
            _buildSectionTitle('Suscripción', Icons.workspace_premium),
            _buildSubscriptionCard(currentUser),

            const SizedBox(height: 24),

            // Asistente KOA
            _buildSectionTitle('Tu Asistente KOA', Icons.smart_toy),
            _buildKoaAssistantCard(aiProvider),

            const SizedBox(height: 24),

            // Gestión de Cuenta
            _buildSectionTitle('Configuración', Icons.settings),
            _buildAccountSettings(authProvider),

            const SizedBox(height: 32),

            // Información de la App
            _buildAppInfo(),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildUserHeader(UserModel? user) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                user?.name.substring(0, 1).toUpperCase() ?? 'U',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.name ?? 'Usuario',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? 'email@ejemplo.com',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      user?.userType == 'parent'
                          ? 'Padre/Madre'
                          : 'Profesional',
                      style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                // Navegar a edición de perfil
                Helpers.showSnackBar(context, 'Editar perfil - Próximamente');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingCard({required List<Widget> children}) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildSwitchSetting({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return SwitchListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: Theme.of(context).colorScheme.primary,
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, thickness: 0.5);
  }

  Widget _buildSubscriptionCard(UserModel? user) {
    final subscription = user?.subscription;
    final isActive = subscription?.isActive ?? false;
    final planType = subscription?.planType ?? 'Gratuito';
    final price = subscription?.price ?? 0.0;

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.workspace_premium,
                  color: isActive ? Colors.amber : Colors.grey,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Plan $planType',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        isActive ? 'Estado: Activo' : 'Estado: Inactivo',
                        style: TextStyle(
                          color: isActive ? Colors.green : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: isActive
                        ? Colors.green.withOpacity(0.1)
                        : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    isActive ? 'ACTIVO' : 'GRATUITO',
                    style: TextStyle(
                      color: isActive ? Colors.green : Colors.orange,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            if (isActive && price > 0) ...[
              const SizedBox(height: 12),
              Text(
                'Precio: ${Formatters.formatCurrency(price)}/mes',
                style: const TextStyle(fontSize: 14),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _showSubscriptionManagement(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Gestionar Suscripción'),
                  ),
                ),
                const SizedBox(width: 8),
                if (!isActive)
                  OutlinedButton(
                    onPressed: () {
                      // Navegar a pantalla de planes
                      Helpers.showSnackBar(
                        context,
                        'Ver planes de suscripción - Próximamente',
                      );
                    },
                    child: const Text('Mejorar Plan'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildKoaAssistantCard(AIProvider aiProvider) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.smart_toy, color: Colors.blue, size: 24),
                const SizedBox(width: 12),
                const Text(
                  'Asistente KOA',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'IA',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'KOA está aquí para ayudarte con el progreso de tus hijos, crear rutinas personalizadas y responder tus preguntas.',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    _openKoaChat(context);
                  },
                  icon: const Icon(Icons.chat),
                  label: const Text('Hablar con KOA'),
                ),
                OutlinedButton.icon(
                  onPressed: () {
                    _openKoaHistory(context);
                  },
                  icon: const Icon(Icons.history),
                  label: const Text('Ver Historial'),
                ),
                if (aiProvider.isModelLoaded)
                  OutlinedButton.icon(
                    onPressed: () {
                      _testKoaAnalysis(context, aiProvider);
                    },
                    icon: const Icon(Icons.psychology),
                    label: const Text('Probar IA'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSettings(AuthProvider authProvider) {
    return Card(
      elevation: 2,
      child: Column(
        children: [
          _buildSettingItem(
            icon: Icons.person,
            title: 'Mi Perfil',
            subtitle: 'Editar información personal',
            onTap: () {
              Helpers.showSnackBar(context, 'Editar perfil - Próximamente');
            },
          ),
          _buildDivider(),
          _buildSettingItem(
            icon: Icons.child_care,
            title: 'Perfiles de Hijos',
            subtitle: 'Gestionar perfiles de niños',
            onTap: () {
              Helpers.showSnackBar(context, 'Gestión de hijos - Próximamente');
            },
          ),
          _buildDivider(),
          _buildSettingItem(
            icon: Icons.family_restroom,
            title: 'Panel de Familia',
            subtitle: 'Gestionar miembros familiares',
            onTap: () {
              Helpers.showSnackBar(context, 'Panel familiar - Próximamente');
            },
          ),
          _buildDivider(),
          _buildSettingItem(
            icon: Icons.help,
            title: 'Ayuda y Soporte',
            subtitle: 'Centro de ayuda y FAQs',
            onTap: () {
              Helpers.showSnackBar(context, 'Ayuda - Próximamente');
            },
          ),
          _buildDivider(),
          _buildSettingItem(
            icon: Icons.bug_report,
            title: 'Reportar Problema',
            subtitle: 'Enviar feedback o reportar error',
            onTap: () {
              _showReportDialog(context);
            },
          ),
          _buildDivider(),
          _buildSettingItem(
            icon: Icons.privacy_tip,
            title: 'Privacidad y Seguridad',
            subtitle: 'Configuración de privacidad',
            onTap: () {
              Helpers.showSnackBar(context, 'Privacidad - Próximamente');
            },
          ),
          _buildDivider(),
          _buildSettingItem(
            icon: Icons.exit_to_app,
            title: 'Cerrar Sesión',
            subtitle: 'Salir de la aplicación',
            color: Colors.red,
            onTap: () {
              _showLogoutDialog(context, authProvider);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: color ?? Theme.of(context).colorScheme.primary,
      ),
      title: Text(title, style: TextStyle(color: color)),
      subtitle: Text(
        subtitle,
        style: TextStyle(color: color?.withOpacity(0.7) ?? Colors.grey[600]),
      ),
      trailing:
          color == null ? const Icon(Icons.arrow_forward_ios, size: 16) : null,
      onTap: onTap,
    );
  }

  Widget _buildAppInfo() {
    return Center(
      child: Column(
        children: [
          Text(
            'KOVA v${AppConstants.appVersion}',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 4),
          Text(
            '© 2024 KOVA App - Todos los derechos reservados',
            style: TextStyle(fontSize: 12, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  void _updateSetting(String setting, bool value) async {
    setState(() {
      switch (setting) {
        case 'notifications':
          _notificationsEnabled = value;
          break;
        case 'aiSuggestions':
          _aiSuggestionsEnabled = value;
          break;
        case 'weeklyReports':
          _weeklyReportsEnabled = value;
          break;
        case 'progressAlerts':
          _progressAlertsEnabled = value;
          break;
      }
    });

    await _localStorage.saveSetting(setting, value);
    Helpers.showSnackBar(context, 'Configuración actualizada');
  }

  void _showSubscriptionManagement(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gestión de Suscripción'),
        content: const Text('¿Qué te gustaría hacer con tu suscripción?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Helpers.showSnackBar(context, 'Cambiar plan - Próximamente');
            },
            child: const Text('Cambiar Plan'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showCancelSubscriptionDialog(context);
            },
            child: const Text(
              'Cancelar Suscripción',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _showCancelSubscriptionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cancelar Suscripción'),
        content: const Text(
          '¿Estás seguro de que quieres cancelar tu suscripción? Perderás acceso a funciones premium.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Mantener Suscripción'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Helpers.showSnackBar(
                context,
                'Suscripción cancelada - Próximamente',
              );
            },
            child: const Text(
              'Cancelar Suscripción',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  void _openKoaChat(BuildContext context) {
    Helpers.showSnackBar(context, 'Chat con KOA - Próximamente');
  }

  void _openKoaHistory(BuildContext context) {
    Helpers.showSnackBar(context, 'Historial de KOA - Próximamente');
  }

  void _testKoaAnalysis(BuildContext context, AIProvider aiProvider) {
    Helpers.showSnackBar(
      context,
      'Análisis IA: ${aiProvider.isModelLoaded ? "Activo" : "Inactivo"}',
    );
  }

  void _showReportDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Reportar Problema',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text('Describe el problema o sugerencia:'),
            const SizedBox(height: 12),
            TextField(
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Escribe aquí...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      Helpers.showSnackBar(
                        context,
                        'Reporte enviado. ¡Gracias!',
                      );
                    },
                    child: const Text('Enviar Reporte'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, AuthProvider authProvider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await authProvider.signOut();
              // El AuthProvider ya debería manejar la navegación al login
              Helpers.showSnackBar(context, 'Sesión cerrada');
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'Cerrar Sesión',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
