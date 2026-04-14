import 'package:flutter/material.dart';
import 'package:path/path.dart';
class CustomButton extends StatelessWidget{
  final String text;
  final VoidCallback onPressed;
  final Color color;
  const CustomButton({
  Key? key,
  required this.text,
  required this.onPressed,
  this.color = Colors.blue
  }):super(key: key);
  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
    style: ElevatedButton.styleFrom(
    backgroundColor: Colors.green,
    padding: const EdgeInsets.symmetric(horizontal: 24,vertical: 12),
   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
    ),
    onPressed:onPressed,
    child: Text(text,style: const TextStyle(fontSize: 16),),);
  }
}