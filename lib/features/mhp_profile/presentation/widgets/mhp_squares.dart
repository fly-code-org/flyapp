import 'package:flutter/material.dart';

class MHPSquare extends StatelessWidget {
  const MHPSquare({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> communities = [
      {"title": "Mindful Living", "image": "assets/images/community_demo.png"},
      {"title": "Anxiety Support", "image": "assets/images/community_demo.png"},
      {"title": "Self-Growth Hub", "image": "assets/images/community_demo.png"},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ------------------ Title Row ------------------
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 2.0, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Divider(
                  thickness: 1,
                  color: Colors.grey[400],
                  endIndent: 10,
                ),
              ),
              const Text(
                "MHP's Square",
                style: TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 18,
                  fontFamily: 'Lexend',
                  color: Colors.black,
                ),
              ),
              Expanded(
                child: Divider(
                  thickness: 1,
                  color: Colors.grey[400],
                  indent: 10,
                ),
              ),
            ],
          ),
        ),

        // ------------------ Community List ------------------
        ListView.builder(
          itemCount: communities.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final community = communities[index];
            return Container(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  // Square image box
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[300],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Image.asset(community['image'], fit: BoxFit.cover),
                  ),
                  const SizedBox(width: 16),

                  // Title text
                  Expanded(
                    child: Text(
                      community['title'],
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Lexend',
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
