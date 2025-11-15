import 'package:flutter/material.dart';

class CustomCalendar extends StatefulWidget {
  final DateTime initialSelected;
  final void Function(DateTime) onDayTap;

  const CustomCalendar(
      {super.key, required this.initialSelected, required this.onDayTap});

  @override
  State<CustomCalendar> createState() => _CustomCalendarState();
}

class _CustomCalendarState extends State<CustomCalendar> {
  late DateTime month;
  late DateTime selected;

  @override
  void initState() {
    super.initState();
    selected = widget.initialSelected;
    month = DateTime(selected.year, selected.month);
  }

  void _prevMonth() =>
      setState(() => month = DateTime(month.year, month.month - 1));
  void _nextMonth() =>
      setState(() => month = DateTime(month.year, month.month + 1));

  List<DateTime> daysForMonth(DateTime m) {
    final first = DateTime(m.year, m.month, 1);
    final last = DateTime(m.year, m.month + 1, 0);
    final List<DateTime> list = [];
    int prefix = (first.weekday % 7);
    for (int i = 0; i < prefix; i++) {
      list.add(first.subtract(Duration(days: prefix - i)));
    }
    for (int i = 0; i < last.day; i++) {
      list.add(DateTime(m.year, m.month, i + 1));
    }
    while (list.length % 7 != 0) {
      list.add(list.last.add(const Duration(days: 1)));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final days = daysForMonth(month);
    final labels = ['S', 'M', 'T', 'W', 'T', 'F', 'S'];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                  onPressed: _prevMonth, icon: const Icon(Icons.chevron_left)),
              Text("${month.year} • ${_monthName(month.month)}",
                  style: const TextStyle(fontSize: 18)),
              IconButton(
                  onPressed: _nextMonth, icon: const Icon(Icons.chevron_right)),
            ],
          ),
        ),
        Row(
          children: labels
              .map((l) => Expanded(
                  child: Center(
                      child: Text(l,
                          style:
                              const TextStyle(fontWeight: FontWeight.bold)))))
              .toList(),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: days.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7),
            itemBuilder: (c, i) {
              final d = days[i];
              final inMonth = d.month == month.month;
              final isSelected = d.year == selected.year &&
                  d.month == selected.month &&
                  d.day == selected.day;
              return GestureDetector(
                onTap: inMonth
                    ? () {
                        setState(() => selected = d);
                        widget.onDayTap(d);
                      }
                    : null,
                child: Container(
                  margin: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blueAccent : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text("${d.day}",
                        style: TextStyle(
                            color: inMonth ? Colors.white : Colors.grey)),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  String _monthName(int m) {
    const names = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return names[m - 1];
  }
}
