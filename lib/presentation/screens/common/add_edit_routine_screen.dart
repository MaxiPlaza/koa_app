import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:koa_app/data/models/routine_model.dart';
import 'package:koa_app/presentation/providers/routine_provider.dart';
import 'package:koa_app/presentation/widgets/common/kova_mascot.dart';
import 'package:koa_app/presentation/widgets/common/custom_button.dart';
import "package:koa_app/data/models/routine_task_model.dart";

class AddEditRoutineScreen extends StatefulWidget {
  final String childId;
  final RoutineModel? routine;

  const AddEditRoutineScreen({super.key, required this.childId, this.routine});

  @override
  State<AddEditRoutineScreen> createState() => _AddEditRoutineScreenState();
}

class _AddEditRoutineScreenState extends State<AddEditRoutineScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Valores por defecto para nueva rutina
  String _selectedIcon = '📝';
  String _selectedColor = '#10B981';
  List<RoutineTask> _tasks = [];
  RoutineSchedule _schedule = RoutineSchedule(
    daysOfWeek: [1, 2, 3, 4, 5], // Lunes a Viernes
    startTime: const TimeOfDay(hour: 8, minute: 0),
    endTime: const TimeOfDay(hour: 9, minute: 0),
    hasReminder: true,
    reminderMinutesBefore: 15,
  );

  // Opciones predefinidas
  final List<String> _icons = [
    '📝',
    '🌅',
    '🌙',
    '🛁',
    '🍳',
    '📚',
    '🎮',
    '👕',
    '🦷',
    '🚿',
    '👐',
    '🌬️',
  ];
  final List<String> _colors = [
    '#10B981',
    '#7E22CE',
    '#F97316',
    '#3B82F6',
    '#EF4444',
    '#8B5CF6',
  ];

  @override
  void initState() {
    super.initState();

    // Si estamos editando, cargar datos existentes
    if (widget.routine != null) {
      _nameController.text = widget.routine!.name;
      _descriptionController.text = widget.routine!.description;
      _selectedIcon = widget.routine!.icon;
      _selectedColor = widget.routine!.color;
      _tasks = List.from(widget.routine!.tasks);
      _schedule = widget.routine!.schedule;
    } else {
      // Para nueva rutina, usar tareas predefinidas según el tipo
      _tasks = PredefinedRoutines.morningRoutineTEA;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _saveRoutine() async {
    if (_formKey.currentState!.validate() && _tasks.isNotEmpty) {
      final routineProvider = context.read<RoutineProvider>();

      final routine = RoutineModel(
        id: widget.routine?.id ??
            DateTime.now().millisecondsSinceEpoch.toString(),
        childId: widget.childId,
        name: _nameController.text,
        description: _descriptionController.text,
        icon: _selectedIcon,
        color: _selectedColor,
        tasks: _tasks,
        schedule: _schedule,
        createdAt: widget.routine?.createdAt ?? DateTime.now(),
        updatedAt: DateTime.now(),
      );

      try {
        if (widget.routine == null) {
          await routineProvider.addRoutine(routine);
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Rutina creada exitosamente')),
          );
        } else {
          await routineProvider.updateRoutine(routine);
          // ignore: use_build_context_synchronously
          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Rutina actualizada exitosamente')),
          );
        }
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } else if (_tasks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Agrega al menos una tarea a la rutina')),
      );
    }
  }

  void _addNewTask() {
    showDialog(
      context: context,
      builder: (context) => _TaskEditorDialog(
        onSave: (task) {
          setState(() {
            _tasks.add(task.copyWith(order: _tasks.length));
          });
        },
      ),
    );
  }

  void _editTask(int index) {
    showDialog(
      context: context,
      builder: (context) => _TaskEditorDialog(
        task: _tasks[index],
        onSave: (updatedTask) {
          setState(() {
            _tasks[index] = updatedTask;
          });
        },
      ),
    );
  }

  void _deleteTask(int index) {
    setState(() {
      _tasks.removeAt(index);
      // Reordenar las tareas restantes
      for (int i = 0; i < _tasks.length; i++) {
        _tasks[i] = _tasks[i].copyWith(order: i);
      }
    });
  }

  void _reorderTask(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final task = _tasks.removeAt(oldIndex);
    setState(() {
      _tasks.insert(newIndex, task);
      // Actualizar el orden de todas las tareas
      for (int i = 0; i < _tasks.length; i++) {
        _tasks[i] = _tasks[i].copyWith(order: i);
      }
    });
  }

  Future<void> _selectSchedule() async {
    final result = await showDialog<RoutineSchedule>(
      context: context,
      builder: (context) => _ScheduleEditorDialog(schedule: _schedule),
    );

    if (result != null) {
      setState(() {
        _schedule = result;
      });
    }
  }

  void _loadPredefinedRoutine(String type) {
    setState(() {
      switch (type) {
        case 'morning':
          _tasks = PredefinedRoutines.morningRoutineTEA;
          _selectedIcon = '🌅';
          _selectedColor = '#10B981';
          _nameController.text = 'Rutina Matutina';
          _descriptionController.text = 'Para empezar el día con energía';
          break;
        case 'evening':
          _tasks = PredefinedRoutines.eveningRoutineTDAH;
          _selectedIcon = '🌙';
          _selectedColor = '#7E22CE';
          _nameController.text = 'Rutina Nocturna';
          _descriptionController.text = 'Para prepararse para dormir';
          break;
        case 'sensory':
          _tasks = PredefinedRoutines.sensoryRoutine;
          _selectedIcon = '👐';
          _selectedColor = '#F97316';
          _nameController.text = 'Rutina Sensorial';
          _descriptionController.text = 'Para regular el sistema sensorial';
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.routine == null ? 'Crear Rutina' : 'Editar Rutina'),
        actions: [
          IconButton(
            onPressed: _saveRoutine,
            icon: const Icon(Icons.save),
            tooltip: 'Guardar rutina',
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Plantillas predefinidas
            _buildPredefinedTemplates(),
            const SizedBox(height: 24),

            // Información básica
            _buildBasicInfoSection(),
            const SizedBox(height: 24),

            // Apariencia
            _buildAppearanceSection(),
            const SizedBox(height: 24),

            // Tareas
            _buildTasksSection(),
            const SizedBox(height: 24),

            // Horario
            _buildScheduleSection(),
            const SizedBox(height: 32),

            // Botón de guardar
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildPredefinedTemplates() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Plantillas Predefinidas',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Elige una plantilla para comenzar rápido:',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildTemplateChip('Matutina', 'morning', '🌅'),
                _buildTemplateChip('Nocturna', 'evening', '🌙'),
                _buildTemplateChip('Sensorial', 'sensory', '👐'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTemplateChip(String label, String type, String icon) {
    return ActionChip(
      avatar: Text(icon),
      label: Text(label),
      onPressed: () => _loadPredefinedRoutine(type),
      backgroundColor: Colors.grey[100],
    );
  }

  Widget _buildBasicInfoSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Información Básica',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nombre de la rutina *',
                border: OutlineInputBorder(),
                hintText: 'Ej: Rutina Matutina',
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Por favor ingresa un nombre';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                border: OutlineInputBorder(),
                hintText: 'Describe el propósito de esta rutina',
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppearanceSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Apariencia',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Selector de icono
            const Text('Icono:'),
            const SizedBox(height: 8),
            SizedBox(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _icons.length,
                itemBuilder: (context, index) {
                  final icon = _icons[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(icon, style: const TextStyle(fontSize: 18)),
                      selected: _selectedIcon == icon,
                      onSelected: (selected) {
                        setState(() {
                          _selectedIcon = icon;
                        });
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),

            // Selector de color
            const Text('Color:'),
            const SizedBox(height: 8),
            SizedBox(
              height: 60,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _colors.length,
                itemBuilder: (context, index) {
                  final color = _colors[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Container(
                        width: 24,
                        height: 24,
                        decoration: BoxDecoration(
                          color: _getColorFromHex(color),
                          shape: BoxShape.circle,
                        ),
                      ),
                      selected: _selectedColor == color,
                      onSelected: (selected) {
                        setState(() {
                          _selectedColor = color;
                        });
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTasksSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  'Tareas',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${_tasks.length} tareas',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: _addNewTask,
                  icon: const Icon(Icons.add),
                  tooltip: 'Agregar tarea',
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_tasks.isEmpty) _buildEmptyTasksState() else _buildTasksList(),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyTasksState() {
    return Column(
      children: [
        const KovaMascot(expression: KovaExpression.thinking, size: 80),
        const SizedBox(height: 16),
        const Text(
          'No hay tareas en esta rutina',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
        const SizedBox(height: 8),
        const Text(
          'Agrega tareas para crear una rutina completa',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
        const SizedBox(height: 16),
        CustomButton(
          onPressed: _addNewTask,
          text: 'Agregar Primera Tarea',
          icon: Icons.add,
        ),
      ],
    );
  }

  Widget _buildTasksList() {
    final sortedTasks = _tasks.toList()
      ..sort((a, b) => a.order.compareTo(b.order));

    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: sortedTasks.length,
      itemBuilder: (context, index) {
        final task = sortedTasks[index];
        return Card(
          key: Key(task.id),
          margin: const EdgeInsets.only(bottom: 8),
          elevation: 1,
          child: ListTile(
            leading: const Icon(Icons.drag_handle, color: Colors.grey),
            title: Text(task.title),
            subtitle: Text(
              '${task.estimatedMinutes} min • Nvl ${task.difficulty}',
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () =>
                      _editTask(_tasks.indexWhere((t) => t.id == task.id)),
                  icon: const Icon(Icons.edit, size: 20),
                  tooltip: 'Editar tarea',
                ),
                IconButton(
                  onPressed: () =>
                      _deleteTask(_tasks.indexWhere((t) => t.id == task.id)),
                  icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                  tooltip: 'Eliminar tarea',
                ),
              ],
            ),
          ),
        );
      },
      onReorder: _reorderTask,
    );
  }

  Widget _buildScheduleSection() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Horario y Recordatorios',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text('Horario'),
              subtitle: Text(
                '${_formatTime(_schedule.startTime)} - ${_formatTime(_schedule.endTime)}',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: _selectSchedule,
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text('Días de la semana'),
              subtitle: Text(_getDaysText(_schedule.daysOfWeek)),
              trailing: const Icon(Icons.chevron_right),
              onTap: _selectSchedule,
            ),
            SwitchListTile(
              title: const Text('Recordatorio'),
              subtitle: const Text('Recibir notificación antes de la rutina'),
              value: _schedule.hasReminder,
              onChanged: (value) {
                setState(() {
                  _schedule = _schedule.copyWith(hasReminder: value);
                });
              },
            ),
            if (_schedule.hasReminder)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Recordar con:',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    DropdownButton<int>(
                      value: _schedule.reminderMinutesBefore,
                      items: [5, 10, 15, 30, 60].map((minutes) {
                        return DropdownMenuItem(
                          value: minutes,
                          child: Text('$minutes minutos antes'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _schedule = _schedule.copyWith(
                            reminderMinutesBefore: value!,
                          );
                        });
                      },
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return CustomButton(
      onPressed: _saveRoutine,
      text: widget.routine == null ? 'Crear Rutina' : 'Actualizar Rutina',
      icon: Icons.save,
    );
  }

  Color _getColorFromHex(String hexColor) {
    hexColor = hexColor.replaceAll("#", "");
    if (hexColor.length == 6) {
      hexColor = "FF$hexColor";
    }
    return Color(int.parse(hexColor, radix: 16));
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  String _getDaysText(List<int> days) {
    if (days.length == 7) return 'Todos los días';
    if (days.length == 5 && !days.contains(6) && !days.contains(7)) {
      return 'Lunes a Viernes';
    }

    final dayNames = {
      1: 'Lun',
      2: 'Mar',
      3: 'Mié',
      4: 'Jue',
      5: 'Vie',
      6: 'Sáb',
      7: 'Dom',
    };

    return days.map((day) => dayNames[day]).join(', ');
  }
}

// Diálogo para editar tareas individuales
class _TaskEditorDialog extends StatefulWidget {
  final RoutineTask? task;
  final Function(RoutineTask) onSave;

  const _TaskEditorDialog({this.task, required this.onSave});

  @override
  State<_TaskEditorDialog> createState() => _TaskEditorDialogState();
}

class _TaskEditorDialogState extends State<_TaskEditorDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  int _estimatedMinutes = 5;
  int _difficulty = 1;
  bool _isSkippable = false;
  String? _selectedIcon;

  @override
  void initState() {
    super.initState();
    if (widget.task != null) {
      _titleController.text = widget.task!.title;
      _descriptionController.text = widget.task!.description;
      _estimatedMinutes = widget.task!.estimatedMinutes;
      _difficulty = widget.task!.difficulty;
      _isSkippable = widget.task!.isSkippable;
      _selectedIcon = widget.task!.icon;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      final task = RoutineTask(
        id: widget.task?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        title: _titleController.text,
        description: _descriptionController.text,
        icon: _selectedIcon,
        estimatedMinutes: _estimatedMinutes,
        order: widget.task?.order ?? 0,
        difficulty: _difficulty,
        isSkippable: _isSkippable,
      );
      widget.onSave(task);
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.task == null ? 'Agregar Tarea' : 'Editar Tarea'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Título de la tarea *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor ingresa un título';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción (opcional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _estimatedMinutes,
                items: [1, 2, 3, 5, 10, 15, 20, 30, 45, 60]
                    .map(
                      (minutes) => DropdownMenuItem(
                        value: minutes,
                        child: Text('$minutes minutos'),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _estimatedMinutes = value!;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Tiempo estimado',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<int>(
                value: _difficulty,
                items: [1, 2, 3, 4, 5]
                    .map(
                      (level) => DropdownMenuItem(
                        value: level,
                        child: Text('Nivel $level'),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _difficulty = value!;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'Dificultad',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                title: const Text('Tarea opcional'),
                subtitle: const Text('Puede ser omitida si es necesario'),
                value: _isSkippable,
                onChanged: (value) {
                  setState(() {
                    _isSkippable = value!;
                  });
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _saveTask, child: const Text('Guardar')),
      ],
    );
  }
}

// Diálogo para editar horario
class _ScheduleEditorDialog extends StatefulWidget {
  final RoutineSchedule schedule;

  const _ScheduleEditorDialog({required this.schedule});

  @override
  State<_ScheduleEditorDialog> createState() => _ScheduleEditorDialogState();
}

class _ScheduleEditorDialogState extends State<_ScheduleEditorDialog> {
  late List<bool> _selectedDays;
  late TimeOfDay _startTime;
  late TimeOfDay _endTime;

  @override
  void initState() {
    super.initState();
    _selectedDays = List.generate(
      7,
      (index) => widget.schedule.daysOfWeek.contains(index + 1),
    );
    _startTime = widget.schedule.startTime;
    _endTime = widget.schedule.endTime;
  }

  Future<void> _selectStartTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _startTime,
    );
    if (picked != null) {
      setState(() {
        _startTime = picked;
      });
    }
  }

  Future<void> _selectEndTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _endTime,
    );
    if (picked != null) {
      setState(() {
        _endTime = picked;
      });
    }
  }

  void _saveSchedule() {
    final daysOfWeek = <int>[];
    for (int i = 0; i < _selectedDays.length; i++) {
      if (_selectedDays[i]) {
        daysOfWeek.add(i + 1);
      }
    }

    final schedule = RoutineSchedule(
      daysOfWeek: daysOfWeek,
      startTime: _startTime,
      endTime: _endTime,
      hasReminder: widget.schedule.hasReminder,
      reminderMinutesBefore: widget.schedule.reminderMinutesBefore,
    );

    Navigator.pop(context, schedule);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Configurar Horario'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Días de la semana:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom']
                  .asMap()
                  .entries
                  .map((entry) {
                final index = entry.key;
                final day = entry.value;
                return FilterChip(
                  label: Text(day),
                  selected: _selectedDays[index],
                  onSelected: (selected) {
                    setState(() {
                      _selectedDays[index] = selected;
                    });
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text('Hora de inicio'),
              subtitle: Text(_formatTime(_startTime)),
              trailing: const Icon(Icons.edit),
              onTap: _selectStartTime,
            ),
            ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text('Hora de fin'),
              subtitle: Text(_formatTime(_endTime)),
              trailing: const Icon(Icons.edit),
              onTap: _selectEndTime,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _saveSchedule, child: const Text('Guardar')),
      ],
    );
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}
