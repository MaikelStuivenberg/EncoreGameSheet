import 'package:flutter/material.dart';

class ChooseCardPage extends StatefulWidget {
  const ChooseCardPage({required Key key}) : super(key: key);

  @override
  _ChooseCardPageState createState() => _ChooseCardPageState();
}

class _ChooseCardPageState extends State<ChooseCardPage> {
  var _lvl = "1";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    precacheImage(const AssetImage("assets/images/lvl1.jpg"), context);
    precacheImage(const AssetImage("assets/images/lvl2.jpg"), context);
    precacheImage(const AssetImage("assets/images/lvl3.jpg"), context);
    precacheImage(const AssetImage("assets/images/lvl4.jpg"), context);
    precacheImage(const AssetImage("assets/images/lvl5.jpg"), context);
    precacheImage(const AssetImage("assets/images/lvl6.jpg"), context);
    precacheImage(const AssetImage("assets/images/lvl7.jpg"), context);

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 240, 240, 240),
      body: Container(
        margin: const EdgeInsets.all(25),
        child: Column(
          children: [
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Choose a game card",
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child: Scrollbar(
                            thumbVisibility: true,
                            child: ListView(
                              shrinkWrap: true,
                              children: [
                                levelListItem("1"),
                                levelListItem("2"),
                                levelListItem("3"),
                                levelListItem("4"),
                                levelListItem("5"),
                                levelListItem("6"),
                                levelListItem("7"),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(flex: 3, child: Image.asset("assets/images/lvl$_lvl.jpg")),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                SizedBox(
                  width: 150,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, ['Cancel']);
                    },
                    child: const Text('Back'),
                  ),
                ),
                SizedBox(
                  width: 150,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop([_lvl, 'multi']);
                    },
                    child: const Text('Start Game'),
                  ),
                ),
                SizedBox(
                  width: 150,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop([_lvl, 'single']);
                    },
                    child: const Text('Start Solo Mode'),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget levelListItem(String lvl) {
    return ListTile(
      contentPadding: const EdgeInsets.all(0),
      visualDensity: const VisualDensity(vertical: -3),
      horizontalTitleGap: 5,
      title: Text("Level $lvl"),
      leading: Radio(
        value: lvl,
        groupValue: _lvl,
        onChanged: (String? val) => {
          setState(() => {
                if (val!.isNotEmpty) {_lvl = val}
              }),
        },
      ),
      onTap: () => {
        setState(() => {
              _lvl = lvl,
            }),
      },
    );
  }
}
