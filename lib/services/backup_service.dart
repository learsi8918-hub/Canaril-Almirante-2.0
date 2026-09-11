import 'dart:convert'; import 'dart:io'; import 'package:path_provider/path_provider.dart'; import 'package:share_plus/share_plus.dart'; import '../database/db_helper.dart';
class BackupService {
  Future<File> criarBackup() async { final d=await DbHelper.instance.db; final tables=['criador','aves','ciclos','ciclo_femeas','posturas','ovos','filhotes','baixas','lembretes','saude','retrocruzamentos']; final out=<String,dynamic>{'versao':13,'data':DateTime.now().toIso8601String()}; for(final t in tables) out[t]=await d.query(t); final dir=await getTemporaryDirectory(); final f=File('${dir.path}/canary_backup_${DateTime.now().millisecondsSinceEpoch}.json'); await f.writeAsString(jsonEncode(out)); return f; }
  Future<void> compartilharBackup() async {final f=await criarBackup(); await Share.shareXFiles([XFile(f.path)],text:'Backup Canary Control Pro');}
}
