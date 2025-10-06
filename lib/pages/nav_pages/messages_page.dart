import 'package:dermuell/const/constants.dart';
import 'package:dermuell/model/message.dart';
import 'package:dermuell/widgets/custom_app_bar.dart';
import 'package:dermuell/widgets/message_card.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MessagesPage extends ConsumerStatefulWidget {
  const MessagesPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MessagesPageState();
}

class _MessagesPageState extends ConsumerState<MessagesPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Der Müll'.tr()),
      floatingActionButton: InkWell(
        onTap: () {},
        child: Stack(
          alignment: Alignment.center,
          children: [
            Image.asset("assets/images/muell.png", width: 80, height: 80),

            Icon(
              Icons.add,
              size: 40,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
            Icon(Icons.add, size: 40, color: XConst.thirdColor),
          ],
        ),
      ),

      body: ListView(
        children: [
          Text(
            " “Nur recycelbare Ideen überleben.” ",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontStyle: FontStyle.italic,
              fontFamily: 'FingerPaint',
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          MessageCard(
            message: Message(
              id: 1,
              user_id: 1,
              username: 'Max',
              title: 'Mein Auto',
              content:
                  "Es ist zu schmutzig. Putzen ist teurer als mein Auto.Es ist zu schmutzig. Putzen ist teurer als mein Auto.Es ist zu schmutzig. Putzen ist teurer als mein Auto.Es ist zu schmutzig. Putzen ist teurer als mein Auto.Es ist zu schmutzig. Putzen ist teurer als mein Auto.",
              createdAt: DateTime.now(),
              willDeleteAt: DateTime.now().add(Duration(days: 1)),
              recycleCount: 12,
              commentCount: 4,
              deleteCount: 4,
              comments: null,
            ),
          ),
          MessageCard(
            message: Message(
              id: 2,
              user_id: 2,
              username: 'Anna',
              title: 'Mein Auto',
              content: "Es ist zu schmutzig. Putzen ist teurer als mein Auto.",
              createdAt: DateTime.now(),
              willDeleteAt: DateTime.now().add(Duration(days: 1)),
              recycleCount: 12,
              commentCount: 4,
              deleteCount: 4,
              comments: null,
            ),
          ),
        ],
      ),
    );
  }
}
