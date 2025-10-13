import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/child_model.dart';
import '../../../providers/child_provider.dart';
import '../../../providers/ai_provider.dart';
import '../../widgets/common/kova_mascot.dart';

class ProfessionalDashboard extends StatelessWidget {
  const ProfessionalDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    final childProvider = Provider.of<ChildProvider>(context);
    final aiProvider = Provider.of<AIProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel Profesional KOA'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.analytics),
            onPressed: () {
              Navigator.pushNamed(context, '/ai_analysis');
            },
            tooltip: 'Análisis IA',
          ),
          IconButton(
            icon: const Icon(Icons.bar_chart),
            onPressed: () {
              Navigator.pushNamed(context, '/reports');
            },
            tooltip: 'Reportes',
          ),
        ],
      ),
      body: _buildDashboardContent(childProvider, aiProvider, context),
    );
  }

  Widget _buildDashboardContent(
    ChildProvider childProvider,
    AIProvider aiProvider,
    BuildContext context,
  ) {
    // En una app real, aquí obtendrías la lista de alumnos del profesional
    final students = _getSampleStudents(); // Datos de ejemplo

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header de Bienvenida
          _buildWelcomeHeader(context),
          const SizedBox(height: 24),

          // Estadísticas Rápidas
          _buildQuickStats(students, context),
          const SizedBox(height: 24),

          // Lista de Alumnos
          Expanded(child: _buildStudentsList(students, aiProvider, context)),
        ],
      ),
    );
  }

  Widget _buildWelcomeHeader(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            const KovaMascot(expression: KovaExpression.happy, size: 80),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Bienvenido/a Profesional',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Monitorea el progreso de tus alumnos y ajusta sus terapias',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(
                        context,
                      ).colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickStats(List<ChildModel> students, BuildContext context) {
    final totalStudents = students.length;
    final activeThisWeek = students
        .where(
          (s) => DateTime.now().difference(s.progress.lastSession).inDays <= 7,
        )
        .length;
    final needAttention = students
        .where((s) => _calculateOverallProgress(s) < 0.4)
        .length;

    return Row(
      children: [
        _buildStatCard(
          'Total Alumnos',
          '$totalStudents',
          Icons.group,
          Colors.blue,
          context,
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          'Activos esta Semana',
          '$activeThisWeek',
          Icons.trending_up,
          Colors.green,
          context,
        ),
        const SizedBox(width: 12),
        _buildStatCard(
          'Necesitan Atención',
          '$needAttention',
          Icons.warning,
          Colors.orange,
          context,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    BuildContext context,
  ) {
    return Expanded(
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStudentsList(
    List<ChildModel> students,
    AIProvider aiProvider,
    BuildContext context,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mis Alumnos',
          style: Theme.of(
            context,
          ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: students.isEmpty
              ? _buildEmptyState(context)
              : ListView.builder(
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    final student = students[index];
                    return _buildStudentCard(student, aiProvider, context);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const KovaMascot(expression: KovaExpression.thinking, size: 120),
          const SizedBox(height: 24),
          Text(
            'Aún no tienes alumnos asignados',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Los alumnos que se te asignen aparecerán aquí para que puedas monitorear su progreso.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 32),
          FilledButton(
            onPressed: () {
              // En una app real, navegarías a la gestión de alumnos
              _showAddStudentDialog(context);
            },
            child: const Text('Agregar Primer Alumno'),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentCard(
    ChildModel student,
    AIProvider aiProvider,
    BuildContext context,
  ) {
    final progress = _calculateOverallProgress(student);
    final lastSession = _formatLastSession(student.progress.lastSession);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.child_care,
            color: Theme.of(context).colorScheme.primary,
            size: 24,
          ),
        ),
        title: Text(
          student.name,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              '${student.age} años • ${student.syndrome ?? "Sin diagnóstico"}',
            ),
            const SizedBox(height: 8),
            // Barra de progreso
            Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: progress,
                    backgroundColor: Colors.grey.shade300,
                    color: _getProgressColor(progress),
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: Theme.of(
                    context,
                  ).textTheme.labelSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              'Última sesión: $lastSession',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.arrow_forward_ios),
          onPressed: () {
            _navigateToStudentDetail(student, context);
          },
        ),
        onTap: () {
          _navigateToStudentDetail(student, context);
        },
      ),
    );
  }

  double _calculateOverallProgress(ChildModel student) {
    if (student.progress.skillLevels.isEmpty) return 0.0;
    return student.progress.skillLevels.values.reduce((a, b) => a + b) /
        student.progress.skillLevels.length;
  }

  String _formatLastSession(DateTime lastSession) {
    final difference = DateTime.now().difference(lastSession);
    if (difference.inDays == 0) return 'Hoy';
    if (difference.inDays == 1) return 'Ayer';
    if (difference.inDays < 7) return 'Hace ${difference.inDays} días';
    if (difference.inDays < 30) return 'Hace ${difference.inDays ~/ 7} semanas';
    return 'Hace ${difference.inDays ~/ 30} meses';
  }

  Color _getProgressColor(double progress) {
    if (progress >= 0.7) return Colors.green;
    if (progress >= 0.4) return Colors.orange;
    return Colors.red;
  }

  void _navigateToStudentDetail(ChildModel student, BuildContext context) {
    // Navegar a la pantalla de gestión del estudiante
    Navigator.pushNamed(context, '/student_management', arguments: student);
  }

  void _showAddStudentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agregar Alumno'),
        content: const Text(
          'En la versión completa, aquí podrás agregar nuevos alumnos '
          'escaneando un código QR o ingresando sus datos manualmente.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  // Datos de ejemplo para demostración
  List<ChildModel> _getSampleStudents() {
    return [
      ChildModel(
        id: '1',
        name: 'Ana García',
        age: 8,
        syndrome: 'TEA',
        learningStyle: 'visual',
        parentId: 'parent1',
        progress: ChildProgress(
          skillLevels: {
            'cognitive_skills': 0.7,
            'emotional_intelligence': 0.6,
            'attention_span': 0.8,
          },
          totalPlayTime: 1245,
          totalStars: 45,
          lastSession: DateTime.now().subtract(const Duration(days: 1)),
          recentSessions: [],
        ),
        settings: ChildSettings(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      ChildModel(
        id: '2',
        name: 'Carlos López',
        age: 7,
        syndrome: 'TDAH',
        learningStyle: 'kinestésico',
        parentId: 'parent2',
        progress: ChildProgress(
          skillLevels: {
            'cognitive_skills': 0.4,
            'emotional_intelligence': 0.3,
            'attention_span': 0.5,
          },
          totalPlayTime: 890,
          totalStars: 32,
          lastSession: DateTime.now().subtract(const Duration(days: 3)),
          recentSessions: [],
        ),
        settings: ChildSettings(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      ChildModel(
        id: '3',
        name: 'María Rodríguez',
        age: 9,
        syndrome: 'Síndrome de Down',
        learningStyle: 'auditivo',
        parentId: 'parent3',
        progress: ChildProgress(
          skillLevels: {
            'cognitive_skills': 0.6,
            'emotional_intelligence': 0.8,
            'attention_span': 0.5,
          },
          totalPlayTime: 1567,
          totalStars: 52,
          lastSession: DateTime.now().subtract(const Duration(days: 7)),
          recentSessions: [],
        ),
        settings: ChildSettings(),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    ];
  }
}
