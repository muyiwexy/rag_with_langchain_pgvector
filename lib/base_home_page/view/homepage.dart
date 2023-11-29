import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:rag_with_langchain_pgvector/base_home_page/controller/query_notifier.dart';
import 'package:rag_with_langchain_pgvector/base_home_page/controller/table_notifier.dart';
import 'package:rag_with_langchain_pgvector/base_home_page/widgets/animated_send_arrow.dart';
import 'package:rag_with_langchain_pgvector/base_home_page/widgets/animated_widget.dart';
part 'widgets/display_area.dart';
part 'widgets/text_area.dart';

class BaseHomePage extends StatelessWidget {
  BaseHomePage({super.key});
  final queryController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final queryNotifierProvider =
        Provider.of<QueryNotifier>(context, listen: false);
    final tableNotifierProvider =
        Provider.of<TableNotifier>(context, listen: false);
    return ValueListenableBuilder<CreateandUploadState>(
        valueListenable: tableNotifierProvider.createandUploadState,
        builder: (context, upload, __) {
          return Scaffold(
            backgroundColor: Colors.white,
            drawer: Drawer(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  const DrawerHeader(
                    decoration: BoxDecoration(
                      color: Colors.black,
                    ),
                    child: Text(
                      'Drawer Header',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ElevatedButton(
                        onPressed: () {
                          tableNotifierProvider.createAndUploadNeonTable();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            const Text(
                              "Upload pdf file",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            if (upload == CreateandUploadState.loading)
                              const AnimatedSvgWidget()
                            else
                              SvgPicture.asset(
                                "assets/file_upload_icon.svg",
                                height: 35,
                                colorFilter:
                                    upload == CreateandUploadState.error
                                        ? const ColorFilter.mode(
                                            Colors.red, BlendMode.srcIn)
                                        : const ColorFilter.mode(
                                            Colors.white, BlendMode.srcIn),
                              )
                          ],
                        )),
                  )
                ],
              ),
            ),
            appBar: AppBar(
              toolbarHeight: kToolbarHeight * 1.5,
              leadingWidth: 100,
              leading: Center(
                child: Builder(builder: (context) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 5.0, vertical: 5.0),
                    child: InkWell(
                      onTap: () {
                        Scaffold.of(context).openDrawer();
                      },
                      child: ClipOval(
                        child: Container(
                          height: 60,
                          width: 60,
                          color: const Color(0xffffffff),
                          child: Center(
                            child: SvgPicture.asset(
                              "assets/drawer_icon.svg",
                              height: 40,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              backgroundColor: const Color.fromARGB(255, 0, 0, 0),
              elevation: 0,
              scrolledUnderElevation: 0,
              title: const Text(
                "Whisper",
                style: TextStyle(
                  letterSpacing: 1,
                  fontSize: 25,
                  fontFamily: "Roboto",
                  fontWeight: FontWeight.w600,
                  color: Color.fromARGB(255, 122, 124, 126),
                ),
              ),
              actions: const [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.0),
                  child: CircleAvatar(
                    backgroundColor: Color.fromARGB(255, 122, 124, 126),
                  ),
                )
              ],
            ),
            body: SelectionArea(
              child: Column(
                children: [
                  DisplayArea(queryNotifierProvider: queryNotifierProvider),
                  TextSection(
                      queryController: queryController,
                      queryNotifierProvider: queryNotifierProvider)
                ],
              ),
            ),
          );
        });
  }
}
