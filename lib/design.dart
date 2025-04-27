import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Design{
  final primaryColor = Color.fromRGBO(185, 211, 251, 1); //blue
  final secondaryColor = Color.fromRGBO(231,238,253,1); //light blue
  final primaryButton = Color.fromRGBO(255, 236, 185, 1); //yellow
  final secondaryButton = Color.fromRGBO(236, 157, 171, 1); //pink
  final submitButton = Color.fromRGBO(180, 248, 200, 1); //green
  final titleText = GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 38);
  final subtitleText = GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 26);
  final contentText = GoogleFonts.poppins(fontWeight: FontWeight.w600, fontSize: 18);
  final captionText = GoogleFonts.poppins(fontWeight: FontWeight.w500, fontSize: 12, color: Colors.grey);
}