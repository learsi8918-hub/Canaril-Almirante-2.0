import 'dart:io';

import 'package:flutter/material.dart';

import '../core/theme_controller.dart';
import '../database/db_helper.dart';

class DashboardScreen extends StatefulWidget {
  final AppThemeController theme;

  const DashboardScreen({
    super.key,
    required this.theme,
  });

  @override
  State<DashboardScreen> createState() => _DashboardState();
}

class _DashboardState extends State<DashboardScreen> {
  int birds = 0;
  int active = 0;
  int cycles = 0;
  int eggs = 0;
  int chicks = 0;
  int alerts = 0;

  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    if (mounted) {
      setState(() {
        loading = true;
      });
    }

    try {
      final db = await DBHelper.db;

      final birdsResult = await db.rawQuery(
        'SELECT COUNT(*) AS n FROM aves',
      );

      final activeResult = await db.rawQuery(
        "SELECT COUNT(*) AS n FROM aves WHERE status = 'ATIVA'",
      );

      final cyclesResult = await db.rawQuery(
        """
        SELECT COUNT(*) AS n
        FROM ciclos
        WHERE status IS NULL
           OR status != 'FINALIZADO'
        """,
      );

      final eggsResult = await db.rawQuery(
        'SELECT COUNT(*) AS n FROM ovos',
      );

      final chicksResult = await db.rawQuery(
        'SELECT COUNT(*) AS n FROM filhotes',
      );

      final alertsResult = await db.rawQuery(
        """
        SELECT COUNT(*) AS n
        FROM lembretes
        WHERE concluido = 0
        """,
      );

      if (!mounted) return;

      setState(() {
        birds = _count(birdsResult);
        active = _count(activeResult);
        cycles = _count(cyclesResult);
        eggs = _count(eggsResult);
        chicks = _count(chicksResult);
        alerts = _count(alertsResult);
        loading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });
    }
  }

  int _count(List<Map<String, Object?>> result) {
    if (result.isEmpty) {
      return 0;
    }

    final value = result.first['n'];

    if (value is int) {
      return value;
    }

    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  Widget _metricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: Card(
        elevation: 1,
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                value,
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 3),
              Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(
                      color: Colors.grey.shade700,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(
    String title, {
    String? subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 8,
        bottom: 12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context)
                .textTheme
                .titleLarge
                ?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 3),
            Text(
              subtitle,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(
                    color: Colors.grey.shade700,
                  ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _identityHeader() {
    final theme = widget.theme;

    final hasLogo =
        theme.logoPath != null &&
        theme.logoPath!.trim().isNotEmpty &&
        File(theme.logoPath!).existsSync();

    final location = [
      if (theme.city.trim().isNotEmpty) theme.city.trim(),
      if (theme.state.trim().isNotEmpty) theme.state.trim(),
    ].join(' - ');

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.primary,
            theme.secondary,
          ],
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          if (hasLogo)
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                image: DecorationImage(
                  image: FileImage(
                    File(theme.logoPath!),
                  ),
                  fit: BoxFit.cover,
                ),
              ),
            )
          else
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.18),
              ),
              child: Icon(
                Icons.flutter_dash,
                color: theme.onPrimary,
                size: 34,
              ),
            ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  theme.houseName.trim().isEmpty
                      ? 'Meu Canaril'
                      : theme.houseName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: theme.onPrimary,
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (theme.breederName
                    .trim()
                    .isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    theme.breederName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: theme.onPrimary
                          .withValues(alpha: 0.90),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                if (location.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    location,
                    style: TextStyle(
                      color: theme.onPrimary
                          .withValues(alpha: 0.78),
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _alertCard() {
    final theme = widget.theme;

    return Card(
      elevation: 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'O módulo de Alertas será disponibilizado nesta etapa.',
              ),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: alerts > 0
                      ? Colors.orange.withValues(alpha: 0.14)
                      : theme.primary
                          .withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  alerts > 0
                      ? Icons.notifications_active
                      : Icons.notifications_none,
                  color: alerts > 0
                      ? Colors.orange.shade800
                      : theme.primary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      alerts > 0
                          ? '$alerts alerta${alerts == 1 ? '' : 's'} pendente${alerts == 1 ? '' : 's'}'
                          : 'Nenhum alerta pendente',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      alerts > 0
                          ? 'Existem tarefas de manejo que precisam de atenção.'
                          : 'O manejo programado está em dia.',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: Colors.grey.shade500,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final theme = widget.theme;

    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: theme.primary
                    .withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(
                icon,
                color: theme.primary,
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 12.5,
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

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Painel',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Atualizar',
            onPressed: loading ? null : load,
            icon: const Icon(
              Icons.refresh,
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: load,
        color: theme.primary,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            16,
            12,
            16,
            30,
          ),
          children: [
            _identityHeader(),

            const SizedBox(height: 22),

            _sectionTitle(
              'Vis
