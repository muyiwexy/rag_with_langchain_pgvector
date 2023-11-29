import 'package:flutter/material.dart';

import '../view_models/langchain_services.dart';

class Message {
  String? query;
  String? response;
  Message({required this.query, this.response = ""});
}

enum QueryState {
  initial,
  loading,
  loaded,
  error,
}

class QueryNotifier extends ChangeNotifier {
  late LangchainService langchainService;
  QueryNotifier({required this.langchainService});

  final List<Message> _messages = [];
  final _messagesState = ValueNotifier<List<Message>>([]);
  ValueNotifier<List<Message>> get messageState => _messagesState;

  final _queryState = ValueNotifier<QueryState>(QueryState.initial);
  ValueNotifier<QueryState> get queryState => _queryState;

  userqueryResponse(String tableName, String query) async {
    _messages.add(Message(query: query, response: ""));
    _messagesState.value = List.from(_messages);
    try {
      _queryState.value = QueryState.loading;
      String response = await langchainService.queryNeonTable(tableName, query);

      final List<Message> updatedMessages = List.from(_messages);
      updatedMessages.last.response = response;
      _messagesState.value = updatedMessages;
      _queryState.value = QueryState.loaded;
    } catch (e) {
      // Handle errors if necessary
      print(e);
      _queryState.value = QueryState.error;
      await Future.delayed(const Duration(milliseconds: 2000));
      _queryState.value = QueryState.initial;
    }
  }
}
