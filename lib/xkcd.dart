import 'package:xkcd/networking.dart';
import 'dart:math';

const urlLatest = 'https://xkcd.com/info.0.json';
const urlRandom = 'https://xkcd.com/';

class Xkcd {
  Future<dynamic> getLatest() async {
    NetworkHelper networkHelper = NetworkHelper(Uri.parse(urlLatest));

    var xkcdData = await networkHelper.getData();
    return xkcdData;
  }

  Future<dynamic> getRandom() async {
    var maxNum = await getMaxNum();

    Random random = Random();

    int randomNumber = random.nextInt(maxNum);

    // ToDo: Use index parameter in URL
    var url = urlRandom + randomNumber.toString() + '/info.0.json';

    NetworkHelper networkHelper = NetworkHelper(Uri.parse(url));

    var randomData = await networkHelper.getData();
    return randomData;
  }

  Future<dynamic> getMaxNum() async {
    NetworkHelper networkHelper = NetworkHelper(Uri.parse(urlLatest));

    var xkcdData = await networkHelper.getData();
    return xkcdData['num'];
  }
}
