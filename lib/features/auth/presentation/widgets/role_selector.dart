import 'package:flutter/material.dart';

class RoleSelector extends StatefulWidget {
  final Function(String) onRoleSelected;

  const RoleSelector({super.key, required this.onRoleSelected});

  @override
  State<RoleSelector> createState() => _RoleSelectorState();
}

class _RoleSelectorState extends State<RoleSelector> {
  String selectedRole = 'User';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onRoleSelected('User');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            _buildRoleButton('User'),
            _buildRoleButton('MHP'),
          ],
        ),
        if (selectedRole == 'MHP')
          const Padding(
            padding: EdgeInsets.only(top: 8, left: 4),
            child: Text(
              'Mental Health Professional — therapist, counselor, or coach',
              style: TextStyle(
                
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: Color(0xFF8545E1),
              ),
            ),
          ),
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
          widget.onRoleSelected(role);
        },
        child: Container(
          height: 45,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            border: Border.all(
              color: isSelected ? const Color(0xFF8545E1) : Colors.grey,
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
                color: isSelected ? const Color(0xFF8545E1) : Colors.grey,
              ),
              const SizedBox(width: 6),
              Text(
                role,
                style: TextStyle(
                  
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: isSelected ? const Color(0xFF8545E1) : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
