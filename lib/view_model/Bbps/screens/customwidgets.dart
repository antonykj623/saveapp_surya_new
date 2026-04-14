// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
//
// import 'catogorydatascreen.dart';
//
// /// Widget for String input
// class StringParamField extends StatelessWidget {
//   //final CustomParamResp param;
//   final TextEditingController controller;
//   final ValueChanged<String> onChanged;
//
//   const StringParamField({
//     super.key,
//     //required this.param,
//     required this.controller,
//     required this.onChanged,
//   });
//
//   String? _validate(String? value) {
//     if (!param.optional && (value == null || value.isEmpty)) {
//       return '${param.customParamName} is required';
//     }
//     if (param.regex.isNotEmpty) {
//       final regExp = RegExp(param.regex);
//       if (!regExp.hasMatch(value ?? '')) {
//         return 'Invalid format';
//       }
//     }
//     if (value != null && value.length < param.minLength) {
//       return 'Minimum length is ${param.minLength}';
//     }
//     if (value != null && value.length > param.maxLength) {
//       return 'Maximum length is ${param.maxLength}';
//     }
//     return null;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return TextFormField(
//       controller: controller,
//       decoration: InputDecoration(
//         labelText: param.optional ? param.customParamName : '${param.customParamName} *',
//         hintText: 'Enter ${param.customParamName}',
//       ),
//       keyboardType: TextInputType.text,
//       validator: _validate,
//       onChanged: onChanged,
//     );
//   }
// }
//
// /// Widget for Number input
// class NumberParamField extends StatelessWidget {
//   final CustomParamResp param;
//   final TextEditingController controller;
//   final ValueChanged<double?> onChanged;
//
//   const NumberParamField({
//     super.key,
//     required this.param,
//     required this.controller,
//     required this.onChanged,
//   });
//
//   String? _validate(String? value) {
//     if (!param.optional && (value == null || value.isEmpty)) {
//       return '${param.customParamName} is required';
//     }
//     if (value != null && value.isNotEmpty) {
//       final number = double.tryParse(value);
//       if (number == null) return 'Invalid number';
//     }
//     return null;
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return TextFormField(
//       controller: controller,
//       decoration: InputDecoration(
//         labelText: param.optional ? param.customParamName : '${param.customParamName} *',
//         hintText: 'Enter ${param.customParamName}',
//       ),
//       keyboardType: const TextInputType.numberWithOptions(decimal: true),
//       inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*'))],
//       validator: _validate,
//       onChanged: (value) => onChanged(double.tryParse(value)),
//     );
//   }
// }
//
// /// Widget for Boolean input
// class BooleanParamField extends StatelessWidget {
//   final CustomParamResp param;
//   final bool value;
//   final ValueChanged<bool> onChanged;
//
//   const BooleanParamField({
//     super.key,
//     required this.param,
//     required this.value,
//     required this.onChanged,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return SwitchListTile(
//       title: Text(param.customParamName),
//       value: value,
//       onChanged: onChanged,
//     );
//   }
// }
