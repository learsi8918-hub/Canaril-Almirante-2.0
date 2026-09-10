import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._privateConstructor();
  static final NotificationService instance = NotificationService._privateConstructor();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  // Inicializa o motor de alarmes nativo do smartphone
  Future<void> inicializar() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Lógica para quando o criador clicar na notificação com o app fechado
      },
    );
  }

  /// -----------------------------------------------------------------------
  /// AGENDAMENTO DE MANEJOS CRÍTICOS (OFFLINE EM SEGUNDO PLANO)
  /// -----------------------------------------------------------------------

  // Agenda todos os gatilhos cronológicos automáticos a partir do início do choco
  Future<void> agendarAlertasChoco({
    required int idCiclo,
    required String gaiola,
    required String anilhaFemea,
    required DateTime dataInicioChoco,
  }) async {
    final androidDetails = _obterConfiguracaoCanalNativo();

    // 1. Alerta de Ovoscopia (7º Dia)
    await _notificationsPlugin.zonedSchedule(
      idCiclo * 10 + 1,
      '🔬 Hora da Ovoscopia - $gaiola',
      'Verifique se os ovos da fêmea $anilhaFemea estão galados.',
      tz.TZDateTime.from(dataInicioChoco.add(const Duration(days: 7, hours: 9)), tz.local),
      NotificationDetails(android: androidDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );

    // 2. Alerta de Banheira de Umidade (12º Dia)
    await _notificationsPlugin.zonedSchedule(
      idCiclo * 10 + 2,
      '🛁 Colocar Banheira - $gaiola',
      'Aumente a umidade para ajudar a quebrar a casca dos ovos da fêmea $anilhaFemea.',
      tz.TZDateTime.from(dataInicioChoco.add(const Duration(days: 12, hours: 8)), tz.local),
      NotificationDetails(android: androidDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );

    // 3. Alerta de Previsão de Nascimento (13º Dia)
    await _notificationsPlugin.zonedSchedule(
      idCiclo * 10 + 3,
      '🐣 Previsão de Nascimento - $gaiola',
      'Nascimento dos filhotes previsto para hoje. Forneça alimentação mole.',
      tz.TZDateTime.from(dataInicioChoco.add(const Duration(days: 13, hours: 7)), tz.local),
      NotificationDetails(android: androidDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );

    // 4. Alerta de Desmame Automático dos Filhotes
    await _notificationsPlugin.zonedSchedule(
      idCiclo * 10 + 4,
      '💍 Alerta de Desmame - $gaiola',
      'Período de desmame concluído para os filhotes da fêmea $anilhaFemea. Matriz liberada para descanso.',
      tz.TZDateTime.from(dataInicioChoco.add(const Duration(days: 35, hours: 9)), tz.local), // 35 dias após choco / ~22 pós nascimento
      NotificationDetails(android: androidDetails),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // Agenda alerta para finalização de tratamentos sanitários (Ex: Medicamento por 5 dias)
  Future<void> agendarFimTratamento({
    required String idTratamento,
    required String identificadorAve,
    required String remedio,
    required int diasDuracao,
  }) async {
    await _notificationsPlugin.zonedSchedule(
      idTratamento.hashCode,
      '🏥 Término de Tratamento Clínico',
      'O ciclo de 5 dias do medicamento ($remedio) da ave $identificadorAve chegou ao fim hoje.',
      tz.TZDateTime.now(tz.local).add(Duration(days: diasDuracao, hours: 9)),
      NotificationDetails(android: _obterConfiguracaoCanalNativo()),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // Cria o canal nativo de alta prioridade para furar o bloqueio de bateria do celular
  AndroidNotificationDetails _obterConfiguracaoCanalNativo() {
    return const AndroidNotificationDetails(
      'canaril_alertas_prioritarios',
      'Alertas de Manejo do Canaril',
      channelDescription: 'Notificações críticas de ovoscopia, nascimento e desmame de filhotes',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );
  }
}
