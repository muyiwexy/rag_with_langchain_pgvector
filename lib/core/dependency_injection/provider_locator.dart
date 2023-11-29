import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:langchain_openai/langchain_openai.dart';
import 'package:postgres/postgres.dart';
import 'package:provider/provider.dart';

import '../../base_home_page/controller/query_notifier.dart';
import '../../base_home_page/controller/table_notifier.dart';
import '../../base_home_page/view_models/langchain_services.dart';
import '../../base_home_page/view_models/langchain_services_impl.dart';

class ProviderLocator {
  // provider tree
  static Future<MultiProvider> getProvider(Widget child) async {
    final langchainService = await _createLangchainService();

    return MultiProvider(
      providers: [
        Provider<LangchainService>.value(value: langchainService),
        ChangeNotifierProvider<TableNotifier>(
          create: (_) => TableNotifier(langchainService: langchainService),
        ),
        ChangeNotifierProvider<QueryNotifier>(
          create: (_) => QueryNotifier(langchainService: langchainService),
        ),
      ],
      child: child,
    );
  }

  // langchain services function
  static Future<LangchainService> _createLangchainService() async {
    final connection = await createPostgresConnection();
    final embeddings = await _createEmbeddings();
    final openAI = await _createOpenAIConnection();

    return LangchainServicesImpl(
      connection: connection,
      embeddings: embeddings,
      openAI: openAI,
    );
  }

  // postgres connection
  static Future<Connection> createPostgresConnection() async {
    const maxRetries = 3;
    for (var retry = 0; retry < maxRetries; retry++) {
      try {
        final endpoint = Endpoint(
          host: dotenv.env['PGHOST']!,
          database: dotenv.env['PGDATABASE']!,
          port: 5432,
          username: dotenv.env['PGUSER']!,
          password: dotenv.env['PGPASSWORD']!,
        );

        final connection = await Connection.open(
          endpoint,
          settings: ConnectionSettings(
            sslMode: SslMode.verifyFull,
            connectTimeout: const Duration(milliseconds: 20000),
          ),
        );

        if (connection.isOpen) {
          if (kDebugMode) {
            print("Connection Established!");
          }
          return connection;
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error creating PostgreSQL connection: $e');
        }
      }

      await Future.delayed(const Duration(seconds: 2));
    }

    // If maxRetries is reached and the connection is still not open, throw an exception
    throw Exception(
        'Failed to establish a PostgreSQL connection after $maxRetries retries');
  }

  // Lanchain openAI embeddings
  static Future<OpenAIEmbeddings> _createEmbeddings() async {
    return OpenAIEmbeddings(
      apiKey: dotenv.env['OPENAI_API_KEY'],
      model: "text-embedding-ada-002",
    );
  }

  // openAi connection
  static Future<OpenAI> _createOpenAIConnection() async {
    return OpenAI(apiKey: dotenv.env['OPENAI_API_KEY']);
  }
}
