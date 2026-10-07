import 'package:flutter/material.dart';
import '../../domain/usecases/get_conversations.dart';
import '../../domain/usecases/delete_conversation.dart';
import '../../domain/entities/conversation.dart';

class ConversationController extends ChangeNotifier {
  final GetConversations getConversations;
  final DeleteConversation deleteConversationUseCase;

  ConversationController({
    required this.getConversations,
    required this.deleteConversationUseCase,
  });

  List<Conversation> _conversations = [];
  List<Conversation> get conversations => _conversations;
  
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> loadConversations() async {
    _isLoading = true;
    notifyListeners();

    final result = await getConversations();
    result.fold(
      (f) => debugPrint(f.message),
      (convs) => _conversations = convs,
    );

    _isLoading = false;
    notifyListeners();
  }
  
  Future<void> deleteConversation(String id) async {
      await deleteConversationUseCase(id);
      await loadConversations();
  }
}