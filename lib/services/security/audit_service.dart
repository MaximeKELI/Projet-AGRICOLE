import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service d'audit trail pour traçabilité complète des actions
/// Enregistre toutes les actions importantes pour la conformité et la sécurité
class AuditService {
  // Configuration de l'audit
  static const String _auditEndpoint = 'https://api.audit.gouv.tg';
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 5);
  
  // Cache local pour les logs en cas de panne réseau
  static final List<Map<String, dynamic>> _pendingLogs = [];
  static const int _maxPendingLogs = 1000;

  /// Enregistrer une action utilisateur
  static Future<void> logUserAction({
    required String userId,
    required String action,
    required String resource,
    Map<String, dynamic>? details,
    String? ipAddress,
    String? userAgent,
  }) async {
    try {
      final logEntry = {
        'timestamp': DateTime.now().toIso8601String(),
        'userId': userId,
        'action': action,
        'resource': resource,
        'details': details ?? {},
        'ipAddress': ipAddress ?? 'unknown',
        'userAgent': userAgent ?? 'mobile',
        'sessionId': _generateSessionId(),
        'severity': _getActionSeverity(action),
        'category': _getActionCategory(action),
      };

      await _sendLogEntry(logEntry);
      
    } catch (e) {
      print('Erreur enregistrement action utilisateur: $e');
      // En cas d'erreur, sauvegarder localement
      _savePendingLog({
        'type': 'USER_ACTION',
        'data': {
          'userId': userId,
          'action': action,
          'resource': resource,
          'details': details ?? {},
          'timestamp': DateTime.now().toIso8601String(),
        }
      });
    }
  }

  /// Enregistrer une action système
  static Future<void> logSystemAction({
    required String component,
    required String action,
    required String status,
    Map<String, dynamic>? details,
    String? errorMessage,
  }) async {
    try {
      final logEntry = {
        'timestamp': DateTime.now().toIso8601String(),
        'component': component,
        'action': action,
        'status': status,
        'details': details ?? {},
        'errorMessage': errorMessage,
        'severity': _getSystemSeverity(status, errorMessage),
        'category': 'SYSTEM',
      };

      await _sendLogEntry(logEntry);
      
    } catch (e) {
      print('Erreur enregistrement action système: $e');
      _savePendingLog({
        'type': 'SYSTEM_ACTION',
        'data': {
          'component': component,
          'action': action,
          'status': status,
          'details': details ?? {},
          'timestamp': DateTime.now().toIso8601String(),
        }
      });
    }
  }

  /// Enregistrer une action de sécurité
  static Future<void> logSecurityEvent({
    required String userId,
    required String event,
    required String level,
    Map<String, dynamic>? details,
    String? ipAddress,
  }) async {
    try {
      final logEntry = {
        'timestamp': DateTime.now().toIso8601String(),
        'userId': userId,
        'event': event,
        'level': level,
        'details': details ?? {},
        'ipAddress': ipAddress ?? 'unknown',
        'severity': _getSecuritySeverity(level),
        'category': 'SECURITY',
      };

      await _sendLogEntry(logEntry);
      
    } catch (e) {
      print('Erreur enregistrement événement sécurité: $e');
      _savePendingLog({
        'type': 'SECURITY_EVENT',
        'data': {
          'userId': userId,
          'event': event,
          'level': level,
          'details': details ?? {},
          'timestamp': DateTime.now().toIso8601String(),
        }
      });
    }
  }

  /// Enregistrer une action de données
  static Future<void> logDataAction({
    required String userId,
    required String action,
    required String dataType,
    required String dataId,
    Map<String, dynamic>? oldData,
    Map<String, dynamic>? newData,
  }) async {
    try {
      final logEntry = {
        'timestamp': DateTime.now().toIso8601String(),
        'userId': userId,
        'action': action,
        'dataType': dataType,
        'dataId': dataId,
        'oldData': oldData,
        'newData': newData,
        'severity': _getDataSeverity(action),
        'category': 'DATA',
      };

      await _sendLogEntry(logEntry);
      
    } catch (e) {
      print('Erreur enregistrement action données: $e');
      _savePendingLog({
        'type': 'DATA_ACTION',
        'data': {
          'userId': userId,
          'action': action,
          'dataType': dataType,
          'dataId': dataId,
          'timestamp': DateTime.now().toIso8601String(),
        }
      });
    }
  }

  /// Enregistrer une action de validation
  static Future<void> logValidationAction({
    required String userId,
    required String validationType,
    required String status,
    required Map<String, dynamic> data,
    Map<String, dynamic>? results,
  }) async {
    try {
      final logEntry = {
        'timestamp': DateTime.now().toIso8601String(),
        'userId': userId,
        'validationType': validationType,
        'status': status,
        'data': data,
        'results': results ?? {},
        'severity': _getValidationSeverity(status),
        'category': 'VALIDATION',
      };

      await _sendLogEntry(logEntry);
      
    } catch (e) {
      print('Erreur enregistrement validation: $e');
      _savePendingLog({
        'type': 'VALIDATION_ACTION',
        'data': {
          'userId': userId,
          'validationType': validationType,
          'status': status,
          'timestamp': DateTime.now().toIso8601String(),
        }
      });
    }
  }

  /// Obtenir l'historique des actions d'un utilisateur
  static Future<List<Map<String, dynamic>>> getUserActionHistory({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
    String? action,
    int? limit,
  }) async {
    try {
      final queryParams = <String, String>{
        'userId': userId,
        if (startDate != null) 'startDate': startDate.toIso8601String(),
        if (endDate != null) 'endDate': endDate.toIso8601String(),
        if (action != null) 'action': action,
        if (limit != null) 'limit': limit.toString(),
      };

      final uri = Uri.parse('$_auditEndpoint/user-actions').replace(
        queryParameters: queryParams,
      );

      final response = await http.get(uri).timeout(Duration(seconds: 30));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return List<Map<String, dynamic>>.from(data['actions'] ?? []);
      }
      
      return [];
      
    } catch (e) {
      print('Erreur récupération historique: $e');
      return [];
    }
  }

  /// Obtenir les statistiques d'audit
  static Future<Map<String, dynamic>> getAuditStatistics({
    DateTime? startDate,
    DateTime? endDate,
    String? category,
  }) async {
    try {
      final queryParams = <String, String>{
        if (startDate != null) 'startDate': startDate.toIso8601String(),
        if (endDate != null) 'endDate': endDate.toIso8601String(),
        if (category != null) 'category': category,
      };

      final uri = Uri.parse('$_auditEndpoint/statistics').replace(
        queryParameters: queryParams,
      );

      final response = await http.get(uri).timeout(Duration(seconds: 30));
      
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      
      return {};
      
    } catch (e) {
      print('Erreur récupération statistiques: $e');
      return {};
    }
  }

  /// Exporter les logs d'audit
  static Future<Map<String, dynamic>> exportAuditLogs({
    DateTime? startDate,
    DateTime? endDate,
    String? userId,
    String? category,
    String format = 'JSON',
  }) async {
    try {
      final queryParams = <String, String>{
        if (startDate != null) 'startDate': startDate.toIso8601String(),
        if (endDate != null) 'endDate': endDate.toIso8601String(),
        if (userId != null) 'userId': userId,
        if (category != null) 'category': category,
        'format': format,
      };

      final uri = Uri.parse('$_auditEndpoint/export').replace(
        queryParameters: queryParams,
      );

      final response = await http.get(uri).timeout(Duration(seconds: 60));
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'data': json.decode(response.body),
          'format': format,
          'exportDate': DateTime.now().toIso8601String(),
        };
      }
      
      return {
        'success': false,
        'error': 'Erreur lors de l\'export',
      };
      
    } catch (e) {
      print('Erreur export logs: $e');
      return {
        'success': false,
        'error': 'Erreur lors de l\'export: $e',
      };
    }
  }

  /// Envoyer un log vers le service d'audit
  static Future<void> _sendLogEntry(Map<String, dynamic> logEntry) async {
    int retries = 0;
    
    while (retries < _maxRetries) {
      try {
        final response = await http.post(
          Uri.parse('$_auditEndpoint/logs'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${_getAuditToken()}',
          },
          body: json.encode(logEntry),
        ).timeout(Duration(seconds: 10));
        
        if (response.statusCode == 200 || response.statusCode == 201) {
          return; // Succès
        }
        
        retries++;
        if (retries < _maxRetries) {
          await Future.delayed(_retryDelay);
        }
        
      } catch (e) {
        retries++;
        if (retries < _maxRetries) {
          await Future.delayed(_retryDelay);
        } else {
          throw e;
        }
      }
    }
    
    // Si tous les essais ont échoué, sauvegarder localement
    _savePendingLog({
      'type': 'AUDIT_LOG',
      'data': logEntry,
    });
  }

  /// Sauvegarder un log en attente
  static void _savePendingLog(Map<String, dynamic> log) {
    if (_pendingLogs.length >= _maxPendingLogs) {
      _pendingLogs.removeAt(0); // Supprimer le plus ancien
    }
    
    _pendingLogs.add(log);
  }

  /// Traiter les logs en attente
  static Future<void> processPendingLogs() async {
    if (_pendingLogs.isEmpty) return;
    
    final logsToProcess = List<Map<String, dynamic>>.from(_pendingLogs);
    _pendingLogs.clear();
    
    for (final log in logsToProcess) {
      try {
        await _sendLogEntry(log['data']);
      } catch (e) {
        // Remettre en attente si l'envoi échoue
        _savePendingLog(log);
      }
    }
  }

  /// Générer un ID de session
  static String _generateSessionId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  /// Obtenir la sévérité d'une action
  static String _getActionSeverity(String action) {
    switch (action.toLowerCase()) {
      case 'delete':
      case 'remove':
      case 'destroy':
        return 'HIGH';
      case 'update':
      case 'modify':
      case 'edit':
        return 'MEDIUM';
      case 'view':
      case 'read':
      case 'list':
        return 'LOW';
      default:
        return 'MEDIUM';
    }
  }

  /// Obtenir la catégorie d'une action
  static String _getActionCategory(String action) {
    switch (action.toLowerCase()) {
      case 'login':
      case 'logout':
      case 'register':
        return 'AUTHENTICATION';
      case 'create':
      case 'update':
      case 'delete':
        return 'DATA_MANAGEMENT';
      case 'view':
      case 'read':
      case 'list':
        return 'DATA_ACCESS';
      case 'export':
      case 'download':
        return 'DATA_EXPORT';
      default:
        return 'GENERAL';
    }
  }

  /// Obtenir la sévérité d'une action système
  static String _getSystemSeverity(String status, String? errorMessage) {
    if (status == 'ERROR' || errorMessage != null) {
      return 'HIGH';
    }
    if (status == 'WARNING') {
      return 'MEDIUM';
    }
    return 'LOW';
  }

  /// Obtenir la sévérité d'un événement de sécurité
  static String _getSecuritySeverity(String level) {
    switch (level.toUpperCase()) {
      case 'CRITICAL':
        return 'CRITICAL';
      case 'HIGH':
        return 'HIGH';
      case 'MEDIUM':
        return 'MEDIUM';
      case 'LOW':
        return 'LOW';
      default:
        return 'MEDIUM';
    }
  }

  /// Obtenir la sévérité d'une action de données
  static String _getDataSeverity(String action) {
    switch (action.toLowerCase()) {
      case 'delete':
      case 'purge':
        return 'HIGH';
      case 'update':
      case 'modify':
        return 'MEDIUM';
      case 'create':
      case 'read':
        return 'LOW';
      default:
        return 'MEDIUM';
    }
  }

  /// Obtenir la sévérité d'une validation
  static String _getValidationSeverity(String status) {
    switch (status.toUpperCase()) {
      case 'FAILED':
      case 'REJECTED':
        return 'HIGH';
      case 'WARNING':
      case 'PENDING':
        return 'MEDIUM';
      case 'PASSED':
      case 'APPROVED':
        return 'LOW';
      default:
        return 'MEDIUM';
    }
  }

  /// Obtenir le token d'audit
  static String _getAuditToken() {
    // En production, utiliser un token d'API sécurisé
    return 'audit_token_placeholder';
  }
}


