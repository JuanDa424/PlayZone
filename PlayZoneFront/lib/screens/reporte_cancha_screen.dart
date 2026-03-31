// lib/screens/reporte_cancha_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:convert';
import '../util/constants.dart';

class ReporteCanchaScreen extends StatefulWidget {
  final int canchaId;
  final String nombreCancha;

  const ReporteCanchaScreen({
    super.key,
    required this.canchaId,
    required this.nombreCancha,
  });

  @override
  State<ReporteCanchaScreen> createState() => _ReporteCanchaScreenState();
}

class _ReporteCanchaScreenState extends State<ReporteCanchaScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _reporte;
  int _mesSeleccionado = DateTime.now().month;
  int _anioSeleccionado = DateTime.now().year;

  final _formatCOP = NumberFormat.currency(
    locale: 'es_CO',
    symbol: '\$',
    decimalDigits: 0,
  );
  final List<String> _meses = [
    'Enero',
    'Febrero',
    'Marzo',
    'Abril',
    'Mayo',
    'Junio',
    'Julio',
    'Agosto',
    'Septiembre',
    'Octubre',
    'Noviembre',
    'Diciembre',
  ];

  @override
  void initState() {
    super.initState();
    _cargarReporte();
  }

  Future<void> _cargarReporte() async {
    setState(() => _isLoading = true);
    try {
      final res = await http.get(
        Uri.parse(
          '$baseUrl/reportes/cancha/${widget.canchaId}?mes=$_mesSeleccionado&anio=$_anioSeleccionado',
        ),
      );
      if (res.statusCode == 200) {
        setState(() => _reporte = jsonDecode(res.body));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(buildSnackBar('Error cargando reporte', isError: true));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _exportarPDF() async {
    if (_reporte == null) return;
    final pdf = pw.Document();

    final ganancia = (_reporte!['gananciaTotal'] as num?)?.toDouble() ?? 0;
    final totalRes = _reporte!['totalReservas'] ?? 0;
    final confirmadas = _reporte!['reservasConfirmadas'] ?? 0;
    final pendientes = _reporte!['reservasPendientes'] ?? 0;
    final canceladas = _reporte!['reservasCanceladas'] ?? 0;
    final topUsuarios = (_reporte!['topUsuarios'] as List?) ?? [];
    final porHora = (_reporte!['reservasPorHora'] as Map?) ?? {};
    final porDia = (_reporte!['porDia'] as Map?) ?? {};

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => [
          // Encabezado
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex('0D0D0D'),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      'PLAYZONE',
                      style: pw.TextStyle(
                        color: PdfColor.fromHex('00FF85'),
                        fontSize: 22,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      'Reporte de Cancha',
                      style: pw.TextStyle(color: PdfColors.white, fontSize: 14),
                    ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text(
                      widget.nombreCancha,
                      style: pw.TextStyle(
                        color: PdfColors.white,
                        fontSize: 13,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      '${_meses[_mesSeleccionado - 1]} $_anioSeleccionado',
                      style: pw.TextStyle(
                        color: PdfColor.fromHex('AAAAAA'),
                        fontSize: 11,
                      ),
                    ),
                    pw.Text(
                      'Generado: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
                      style: pw.TextStyle(
                        color: PdfColor.fromHex('AAAAAA'),
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          // KPIs
          pw.Text(
            'Resumen del mes',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
          pw.Row(
            children: [
              _pdfKpi(
                'Total Reservas',
                totalRes.toString(),
                PdfColor.fromHex('1E1E1E'),
              ),
              pw.SizedBox(width: 8),
              _pdfKpi(
                'Confirmadas',
                confirmadas.toString(),
                PdfColor.fromHex('00FF85'),
              ),
              pw.SizedBox(width: 8),
              _pdfKpi(
                'Pendientes',
                pendientes.toString(),
                PdfColor.fromHex('FF6B00'),
              ),
              pw.SizedBox(width: 8),
              _pdfKpi(
                'Canceladas',
                canceladas.toString(),
                PdfColor.fromHex('FF4444'),
              ),
            ],
          ),
          pw.SizedBox(height: 8),
          pw.Container(
            padding: const pw.EdgeInsets.all(12),
            decoration: pw.BoxDecoration(
              color: PdfColor.fromHex('1A1A1A'),
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'Ganancias del mes',
                  style: pw.TextStyle(color: PdfColors.white, fontSize: 12),
                ),
                pw.Text(
                  _formatCOP.format(ganancia),
                  style: pw.TextStyle(
                    color: PdfColor.fromHex('00FF85'),
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 20),

          // Reservas por día
          if (porDia.isNotEmpty) ...[
            pw.Text(
              'Reservas por día',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            pw.Table(
              border: pw.TableBorder.all(
                color: PdfColor.fromHex('2E2E2E'),
                width: 0.5,
              ),
              children: [
                pw.TableRow(
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('1A1A1A'),
                  ),
                  children: ['Fecha', 'Reservas', 'Ganancias']
                      .map(
                        (h) => pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(
                            h,
                            style: pw.TextStyle(
                              color: PdfColor.fromHex('00FF85'),
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                ...porDia.entries
                    .map(
                      (e) => pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text(
                              e.key,
                              style: const pw.TextStyle(fontSize: 10),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text(
                              '${e.value['reservas']}',
                              style: const pw.TextStyle(fontSize: 10),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text(
                              _formatCOP.format(
                                (e.value['ganancias'] as num?)?.toDouble() ?? 0,
                              ),
                              style: const pw.TextStyle(fontSize: 10),
                            ),
                          ),
                        ],
                      ),
                    )
                    .toList(),
              ],
            ),
            pw.SizedBox(height: 20),
          ],

          // Horas más reservadas
          if (porHora.isNotEmpty) ...[
            pw.Text(
              'Horas más reservadas',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            pw.Wrap(
              spacing: 8,
              runSpacing: 8,
              children: porHora.entries
                  .map(
                    (e) => pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: pw.BoxDecoration(
                        color: PdfColor.fromHex('00FF85'),
                        borderRadius: pw.BorderRadius.circular(6),
                      ),
                      child: pw.Text(
                        '${e.key}  -  ${e.value} reservas',
                        style: const pw.TextStyle(fontSize: 9),
                      ),
                    ),
                  )
                  .toList(),
            ),
            pw.SizedBox(height: 20),
          ],

          // Top usuarios
          if (topUsuarios.isNotEmpty) ...[
            pw.Text(
              'Top clientes del mes',
              style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 8),
            pw.Table(
              border: pw.TableBorder.all(
                color: PdfColor.fromHex('2E2E2E'),
                width: 0.5,
              ),
              children: [
                pw.TableRow(
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('1A1A1A'),
                  ),
                  children: ['Nombre', 'Correo', 'Reservas', 'Total gastado']
                      .map(
                        (h) => pw.Padding(
                          padding: const pw.EdgeInsets.all(6),
                          child: pw.Text(
                            h,
                            style: pw.TextStyle(
                              color: PdfColor.fromHex('00FF85'),
                              fontWeight: pw.FontWeight.bold,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                ...topUsuarios
                    .map(
                      (u) => pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text(
                              u['nombre'] ?? '',
                              style: const pw.TextStyle(fontSize: 10),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text(
                              u['correo'] ?? '',
                              style: const pw.TextStyle(fontSize: 9),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text(
                              '${u['totalReservas']}',
                              style: const pw.TextStyle(fontSize: 10),
                            ),
                          ),
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text(
                              _formatCOP.format(
                                (u['totalGastado'] as num?)?.toDouble() ?? 0,
                              ),
                              style: const pw.TextStyle(fontSize: 10),
                            ),
                          ),
                        ],
                      ),
                    )
                    .toList(),
              ],
            ),
          ],

          pw.SizedBox(height: 30),
          pw.Divider(color: PdfColor.fromHex('2E2E2E')),
          pw.Text(
            'Generado por PlayZone — ${DateFormat('dd/MM/yyyy').format(DateTime.now())}',
            style: pw.TextStyle(color: PdfColor.fromHex('AAAAAA'), fontSize: 9),
          ),
        ],
      ),
    );

    await Printing.layoutPdf(onLayout: (format) => pdf.save());
  }

  pw.Widget _pdfKpi(String label, String value, PdfColor color) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(10),
        decoration: pw.BoxDecoration(
          color: color,
          borderRadius: pw.BorderRadius.circular(6),
        ),
        child: pw.Column(
          children: [
            pw.Text(
              value,
              style: pw.TextStyle(
                color: PdfColors.white,
                fontSize: 20,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.Text(
              label,
              style: pw.TextStyle(color: PdfColors.white, fontSize: 9),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kCarbonBlack,
      appBar: AppBar(
        backgroundColor: kSurfaceColor,
        title: Text(
          'Reporte — ${widget.nombreCancha}',
          style: const TextStyle(
            color: kWhite,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        iconTheme: const IconThemeData(color: kWhite),
        actions: [
          if (_reporte != null)
            TextButton.icon(
              onPressed: _exportarPDF,
              icon: const Icon(
                Icons.picture_as_pdf_rounded,
                color: kGreenNeon,
                size: 18,
              ),
              label: const Text(
                'PDF',
                style: TextStyle(
                  color: kGreenNeon,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          _buildFiltros(),
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: kGreenNeon),
                  )
                : _reporte == null
                ? const Center(
                    child: Text(
                      'Sin datos',
                      style: TextStyle(color: kLightGray),
                    ),
                  )
                : _buildContenido(),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltros() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: kSurfaceColor,
      child: Row(
        children: [
          const Icon(Icons.calendar_month_rounded, color: kGreenNeon, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: DropdownButton<int>(
              value: _mesSeleccionado,
              dropdownColor: kCardColor,
              style: const TextStyle(color: kWhite, fontSize: 14),
              underline: const SizedBox(),
              isExpanded: true,
              items: List.generate(
                12,
                (i) => DropdownMenuItem(value: i + 1, child: Text(_meses[i])),
              ),
              onChanged: (v) {
                if (v != null) setState(() => _mesSeleccionado = v);
                _cargarReporte();
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: DropdownButton<int>(
              value: _anioSeleccionado,
              dropdownColor: kCardColor,
              style: const TextStyle(color: kWhite, fontSize: 14),
              underline: const SizedBox(),
              isExpanded: true,
              items: [2024, 2025, 2026]
                  .map((a) => DropdownMenuItem(value: a, child: Text('$a')))
                  .toList(),
              onChanged: (v) {
                if (v != null) setState(() => _anioSeleccionado = v);
                _cargarReporte();
              },
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: _cargarReporte,
            icon: const Icon(Icons.refresh_rounded, color: kGreenNeon),
          ),
        ],
      ),
    );
  }

  Widget _buildContenido() {
    final ganancia = (_reporte!['gananciaTotal'] as num?)?.toDouble() ?? 0;
    final totalRes = _reporte!['totalReservas'] ?? 0;
    final confirmadas = _reporte!['reservasConfirmadas'] ?? 0;
    final pendientes = _reporte!['reservasPendientes'] ?? 0;
    final canceladas = _reporte!['reservasCanceladas'] ?? 0;
    final topUsuarios = (_reporte!['topUsuarios'] as List?) ?? [];
    final porHora = (_reporte!['reservasPorHora'] as Map?) ?? {};
    final porDia = (_reporte!['porDia'] as Map?) ?? {};
    final porMes = (_reporte!['porMes'] as Map?) ?? {};

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // KPIs
          _buildKpis(totalRes, confirmadas, pendientes, canceladas, ganancia),
          const SizedBox(height: 20),

          // Ganancias por mes
          if (porMes.isNotEmpty) ...[
            _buildSectionTitle('Ganancias últimos 12 meses'),
            const SizedBox(height: 12),
            _buildBarChart(porMes),
            const SizedBox(height: 20),
          ],

          // Reservas por día
          if (porDia.isNotEmpty) ...[
            _buildSectionTitle('Reservas del mes por día'),
            const SizedBox(height: 12),
            _buildTablasDia(porDia),
            const SizedBox(height: 20),
          ],

          // Horas más reservadas
          if (porHora.isNotEmpty) ...[
            _buildSectionTitle('Horas más reservadas'),
            const SizedBox(height: 12),
            _buildHoras(porHora),
            const SizedBox(height: 20),
          ],

          // Top clientes
          if (topUsuarios.isNotEmpty) ...[
            _buildSectionTitle('Top clientes del mes'),
            const SizedBox(height: 12),
            _buildTopUsuarios(topUsuarios),
          ],

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildKpis(
    int total,
    int confirmadas,
    int pendientes,
    int canceladas,
    double ganancia,
  ) {
    return Column(
      children: [
        // Ganancia destacada
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: kCardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: kGreenNeon.withOpacity(0.3)),
          ),
          child: Column(
            children: [
              const Text(
                'Ganancias del mes',
                style: TextStyle(color: kLightGray, fontSize: 13),
              ),
              const SizedBox(height: 6),
              Text(
                _formatCOP.format(ganancia),
                style: const TextStyle(
                  color: kGreenNeon,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1),
        const SizedBox(height: 12),

        // Grid de KPIs
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 1.3,
          children: [
            _kpiCard('Total', '$total', Icons.calendar_today_rounded, kWhite),
            _kpiCard(
              'Pagadas',
              '$confirmadas',
              Icons.check_circle_rounded,
              kGreenNeon,
            ),
            _kpiCard(
              'Canceladas',
              '$canceladas',
              Icons.cancel_rounded,
              Colors.redAccent,
            ),
          ],
        ),
      ],
    );
  }

  Widget _kpiCard(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorderColor),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(label, style: const TextStyle(color: kLightGray, fontSize: 11)),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms).scale(begin: const Offset(0.9, 0.9));
  }

  Widget _buildSectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 18,
          decoration: BoxDecoration(
            color: kGreenNeon,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: kWhite,
            fontSize: 15,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildBarChart(Map porMes) {
    final entries = porMes.entries.toList();
    final maxGanancia = entries
        .map((e) => (e.value['ganancias'] as num?)?.toDouble() ?? 0)
        .fold(0.0, (a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorderColor),
      ),
      child: SizedBox(
        height: 160,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: entries.map((e) {
            final ganancia = (e.value['ganancias'] as num?)?.toDouble() ?? 0;
            final altura = maxGanancia > 0 ? (ganancia / maxGanancia) : 0.0;
            final mes = e.key.toString().split('-').last;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Container(
                      height: 120 * altura,
                      decoration: BoxDecoration(
                        color: ganancia > 0
                            ? kGreenNeon.withOpacity(0.8)
                            : kDarkGray,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      mes,
                      style: const TextStyle(color: kLightGray, fontSize: 9),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    ).animate().fadeIn(duration: 500.ms);
  }

  Widget _buildTablasDia(Map porDia) {
    return Container(
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorderColor),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(
              children: const [
                Expanded(
                  child: Text(
                    'Fecha',
                    style: TextStyle(
                      color: kGreenNeon,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                SizedBox(
                  width: 60,
                  child: Text(
                    'Reservas',
                    style: TextStyle(
                      color: kGreenNeon,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                SizedBox(
                  width: 100,
                  child: Text(
                    'Ganancias',
                    style: TextStyle(
                      color: kGreenNeon,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
          Divider(color: kBorderColor, height: 1),
          ...porDia.entries
              .map(
                (e) => Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              e.key,
                              style: const TextStyle(
                                color: kWhite,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 60,
                            child: Text(
                              '${e.value['reservas']}',
                              style: const TextStyle(
                                color: kWhite,
                                fontSize: 13,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(
                            width: 100,
                            child: Text(
                              _formatCOP.format(
                                (e.value['ganancias'] as num?)?.toDouble() ?? 0,
                              ),
                              style: const TextStyle(
                                color: kGreenNeon,
                                fontSize: 13,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Divider(color: kBorderColor, height: 1),
                  ],
                ),
              )
              .toList(),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildHoras(Map porHora) {
    final valores = porHora.values.map((v) => (v as num).toInt()).toList();
    final maxVal = valores.isEmpty
        ? 1
        : valores.reduce((a, b) => a > b ? a : b);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: porHora.entries.map((e) {
        final val = (e.value as num).toInt();
        final pct = maxVal > 0 ? val / maxVal : 0.0;
        final color = pct > 0.7
            ? kGreenNeon
            : pct > 0.4
            ? kOrangeAccent
            : kLightGray;
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 255, 255, 255),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: color.withOpacity(0.4)),
          ),
          child: Column(
            children: [
              Text(
                e.key,
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '$val res.',
                style: const TextStyle(color: kLightGray, fontSize: 11),
              ),
            ],
          ),
        );
      }).toList(),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildTopUsuarios(List topUsuarios) {
    return Container(
      decoration: BoxDecoration(
        color: kCardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorderColor),
      ),
      child: Column(
        children: topUsuarios.asMap().entries.map((entry) {
          final i = entry.key;
          final u = entry.value;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: i == 0 ? kGreenNeon.withOpacity(0.2) : kDarkGray,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: i == 0 ? kGreenNeon : kBorderColor,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '${i + 1}',
                          style: TextStyle(
                            color: i == 0 ? kGreenNeon : kLightGray,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            u['nombre'] ?? '',
                            style: const TextStyle(
                              color: kWhite,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            u['correo'] ?? '',
                            style: const TextStyle(
                              color: kLightGray,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${u['totalReservas']} reservas',
                          style: const TextStyle(color: kWhite, fontSize: 12),
                        ),
                        Text(
                          _formatCOP.format(
                            (u['totalGastado'] as num?)?.toDouble() ?? 0,
                          ),
                          style: const TextStyle(
                            color: kGreenNeon,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (i < topUsuarios.length - 1)
                Divider(color: kBorderColor, height: 1),
            ],
          );
        }).toList(),
      ),
    ).animate().fadeIn(duration: 400.ms);
  }
}
