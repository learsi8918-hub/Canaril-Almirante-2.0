import 'package:flutter/material.dart';

import '../core/theme_controller.dart';
import '../services/export_service.dart';
import '../database/db_helper.dart';

class SettingsScreen extends StatelessWidget {
  final AppThemeController theme;

  const SettingsScreen({
    super.key,
    required this.theme,
  });

  Future<void> _export(BuildContext context) async {
    await ExportService.shareBackup();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configurações'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.business),
              title: Text(theme.houseName),
              subtitle: Text(
                '${theme.breederName}\n'
                '${theme.city}-${theme.state} · '
                'Clube: ${theme.club} ${theme.clubCode}',
              ),
            ),
          ),

          Card(
            child: Column(
              children: [
                const ListTile(
                  title: Text('Identidade visual'),
                  subtitle: Text(
                    'As cores atuais foram extraídas automaticamente da logo.',
                  ),
                ),
                ListTile(
                  leading: Icon(
                    Icons.palette,
                    color: theme.primary,
                  ),
                  title: const Text('Cor principal'),
                  subtitle: const Text('Derivada da logo'),
                ),
                ListTile(
                  leading: Icon(
                    Icons.circle,
                    color: theme.secondary,
                  ),
                  title: const Text('Cor secundária'),
                  subtitle: const Text('Derivada da logo'),
                ),
              ],
            ),
          ),

          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.backup),
                  title: const Text('Backup dos dados'),
                  subtitle: const Text(
                    'Exporta aves, reprodução, ovos, filhotes, saúde e histórico.',
                  ),
                  onTap: () => _export(context),
                ),
                const ListTile(
                  leading: Icon(Icons.storage),
                  title: Text('Banco de dados'),
                  subtitle: Text(
                    'SQLite local como fonte principal dos dados.',
                  ),
                ),
              ],
            ),
          ),

          Card(
            child: Column(
              children: [
                const ListTile(
                  title: Text('Módulos V14'),
                ),
                const ListTile(
                  leading: Icon(Icons.flutter_dash),
                  title: Text('Plantel'),
                  subtitle: Text(
                    'Anilha, gaiola, sexo, FOB, origem, foto e observações',
                  ),
                ),
                const ListTile(
                  leading: Icon(Icons.favorite),
                  title: Text('Reprodução'),
                  subtitle: Text(
                    'Monogamia, bigamia, poligamia, ovos e datas',
                  ),
                ),
                const ListTile(
                  leading: Icon(Icons.account_tree),
                  title: Text('Genealogia'),
                  subtitle: Text(
                    'Pais e descendentes preservados',
                  ),
                ),
                const ListTile(
                  leading: Icon(Icons.medical_services),
                  title: Text('Saúde'),
                  subtitle: Text(
                    'Tratamentos, medicamentos, dosagem, quarentena e histórico',
                  ),
                ),
                const ListTile(
                  leading: Icon(Icons.sync_alt),
                  title: Text('Retrocruzamento'),
                  subtitle: Text(
                    'Planejamento teórico por gerações, sem inventar genótipos desconhecidos',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
