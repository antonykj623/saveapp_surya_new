import 'package:flutter/material.dart';
import '../../../view/home/widget/save_DB/Budegt_database_helper/Save_DB.dart';

class Editaccount1 extends StatefulWidget {
  final String keyid, year, accname, cat, obalance, actype;

  const Editaccount1({
    super.key,
    required this.keyid,
    required this.year,
    required this.accname,
    required this.cat,
    required this.obalance,
    required this.actype,
  });

  @override
  State<Editaccount1> createState() => _Editaccount1State();
}

/// MODELS
class MenuItem {
  final String label;
  MenuItem(this.label);
}

class MenuItem1 {
  final String label1;
  MenuItem1(this.label1);
}

class MenuItem2 {
  final String label2;
  MenuItem2(this.label2);
}

/// DATA
final List<MenuItem> menuItems = [
  MenuItem('Asset Account'),
  MenuItem('Bank'),
  MenuItem('Cash'),
  MenuItem('Credit Card'),
  MenuItem('Customers'),
  MenuItem('Expense Account'),
  MenuItem('Income Account'),
  MenuItem('Insurance'),
  MenuItem('Investment'),
  MenuItem('Liability Account'),
];

final List<MenuItem1> menuItems1 = [
  MenuItem1('Debit'),
  MenuItem1('Credit'),
];

final List<MenuItem2> menuItems2 = [
  MenuItem2('2025'),
  MenuItem2('2026'),
  MenuItem2('2027'),
  MenuItem2('2028'),
  MenuItem2('2029'),
  MenuItem2('2030'),
];

class _Editaccount1State extends State<Editaccount1> {
  late TextEditingController accountname;
  late TextEditingController openingbalance;

  MenuItem? selectedCategory;
  MenuItem1? selectedType;
  MenuItem2? selectedYear;

  @override
  void initState() {
    super.initState();

    accountname = TextEditingController(text: widget.accname);
    openingbalance = TextEditingController(text: widget.obalance);

    selectedCategory = menuItems.firstWhere(
          (e) => e.label == widget.cat,
      orElse: () => menuItems.first,
    );

    selectedType = menuItems1.firstWhere(
          (e) => e.label1 == widget.actype,
      orElse: () => menuItems1.first,
    );

    selectedYear = menuItems2.firstWhere(
          (e) => e.label2 == widget.year,
      orElse: () => menuItems2.first,
    );
  }

  @override
  void dispose() {
    accountname.dispose();
    openingbalance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xfff4f6fb),

      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior:
          ScrollViewKeyboardDismissBehavior.onDrag,

          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 0,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),

          child: Column(
            children: [

              /// HEADER
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(
                  top: 20,
                  left: 16,
                  right: 16,
                  bottom: 20,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.teal, Colors.blue],
                  ),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(25),
                    bottomRight: Radius.circular(25),
                  ),
                ),

                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back,
                        color: Colors.white,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),

                    const SizedBox(width: 5),

                    const Text(
                      "Edit Account",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// CARD
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: isDark
                      ? Colors.white.withOpacity(0.05)
                      : Colors.white,

                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 10,
                      color: Colors.black12,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),

                padding: const EdgeInsets.all(16),

                child: Column(
                  children: [

                    /// ACCOUNT NAME
                    _inputField(
                      accountname,
                      "Account Name",
                      Icons.person,
                    ),

                    const SizedBox(height: 15),

                    /// CATEGORY
                    _dropdown<MenuItem>(
                      value: selectedCategory,
                      hint: "Category",
                      items: menuItems,
                      label: (e) => e.label,
                      onChanged: (val) {
                        setState(() {
                          selectedCategory = val;
                        });
                      },
                    ),

                    const SizedBox(height: 15),

                    /// OPENING BALANCE
                    _inputField(
                      openingbalance,
                      "Opening Balance",
                      Icons.currency_rupee,
                      keyboardType: TextInputType.number,
                    ),

                    const SizedBox(height: 15),

                    /// TYPE
                    _dropdown<MenuItem1>(
                      value: selectedType,
                      hint: "Type",
                      items: menuItems1,
                      label: (e) => e.label1,
                      onChanged: (val) {
                        setState(() {
                          selectedType = val;
                        });
                      },
                    ),

                    const SizedBox(height: 15),

                    /// YEAR
                    _dropdown<MenuItem2>(
                      value: selectedYear,
                      hint: "Year",
                      items: menuItems2,
                      label: (e) => e.label2,
                      onChanged: (val) {
                        setState(() {
                          selectedYear = val;
                        });
                      },
                    ),

                    const SizedBox(height: 30),

                    /// UPDATE BUTTON
                    GestureDetector(
                      onTap: _updateAccount,
                      child: Container(
                        width: double.infinity,
                        height: 50,

                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF0F9D9D),
                              Color(0xFF3B82F6),
                            ],
                          ),

                          borderRadius: BorderRadius.circular(12),
                        ),

                        child: const Center(
                          child: Text(
                            "Update Account",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// UPDATE
  void _updateAccount() {
    if (accountname.text.isEmpty ||
        openingbalance.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill all fields"),
        ),
      );
      return;
    }

    DatabaseHelper().updateaccountdet(
      accountname.text,
      selectedCategory!.label,
      openingbalance.text,
      selectedType!.label1,
      selectedYear!.label2,
      widget.keyid,
    );

    Navigator.pop(context, true);
  }

  /// INPUT FIELD
  Widget _inputField(
      TextEditingController controller,
      String hint,
      IconData icon, {
        TextInputType keyboardType = TextInputType.text,
      }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,

      textInputAction: TextInputAction.next,

      autocorrect: false,
      enableSuggestions: false,

      decoration: InputDecoration(
        prefixIcon: Icon(
          icon,
          color: Colors.teal,
        ),

        hintText: hint,

        filled: true,
        fillColor: Colors.grey.withOpacity(0.15),

        contentPadding: const EdgeInsets.symmetric(
          vertical: 18,
          horizontal: 12,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  /// DROPDOWN
  Widget _dropdown<T>({
    required T? value,
    required String hint,
    required List<T> items,
    required String Function(T) label,
    required Function(T?) onChanged,
  }) {
    return DropdownButtonFormField<T>(
      value: value,

      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey.withOpacity(0.15),

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 16,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),

      hint: Text(hint),

      items: items.map((e) {
        return DropdownMenuItem<T>(
          value: e,
          child: Text(label(e)),
        );
      }).toList(),

      onChanged: onChanged,
    );
  }
}