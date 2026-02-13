import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../utils/colors.dart';

class CategoryItem extends StatelessWidget {
  final String title;
  final IconData icon; // Using IconData for simplicity for now
  final bool isSelected;

  const CategoryItem({
    Key? key,
    required this.title,
    required this.icon,
    this.isSelected = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 70,
          height: 70,
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : const Color(0xFFE0DCD9),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Icon(
            icon,
            color:
                isSelected ? Colors.white : AppColors.textDark.withOpacity(0.6),
            size: 30,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark,
          ),
        ),
      ],
    );
  }
}
