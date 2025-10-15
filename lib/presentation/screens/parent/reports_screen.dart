import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:koa_app/data/models/child_model.dart';
import 'package:koa_app/data/models/report_model.dart';
import 'package:koa_app/core/services/local_storage.dart';
import 'package:koa_app/core/services/pdf_service.dart';
import 'package:koa_app/presentation/providers/child_provider.dart';
import 'package:koa_app/presentation/providers/auth_provider.dart';
import 'package:koa_app/presentation/widgets/common/kova_mascot.dart';
import 'package:koa_app/presentation/widgets/common/loading_indicator.dart';
import 'package:koa_app/presentation/widgets/common/custom_button.dart';
import 'package:koa_app/presentation/widgets/parent/report_card.dart';
import 'package:koa_app/core/theme/colors.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final LocalStorage _localStorage = LocalStorage();
  final PdfService _pdfService = PdfService();

  List<ReportModel> _reports = [];
  bool _isLoading = true;
  String? _selectedChildId;
  String _filter = 'all'; // 'all', 'synced', 'unsynced'

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() => _isLoading = true);

    try {
      final reports = await _localStorage.getReports();
      setState(() {
        _reports = reports;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Error cargando reportes: $e');
    }
  }

  List<ReportModel> get _filteredReports {
    switch (_filter) {
      case 'synced':
        return _reports.where((report) => report.isSynced).toList();
      case 'unsynced':
        return _reports.where((report) => !report.isSynced).toList();
      default:
        return _reports;
    }
  }

  Future<void> _generateNewReport() async {
    final authProvider = context.read<AuthProvider>();
    final childProvider = context.read<ChildProvider>();

    if (childProvider.children.isEmpty) {
      _showSnackBar('No hay niños registrados para generar reportes');
      return;
    }

    // Si hay más de un niño, mostrar diálogo para seleccionar
    if (childProvider.children.length > 1) {
      await _showChildSelectionDialog(childProvider.children);
    } else {
      _selectedChildId = childProvider.children.first.id;
    }

    if (_selectedChildId == null) return;

    final child = childProvider.children.firstWhere(
      (c) => c.id == _selectedChildId,
    );

    // Mostrar diálogo de configuración del reporte
    final result = await _showReportConfigDialog(child);
    if (result == null) return;

    setState(() => _isLoading = true);

    try {
      final report = await _pdfService.generateReport(
        child: child,
        generatedBy: authProvider.currentUser!,
        periodStart: result['periodStart'],
        periodEnd: result['periodEnd'],
      );

      await _localStorage.saveReport(report);
      await _loadReports(); // Recargar lista

      _showSnackBar('Reporte generado exitosamente');
    } catch (e) {
      _showSnackBar('Error generando reporte: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<Map<String, DateTime>?> _showReportConfigDialog(
    ChildModel child,
  ) async {
    final now = DateTime.now();
    final periodStart = now.subtract(const Duration(days: 30));
    final periodEnd = now;

    return showDialog<Map<String, DateTime>>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Configurar Reporte'),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Generar reporte para ${child.name}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildDateInfo('Fecha de inicio:', periodStart),
              const SizedBox(height: 8),
              _buildDateInfo('Fecha de fin:', periodEnd),
              const SizedBox(height: 16),
              const Text(
                'El reporte incluirá análisis de progreso, recomendaciones IA y estadísticas detalladas.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, {
              'periodStart': periodStart,
              'periodEnd': periodEnd,
            }),
            child: const Text('Generar Reporte'),
          ),
        ],
      ),
    );
  }

  Widget _buildDateInfo(String label, DateTime date) {
    return Row(
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(width: 8),
        Text(
          '${date.day}/${date.month}/${date.year}',
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Future<void> _showChildSelectionDialog(List<ChildModel> children) async {
    await showDialog(
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
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Future<void> _deleteReport(ReportModel report) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Reporte'),
        content: const Text(
          '¿Estás seguro de que quieres eliminar este reporte? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      await _localStorage.deleteReport(report.id);
      await _loadReports();
      _showSnackBar('Reporte eliminado');
    }
  }

  Future<void> _shareReport(ReportModel report) async {
    if (report.pdfUrl == null) {
      _showSnackBar('Este reporte no tiene un PDF generado');
      return;
    }

    // TODO: Integrar con share_plus para compartir el PDF
    _showSnackBar('Funcionalidad de compartir próximamente disponible');
  }

  void _viewReportDetails(ReportModel report) {
    // TODO: Navegar a pantalla de detalles del reporte
    _showSnackBar('Vista de detalles próximamente disponible');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 3)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportes de Progreso'),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
        actions: [
          // Filtros
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() => _filter = value);
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'all',
                child: Text('Todos los reportes'),
              ),
              const PopupMenuItem(
                value: 'synced',
                child: Text('Solo sincronizados'),
              ),
              const PopupMenuItem(
                value: 'unsynced',
                child: Text('Solo no sincronizados'),
              ),
            ],
          ),

          // Botón de generar nuevo reporte
          IconButton(
            onPressed: _generateNewReport,
            icon: const Icon(Icons.add),
            tooltip: 'Generar nuevo reporte',
          ),
        ],
      ),
      body: _isLoading
          ? const LoadingIndicator()
          : _filteredReports.isEmpty
              ? _buildEmptyState()
              : _buildReportsList(),
      floatingActionButton: _reports.isNotEmpty
          ? FloatingActionButton(
              onPressed: _generateNewReport,
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
              child: const Icon(Icons.add),
            )
          : null,
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
            'No hay reportes generados',
            style: TextStyle(
              fontSize: 18,
              color: AppColors.textGray,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Comienza generando tu primer reporte\nde progreso para ver el análisis detallado.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textGray),
          ),
          const SizedBox(height: 24),
          CustomButton(
            onPressed: _generateNewReport,
            text: 'Generar Primer Reporte',
            icon: Icons.assessment,
          ),
        ],
      ),
    );
  }

  Widget _buildReportsList() {
    return Column(
      children: [
        // Contador de reportes
        Container(
          padding: const EdgeInsets.all(16),
          color: AppColors.backgroundLight,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${_filteredReports.length} reporte${_filteredReports.length != 1 ? 's' : ''}',
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
              if (_reports.any((report) => !report.isSynced))
                Row(
                  children: [
                    Icon(Icons.cloud_off, size: 16, color: AppColors.warning),
                    const SizedBox(width: 4),
                    Text(
                      '${_reports.where((report) => !report.isSynced).length} no sincronizado',
                      style: TextStyle(color: AppColors.warning, fontSize: 12),
                    ),
                  ],
                ),
            ],
          ),
        ),

        // Lista de reportes
        Expanded(
          child: RefreshIndicator(
            onRefresh: _loadReports,
            child: ListView.builder(
              itemCount: _filteredReports.length,
              itemBuilder: (context, index) {
                final report = _filteredReports[index];
                return ReportCard(
                  report: report,
                  onTap: () => _viewReportDetails(report),
                  onShare: () => _shareReport(report),
                  onDelete: () => _deleteReport(report),
                  isSynced: report.isSynced,
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
