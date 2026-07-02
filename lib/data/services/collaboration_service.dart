import 'dart:async';
import 'dart:convert';

class CollaborationService {
  final Map<String, CollaborativeSession> _activeSessions = {};
  final Map<String, StreamController<CollaborationEvent>> _eventControllers = {};
  
  bool _isInitialized = false;
  
  /// Initialize collaboration service
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    // In a real implementation, this would initialize WebSocket connections
    await Future.delayed(const Duration(milliseconds: 500));
    _isInitialized = true;
  }
  
  /// Create a new collaborative session
  Future<CollaborativeSession> createSession({
    required String presentationId,
    required String hostUserId,
    String? sessionName,
    CollaborationPermissions? permissions,
  }) async {
    if (!_isInitialized) {
      throw Exception('Collaboration service not initialized');
    }
    
    final sessionId = 'session_${DateTime.now().millisecondsSinceEpoch}';
    final session = CollaborativeSession(
      id: sessionId,
      presentationId: presentationId,
      hostUserId: hostUserId,
      name: sessionName ?? 'Collaborative Session',
      createdAt: DateTime.now(),
      permissions: permissions ?? CollaborationPermissions.defaultPermissions(),
      participants: [hostUserId],
      isActive: true,
    );
    
    _activeSessions[sessionId] = session;
    _eventControllers[sessionId] = StreamController<CollaborationEvent>.broadcast();
    
    return session;
  }
  
  /// Join an existing collaborative session
  Future<CollaborativeSession> joinSession({
    required String sessionId,
    required String userId,
    String? userName,
  }) async {
    if (!_isInitialized) {
      throw Exception('Collaboration service not initialized');
    }
    
    final session = _activeSessions[sessionId];
    if (session == null) {
      throw Exception('Session not found: $sessionId');
    }
    
    if (!session.isActive) {
      throw Exception('Session is not active: $sessionId');
    }
    
    // Add user to session
    if (!session.participants.contains(userId)) {
      session.participants.add(userId);
    }
    
    // Notify other participants
    _emitEvent(sessionId, CollaborationEvent(
      type: CollaborationEventType.userJoined,
      userId: userId,
      userName: userName ?? 'User',
      timestamp: DateTime.now(),
      data: {'sessionId': sessionId},
    ));
    
    return session;
  }
  
  /// Leave a collaborative session
  Future<void> leaveSession({
    required String sessionId,
    required String userId,
  }) async {
    if (!_isInitialized) {
      throw Exception('Collaboration service not initialized');
    }
    
    final session = _activeSessions[sessionId];
    if (session == null) {
      throw Exception('Session not found: $sessionId');
    }
    
    // Remove user from session
    session.participants.remove(userId);
    
    // Notify other participants
    _emitEvent(sessionId, CollaborationEvent(
      type: CollaborationEventType.userLeft,
      userId: userId,
      timestamp: DateTime.now(),
      data: {'sessionId': sessionId},
    ));
    
    // If host leaves, transfer ownership or end session
    if (userId == session.hostUserId) {
      if (session.participants.isNotEmpty) {
        session.hostUserId = session.participants.first;
        _emitEvent(sessionId, CollaborationEvent(
          type: CollaborationEventType.hostChanged,
          userId: session.hostUserId,
          timestamp: DateTime.now(),
          data: {'newHost': session.hostUserId},
        ));
      } else {
        await endSession(sessionId: sessionId);
      }
    }
  }
  
  /// End a collaborative session
  Future<void> endSession({required String sessionId}) async {
    if (!_isInitialized) {
      throw Exception('Collaboration service not initialized');
    }
    
    final session = _activeSessions[sessionId];
    if (session == null) {
      throw Exception('Session not found: $sessionId');
    }
    
    session.isActive = false;
    session.endedAt = DateTime.now();
    
    // Notify all participants
    _emitEvent(sessionId, CollaborationEvent(
      type: CollaborationEventType.sessionEnded,
      userId: session.hostUserId,
      timestamp: DateTime.now(),
      data: {'sessionId': sessionId},
    ));
    
    // Clean up
    _eventControllers[sessionId]?.close();
    _eventControllers.remove(sessionId);
    _activeSessions.remove(sessionId);
  }
  
  /// Send a collaboration event
  Future<void> sendEvent({
    required String sessionId,
    required CollaborationEvent event,
  }) async {
    if (!_isInitialized) {
      throw Exception('Collaboration service not initialized');
    }
    
    final session = _activeSessions[sessionId];
    if (session == null) {
      throw Exception('Session not found: $sessionId');
    }
    
    if (!session.isActive) {
      throw Exception('Session is not active: $sessionId');
    }
    
    // Broadcast event to all participants
    _emitEvent(sessionId, event);
  }
  
  /// Listen for collaboration events
  Stream<CollaborationEvent> listenToEvents(String sessionId) {
    if (!_isInitialized) {
      throw Exception('Collaboration service not initialized');
    }
    
    final controller = _eventControllers[sessionId];
    if (controller == null) {
      throw Exception('Session not found: $sessionId');
    }
    
    return controller.stream;
  }
  
  /// Update presentation content collaboratively
  Future<void> updatePresentationContent({
    required String sessionId,
    required String userId,
    required Map<String, dynamic> content,
    required ContentUpdateType updateType,
  }) async {
    if (!_isInitialized) {
      throw Exception('Collaboration service not initialized');
    }
    
    final session = _activeSessions[sessionId];
    if (session == null) {
      throw Exception('Session not found: $sessionId');
    }
    
    // Check permissions
    if (!session.permissions.canEdit && userId != session.hostUserId) {
      throw Exception('User does not have edit permissions');
    }
    
    // Send content update event
    _emitEvent(sessionId, CollaborationEvent(
      type: CollaborationEventType.contentUpdated,
      userId: userId,
      timestamp: DateTime.now(),
      data: {
        'content': content,
        'updateType': updateType.toString(),
      },
    ));
  }
  
  /// Add comment to presentation
  Future<void> addComment({
    required String sessionId,
    required String userId,
    required String userName,
    required String slideId,
    required String comment,
    CommentType type = CommentType.general,
  }) async {
    if (!_isInitialized) {
      throw Exception('Collaboration service not initialized');
    }
    
    final session = _activeSessions[sessionId];
    if (session == null) {
      throw Exception('Session not found: $sessionId');
    }
    
    // Send comment event
    _emitEvent(sessionId, CollaborationEvent(
      type: CollaborationEventType.commentAdded,
      userId: userId,
      userName: userName,
      timestamp: DateTime.now(),
      data: {
        'slideId': slideId,
        'comment': comment,
        'commentType': type.toString(),
      },
    ));
  }
  
  /// Get active sessions
  List<CollaborativeSession> getActiveSessions() {
    return _activeSessions.values.where((session) => session.isActive).toList();
  }
  
  /// Get session by ID
  CollaborativeSession? getSession(String sessionId) {
    return _activeSessions[sessionId];
  }
  
  /// Check if service is initialized
  bool get isInitialized => _isInitialized;
  
  /// Dispose resources
  void dispose() {
    for (final controller in _eventControllers.values) {
      controller.close();
    }
    _eventControllers.clear();
    _activeSessions.clear();
    _isInitialized = false;
  }
  
  void _emitEvent(String sessionId, CollaborationEvent event) {
    final controller = _eventControllers[sessionId];
    if (controller != null && !controller.isClosed) {
      controller.add(event);
    }
  }
}

