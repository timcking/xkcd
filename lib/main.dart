import 'package:flutter/material.dart';
import 'package:xkcd/xkcd.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
          scaffoldBackgroundColor: const Color.fromARGB(255, 236, 214, 194)),
      home: const MyHomePage(title: 'XKCD'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var xkcdData;
  var xkcdImage;
  var xkNumber;
  var xkMonth;
  var xkDay;
  var xkYear;
  var xkAlt;
  bool imageLoading = false;

  Xkcd xkcd = Xkcd();

  @override
  void initState() {
    super.initState();
    getLatest();
  }

  void getLatest() async {
    imageLoading = false;
    xkcdData = await xkcd.getLatest();
    imageLoading = true;

    setState(() {
      xkcdImage = xkcdData['img'].toString();
      xkNumber = xkcdData['num'];
      xkMonth = xkcdData['month'];
      xkDay = xkcdData['day'];
      xkYear = xkcdData['year'];
      xkAlt = xkcdData['alt'];
    });
  }

  void getRandom() async {
    imageLoading = false;
    xkcdData = await xkcd.getRandom();
    imageLoading = true;

    setState(() {
      xkcdImage = xkcdData['img'];
      xkNumber = xkcdData['num'];
      xkMonth = xkcdData['month'];
      xkDay = xkcdData['day'];
      xkYear = xkcdData['year'];
      xkAlt = xkcdData['alt'];
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            xkAlt.toString(),
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            softWrap: true,
            overflow: TextOverflow.visible,
            maxLines: 2, // You can adjust maxLines as needed
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  imageLoading
                      ? Text('#$xkNumber $xkMonth/$xkDay/$xkYear',
                          style: const TextStyle(
                              fontSize: 14.0,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.bold))
                      : Container(),
                  const SizedBox(height: 20),
                  imageLoading
                      ? Image.network(
                          xkcdImage,
                          fit: BoxFit.fill,
                        )
                      : Container(),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          getLatest();
                        },
                        child: const Text(
                          'Latest',
                          style: TextStyle(
                            fontSize: 20.0,
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      ElevatedButton(
                        onPressed: () {
                          getRandom();
                        },
                        child: const Text(
                          'Random',
                          style: TextStyle(
                            fontSize: 20.0,
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
