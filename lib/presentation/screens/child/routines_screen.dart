import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:koa_app/core/models/child_model.dart';
import 'package:koa_app/core/models/routine_model.dart';
import 'package:koa_app/presentation/providers/routine_provider.dart';
import 'package:koa_app/presentation/providers/child_provider.dart';
import 'package:koa_app/presentation/widgets/common/kova_mascot.dart';
import 'package:koa_app/presentation/widgets/common/loading_indicator.dart';
import 'package:koa_app/presentation/widgets/common/custom_button.dart';
import 'package:koa_app/presentation/widgets/routines/routine_card.dart';
import 'package:koa_app/presentation/widgets/routines/routine_progress_widget.dart';
import 'package:koa_app/presentation/screens/routines/add_edit_routine_screen.dart';
import 'package:koa_app/presentation/screens/routines/routine_detail_screen.dart';

class RoutinesScreen extends StatefulWidget {
  const RoutinesScreen({super.key});

  @override
  State<RoutinesScreen> createState() => _RoutinesScreenState();
}

class _RoutinesScreenState extends State<RoutinesScreen> {
  String _selectedFilter = 'today'; // 'today', 'all', 'completed', 'active'
  String? _selectedChildId;

  @override
  void initState() {
    super.initState();
    _loadRoutines();
  }

  void _loadRoutines() {
    final childProvider = context.read<ChildProvider>();
    final routineProvider = context.read<RoutineProvider>();

    if (childProvider.children.isNotEmpty && _selectedChildId == null) {
      _selectedChildId = childProvider.children.first.id;
    }

    if (_selectedChildId != null) {
      routineProvider.loadRoutines(_selectedChildId!);
    }
  }

  List<RoutineModel> _getFilteredRoutines(List<RoutineModel> routines) {
    switch (_selectedFilter) {
      case 'today':
        return routines
            .where((routine) => routine.schedule.isScheduledToday)
            .toList();
      case 'completed':
        return routines.where((routine) => routine.isCompletedToday).toList();
      case 'active':
        return routines.where((routine) => routine.isActive).toList();
      case 'all':
      default:
        return routines;
    }
  }

  void _navigateToAddRoutine() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditRoutineScreen(childId: _selectedChildId!),
      ),
    ).then((_) => _loadRoutines());
  }

  void _navigateToRoutineDetail(RoutineModel routine) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RoutineDetailScreen(routine: routine),
      ),
    ).then((_) => _loadRoutines());
  }

  void _showChildSelectionDialog(List<ChildModel> children) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Seleccionar Niño'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: children.length,
            itemBuilder: (context, index) {
              final child = children[index];
              return ListTile(
                leading: const Icon(Icons.child_care),
                title: Text(child.name),
                subtitle: Text(
                  'Edad: ${child.age} ${child.syndrome != null ? '• ${child.syndrome}' : ''}',
                ),
                onTap: () {
                  setState(() => _selectedChildId = child.id);
                  _loadRoutines();
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final childProvider = context.watch<ChildProvider>();
    final routineProvider = context.watch<RoutineProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rutinas Diarias'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        actions: [
          // Selector de niño
          if (childProvider.children.length > 1)
            IconButton(
              onPressed: () =>
                  _showChildSelectionDialog(childProvider.children),
              icon: const Icon(Icons.child_care),
              tooltip: 'Cambiar niño',
            ),
          // Botón para agregar rutina
          IconButton(
            onPressed: _selectedChildId != null ? _navigateToAddRoutine : null,
            icon: const Icon(Icons.add),
            tooltip: 'Agregar rutina',
          ),
        ],
      ),
      body: _selectedChildId == null
          ? _buildNoChildrenState(childProvider)
          : _buildRoutinesContent(routineProvider),
      floatingActionButton: _selectedChildId != null
          ? FloatingActionButton(
              onPressed: _navigateToAddRoutine,
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildNoChildrenState(ChildProvider childProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const KovaMascot(expression: KovaExpression.thinking, size: 120),
          const SizedBox(height: 24),
          Text(
            'No hay niños registrados',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Agrega un niño para comenzar a crear rutinas personalizadas',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildRoutinesContent(RoutineProvider routineProvider) {
    if (routineProvider.isLoading) {
      return const LoadingIndicator();
    }

    if (routineProvider.error != null) {
      return _buildErrorState(routineProvider);
    }

    final routines = _getFilteredRoutines(routineProvider.routines);

    return Column(
      children: [
        // Filtros y estadísticas
        _buildFiltersAndStats(routineProvider, routines),

        // Lista de rutinas
        Expanded(
          child: routines.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: () async => _loadRoutines(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: routines.length,
                    itemBuilder: (context, index) {
                      final routine = routines[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: RoutineCard(
                          routine: routine,
                          onTap: () => _navigateToRoutineDetail(routine),
                          onToggleStatus: (isActive) {
                            routineProvider.updateRoutine(
                              routine.copyWith(isActive: isActive),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildFiltersAndStats(
    RoutineProvider routineProvider,
    List<RoutineModel> routines,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[50],
      child: Column(
        children: [
          // Filtros rápidos
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('Hoy', 'today'),
                const SizedBox(width: 8),
                _buildFilterChip('Todas', 'all'),
                const SizedBox(width: 8),
                _buildFilterChip('Completadas', 'completed'),
                const SizedBox(width: 8),
                _buildFilterChip('Activas', 'active'),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Estadísticas rápidas
          RoutineProgressWidget(routines: routineProvider.routines),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    return ChoiceChip(
      label: Text(label),
      selected: _selectedFilter == value,
      onSelected: (selected) {
        setState(() => _selectedFilter = value);
      },
      selectedColor: Colors.green,
      labelStyle: TextStyle(
        color: _selectedFilter == value ? Colors.white : Colors.black,
      ),
    );
  }

  Widget _buildErrorState(RoutineProvider routineProvider) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Error cargando rutinas',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            routineProvider.error!,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          CustomButton(
            onPressed: _loadRoutines,
            text: 'Reintentar',
            icon: Icons.refresh,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const KovaMascot(expression: KovaExpression.thinking, size: 120),
          const SizedBox(height: 24),
          Text(
            _selectedFilter == 'today'
                ? 'No hay rutinas para hoy'
                : 'No hay rutinas ${_selectedFilter == 'completed' ? 'completadas' : ''}',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            _selectedFilter == 'today'
                ? 'Las rutinas programadas para hoy aparecerán aquí'
                : 'Crea tu primera rutina para comenzar',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 24),
          if (_selectedFilter != 'today')
            CustomButton(
              onPressed: _navigateToAddRoutine,
              text: 'Crear Primera Rutina',
              icon: Icons.add,
            ),
        ],
      ),
    );
  }
}