/// Collaborative session class
class CollaborativeSession {
  final String id;
  final String presentationId;
  String hostUserId;
  final String name;
  final DateTime createdAt;
  DateTime? endedAt;
  final CollaborationPermissions permissions;
  final List<String> participants;
  bool isActive;
  
  CollaborativeSession({
    required this.id,
    required this.presentationId,
    required this.hostUserId,
    required this.name,
    required this.createdAt,
    this.endedAt,
    required this.permissions,
    required this.participants,
    required this.isActive,
  });
  
  Duration get duration {
    final endTime = endedAt ?? DateTime.now();
    return endTime.difference(createdAt);
  }
  
  int get participantCount => participants.length;
}

/// Collaboration event class
class CollaborationEvent {
  final CollaborationEventType type;
  final String userId;
  final String? userName;
  final DateTime timestamp;
  final Map<String, dynamic> data;
  
  CollaborationEvent({
    required this.type,
    required this.userId,
    this.userName,
    required this.timestamp,
    required this.data,
  });
}

/// Collaboration event types
enum CollaborationEventType {
  userJoined,
  userLeft,
  hostChanged,
  contentUpdated,
  commentAdded,
  sessionEnded,
  cursorMoved,
  selectionChanged,
}

/// Content update types
enum ContentUpdateType {
  slideAdded,
  slideRemoved,
  slideModified,
  textChanged,
  imageAdded,
  imageRemoved,
  layoutChanged,
  styleChanged,
}

/// Comment types
enum CommentType {
  general,
  suggestion,
  question,
  approval,
  revision,
}

/// Collaboration permissions class
class CollaborationPermissions {
  final bool canEdit;
  final bool canComment;
  final bool canView;
  final bool canInvite;
  final bool canManage;
  
  const CollaborationPermissions({
    required this.canEdit,
    required this.canComment,
    required this.canView,
    required this.canInvite,
    required this.canManage,
  });
  
  factory CollaborationPermissions.defaultPermissions() {
    return const CollaborationPermissions(
      canEdit: true,
      canComment: true,
      canView: true,
      canInvite: false,
      canManage: false,
    );
  }
  
  factory CollaborationPermissions.viewOnly() {
    return const CollaborationPermissions(
      canEdit: false,
      canComment: true,
      canView: true,
      canInvite: false,
      canManage: false,
    );
  }
  
  factory CollaborationPermissions.fullAccess() {
    return const CollaborationPermissions(
      canEdit: true,
      canComment: true,
      canView: true,
      canInvite: true,
      canManage: true,
    );
  }
}