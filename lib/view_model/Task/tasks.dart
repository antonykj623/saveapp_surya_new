import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:new_project_2025/view/home/widget/save_DB/Budegt_database_helper/Save_DB.dart';

import 'addtask.dart';
import 'edittask.dart';

class TaskModel {
  final String task;
  final String startDate;
  final String endDate;
  final String time;
  final String remindUpto;
  final String selectedItem;
  final int keyid; // Add this
  final String status;

  TaskModel({
    required this.status,
    required this.task,
    required this.startDate,
    required this.endDate,
    required this.time,
    required this.remindUpto,
    required this.selectedItem,
    required this.keyid, // Add this
  });

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      task: map['task'] ?? '',
      startDate: map['statrdatectrl'] ?? '',
      endDate: map['enddatectrl'] ?? '',
      time: map['timectrl'] ?? '',
      remindUpto: map['reminddateupto'] ?? '',
      selectedItem: map['selectedItem'] ?? '',
      status: map['status'] ?? '',
      keyid: map['keyid'] ?? 0, // Add this
    );
  }
}
class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  DateTime? selectedStartDate;
  DateTime? selectedEndDate;
  List<TaskModel> taskList = [];
  List<TaskModel> taskLinks = [];
  @override
  void initState() {
    super.initState();
    _loadData();
 //   print(taskLinks);
  }
  void _loadData() async {
    final rawData = await DatabaseHelper().fetchAllTaskData();

  print("RawDatas are $rawData");
    List<TaskModel> loadedLinks = [];
    for (var entry in rawData) {
      final keyId = entry['keyid'];
      final jsonString = entry['data'];

      try {
        final decodedMap = jsonDecode(jsonString) as Map<String, dynamic>;
        decodedMap['keyid'] = keyId; // Add keyId
        loadedLinks.add(TaskModel.fromMap(decodedMap));
      } catch (e) {
        print("Error decoding JSON: $e");
      }
    }

    setState(() {
      taskLinks = loadedLinks;
   //   print("Datas from jsondecod is  $loadedLinks");
    });
  }
  ///  Fetch all tasks from DB
  Future<List<TaskModel>> _fetchAllTasks() async {
    final rawData = await DatabaseHelper().fetchAllTaskData();
    List<TaskModel> tasks = [];

    for (var entry in rawData) {
      final keyId = entry['keyid'];
      final jsonString = entry['data'];

      try {
        final decodedMap = jsonDecode(jsonString) as Map<String, dynamic>;
        decodedMap['keyid'] = keyId;
        tasks.add(TaskModel.fromMap(decodedMap));
      } catch (e) {
        print("Error decoding JSON: $e");
      }
    }
    return tasks;
  }

  ///  Filter tasks by selected dates
  Future<void> _searchTasks() async {
    if (selectedStartDate == null || selectedEndDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select both start and end dates")),
      );
      return;
    }

    if (selectedEndDate!.isBefore(selectedStartDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("End date cannot be before start date")),
      );
      return;
    }

    final allTasks = await _fetchAllTasks();
    final filtered = allTasks.where((task) {
      try {
        final taskDate = DateFormat('dd/MM/yyyy').parse(task.startDate);
        return taskDate.isAtSameMomentAs(selectedStartDate!) ||
            taskDate.isAtSameMomentAs(selectedEndDate!) ||
            (taskDate.isAfter(selectedStartDate!) &&
                taskDate.isBefore(selectedEndDate!));
      } catch (e) {
        return false;
      }
    }).toList();

    setState(() {
      taskList = filtered;
    });
  }

  ///  Pick date helper
  Future<void> _pickDate(bool isStart) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        if (isStart) {
          selectedStartDate = picked;
        } else {
          selectedEndDate = picked;
        }
      });
    }
  }
    Widget _buildResultCard(TaskModel task) {
    return GestureDetector(
      onTap: () {
        // Pass data to another screen
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditTasks( // Replace with your target screen
              task1: task,  // send full object
            ),
          ),
        );
      },
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.symmetric(vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InfoRow(label: "Task", value: task.task),
              InfoRow(label: "Date", value: task.startDate),
              InfoRow(label: "Time", value: task.time),
              InfoRow(label: "Remind Date", value: task.endDate),
              InfoRow(label: "Status", value: task.status),
            ],
          ),
        ),
      ),
    );
  }


  ///  Build Card widget
  // Widget _buildTaskCard(TaskModel task) {
  //   return Card(
  //     elevation: 4,
  //     margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
  //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
  //     child: Padding(
  //       padding: const EdgeInsets.all(16),
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           InfoRow(label: "Task", value: task.task),
  //           InfoRow(label: "Date", value: task.startDate),
  //           InfoRow(label: "Time", value: task.time),
  //           InfoRow(label: "Remind Date", value: task.remindUpto),
  //           InfoRow(label: "Status", value: task.status),
  //         ],
  //       ),
  //     ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Search Tasks")),
      body: Column(
        children: [
          //  Date pickers
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.spaceAround,
          //   children: [
          //     TextButton(
          //       onPressed: () => _pickDate(true),
          //       child: Text(
          //         selectedStartDate == null
          //             ? "Select Start Date"
          //             : DateFormat('dd/MM/yyyy').format(selectedStartDate!),
          //       ),
          //     ),
          //     TextButton(
          //       onPressed: () => _pickDate(false),
          //       child: Text(
          //         selectedEndDate == null
          //             ? "Select End Date"
          //             : DateFormat('dd/MM/yyyy').format(selectedEndDate!),
          //       ),
          //     ),
          //     ElevatedButton(
          //       onPressed: _searchTasks,
          //       child: const Text("Search"),
          //     ),
          //   ],
          // ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Start Date field
                GestureDetector(
                  onTap: () => _pickDate(true),
                  child: AbsorbPointer(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Start Date",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      controller: TextEditingController(
                        text: selectedStartDate == null
                            ? ""
                            : DateFormat('dd/MM/yyyy').format(selectedStartDate!),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // End Date field
                GestureDetector(
                  onTap: () => _pickDate(false),
                  child: AbsorbPointer(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "End Date",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      controller: TextEditingController(
                        text: selectedEndDate == null
                            ? ""
                            : DateFormat('dd/MM/yyyy').format(selectedEndDate!),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Search button (rounded style like in screenshot)
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                    elevation: 6,
                  ),
                  onPressed: _searchTasks,
                  child: const Text(
                    "Search",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          //  Results


          Padding(
            padding: const EdgeInsets.only(  ),
            child: Container(

                  width: double.infinity,
                height: 500,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue,           // Start with white
                      Color(0xFFCFD1EE),      // Light BlueGrey (BlueGrey[100])
                    ], // white to BlueGrey[100] // BlueGrey[700] to BlueGrey[100]
                    //   colors: [Color(0xFF001010), Color(0xFF70e2f5)],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Center(
                  child: Expanded(
                    child: taskList.isEmpty
                        ? const Text("No tasks found.")
                        : ListView.builder(
                      itemCount: taskList.length,
                      itemBuilder: (context, index) {
                        final task = taskList[index];
                        return _buildResultCard(taskList[index]);
                      },
                    ),
                  ),
                )

            ),
          ),
          // Expanded(
          //   child: taskList.isEmpty
          //       ? const Center(child: Text("No tasks found"))
          //       : ListView.builder(
          //     itemCount: taskList.length,
          //     itemBuilder: (context, index) {
          //       // return _buildTaskCard(taskList[index]);
          //       return _buildResultCard(taskList[index]);
          //     },
          //   ),
          // ),
    // Floating Button
      Padding(
        padding: const EdgeInsets.only(left: 250.0),
        child: FloatingActionButton(
            backgroundColor: Colors.pink,
            onPressed: () {
        Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => Tasks())


            );
            ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Floating button pressed")),
            );
            },
            child: const Icon(Icons.add, size: 28, color: Colors.white),
            ),
      ),


        ],
      ),
    );
  }
}

