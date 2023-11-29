import 'dart:io';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:langchain/langchain.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rag_with_langchain_pgvector/base_home_page/view_models/langchain_services.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

enum CreateandUploadState { initial, loading, loaded, error }

class TableNotifier extends ChangeNotifier {
  late LangchainService langchainService;
  TableNotifier({required this.langchainService});

  String? _filepath;
  String? _fileName;
  String? get fileName => _fileName;

  final _createandUploadState =
      ValueNotifier<CreateandUploadState>(CreateandUploadState.initial);

  ValueNotifier<CreateandUploadState> get createandUploadState =>
      _createandUploadState;

  Future<void> createAndUploadNeonTable() async {
    try {
      // load the document into the application
      final pickedDocument = await _pickedFile();
      _createandUploadState.value = CreateandUploadState.loading;
      // split the document to different chunks
      final splitChunks = langchainService.splitDocToChunks(pickedDocument);
      // Embed the chunks
      final embededDoc = await langchainService.embedChunks(splitChunks);

      if (!(await langchainService.checkExtExist())) {
        await langchainService.createNeonVecorExt();
      }

      if (!(await langchainService.checkTableExist(_fileName!))) {
        await langchainService.createNeonTable(_fileName!);
      } else {
        await langchainService.deleteNeonTableRows(_fileName!);
      }

      await langchainService.storeDocumentData(
          pickedDocument, splitChunks, embededDoc, _fileName!);

      _createandUploadState.value = CreateandUploadState.loaded;
    } catch (e) {
      _createandUploadState.value = CreateandUploadState.error;
      print(e);
    } finally {
      await Future.delayed(const Duration(milliseconds: 2000));
      _createandUploadState.value = CreateandUploadState.initial;
    }
  }

  Future<Document> _pickedFile() async {
    FilePickerResult? result = await FilePicker.platform
        .pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);

    if (result != null) {
      _filepath = result.files.single.path;
      _fileName = result.files.single.name.replaceAll('.pdf', '').toLowerCase();
      final textfile =
          _filepath!.isNotEmpty ? await _readPDFandConvertToText() : "";
      final loader = TextLoader(textfile);
      final document = await loader.load();
      Document? docs;
      for (var doc in document) {
        docs = doc;
      }
      return docs!;
    } else {
      throw Exception("No file selected");
    }
  }

  Future<String> _readPDFandConvertToText() async {
    File file = File(_filepath!);
    List<int> bytes = await file.readAsBytes();
    final document = PdfDocument(inputBytes: Uint8List.fromList(bytes));

    String text = PdfTextExtractor(document).extractText();
    final localPath = await _localPath;
    File createFile = File('$localPath/output.txt');
    final res = await createFile.writeAsString(text);

    document.dispose();
    return res.path;
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }
}
