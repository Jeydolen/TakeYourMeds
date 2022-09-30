import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:take_your_meds/common/file_handler.dart';
import 'package:take_your_meds/widgets/meds_list.dart';

class TookMedPage extends StatefulWidget {
  const TookMedPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => TookMedPageState();
}

class TookMedPageState extends State<TookMedPage> {
  late Future<List<dynamic>> futureMeds;

  @override
  void initState() {
    super.initState();
    futureMeds = fetchMeds();
  }

  Future<List<dynamic>> fetchMeds() async {
    String? jsonString = await FileHandler.readContent("meds");

    if (jsonString != null) {
      return jsonDecode(jsonString);
    }

    return [];
  }

  @override
  Widget build(BuildContext context) {
    // Get json saved data for meds and create list
    // Make it reorganizable
    // On click new page with med presentation, current date and quantity
    return FutureBuilder<List<dynamic>>(
      future: futureMeds,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return MedsList(json: snapshot.data ?? []);
        } else if (snapshot.hasError) {
          return Text('${snapshot.error}');
        }

        // By default, show a loading spinner.
        return const CircularProgressIndicator();
      },
    );
  }
}
