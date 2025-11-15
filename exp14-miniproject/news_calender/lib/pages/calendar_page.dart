import 'package:flutter/material.dart';
import '../widgets/custom_calendar.dart';
import 'news_page.dart';

class CalendarPage extends StatefulWidget {
  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  DateTime selected = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          "${selected.year}-${selected.month}-${selected.day}",
          style: const TextStyle(fontSize: 22),
        ),
        Expanded(
          child: CustomCalendar(
            selectedDate: selected,
            onDateSelected: (d) {
              setState(() => selected = d);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => NewsPage(date: d),
                ),
              );
            },
          ),
        )
      ],
    );
  }
}
