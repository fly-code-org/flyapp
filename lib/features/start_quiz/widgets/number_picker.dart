import 'package:flutter/material.dart';

class NumberPickerWithBall extends StatefulWidget {
  const NumberPickerWithBall({Key? key}) : super(key: key);

  @override
  State<NumberPickerWithBall> createState() => _NumberPickerWithBallState();
}

class _NumberPickerWithBallState extends State<NumberPickerWithBall> {
  int selectedNumber = 1;

  final Gradient purpleGradient = LinearGradient(
    colors: [
      Color(0xFFC36AFD), // Purple gradient start (#C36AFD)
      Color(0xFF7A5AF8), // Purple gradient end (#7A5AF8)
    ],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  final RadialGradient purpleRadialGradient = RadialGradient(
  colors: [
    Color(0xFFC36AFD), // Purple gradient start
    Color(0xFF7A5AF8), // Purple gradient end
  ],
  center: Alignment.center,
  radius: 0.8,
);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Big text showing selected number
        Text(
          selectedNumber.toString(),
          style: TextStyle(
            fontSize: 180,
            fontWeight: FontWeight.bold,
            foreground: Paint()
              ..shader = purpleRadialGradient.createShader(
                Rect.fromLTWH(0, 0, 200, 200),
              ),
          ),
        ),
        SizedBox(height: 24),

        // Pill container with numbers 1-5
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(40),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(5, (index) {
              int number = index + 1;
              bool isSelected = number == selectedNumber;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    selectedNumber = number;
                  });
                },
                child: Container(
                  width: 50,
                  height: 40,
                  margin: EdgeInsets.symmetric(horizontal: 6),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Circular purple ball behind the selected number
                      if (isSelected)
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: purpleRadialGradient,
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xAA7B2FF7),
                                blurRadius: 10,
                                spreadRadius: 3,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                        ),

                      // Number text
                      Text(
                        number.toString(),
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }
}
