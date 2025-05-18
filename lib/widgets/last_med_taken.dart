import 'package:flutter/material.dart';

import 'package:easy_localization/easy_localization.dart';
import 'package:take_your_meds/common/database.dart';

class LastMedTaken extends StatefulWidget {
  const LastMedTaken({super.key});

  @override
  State<StatefulWidget> createState() => LastMedTakenState();
}

class LastMedTakenState extends State<LastMedTaken> {
  Widget lastTaken = const SizedBox();
  Widget lastFavoriteTaken = const SizedBox();

  @override
  void initState() {
    super.initState();
    initValues();
  }

  void initValues() async {
    Widget lastTakenWidget = await getLastTaken() ?? const SizedBox();
    Widget lastFavoriteWidget =
        await getLastTaken(isFavorite: true) ?? const SizedBox();
    setState(() {
      lastTaken = lastTakenWidget;
      lastFavoriteTaken = lastFavoriteWidget;
    });
  }

  Future<Widget?> getLastTaken({bool isFavorite = false}) async {
    if (!DatabaseHandler.isDBAvailable) {
      return null;
    }

    String query = "SELECT * FROM events INNER JOIN meds on uid = med_uid ";
    if (isFavorite) {
      query += "WHERE favorite = 1 ";
    }
    query += "ORDER BY date desc LIMIT 1";

    List result = await DatabaseHandler().rawQuery(query);

    if (mounted && result.isNotEmpty) {
      Map<String, dynamic> jsonTaken = result[0];
      String type = isFavorite ? "last_favorite_taken" : "last_taken";
      String quantity = jsonTaken["quantity"].toString();
      DateTime date = DateTime.parse(jsonTaken["date"]);

      return SizedBox(
        width: MediaQuery.of(context).size.width * .8,
        child: Text(
          type,
          style: const TextStyle(fontSize: 18),
        ).tr(args: [
          "$quantity x ${tr(jsonTaken["unit"])} ${jsonTaken["name"]}",
          DateFormat.Hm().add_EEEE().format(date)
        ]),
      );
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: lastTaken,
      ),
      const SizedBox(height: 20),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: lastFavoriteTaken,
      ),
    ]);
  }
}
