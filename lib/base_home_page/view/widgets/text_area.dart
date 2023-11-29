part of '../homepage.dart';

class TextSection extends StatelessWidget {
  const TextSection({
    super.key,
    required this.queryController,
    required this.queryNotifierProvider,
  });

  final TextEditingController queryController;
  final QueryNotifier queryNotifierProvider;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<QueryState>(
        valueListenable: queryNotifierProvider.queryState,
        builder: (context, query, __) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            height: MediaQuery.of(context).size.height * 0.2,
            width: MediaQuery.of(context).size.width,
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(blurRadius: 6),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextField(
                  controller: queryController,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                  decoration: InputDecoration(
                    hintText: "Enter query",
                    suffixIcon: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8.0,
                        vertical: 5.0,
                      ),
                      child: InkWell(
                          onTap: () {
                            queryNotifierProvider.userqueryResponse(
                                "essence", queryController.text);
                            queryController.clear();
                          },
                          child: Container(
                            height: 50,
                            width: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.black,
                            ),
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                query == QueryState.loading
                                    ? SvgPicture.asset(
                                        "assets/send_icon.svg",
                                        height: 35,
                                        colorFilter: const ColorFilter.mode(
                                          Colors.white,
                                          BlendMode.srcIn,
                                        ),
                                      )
                                    : query == QueryState.error
                                        ? SvgPicture.asset(
                                            "assets/send_icon.svg",
                                            height: 35,
                                            colorFilter: const ColorFilter.mode(
                                              Colors.red,
                                              BlendMode.srcIn,
                                            ),
                                          )
                                        : const AnimatedArrow()
                              ],
                            ),
                          )),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 2.0),
                    ),
                    border: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 2.0),
                    ),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.black, width: 2.0),
                    ),
                    errorBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red, width: 2.0),
                    ),
                  ),
                )
              ],
            ),
          );
        });
  }
}
