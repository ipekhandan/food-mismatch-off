import 'package:flutter/material.dart';

class IngredientList extends StatelessWidget {
  final List<String> ingredients;

  const IngredientList({Key? key, required this.ingredients}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Gerçek İçerik Listesi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...ingredients.asMap().entries.map((entry) {
              int index = entry.key;
              String ingredient = entry.value;
              bool isAdditive = ingredient.startsWith('E');
              
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Text(
                      '${index + 1}.',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        ingredient,
                        style: TextStyle(
                          fontSize: 16,
                          color: isAdditive ? Colors.red[700] : Colors.grey[800],
                          fontWeight: isAdditive ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ),
                    if (isAdditive)
                      Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.orange[700],
                        size: 20,
                      ),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
