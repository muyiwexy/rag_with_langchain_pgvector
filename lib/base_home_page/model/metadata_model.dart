class Metadata {
  String loc;
  String pageContent;
  String txtPath;

  Metadata({
    required this.loc,
    required this.pageContent,
    required this.txtPath,
  });

  factory Metadata.fromJson(Map<String, dynamic> json) => Metadata(
        loc: json["loc"],
        pageContent: json["pageContent"],
        txtPath: json["txtPath"],
      );

  Map<String, dynamic> toJson() => {
        "loc": loc,
        "pageContent": pageContent,
        "txtPath": txtPath,
      };
}
