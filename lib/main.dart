import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  bool isSearching = false;
  int xkMaxNum = 0;

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
      xkMaxNum = xkcdData['num'];
      xkMonth = xkcdData['month'];
      xkDay = xkcdData['day'];
      xkYear = xkcdData['year'];
      xkAlt = xkcdData['alt'];
    });
  }

  void getPrevious() async {
    int prevNum = xkNumber - 1;
    if (prevNum == 404) prevNum = 403;
    if (prevNum < 1) return;

    imageLoading = false;
    final data = await xkcd.getByNum(prevNum);
    if (data == null) return;

    setState(() {
      imageLoading = true;
      xkcdImage = data['img'].toString();
      xkNumber = data['num'];
      xkMonth = data['month'];
      xkDay = data['day'];
      xkYear = data['year'];
      xkAlt = data['alt'];
    });
  }

  void getNext() async {
    int nextNum = xkNumber + 1;
    if (nextNum == 404) nextNum = 405;
    if (nextNum > xkMaxNum) return;

    imageLoading = false;
    final data = await xkcd.getByNum(nextNum);
    if (data == null) return;

    setState(() {
      imageLoading = true;
      xkcdImage = data['img'].toString();
      xkNumber = data['num'];
      xkMonth = data['month'];
      xkDay = data['day'];
      xkYear = data['year'];
      xkAlt = data['alt'];
    });
  }

  void searchByDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2006, 1, 1), // XKCD #1 was Jan 1, 2006
      lastDate: DateTime.now(),
    );
    if (picked == null) return;

    setState(() => isSearching = true);

    final data = await xkcd.getByDate(picked.year, picked.month, picked.day);

    setState(() => isSearching = false);

    if (data == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'No comic found for ${picked.month}/${picked.day}/${picked.year}'),
          ),
        );
      }
      return;
    }

    setState(() {
      imageLoading = true;
      xkcdImage = data['img'].toString();
      xkNumber = data['num'];
      xkMonth = data['month'];
      xkDay = data['day'];
      xkYear = data['year'];
      xkAlt = data['alt'];
    });
  }

  void copyLink() {
    final url = 'https://xkcd.com/$xkNumber/';
    Clipboard.setData(ClipboardData(text: url));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Copied: $url')),
    );
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
          actions: [
            if (isSearching)
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: Center(
                  child: SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              )
            else
              IconButton(
                icon: const Icon(Icons.calendar_month),
                tooltip: 'Search by date',
                onPressed: searchByDate,
              ),
            if (imageLoading)
              IconButton(
                icon: const Icon(Icons.link),
                tooltip: 'Copy link',
                onPressed: copyLink,
              ),
          ],
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
                      ElevatedButton.icon(
                        onPressed: (imageLoading && xkNumber > 1)
                            ? getPrevious
                            : null,
                        icon: const Icon(Icons.arrow_back),
                        label: const Text(
                          'Prev',
                          style: TextStyle(
                            fontSize: 20.0,
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
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
                      const SizedBox(width: 12),
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
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        onPressed: (imageLoading && xkNumber < xkMaxNum)
                            ? getNext
                            : null,
                        icon: const Icon(Icons.arrow_forward),
                        iconAlignment: IconAlignment.end,
                        label: const Text(
                          'Next',
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
