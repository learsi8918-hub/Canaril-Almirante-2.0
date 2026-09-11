import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../database/db_helper.dart';
class ExportService {
  static Future<File> exportJson() async {
    final db=await DBHelper.db; final data=<String,dynamic>{};
    for(final t in ['perfil_criador','aves','ciclos','ovos','filhotes','historico_saude','baixas','lembretes','retrocruzamentos']) data[t]=await db.query(t);
    final dir=await getTemporaryDirectory(); final f=File('${dir.path}/canary_control_pro_backup.json'); await f.writeAsString(const JsonEncoder.withIndent('  ').convert(data)); return f;
  }
  static Future<void> shareBackup() async { final f=await exportJson(); await Share.shareXFiles([XFile(f.path)],text:'Backup Canary Control Pro'); }
}
