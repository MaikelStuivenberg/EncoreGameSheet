import 'package:flutter/material.dart';

class ScoreBoardRow extends StatelessWidget {
  final IconData? iconPrefix;
  final String textPrefix;
  final String text;
  final int number;
  final bool darkMode;
  final bool showScore;

  const ScoreBoardRow({
    super.key,
    this.iconPrefix,
    required this.textPrefix,
    required this.text,
    required this.number,
    required this.darkMode,
    required this.showScore,
  });

  @override
  Widget build(BuildContext context) {
    final List<Widget> children = [];
    if (iconPrefix != null) {
      children.add(Container(
        margin: const EdgeInsets.fromLTRB(10, 0, 0, 0),
        child: Icon(iconPrefix,
            color:
                darkMode ? const Color.fromARGB(225, 30, 30, 30) : Colors.black,
            size: 20),
      ));
    }

    if (textPrefix != "") {
      children.add(Container(
        margin: EdgeInsets.fromLTRB(children.isEmpty ? 10 : 5, 0, 0, 0),
        child: Text(
          textPrefix,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.normal,
            fontSize: 12,
          ),
        ),
      ));
    }

    final List<Widget> optionalElements = [];
    if (children.isNotEmpty) {
      optionalElements.add(SizedBox(
        width: 70,
        height: 32,
        child: Row(
          children: children,
        ),
      ));
    }

    return Container(
      margin: const EdgeInsets.fromLTRB(1.5, 0, 1.5, 0),
      child: Column(
        children: [
          ...optionalElements,
          Container(
            width: 90,
            height: 28,
            decoration: BoxDecoration(
              border: Border.all(
                  color: darkMode ? Colors.white : Colors.black, width: 1),
              borderRadius: const BorderRadius.all(Radius.circular(5)),
              color: darkMode
                  ? const Color.fromARGB(225, 30, 30, 30)
                  : const Color.fromARGB(225, 255, 255, 255),
            ),
            child: Row(children: [
              Container(
                margin: const EdgeInsets.fromLTRB(5, 0, 0, 0),
                width: 12,
                child: Text(
                  text,
                  style: TextStyle(
                    color: darkMode ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
              SizedBox(
                width: 55,
                child: Text(
                  showScore ? number.toString() : "?",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: darkMode ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
