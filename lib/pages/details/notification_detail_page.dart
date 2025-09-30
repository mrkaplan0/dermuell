import 'package:dermuell/const/constants.dart';
import 'package:dermuell/model/event.dart';
import 'package:dermuell/widgets/bin_with_eyes.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class NotificationDetailPage extends StatefulWidget {
  const NotificationDetailPage(this.payload, {super.key});

  final String? payload;

  @override
  State<StatefulWidget> createState() => NotificationDetailPageState();
}

class NotificationDetailPageState extends State<NotificationDetailPage> {
  String? _payload;
  Event? _event;

  @override
  void initState() {
    super.initState();
    _payload = widget.payload;
    _event = _payload != null ? Event.fromJson(_payload!) : null;
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text('Erinnerung'.tr()),
      automaticallyImplyLeading: false,
      centerTitle: true,
    ),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        spacing: 20,
        children: <Widget>[
          SizedBox(height: 40),
          BinWithEyes(size: 150),
          if (_event != null) ...[
            CircleAvatar(
              backgroundColor: XConst.getColorFromFraktionName(_event!.title),
              child: XConst.getIconFromFraktionName(_event!.title),
            ),
            Text(
              '${_event!.date.day}.${_event!.date.month}.${_event!.date.year}',
            ),
            Text(_event!.title),
          ],
          Spacer(),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Zurück'.tr()),
          ),
          SizedBox(height: 40),
        ],
      ),
    ),
  );
}
