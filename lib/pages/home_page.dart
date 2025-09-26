import 'package:dermuell/const/constants.dart';
import 'package:dermuell/model/event.dart';
import 'package:dermuell/provider/address_provider.dart';
import 'package:dermuell/provider/notification_provider.dart';
import 'package:dermuell/widgets/my_progress_indicator.dart';
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
  List<Event> items = [];
  late Box myBox;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  late final ValueNotifier<List<Event>> _selectedEvents;

  @override
  void initState() {
    super.initState();
    myBox = Hive.box('dataBox');
    print(myBox.get('address'));
    ref.read(notificationsEnabledProvider.notifier).state = myBox.get(
      'notificationsEnabled',
      defaultValue: false,
    );
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier([]);
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  List<Event> _getEventsForDay(DateTime day, List<Event> allEvents) {
    return allEvents
        .where(
          (item) =>
              item.date.year == day.year &&
              item.date.month == day.month &&
              item.date.day == day.day,
        )
        .toList();
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
      });

      _selectedEvents.value = _getEventsForDay(selectedDay, items);
    }
  }

  @override
  Widget build(BuildContext context) {
    AsyncValue<List<Event>> collectionDates = ref.watch(
      collectionDatesProvider(myBox.get('address')),
    );
    var notificationsEnabled = ref.watch(notificationsEnabledProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Der Müll',
          style: TextStyle(fontFamily: 'FingerPaint'),
        ),
        actions: [
          IconButton(
            onPressed: () => notificationsEnabled
                ? deactivateNotification()
                : dialogForNotificationTime(activateNotification),
            icon: notificationsEnabled
                ? Icon(Icons.notifications)
                : Icon(Icons.notifications_none),
          ),
          IconButton(onPressed: () {}, icon: const Icon(Icons.settings)),
        ],
      ),
      body: switch (collectionDates) {
        AsyncValue(hasError: true) => Text(
          'Oops, something unexpected happened',
        ),
        AsyncValue(:final value, hasValue: true) => showDatas(value ?? []),
        _ => Center(child: MyProgressIndicator()),
      },
    );
  }

  activateNotification() {
    // Benachrichtigungen mit gewählter Zeit aktivieren
    ref
        .read(notificationServiceProvider)
        .scheduleNotificationsForEvents(
          items,
          ref.read(selectedNotificationTimeProvider),
        );
    ref.read(notificationsEnabledProvider.notifier).state = true;
    myBox.put('notificationsEnabled', true);
    // Gewählte Zeit speichern
    myBox.put(
      'notificationTime',
      '${ref.read(selectedNotificationTimeProvider).hour}:${ref.read(selectedNotificationTimeProvider).minute}',
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Benachrichtigungen um ${ref.read(selectedNotificationTimeProvider).format(context)} aktiviert!',
          style: TextStyle(color: XConst.bgColor),
        ),
        backgroundColor: XConst.sixthColor,
      ),
    );
  }

  Future<void> dialogForNotificationTime(Function onConfirmed) {
    return showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Benachrichtigungen aktivieren',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Möchten Sie Benachrichtigungen für bevorstehende Ereignisse erhalten?',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                // TimePicker hinzufügen
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Benachrichtigungszeit: '),
                    TextButton(
                      onPressed: () async {
                        final TimeOfDay? picked = await showTimePicker(
                          context: context,
                          initialTime: ref.watch(
                            selectedNotificationTimeProvider,
                          ),
                        );
                        if (picked != null &&
                            picked !=
                                ref.watch(selectedNotificationTimeProvider)) {
                          ref
                                  .read(
                                    selectedNotificationTimeProvider.notifier,
                                  )
                                  .state =
                              picked;
                        }
                      },
                      child: Consumer(
                        builder: (context, ref, child) {
                          return Text(
                            ref
                                .watch(selectedNotificationTimeProvider)
                                .format(context),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      child: const Text('Abbrechen'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        onConfirmed();
                      },
                      child: const Text('Aktivieren'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  deactivateNotification() {
    ref.read(notificationServiceProvider).cancelAllNotifications();
    ref.read(notificationsEnabledProvider.notifier).state = false;
    myBox.put('notificationsEnabled', false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Benachrichtigungen deaktiviert!',
          style: TextStyle(color: XConst.bgColor),
        ),
        backgroundColor: XConst.primaryColor,
      ),
    );
  }

  Widget showDatas(List<Event> events) {
    // items listesini güncelle
    items = events;
    // Seçili günün eventlerini güncelle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _selectedEvents.value = _getEventsForDay(_selectedDay!, items);
    });

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: TableCalendar<Event>(
            locale: 'de_DE',
            firstDay: DateTime.utc(2010, 10, 16),
            lastDay: DateTime.utc(2030, 3, 14),
            focusedDay: _focusedDay,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            calendarFormat: CalendarFormat.month,
            startingDayOfWeek: StartingDayOfWeek.monday,
            headerStyle: const HeaderStyle(formatButtonVisible: false),
            onDaySelected: _onDaySelected,

            eventLoader: (day) {
              return _getEventsForDay(day, items);
            },
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) {
                if (events.isNotEmpty) {
                  return Align(
                    alignment: Alignment.bottomCenter,
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: Center(
                        child: ListView.builder(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemCount: events.length,
                          itemBuilder: (context, index) {
                            return Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 0.5,
                              ),
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: XConst.getColorFromFraktionName(
                                  events[index].title.substring(0, 3),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ),
        Expanded(
          child: ValueListenableBuilder<List<Event>>(
            valueListenable: _selectedEvents,
            builder: (context, value, _) {
              return ListView.builder(
                itemCount: value.length,
                itemBuilder: (context, index) {
                  Event event = value[index];
                  return Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 12.0,
                      vertical: 4.0,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(),
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: ListTile(
                      onTap: () => dialogForNotificationTime(
                        () => setNotificationforAnEvent(event),
                      ),
                      title: Text(event.title),
                      subtitle: Text(
                        '${event.date.day}.${event.date.month}.${event.date.year}',
                      ),
                      leading: CircleAvatar(
                        backgroundColor: XConst.getColorFromFraktionName(
                          event.title.substring(0, 3),
                        ),
                        child: XConst.getIconFromFraktionName(
                          event.title.substring(0, 3),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  setNotificationforAnEvent(Event event) {
    // Bildirim zamanını ayarla
    ref
        .read(notificationServiceProvider)
        .scheduleNotificationForAnEvents(
          event,
          ref.read(selectedNotificationTimeProvider),
        );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Benachrichtigung für ${_selectedEvents.value.first.title} um ${ref.read(selectedNotificationTimeProvider).format(context)} gesetzt!',
          style: TextStyle(color: XConst.bgColor),
        ),
        backgroundColor: XConst.sixthColor,
      ),
    );
  }
}
