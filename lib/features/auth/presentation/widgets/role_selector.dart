import 'package:flutter/material.dart';

class RoleSelector extends StatefulWidget {
  final Function(String) onRoleSelected;

  const RoleSelector({super.key, required this.onRoleSelected});

  @override
  State<RoleSelector> createState() => _RoleSelectorState();
}

class _RoleSelectorState extends State<RoleSelector> {
  String selectedRole = '';

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildRoleButton('MHP'),
        _buildRoleButton('User'),
      ],
    );
  }

  Widget _buildRoleButton(String role) {
    final bool isSelected = selectedRole == role;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            selectedRole = role;
          });
          widget.onRoleSelected(role); // notify parent
        },
        child: Container(
          height: 45,
          margin: EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? Color(0xFF8545E1) : Colors.grey,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(50),
            color: Colors.transparent,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.person_outline,
                size: 18,
                color: isSelected ? Color(0xFF8545E1) : Colors.grey,
              ),
              SizedBox(width: 6),
              Text(
                role,
                style: TextStyle(
                  fontFamily: 'Lexend',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? Color(0xFF8545E1) : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
