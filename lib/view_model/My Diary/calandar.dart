import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class GemCalendar extends StatefulWidget {
  final Function(DateTime) onDateSelected;
  final List<dynamic> entries;

  const GemCalendar({
    super.key,
    required this.onDateSelected,
    required this.entries,
  });

  @override
  State<GemCalendar> createState() => _GemCalendarState();
}

class _GemCalendarState extends State<GemCalendar> {
  DateTime selectedDate = DateTime.now();
  DateTime currentMonth = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final days = DateUtils.getDaysInMonth(
        currentMonth.year, currentMonth.month);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          /// 🔹 MONTH HEADER (tap → picker)
          GestureDetector(
            onTap: () async {
              final picked = await _pickMonth();

              if (picked != null) {
                setState(() {
                  final maxDays = DateUtils.getDaysInMonth(
                      picked.year, picked.month);

                  final newDay = selectedDate.day > maxDays
                      ? maxDays
                      : selectedDate.day;

                  currentMonth = picked;
                  selectedDate = DateTime(
                      picked.year, picked.month, newDay);
                });

                widget.onDateSelected(selectedDate);
              }
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  DateFormat('MMMM yyyy').format(currentMonth),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.keyboard_arrow_down, size: 18),
              ],
            ),
          ),

          const SizedBox(height: 10),

          /// 🔹 DATE STRIP
          SizedBox(
            height: 60,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: days,
              itemBuilder: (_, i) {
                final date = DateTime(
                    currentMonth.year, currentMonth.month, i + 1);

                final isSelected =
                DateUtils.isSameDay(date, selectedDate);

                return GestureDetector(
                  onTap: () {
                    setState(() => selectedDate = date);
                    widget.onDateSelected(date);
                  },
                  child: Container(
                    width: 45,
                    margin:
                    const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.blue
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text(
                        "${date.day}",
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : Colors.black,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 10),

          /// 🔹 TAGS (UI only)

        ],
      ),
    );
  }

  /// 🔹 MONTH PICKER (returns selected month)
  Future<DateTime?> _pickMonth() async {
    int tempYear = currentMonth.year;

    return await showModalBottomSheet<DateTime>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius:
        BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: const EdgeInsets.all(16),
              height: 300,
              child: Column(
                children: [

                  /// 🔹 YEAR SELECTOR
                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () {
                          setModalState(() => tempYear--);
                        },
                      ),
                      Text(
                        "$tempYear",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          setModalState(() => tempYear++);
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  /// 🔹 MONTH GRID
                  Expanded(
                    child: GridView.builder(
                      itemCount: 12,
                      gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        childAspectRatio: 2.2,
                      ),
                      itemBuilder: (_, index) {
                        final monthName = DateFormat('MMM')
                            .format(DateTime(0, index + 1));

                        return GestureDetector(
                          onTap: () {
                            final pickedMonth =
                            DateTime(tempYear, index + 1);

                            Navigator.pop(
                                context, pickedMonth);
                          },
                          child: Container(
                            margin: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius:
                              BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                monthName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  /// 🔹 TAG UI
  Widget _buildTag(String text, Color color) {
    return Container(
      padding:
      const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12,
        ),
      ),
    );
  }
}