///  Reusable InfoRow widget
class InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const InfoRow({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
}
//
//
// import 'dart:convert';
//
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:new_project_2025/view_model/Task/addtask.dart';
// import 'package:new_project_2025/view_model/VisitingCard/test.dart';
// import '../../view/home/widget/save_DB/Budegt_database_helper/Save_DB.dart';
// import 'package:new_project_2025/view/home/widget/payment_page/payment_class/payment_class.dart';
// import 'package:new_project_2025/view_model/AccountSet_up/Add_Acount.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import 'edittask.dart';
// class TaskModel {
//   final String task;
//   final String startDate;
//   final String endDate;
//   final String time;
//   final String remindUpto;
//   final String selectedItem;
//   final int keyid; // Add this
//  final String status;
//   TaskModel( {
//     required this.status,
//     required this.task,
//     required this.startDate,
//     required this.endDate,
//     required this.time,
//     required this.remindUpto,
//     required this.selectedItem,
//     required this.keyid, // Add this
//   });
//
//   factory TaskModel.fromMap(Map<String, dynamic> map) {
//     return TaskModel(
//       task: map['task'] ?? '',
//       startDate: map['statrdatectrl'] ?? '',
//       endDate: map['enddatectrl'] ?? '',
//       time: map['timectrl'] ?? '',
//       remindUpto: map['reminddateupto'] ?? '',
//       selectedItem: map['selectedItem'] ?? '',
//       status: map['status'] ?? '',
//       keyid: map['keyid'] ?? 0, // Add this
//     );
//   }
//
//   @override
//   String toString() {
//     return 'TaskModel(task: $task, startDate: $startDate, endDate: $endDate, time: $time, remindUpto: $remindUpto, repeat: $selectedItem, keyid: $keyid, status:$status)';
//   }
// }
// class TaskScreen extends StatefulWidget {
//   @override
//   _TaskScreenState createState() => _TaskScreenState();
// }
//
// class _TaskScreenState extends State<TaskScreen> {
//   List<TaskModel> taskLinks = [];
//   DateTime selectedFromDate = DateTime.now();
//   DateTime selectedToDate = DateTime.now();
//   final _formKey = GlobalKey<FormState>();
//   List<TaskModel> taskList = [];
//
//   Future<void> _selectDate(BuildContext context, bool isFromDate) async {
//
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: isFromDate ? selectedFromDate : selectedToDate,
//       firstDate: DateTime(2000),
//       lastDate: DateTime(2101),
//     );
//     if (picked != null) {
//       setState(() {
//         if (isFromDate) {
//           selectedFromDate = picked;
//         } else {
//           selectedToDate = picked;
//         }
//       });
//     }
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     _loadData();
//     print(taskLinks);
//   }
//   void _loadData() async {
//     final rawData = await DatabaseHelper().fetchAllTaskData();
//     List<TaskModel> loadedLinks = [];
//     for (var entry in rawData) {
//       final keyId = entry['keyid'];
//       final jsonString = entry['data'];
//
//       try {
//         final decodedMap = jsonDecode(jsonString) as Map<String, dynamic>;
//         decodedMap['keyid'] = keyId; // Add keyId
//         loadedLinks.add(TaskModel.fromMap(decodedMap));
//       } catch (e) {
//         print("Error decoding JSON: $e");
//       }
//     }
//
//     setState(() {
//       taskLinks = loadedLinks;
//    //   print("Datas from jsondecod is  $loadedLinks");
//     });
//   }
//   Future<void> _searchTasks() async {
//     final rawData = await DatabaseHelper().fetchAllTaskData();
//     List<TaskModel> filteredTasks = [];
//
//     for (var entry in rawData) {
//       final keyId = entry['keyid'];
//       final jsonString = entry['data'];
//
//       try {
//         final decodedMap = jsonDecode(jsonString) as Map<String, dynamic>;
//         decodedMap['keyid'] = keyId;
//
//         final task = TaskModel.fromMap(decodedMap);
//
//         // Convert task.startDate ("dd/MM/yyyy") -> DateTime
//         final taskDate = DateFormat('dd/MM/yyyy').parse(task.startDate);
//
//         // Compare with selectedFromDate & selectedToDate
//         if (taskDate.isAfter(selectedFromDate.subtract(const Duration(days: 1))) &&
//             taskDate.isBefore(selectedToDate.add(const Duration(days: 1)))) {
//           filteredTasks.add(task);
//         }
//       } catch (e) {
//         print("Error decoding JSON: $e");
//       }
//     }
//
//     setState(() {
//       taskLinks = filteredTasks;
//     });
//   }
//   Future<void> _searchTasks1() async {
//     final from = DateFormat('yyyy-MM-dd').format(selectedFromDate);
//     final to = DateFormat('yyyy-MM-dd').format(selectedToDate);
//
//     final db = await DatabaseHelper().database;
//     final result = await db.query(
//       'tasks',
//       where: "date BETWEEN ? AND ?",
//       whereArgs: [from, to],
//     );
//
//     setState(() {
//       taskList = result.map((map) => TaskModel.fromMap(map)).toList();
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     void selectDate(bool isStart) {
//       showDatePicker(
//         context: context,
//         firstDate: DateTime(2000),
//         lastDate: DateTime(2100),
//       ).then((pickedDate) {
//         if (pickedDate != null) {
//           setState(() {
//             if (isStart) {
//               selected_startDate = pickedDate;
//             } else {
//               selected_endDate = pickedDate;
//             }
//           });
//         }
//       });
//     }
//     return Scaffold(
//   backgroundColor: Colors.blueGrey[25],
//       body:
//       Padding(
//         padding: const EdgeInsets.all(0.0),
//         child: Column(
//           children: [
//             Container(
//
//               width: double.infinity,
//               padding:  EdgeInsets.symmetric(
//                 horizontal: 16,
//                 vertical: 12,),
//               decoration: const BoxDecoration(
//                 gradient: LinearGradient(
//                   begin: Alignment.topLeft,
//                   end: Alignment.bottomRight,
//                   colors: [Color(0xFF667eea), Color(0xFF764ba2), Color(0xFFF093fb)],
//                 ),
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   GestureDetector(
//                     onTap: () => Navigator.pop(context),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         Container(
//                           padding: EdgeInsets.all(10),
//                           decoration: BoxDecoration(
//                             color: Colors.white.withOpacity(0.15),
//                             shape: BoxShape.circle,
//                           ),
//                           child: Icon(Icons.arrow_back, color: Colors.white),
//                         ),
//                         SizedBox(width: 8),
//                         Text(
//                           ' Task',
//                           style: TextStyle(
//                             color: Colors.white,
//                             fontSize: 16,
//                             fontWeight: FontWeight.w500,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//
//                // child:
//                 // Padding(
//                 //   padding: const EdgeInsets.all(15),
//          Container(
//                     height: 250,
//                     padding: const EdgeInsets.all(16),
//                     // decoration: BoxDecoration(
//                     //   gradient: LinearGradient(
//                     //     colors: [
//                     //       Colors.blue,           // Start with white
//                     //       Color(0xFFCFD1EE),      // Light BlueGrey (BlueGrey[100])
//                     //     ], // white to BlueGrey[100] // BlueGrey[700] to BlueGrey[100]
//                     //  //   colors: [Color(0xFF001010), Color(0xFF70e2f5)],
//                     //     begin: Alignment.topCenter,
//                     //     end: Alignment.bottomCenter,
//                     //   ),
//                     //   borderRadius: BorderRadius.circular(20),
//                     // ),
//                     child: Form(
//                       key: _formKey,
//
//                       child: Column(
//                         children: [
//
//                           GestureDetector(
//                             onTap: () => selectDate(true),
//                             child: InputDecorator(
//                               decoration: InputDecoration(
//                                 //  labelText: 'Start Date',
//                                 filled: true,
//                                 fillColor: Colors.white,
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(12),
//                                   borderSide: BorderSide.none,
//                                 ),
//                               ),
//                               child: Text(
//                                 _getDisplayStartDate(),
//                                 style: TextStyle(fontSize: 16),
//                               ),
//                             ),
//                           ),
//                           //  _buildDateField(context, "From Date", selectedFromDate, true),
//                           const SizedBox(height: 10),
//                           GestureDetector(
//                             onTap: () => selectDate(false),
//                             child: InputDecorator(
//                               decoration: InputDecoration(
//                                 //   labelText: 'End Date',
//                                 filled: true,
//                                 fillColor: Colors.white,
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(12),
//                                   borderSide: BorderSide.none,
//                                 ),
//                               ),
//                               child: Text(
//                                 _getDisplayEndDate(),
//                                 style: TextStyle(fontSize: 16),
//                               ),
//                             ),
//                           ),
//                           //   _buildDateField(context, "To Date", selectedToDate, false),
//                           const SizedBox(height: 40),
//                           // SizedBox(height: 40, width: 100,
//                           //   child:  ElevatedButton(
//                           //     onPressed: _searchTasks,
//                           //     style: ElevatedButton.styleFrom(
//                           //       backgroundColor: Colors.white,
//                           //       foregroundColor: Colors.white,
//                           //       padding: EdgeInsets.symmetric(vertical:6),
//                           //       shape: RoundedRectangleBorder(
//                           //         borderRadius: BorderRadius.circular(10),
//                           //       ),
//                           //     ),
//                           //     child: const Text("Search", style: TextStyle(fontSize: 18,color: Colors.black,)),
//                           //   ),
//                           // ),
//                           Container(
//
//                             child:
//                             ElevatedButton(
//                               onPressed:  (){
//
//
//
//
//
//                               },
//                               style: ElevatedButton.styleFrom(
//                                 elevation: 0,
//                                 padding: EdgeInsets.zero,
//                                 shape: RoundedRectangleBorder(
//                                   borderRadius: BorderRadius.circular(25),
//                                 ),
//                                 backgroundColor: Colors.transparent,
//                                 shadowColor: Colors.transparent,
//                               ),
//                               child: Ink(
//                                 decoration: BoxDecoration(
//                                   gradient: const LinearGradient(
//                                     colors: [Color(0xFF667eea), Color(0xFF764ba2)],
//                                     begin: Alignment.topLeft,
//                                     end: Alignment.bottomRight,
//                                   ),
//                                   borderRadius: BorderRadius.circular(25),
//                                   boxShadow: [
//                                     BoxShadow(
//                                       color: const Color(0xFF667eea).withOpacity(0.4),
//                                       blurRadius: 15,
//                                       offset: const Offset(0, 8),
//                                     ),
//                                   ],
//                                 ),
//                                 child: Container(
//                                   width:135,
//
//                                   alignment: Alignment.center,
//                                   padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
//                                   child: Text(
//                                     'Search',
//                                     style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//
//
//                         ],
//
//                       ),
//
//
//                     ),
//
//                   ),
//
//
//
//
//
//
// Padding(
//    padding: const EdgeInsets.only(  ),
//   child: Container(
//
//     width: double.infinity,
//   height: 600,
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             Colors.blue,           // Start with white
//             Color(0xFFCFD1EE),      // Light BlueGrey (BlueGrey[100])
//           ], // white to BlueGrey[100] // BlueGrey[700] to BlueGrey[100]
//           //   colors: [Color(0xFF001010), Color(0xFF70e2f5)],
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//         ),
//         borderRadius: BorderRadius.circular(20),
//       ),
//   child:  Expanded(
//       child: taskLinks.isEmpty
//           ? const Text("No tasks found.")
//           : ListView.builder(
//         itemCount: taskLinks.length,
//         itemBuilder: (context, index) {
//           final task = taskLinks[index];
//           return _buildResultCard(task);
//         },
//       ),
//     )
//
//   ),
// )
//           ],),),
//       floatingActionButton: FloatingActionButton(
//         backgroundColor: Colors.pink,
//         onPressed: () {
//           Navigator.push(
//             context,
//             MaterialPageRoute(
//                 builder: (context) => Tasks())
//
//
//           );
//         },
//         child: const Icon(Icons.add),
//       ),
//     );
//   }
//   Widget _buildDateField(BuildContext context, String label, DateTime date, bool isFromDate) {
//     return TextFormField(
//       readOnly: true,
//       onTap: () => _selectDate(context, isFromDate),
//       style: const TextStyle(color: Colors.white), // Optional: white text
//       decoration: InputDecoration(
//         labelText: label,
//         labelStyle: const TextStyle(color: Colors.white), // White label
//         suffixIcon: const Icon(Icons.calendar_today, color: Colors.white), // White icon
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: const BorderSide(color: Colors.white),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: const BorderSide(color: Colors.white),
//         ),
//         border: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(12),
//           borderSide: const BorderSide(color: Colors.white),
//         ),
//       ),
//       controller: TextEditingController(
//         text: DateFormat('dd-MM-yyyy').format(date),
//       ),
//     );
//   }
//   Widget _buildResultCard(TaskModel task) {
//     return GestureDetector(
//       onTap: () {
//         // Pass data to another screen
//         Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => EditTasks( // Replace with your target screen
//               task1: task,  // send full object
//             ),
//           ),
//         );
//       },
//       child: Card(
//         elevation: 4,
//         margin: const EdgeInsets.symmetric(vertical: 8),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               InfoRow(label: "Task", value: task.task),
//               InfoRow(label: "Date", value: task.startDate),
//               InfoRow(label: "Time", value: task.time),
//               InfoRow(label: "Remind Date", value: task.remindUpto),
//               InfoRow(label: "Status", value: task.status),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   // Widget _buildResultCard(TaskModel task) {
//   //   return GestureDetector(onTap: (){
//   //
//   //     Navigator.push(
//   //         context,
//   //         MaterialPageRoute(
//   //             builder:
//   //                 (context) => EditTasks(task1:task)));
//   //     Card(
//   //     elevation: 4,
//   //     margin: const EdgeInsets.symmetric(vertical: 8),
//   //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//   //     child: Padding(
//   //       padding: const EdgeInsets.all(16),
//   //       child: Column(
//   //         crossAxisAlignment: CrossAxisAlignment.start,
//   //         children: [
//   //           InfoRow(label: "Task", value: task.task),
//   //           InfoRow(label: "Date", value: task.startDate),
//   //           InfoRow(label: "Time", value: task.time),
//   //           InfoRow(label: "Remind Date", value: task.remindUpto),
//   //           InfoRow(label: "Status", value: "initial"),
//   //         ],
//   //       ),
//   //     ),
//   //   );
//   //  });
//   // }
//
//
//   // Widget _buildResultCard(TaskModel task) {
//   //   return Card(
//   //     elevation: 4,
//   //     margin: const EdgeInsets.symmetric(vertical: 8),
//   //     shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//   //     child: Padding(
//   //       padding: const EdgeInsets.all(16),
//   //       child: Column(
//   //         crossAxisAlignment: CrossAxisAlignment.start,
//   //         children: [
//   //           InfoRow(label: "Task", value: task.task),
//   //           InfoRow(label: "Date", value: task.startDate),
//   //           InfoRow(label: "Time", value: task.time),
//   //           InfoRow(label: "Remind Date", value: task.remindUpto),
//   //           InfoRow(label: "Status", value: "initial"),
//   //         ],
//   //       ),
//   //     ),
//   //   );
//   // }
// }
// class InfoRow extends StatelessWidget {
//   final String label;
//   final String value;
//
//   const InfoRow({required this.label, required this.value, Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 4),
//       child: Row(
//         children: [
//           SizedBox(
//             width: 100,
//             child: Text(
//               "$label :",
//               style: const TextStyle(
//                 fontWeight: FontWeight.bold,
//                 color: Colors.black,
//               ),
//             ),
//           ),
//           Expanded(
//             child: Text(
//               value,
//               style: const TextStyle(color: Colors.black),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
// String _getDisplayStartDate() {
//   return DateFormat('dd/MM/yyyy').format(selected_startDate);
// }
//
// String _getDisplayEndDate() {
//   return DateFormat('dd/MM/yyyy').format(selected_endDate);
