import 'package:dermuell/const/constants.dart';
import 'package:dermuell/provider/address_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:table_calendar/table_calendar.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  List<Map<String, dynamic>> items = [];
  late Box myBox;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    try {
      myBox = Hive.box('dataBox');
      final selectedAddress = myBox.get(
        'address',
        defaultValue: <Map<String, dynamic>>[],
      );
      await ref
          .read(collectionDatesProvider(selectedAddress).future)
          .then(
            (value) => setState(() {
              items = value;
            }),
          );
      print(selectedAddress);
      print(items);
    } catch (e) {
      print('Error loading data: $e');
      setState(() {
        items = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Der Müll'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.notifications)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.settings)),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TableCalendar<String>(
              firstDay: DateTime.utc(2010, 10, 16),
              lastDay: DateTime.utc(2030, 3, 14),
              focusedDay: DateTime.now(),
              calendarFormat: CalendarFormat.month,
              startingDayOfWeek: StartingDayOfWeek.monday,
              headerStyle: const HeaderStyle(formatButtonVisible: false),
            ),
          ),
          Expanded(
            child: items.isEmpty
                ? const Center(child: Text('No collection dates found'))
                : ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      if (index >= items.length) return const SizedBox.shrink();

                      final item = items[index];
                      return ListTile(
                        leading: const Icon(Icons.delete),
                        title: Text(
                          XConst.setCollTypeName(item['bezirk']['fraktionId']),
                        ),
                        subtitle: Text('${item['datum'] ?? 'No Date'}'),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
