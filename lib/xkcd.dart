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

    var url = '$urlRandom$randomNumber/info.0.json';
    // Use this to test panels that are too high
    // var url = urlRandom + '298/info.0.json';

    NetworkHelper networkHelper = NetworkHelper(Uri.parse(url));

    var randomData = await networkHelper.getData();
    return randomData;
  }

  Future<dynamic> getMaxNum() async {
    NetworkHelper networkHelper = NetworkHelper(Uri.parse(urlLatest));

    var xkcdData = await networkHelper.getData();
    return xkcdData['num'];
  }

  Future<dynamic> getByNum(int num) async {
    var url = '${urlRandom}$num/info.0.json';
    NetworkHelper networkHelper = NetworkHelper(Uri.parse(url));
    return await networkHelper.getData();
  }

  // Binary search by date. Returns null if no comic on that date.
  Future<dynamic> getByDate(int year, int month, int day) async {
    var maxNum = await getMaxNum();
    final targetDate = DateTime(year, month, day);

    int low = 1;
    int high = maxNum;

    while (low <= high) {
      int mid = (low + high) ~/ 2;
      if (mid == 404) mid = 405; // comic 404 doesn't exist

      var data = await getByNum(mid);
      if (data == null) {
        low = mid + 1;
        continue;
      }

      final comicDate = DateTime(
        int.parse(data['year'].toString()),
        int.parse(data['month'].toString()),
        int.parse(data['day'].toString()),
      );

      if (comicDate == targetDate) {
        return data;
      } else if (comicDate.isBefore(targetDate)) {
        low = mid + 1;
      } else {
        high = mid - 1;
      }
    }

    return null;
  }
}
