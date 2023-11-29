import 'package:langchain/langchain.dart';

abstract class LangchainService {
  List<Document> splitDocToChunks(Document doc);
  Future<List<List<double>>> embedChunks(List<Document> chunks);
  Future<void> storeDocumentData(Document doc, List<Document> chunks,
      List<List<double>> embeddedDoc, String tableName);

  Future<bool> checkExtExist();
  Future<bool> checkTableExist(String tableName);
  Future<String> createNeonVecorExt();
  Future<String> createNeonTable(String tableName);
  Future<String> deleteNeonTableRows(String tableName);

  Future<String> queryNeonTable(String tableName, String query);
}
