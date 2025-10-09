import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';

class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String content;
  final DateTime timestamp;
  final String type; // text, image, file, location
  final Map<String, dynamic>? metadata;
  final bool isRead;
  final String? replyToId;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.timestamp,
    this.type = 'text',
    this.metadata,
    this.isRead = false,
    this.replyToId,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'senderId': senderId,
    'senderName': senderName,
    'content': content,
    'timestamp': timestamp.toIso8601String(),
    'type': type,
    'metadata': metadata,
    'isRead': isRead,
    'replyToId': replyToId,
  };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
    id: json['id'],
    senderId: json['senderId'],
    senderName: json['senderName'],
    content: json['content'],
    timestamp: DateTime.parse(json['timestamp']),
    type: json['type'] ?? 'text',
    metadata: json['metadata'],
    isRead: json['isRead'] ?? false,
    replyToId: json['replyToId'],
  );
}

class ChatRoom {
  final String id;
  final String name;
  final String type; // direct, group, support
  final List<String> participants;
  final String? lastMessage;
  final DateTime? lastMessageTime;
  final int unreadCount;
  final Map<String, dynamic>? metadata;

  ChatRoom({
    required this.id,
    required this.name,
    required this.type,
    required this.participants,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount = 0,
    this.metadata,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type,
    'participants': participants,
    'lastMessage': lastMessage,
    'lastMessageTime': lastMessageTime?.toIso8601String(),
    'unreadCount': unreadCount,
    'metadata': metadata,
  };

  factory ChatRoom.fromJson(Map<String, dynamic> json) => ChatRoom(
    id: json['id'],
    name: json['name'],
    type: json['type'],
    participants: List<String>.from(json['participants']),
    lastMessage: json['lastMessage'],
    lastMessageTime: json['lastMessageTime'] != null 
        ? DateTime.parse(json['lastMessageTime']) 
        : null,
    unreadCount: json['unreadCount'] ?? 0,
    metadata: json['metadata'],
  );
}

class ChatService {
  static final StreamController<ChatMessage> _messageController = StreamController<ChatMessage>.broadcast();
  static final StreamController<ChatRoom> _roomController = StreamController<ChatRoom>.broadcast();
  static final StreamController<String> _typingController = StreamController<String>.broadcast();
  
  static final List<ChatRoom> _rooms = [];
  static final Map<String, List<ChatMessage>> _messages = {};
  static final Map<String, Set<String>> _typingUsers = {};
  
  // Streams publics
  static Stream<ChatMessage> get messageStream => _messageController.stream;
  static Stream<ChatRoom> get roomStream => _roomController.stream;
  static Stream<String> get typingStream => _typingController.stream;

  // Initialiser le service de chat
  static Future<void> initialize() async {
    // Simuler la connexion au service de chat
    await _loadInitialData();
  }

  // Charger les données initiales
  static Future<void> _loadInitialData() async {
    // Simuler des salles de chat existantes
    _rooms.addAll([
      ChatRoom(
        id: 'room_001',
        name: 'Support Technique',
        type: 'support',
        participants: ['user_001', 'support_001'],
        lastMessage: 'Bonjour, comment puis-je vous aider ?',
        lastMessageTime: DateTime.now().subtract(const Duration(minutes: 5)),
        unreadCount: 0,
      ),
      ChatRoom(
        id: 'room_002',
        name: 'Vendeurs - Riz de Casamance',
        type: 'group',
        participants: ['user_001', 'seller_001', 'seller_002'],
        lastMessage: 'Nouvelle récolte disponible !',
        lastMessageTime: DateTime.now().subtract(const Duration(hours: 2)),
        unreadCount: 3,
      ),
      ChatRoom(
        id: 'room_003',
        name: 'Acheteurs - Tomates',
        type: 'group',
        participants: ['user_001', 'buyer_001', 'buyer_002'],
        lastMessage: 'Prix très compétitif cette semaine',
        lastMessageTime: DateTime.now().subtract(const Duration(days: 1)),
        unreadCount: 1,
      ),
    ]);

    // Simuler des messages
    _messages['room_001'] = [
      ChatMessage(
        id: 'msg_001',
        senderId: 'support_001',
        senderName: 'Support Technique',
        content: 'Bonjour ! Comment puis-je vous aider aujourd\'hui ?',
        timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
      ),
      ChatMessage(
        id: 'msg_002',
        senderId: 'user_001',
        senderName: 'Vous',
        content: 'J\'ai un problème avec ma commande de riz',
        timestamp: DateTime.now().subtract(const Duration(minutes: 8)),
      ),
      ChatMessage(
        id: 'msg_003',
        senderId: 'support_001',
        senderName: 'Support Technique',
        content: 'Pouvez-vous me donner le numéro de commande ?',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      ),
    ];

    _messages['room_002'] = [
      ChatMessage(
        id: 'msg_004',
        senderId: 'seller_001',
        senderName: 'Mamadou Diallo',
        content: 'Nouvelle récolte de riz de Casamance disponible ! Qualité A, prix compétitif.',
        timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      ),
      ChatMessage(
        id: 'msg_005',
        senderId: 'seller_002',
        senderName: 'Fatou Sall',
        content: 'J\'ai aussi du riz bio disponible, 50 tonnes.',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
      ),
    ];
  }

  // Obtenir toutes les salles de chat
  static List<ChatRoom> getRooms() {
    return List.from(_rooms);
  }

  // Obtenir les messages d'une salle
  static List<ChatMessage> getMessages(String roomId) {
    return _messages[roomId] ?? [];
  }

