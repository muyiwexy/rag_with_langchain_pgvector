import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:langchain/langchain.dart';
import 'package:langchain_openai/langchain_openai.dart';
import 'package:postgres/postgres.dart';
import 'package:rag_with_langchain_pgvector/base_home_page/model/metadata_model.dart';
import 'package:rag_with_langchain_pgvector/base_home_page/view_models/langchain_services.dart';

class LangchainServicesImpl extends LangchainService {
  final Connection connection;
  final OpenAIEmbeddings embeddings;
  final OpenAI openAI;

  LangchainServicesImpl({
    required this.connection,
    required this.embeddings,
    required this.openAI,
  });

  @override
  List<Document> splitDocToChunks(Document doc) {
    final text = doc.pageContent;
    const textSplitter = RecursiveCharacterTextSplitter(chunkSize: 1000);
    final chunks = textSplitter.createDocuments([text]);
    return chunks
        .map(
          (e) => Document(
            id: e.id,
            pageContent: e.pageContent.replaceAll(RegExp('/\n/g'), "  "),
            metadata: doc.metadata,
          ),
        )
        .toList();
  }

  @override
  Future<List<List<double>>> embedChunks(List<Document> chunks) async {
    final embedDocs = await embeddings.embedDocuments(chunks);
    return embedDocs;
  }

  @override
  Future<void> storeDocumentData(Document doc, List<Document> chunks,
      List<List<double>> embeddedDoc, String tableName) async {
    debugPrint("Storing chunks and emedded vectors in the $tableName table");
    await connection.runTx((s) async {
      for (int i = 0; i < chunks.length; i++) {
        final txtPath = doc.metadata['source'] as String;
        final chunk = chunks[i];
        final embeddingArray = embeddedDoc[i];

        await s.execute(
          Sql.named(
            'INSERT INTO $tableName (id, metadata, embedding) VALUES (@id, @metadata, @embedding)',
          ),
          parameters: {
            'id': '${txtPath}_$i',
            'metadata': {
              ...chunk.metadata,
              'loc': jsonEncode(chunk.metadata['loc']),
              'pageContent': chunk.pageContent,
              'txtPath': txtPath,
            },
            'embedding': '$embeddingArray',
          },
        );
      }
    });
  }

  @override
  Future<bool> checkExtExist() async {
    final checkExtExist = await connection.execute(
      "SELECT EXISTS (SELECT FROM pg_extension WHERE extname = 'vectors');",
    );
    return checkExtExist.first[0] as bool;
  }

  @override
  Future<bool> checkTableExist(String tableName) async {
    final checkTableExist = await connection.execute(
      "SELECT EXISTS (SELECT FROM information_schema.tables WHERE  table_schema = 'public' AND table_name = '$tableName');",
    );
    return checkTableExist.first[0] as bool;
  }

  @override
  Future<String> createNeonVecorExt() async {
    debugPrint("Creating pgVector extension ...");
    await connection.execute("CREATE EXTENSION vector;");

    return "Vector extension created Successfully";
  }

  @override
  Future<String> createNeonTable(String tableName) async {
    debugPrint("Creating the $tableName table ... ");
    await connection.execute(
      "CREATE TABLE $tableName (id text, metadata text, embedding vector(1536));",
    );

    debugPrint("Indexing the $tableName using the ivfflat vector cosine");
    await connection.execute(
        'CREATE INDEX ON $tableName USING ivfflat (embedding vector_cosine_ops) WITH (lists = 24);');

    return "Table created successfully";
  }

  @override
  Future<String> deleteNeonTableRows(String tableName) async {
    debugPrint("Deleting tableRows");
    await connection.execute("TRUNCATE $tableName;");
    return "Table rows deleted successfuly";
  }

  @override
  Future<String> queryNeonTable(String tableName, String query) async {
    final embedQuery = await embeddings.embedQuery(query);
    List<List<dynamic>> getSimilar = await connection.execute(
        "SELECT *, 1 - (embedding <=> '$embedQuery') AS cosine_similarity FROM $tableName WHERE (1 - (embedding <=> '$embedQuery')) BETWEEN 0.3 AND 1.00 ORDER BY cosine_similarity DESC LIMIT 10;");

    List<Metadata> pdfMetadata = getSimilar
        .map((item) => Metadata.fromJson(json.decode(item[1])))
        .toList();

    if (pdfMetadata.isNotEmpty) {
      final concatPageContent = pdfMetadata.map((e) {
        return e.pageContent;
      }).join(' ');
      final docChain = StuffDocumentsQAChain(llm: openAI);
      final response = await docChain.call({
        'input_documents': [
          Document(pageContent: concatPageContent),
        ],
        'question': query,
      });

      return response['output'];
    } else {
      return "Couldn't find anything on that topic";
    }
  }
}

void debugPrint(String message) {
  if (kDebugMode) {
    print(message);
  }
}
