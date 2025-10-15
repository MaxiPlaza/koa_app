// lib/presentation/screens/parent/parent_dashboard.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:koa_app/presentation/providers/auth_provider.dart';
import 'package:koa_app/presentation/providers/child_provider.dart';
import 'package:koa_app/data/models/child_model.dart';
import 'package:koa_app/data/models/user_model.dart';
import 'package:koa_app/core/theme/colors.dart';
import 'package:koa_app/core/theme/text_styles.dart';
import 'package:koa_app/core/constants/constants/app_constants.dart';
import 'package:koa_app/presentation/widgets/common/custom_button.dart';
import 'package:koa_app/presentation/widgets/common/loading_indicator.dart';
import 'package:koa_app/presentation/widgets/parent/progress_chart.dart';

class ParentDashboard extends StatefulWidget {
  const ParentDashboard({super.key});

  @override
  State<ParentDashboard> createState() => _ParentDashboardState();
}

class _ParentDashboardState extends State<ParentDashboard> {
  int _selectedChildIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final childProvider = Provider.of<ChildProvider>(context, listen: false);

    if (authProvider.currentUser != null) {
      // Cargar hijos del usuario
      // childProvider.loadChildren(authProvider.currentUser!.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final childProvider = Provider.of<ChildProvider>(context);
    final currentUser = authProvider.currentUser;

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: _buildAppBar(currentUser),
      body: _buildBody(childProvider, currentUser),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  AppBar _buildAppBar(UserModel? currentUser) {
    return AppBar(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '¡Hola, ${currentUser?.name.split(' ').first ?? 'Usuario'}!',
            style: AppTextStyles.displaySmall.copyWith(
              color: AppColors.textDark,
            ),
          ),
          Text(
            'Bienvenido a KOVA',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textGray,
            ),
          ),
        ],
      ),
      backgroundColor: Colors.transparent,
      elevation: 0,
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none),
          onPressed: _showNotifications,
        ),
        IconButton(
          icon: const Icon(Icons.settings),
          onPressed: _goToSettings,
        ),
      ],
    );
  }

  Widget _buildBody(ChildProvider childProvider, UserModel? currentUser) {
    if (childProvider.isLoading) {
      return const Center(child: LoadingIndicator());
    }

    // Datos de ejemplo para demostración
    final demoChildren = _getDemoChildren();
    final selectedChild =
        demoChildren.isNotEmpty ? demoChildren[_selectedChildIndex] : null;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Panel de Hijos
          _buildChildrenPanel(demoChildren),
          const SizedBox(height: 24),

          if (selectedChild != null) ...[
            // Resumen de Progreso
            _buildProgressSummary(selectedChild),
            const SizedBox(height: 24),

            // Estadísticas Rápidas
            _buildQuickStats(selectedChild),
            const SizedBox(height: 24),

            // Gráfico de Progreso
            _buildProgressChart(selectedChild),
            const SizedBox(height: 24),

            // Actividad Reciente
            _buildRecentActivity(selectedChild),
            const SizedBox(height: 24),
          ],

          // Acciones Rápidas
          _buildQuickActions(),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildChildrenPanel(List<ChildModel> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Tus Hijos',
              style: AppTextStyles.displaySmall.copyWith(
                color: AppColors.textDark,
              ),
            ),
            const Spacer(),
            CustomButton(
              onPressed: _addNewChild,
              text: 'Agregar Hijo',
              isPrimary: false,
              isExpanded: false,
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (children.isEmpty) _buildEmptyChildrenState(),
        if (children.isNotEmpty) _buildChildrenList(children),
      ],
    );
  }

  Widget _buildEmptyChildrenState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.textGray.withValues(alpha: 0.2)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.child_friendly,
            size: 64,
            color: AppColors.textGray.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Aún no tienes hijos agregados',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textGray,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          CustomButton(
            onPressed: _addNewChild,
            text: 'Agregar Primer Hijo',
          ),
        ],
      ),
    );
  }

  Widget _buildChildrenList(List<ChildModel> children) {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: children.length,
        itemBuilder: (context, index) {
          final child = children[index];
          final isSelected = index == _selectedChildIndex;

          return GestureDetector(
            onTap: () => setState(() => _selectedChildIndex = index),
            child: Container(
              width: 100,
              margin: EdgeInsets.only(
                right: 16,
                left: index == 0 ? 0 : 0,
              ),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryGreen : Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
                border: Border.all(
                  color:
                      isSelected ? AppColors.primaryGreen : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: isSelected
                        ? Colors.white
                        : AppColors.primaryGreen.withValues(alpha: 0.2),
                    child: Text(
                      child.name[0].toUpperCase(),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? AppColors.primaryGreen
                            : AppColors.textDark,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    child.name,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : AppColors.textDark,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${child.age} años',
                    style: TextStyle(
                      fontSize: 10,
                      color: isSelected
                          ? Colors.white.withValues(alpha: 0.8)
                          : AppColors.textGray,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProgressSummary(ChildModel child) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Progreso de ${child.name}',
                style: AppTextStyles.displaySmall.copyWith(
                  color: AppColors.textDark,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  child.learningStyle.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryGreen,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildProgressItem('Tiempo Total',
                  '${child.progress.totalPlayTime} min', Icons.timer),
              _buildProgressItem(
                  'Estrellas', '${child.progress.totalStars}', Icons.star),
              _buildProgressItem('Sesiones',
                  '${child.progress.recentSessions.length}', Icons.play_arrow),
              _buildProgressItem(
                  'Nivel',
                  _calculateLevel(child.progress.skillLevels),
                  Icons.leaderboard),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressItem(String title, String value, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 20, color: AppColors.primaryGreen),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textDark,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textGray,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickStats(ChildModel child) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Estadísticas Rápidas',
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildStatCard(
                  'Habilidades Desarrolladas', '8/12', AppColors.primaryGreen),
              const SizedBox(width: 12),
              _buildStatCard(
                  'Rutinas Completadas', '15/20', AppColors.secondaryPurple),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildStatCard(
                  'Logros Desbloqueados', '12', AppColors.kovaOrange),
              const SizedBox(width: 12),
              _buildStatCard('Días Consecutivos', '7', AppColors.primaryBlue),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textGray,
              ),
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressChart(ChildModel child) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Progreso por Habilidad',
            style: AppTextStyles.labelLarge.copyWith(
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 16),
          SkillProgressChart(
            skillProgress: child.progress.skillLevels,
            height: 200,
            showLabels: true,
            showValues: true,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(ChildModel child) {
    final recentSessions = child.progress.recentSessions.take(3).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Actividad Reciente',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.textDark,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: _viewAllActivity,
                child: const Text(
                  'Ver Todo',
                  style: TextStyle(color: AppColors.primaryGreen),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (recentSessions.isEmpty) _buildEmptyActivityState(),
          if (recentSessions.isNotEmpty)
            ...recentSessions.map((session) => _buildActivityItem(session)),
        ],
      ),
    );
  }

  Widget _buildEmptyActivityState() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Icon(
            Icons.play_arrow_outlined,
            size: 48,
            color: AppColors.textGray.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 8),
          Text(
            'Aún no hay actividad',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textGray,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Comienza una actividad para ver el progreso aquí',
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textGray,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem(Session session) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primaryGreen.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.play_arrow,
          color: AppColors.primaryGreen,
          size: 20,
        ),
      ),
      title: Text(
        session.activityName ?? 'Actividad',
        style: AppTextStyles.bodyMedium.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        '${session.duration} min • ${session.date?.day}/${session.date?.month}',
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textGray,
        ),
      ),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          '${(session.score ?? 0).toStringAsFixed(0)}%',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: AppColors.success,
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Acciones Rápidas',
          style: AppTextStyles.labelLarge.copyWith(
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                'Ver Reporte',
                Icons.assessment,
                AppColors.primaryGreen,
                _generateReport,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                'Crear Rutina',
                Icons.schedule,
                AppColors.secondaryPurple,
                _createRoutine,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionCard(
                'Jugar Ahora',
                Icons.play_arrow,
                AppColors.kovaOrange,
                _startActivity,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildActionCard(
                'Asistente KOA',
                Icons.smart_toy,
                AppColors.primaryBlue,
                _openKoaAssistant,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionCard(
      String title, IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Icon(icon, size: 24, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  BottomNavigationBar _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: 0,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: AppColors.primaryGreen,
      unselectedItemColor: AppColors.textGray,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: 'Inicio',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.assessment),
          label: 'Progreso',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.family_restroom),
          label: 'Hijos',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Ajustes',
        ),
      ],
      onTap: _onBottomNavigationTap,
    );
  }

  // Métodos de navegación y acciones
  void _onBottomNavigationTap(int index) {
    // Implementar navegación entre pantallas
  }

  void _showNotifications() {
    // Navegar a notificaciones
  }

  void _goToSettings() {
    Navigator.pushNamed(context, AppConstants.settingsRoute);
  }

  void _addNewChild() {
    // Navegar a agregar hijo
  }

  void _viewAllActivity() {
    // Navegar a actividad completa
  }

  void _generateReport() {
    // Navegar a generar reporte
  }

  void _createRoutine() {
    // Navegar a crear rutina
  }

  void _startActivity() {
    // Navegar a actividades
  }

  void _openKoaAssistant() {
    // Navegar a asistente KOA
  }

  // Métodos auxiliares
  String _calculateLevel(Map<String, double> skillLevels) {
    if (skillLevels.isEmpty) return '0';
    final average =
        skillLevels.values.reduce((a, b) => a + b) / skillLevels.length;
    return (average * 10).toStringAsFixed(0);
  }

  List<ChildModel> _getDemoChildren() {
    // Datos de demostración - reemplazar con datos reales
    return [
      ChildModel(
        id: 'child1',
        name: 'Leo Martínez',
        age: 8,
        syndrome: 'TEA',
        learningStyle: 'visual',
        parentId: 'user1',
        progress: ChildProgress(
          skillLevels: {
            'matematica': 0.7,
            'lenguaje': 0.8,
            'social': 0.6,
            'memoria': 0.9,
          },
          totalPlayTime: 1245,
          totalStars: 45,
          lastSession: DateTime.now(),
          recentSessions: [
            Session(
              activityName: 'Memory Cards',
              date: DateTime.now().subtract(const Duration(days: 1)),
              duration: 15,
              score: 85.0,
            ),
            Session(
              activityName: 'Emotional Match',
              date: DateTime.now().subtract(const Duration(days: 2)),
              duration: 20,
              score: 72.0,
            ),
            Session(
              activityName: 'Pattern Sequence',
              date: DateTime.now().subtract(const Duration(days: 3)),
              duration: 12,
              score: 90.0,
            ),
          ],
        ),
        settings: ChildSettings(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }
}