  // Envoyer un message
  static Future<void> sendMessage({
    required String roomId,
    required String content,
    String type = 'text',
    Map<String, dynamic>? metadata,
    String? replyToId,
  }) async {
    final message = ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      senderId: 'user_001', // ID de l'utilisateur actuel
      senderName: 'Vous',
      content: content,
      timestamp: DateTime.now(),
      type: type,
      metadata: metadata,
      replyToId: replyToId,
    );

    // Ajouter le message à la liste
    _messages[roomId] ??= [];
    _messages[roomId]!.add(message);

    // Mettre à jour la salle
    final roomIndex = _rooms.indexWhere((room) => room.id == roomId);
    if (roomIndex != -1) {
      _rooms[roomIndex] = ChatRoom(
        id: _rooms[roomIndex].id,
        name: _rooms[roomIndex].name,
        type: _rooms[roomIndex].type,
        participants: _rooms[roomIndex].participants,
        lastMessage: content,
        lastMessageTime: DateTime.now(),
        unreadCount: _rooms[roomIndex].unreadCount,
        metadata: _rooms[roomIndex].metadata,
      );
    }

    // Notifier les écouteurs
    _messageController.add(message);
    _roomController.add(_rooms[roomIndex]);

    // Simuler une réponse automatique pour le support
    if (roomId == 'room_001') {
      Timer(const Duration(seconds: 2), () {
        _sendAutoReply(roomId, content);
      });
    }
  }

  // Envoyer une réponse automatique
  static void _sendAutoReply(String roomId, String userMessage) {
    String reply = 'Merci pour votre message. Je vais examiner votre demande et vous répondre rapidement.';
    
    if (userMessage.toLowerCase().contains('commande')) {
      reply = 'Pour les problèmes de commande, veuillez fournir le numéro de commande. Je peux vous aider à vérifier le statut.';
    } else if (userMessage.toLowerCase().contains('paiement')) {
      reply = 'Pour les questions de paiement, je peux vous aider à vérifier les transactions ou résoudre les problèmes de facturation.';
    } else if (userMessage.toLowerCase().contains('livraison')) {
      reply = 'Pour le suivi de livraison, je peux vous donner des informations sur l\'état de votre envoi.';
    }

    final autoMessage = ChatMessage(
      id: 'msg_auto_${DateTime.now().millisecondsSinceEpoch}',
      senderId: 'support_001',
      senderName: 'Support Technique',
      content: reply,
      timestamp: DateTime.now(),
    );

    _messages[roomId]!.add(autoMessage);
    _messageController.add(autoMessage);
  }

  // Créer une nouvelle salle de chat
  static Future<String> createRoom({
    required String name,
    required String type,
    required List<String> participants,
    Map<String, dynamic>? metadata,
  }) async {
    final roomId = 'room_${DateTime.now().millisecondsSinceEpoch}';
    final room = ChatRoom(
      id: roomId,
      name: name,
      type: type,
      participants: participants,
      metadata: metadata,
    );

    _rooms.add(room);
    _messages[roomId] = [];
    _roomController.add(room);

    return roomId;
  }

  // Marquer les messages comme lus
  static Future<void> markMessagesAsRead(String roomId) async {
    final messages = _messages[roomId];
    if (messages != null) {
      for (var message in messages) {
        if (message.senderId != 'user_001' && !message.isRead) {
          // Dans une vraie implémentation, on mettrait à jour en base de données
        }
      }
    }

    // Mettre à jour le compteur de messages non lus
    final roomIndex = _rooms.indexWhere((room) => room.id == roomId);
    if (roomIndex != -1) {
      _rooms[roomIndex] = ChatRoom(
        id: _rooms[roomIndex].id,
        name: _rooms[roomIndex].name,
        type: _rooms[roomIndex].type,
        participants: _rooms[roomIndex].participants,
        lastMessage: _rooms[roomIndex].lastMessage,
        lastMessageTime: _rooms[roomIndex].lastMessageTime,
        unreadCount: 0,
        metadata: _rooms[roomIndex].metadata,
      );
      _roomController.add(_rooms[roomIndex]);
    }
  }

  // Indiquer qu'un utilisateur tape
  static void startTyping(String roomId) {
    _typingUsers[roomId] ??= <String>{};
    _typingUsers[roomId]!.add('user_001');
    _typingController.add(roomId);
  }

  // Arrêter d'indiquer qu'un utilisateur tape
  static void stopTyping(String roomId) {
    _typingUsers[roomId]?.remove('user_001');
    if (_typingUsers[roomId]?.isEmpty ?? true) {
      _typingUsers.remove(roomId);
    }
    _typingController.add(roomId);
  }

  // Obtenir les utilisateurs en train de taper
  static Set<String> getTypingUsers(String roomId) {
    return _typingUsers[roomId] ?? <String>{};
  }

  // Rechercher des messages
  static List<ChatMessage> searchMessages(String query) {
    final results = <ChatMessage>[];
    for (var roomMessages in _messages.values) {
      for (var message in roomMessages) {
        if (message.content.toLowerCase().contains(query.toLowerCase())) {
          results.add(message);
        }
      }
    }
    return results;
  }

  // Obtenir les statistiques de chat
  static Map<String, dynamic> getChatStatistics() {
    int totalMessages = 0;
    int totalRooms = _rooms.length;
    int unreadMessages = 0;

    for (var room in _rooms) {
      unreadMessages += room.unreadCount;
    }

    for (var messages in _messages.values) {
      totalMessages += messages.length;
    }

    return {
      'totalMessages': totalMessages,
      'totalRooms': totalRooms,
      'unreadMessages': unreadMessages,
      'activeRooms': _rooms.where((room) => room.lastMessageTime != null && 
          DateTime.now().difference(room.lastMessageTime!).inDays < 7).length,
    };
  }

  // Nettoyer les données
  static void cleanup() {
    _messageController.close();
    _roomController.close();
    _typingController.close();
  }
}
