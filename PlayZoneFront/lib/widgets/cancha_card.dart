import 'package:flutter/material.dart';
import '../util/constants.dart';

class CanchaCard extends StatelessWidget {
  final Map<String, dynamic> cancha;
  final VoidCallback onTap;

  const CanchaCard({super.key, required this.cancha, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: kWhite,
      elevation: 6,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(20),
              ),
              child: Image.network(
                cancha['imagen'],
                width: 100,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      cancha['nombre'],
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Montserrat',
                        color: kCarbonBlack,
                      ),
                    ),
                    Text(
                      cancha['ubicacion'],
                      style: const TextStyle(fontSize: 14, color: kDarkGray),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, color: kOrangeAccent, size: 18),
                        Text(
                          cancha['calificacion'].toString(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '\$${cancha['precio']}/hora',
                          style: const TextStyle(
                            color: kGreenNeon,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kGreenNeon,
                        foregroundColor: kCarbonBlack,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        textStyle: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onPressed: onTap,
                      child: const Text('Ver detalles'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}