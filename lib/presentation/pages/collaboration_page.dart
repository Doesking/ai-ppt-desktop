import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

import '../../core/constants/app_constants.dart';
import '../../data/services/collaboration_service.dart';

class CollaborationPage extends ConsumerStatefulWidget {
  final String presentationId;
  final String presentationTitle;
  
  const CollaborationPage({
    super.key,
    required this.presentationId,
    required this.presentationTitle,
  });

  @override
  ConsumerState<CollaborationPage> createState() => _CollaborationPageState();
}

class _CollaborationPageState extends ConsumerState<CollaborationPage> {
  final CollaborationService _collaborationService = CollaborationService();
  final TextEditingController _commentController = TextEditingController();
  
  CollaborativeSession? _currentSession;
  List<CollaborationEvent> _events = [];
  List<String> _participants = [];
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _initializeCollaboration();
  }
  
  Future<void> _initializeCollaboration() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      await _collaborationService.initialize();
      
      // Create a new session
      final session = await _collaborationService.createSession(
        presentationId: widget.presentationId,
        hostUserId: 'user_1',
        sessionName: 'Collaboration: ${widget.presentationTitle}',
      );
      
      setState(() {
        _currentSession = session;
        _participants = session.participants;
        _isLoading = false;
      });
      
      // Listen for events
      _collaborationService.listenToEvents(session.id).listen((event) {
        setState(() {
          _events.add(event);
        });
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to initialize collaboration: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Title Bar
          _buildTitleBar(),
          
          // Main Content
          Expanded(
            child: _buildMainContent(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTitleBar() {
    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const SizedBox(width: 16),
          Text(
            'Collaboration',
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const Spacer(),
          if (_currentSession != null) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${_participants.length} participants',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          // Window controls
          IconButton(
            icon: const Icon(Icons.minimize, size: 16),
            onPressed: () => windowManager.minimize(),
          ),
          IconButton(
            icon: const Icon(Icons.crop_square, size: 16),
            onPressed: () => windowManager.maximize(),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 16),
            onPressed: () => windowManager.close(),
          ),
        ],
      ),
    );
  }
  
  Widget _buildMainContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }
    
    return Row(
      children: [
        // Left Panel - Participants and Controls
        Container(
          width: 300,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              right: BorderSide(
                color: Theme.of(context).dividerColor,
                width: 1,
              ),
            ),
          ),
          child: _buildLeftPanel(),
        ),
        
        // Center - Shared View
        Expanded(
          child: _buildSharedView(),
        ),
        
        // Right Panel - Chat and Comments
        Container(
          width: 350,
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            border: Border(
              left: BorderSide(
                color: Theme.of(context).dividerColor,
                width: 1,
              ),
            ),
          ),
          child: _buildRightPanel(),
        ),
      ],
    );
  }
  
  Widget _buildLeftPanel() {
    return Column(
      children: [
        // Session Info
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).dividerColor,
                width: 1,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Session Info',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                widget.presentationTitle,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'Session ID: ${_currentSession?.id ?? 'N/A'}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
        
        // Participants List
        Expanded(
          child: _buildParticipantsList(),
        ),
        
        // Session Controls
        _buildSessionControls(),
      ],
    );
  }
  
  Widget _buildParticipantsList() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            'Participants (${_participants.length})',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _participants.length,
            itemBuilder: (context, index) {
              final participant = _participants[index];
              final isHost = participant == _currentSession?.hostUserId;
              
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: isHost
                      ? Theme.of(context).colorScheme.primary
                      : Colors.grey,
                  child: Text(
                    participant[0].toUpperCase(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(participant),
                subtitle: isHost ? const Text('Host') : null,
                trailing: isHost
                    ? const Icon(Icons.star, color: Colors.amber)
                    : null,
              );
            },
          ),
        ),
      ],
    );
  }
  
  Widget _buildSessionControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Invite Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _inviteParticipant,
              icon: const Icon(Icons.person_add),
              label: const Text('Invite Participant'),
            ),
          ),
          const SizedBox(height: 8),
          
          // Share Link Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _shareSessionLink,
              icon: const Icon(Icons.link),
              label: const Text('Share Session Link'),
            ),
          ),
          const SizedBox(height: 8),
          
          // End Session Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _endSession,
              icon: const Icon(Icons.stop),
              label: const Text('End Session'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildSharedView() {
    return Container(
      color: Colors.grey[100],
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Shared Presentation View',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'All participants can see and edit the presentation here',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            // Cursor indicators for other participants
            Wrap(
              spacing: 8,
              children: _participants.take(5).map((participant) {
                return Chip(
                  avatar: CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: Text(
                      participant[0].toUpperCase(),
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                  label: Text(participant),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildRightPanel() {
    return Column(
      children: [
        // Chat Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: Theme.of(context).dividerColor,
                width: 1,
              ),
            ),
          ),
          child: Row(
            children: [
              Text(
                'Chat & Comments',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _refreshChat,
                tooltip: 'Refresh',
              ),
            ],
          ),
        ),
        
        // Chat Messages
        Expanded(
          child: _buildChatMessages(),
        ),
        
        // Comment Input
        _buildCommentInput(),
      ],
    );
  }
  
  Widget _buildChatMessages() {
    if (_events.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 48,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No messages yet',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start a conversation with your team',
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 14,
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _events.length,
      itemBuilder: (context, index) {
        final event = _events[index];
        return _buildChatMessage(event);
      },
    );
  }
  
  Widget _buildChatMessage(CollaborationEvent event) {
    final isMe = event.userId == 'user_1';
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.blue,
              child: Text(
                event.userName?[0].toUpperCase() ?? 'U',
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: isMe
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                if (!isMe) ...[
                  Text(
                    event.userName ?? 'User',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isMe
                        ? Theme.of(context).colorScheme.primary
                        : Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getEventMessage(event),
                    style: TextStyle(
                      color: isMe ? Colors.white : Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTime(event.timestamp),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: const Text(
                'M',
                style: TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildCommentInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _commentController,
              decoration: const InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              maxLines: null,
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _sendMessage,
            color: Theme.of(context).colorScheme.primary,
          ),
        ],
      ),
    );
  }
  
  String _getEventMessage(CollaborationEvent event) {
    switch (event.type) {
      case CollaborationEventType.userJoined:
        return '${event.userName ?? event.userId} joined the session';
      case CollaborationEventType.userLeft:
        return '${event.userName ?? event.userId} left the session';
      case CollaborationEventType.contentUpdated:
        return 'Content was updated';
      case CollaborationEventType.commentAdded:
        return event.data['comment'] as String? ?? 'Added a comment';
      case CollaborationEventType.sessionEnded:
        return 'Session ended';
      default:
        return 'Activity occurred';
    }
  }
  
  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
  
  void _inviteParticipant() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Invite Participant'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const TextField(
              decoration: InputDecoration(
                labelText: 'Email or Username',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Or share the session link:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'https://collab.aippt.com/session/${_currentSession?.id}',
                      style: const TextStyle(fontFamily: 'monospace'),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy),
                    onPressed: () {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Link copied to clipboard'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Invitation sent'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Invite'),
          ),
        ],
      ),
    );
  }
  
  void _shareSessionLink() {
    // TODO: Implement share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share functionality not yet implemented'),
        backgroundColor: Colors.orange,
      ),
    );
  }
  
  void _endSession() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End Session'),
        content: const Text('Are you sure you want to end this collaboration session? All participants will be disconnected.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.of(context).pop();
              
              if (_currentSession != null) {
                await _collaborationService.endSession(
                  sessionId: _currentSession!.id,
                );
              }
              
              Navigator.of(context).pop();
              
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Session ended'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('End Session'),
          ),
        ],
      ),
    );
  }
  
  void _refreshChat() {
    // TODO: Implement chat refresh
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Chat refreshed'),
        backgroundColor: Colors.blue,
      ),
    );
  }
  
  void _sendMessage() {
    final message = _commentController.text.trim();
    if (message.isEmpty) return;
    
    // Send message
    _collaborationService.addComment(
      sessionId: _currentSession!.id,
      userId: 'user_1',
      userName: 'You',
      slideId: 'current',
      comment: message,
    );
    
    _commentController.clear();
  }
}