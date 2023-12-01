import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

void main() {
  runApp(CalorieCalculatorApp());
}

class CalorieCalculatorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calorie Calculator',
      home: CalorieCalculatorScreen(),
    );
  }
}

class CalorieCalculatorScreen extends StatefulWidget {
  @override
  _CalorieCalculatorScreenState createState() => _CalorieCalculatorScreenState();
}

class _CalorieCalculatorScreenState extends State<CalorieCalculatorScreen> {
  final List<Map<String, dynamic>> foodDatabase = [
    {'name': 'Apple', 'calories': 59},
    {'name': 'Banana', 'calories': 151},
    {'name': 'Lettuce', 'calories': 5},
    {'name': 'Beef', 'calories': 142},
    {'name': 'Egg', 'calories': 78},
    {'name': 'Asparagus', 'calories': 27},
    {'name': 'Fish', 'calories': 136},
    {'name': 'Rice', 'calories': 206},
    {'name': 'Beer', 'calories': 154},
    {'name': 'Tomato', 'calories': 22},
    {'name': 'Shrimp', 'calories': 56},
    {'name': 'Dark Chocolate', 'calories': 155},
    {'name': 'Corn', 'calories': 132},
    {'name': 'Potato', 'calories': 130},
    {'name': 'Coca-Cola', 'calories': 150},
    {'name': 'Apple Cider', 'calories': 117},
    {'name': 'Cucumber', 'calories': 17},
    {'name': 'Pizza', 'calories': 285},
    {'name': 'Yogurt', 'calories': 154},
    {'name': 'Strawberry', 'calories': 53},
    
  ];

  int selectedCalories = 0;
  int calorieGoal = 2000; // Set an initial calorie goal
  DateTime? selectedDate; // Nullable DateTime

  Map<DateTime, List<FoodEntry>> entries = {};
  int totalCalories = 0;

  TextEditingController searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Calorie Calculator'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                await _selectDate(context);
              },
              child: Text(selectedDate != null
                  ? 'Selected Date: ${DateFormat('yyyy-MM-dd').format(selectedDate!)}'
                  : 'Select Date'),
            ),
            SizedBox(height: 12),
            Text('Select Calories for the Day:'),
            Slider(
              value: selectedCalories.toDouble(),
              min: 0,
              max: 2000,
              divisions: 20,
              label: selectedCalories.toString(),
              onChanged: (value) {
                setState(() {
                  selectedCalories = value.round();
                });
              },
            ),
            SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    if (selectedDate != null &&
                        selectedCalories > 0 &&
                        selectedCalories <= calorieGoal) {
                      _showFoodSelectionDialog(context);
                    } else {
                      // Show an error message if date or calories are not selected or exceed the goal.
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: Text('Error'),
                            content: Text(
                              'Please select a valid date and calories for the day (less than or equal to the goal).',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: Text('OK'),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                  child: Text('Add Food'),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.resolveWith<Color>(
                      (Set<MaterialState> states) {
                        return selectedDate != null &&
                                selectedCalories > 0 &&
                                selectedCalories <= calorieGoal
                            ? Colors.blue
                            : Colors.grey; // Disable button color
                      },
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    _saveEntries();
                  },
                  child: Text('Save Entry'),
                ),
              ],
            ),
            SizedBox(height: 12),
            _buildSearch(),
            SizedBox(height: 12),
            Expanded(
              child: _buildDetailsList(),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.utc(2000, 1, 1),
      lastDate: DateTime.utc(2101, 12, 31),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
        selectedCalories = 0;
        totalCalories = 0;

        // Fix for the initialization of entries
        entries[selectedDate!] = entries[selectedDate!] ?? [];
      });
    }
  }

  Widget _buildDetailsList() {
  if (entries.containsKey(selectedDate) && entries[selectedDate]!.isNotEmpty) {
    // If there are entries for the selected date, show them
    return ListView.builder(
      itemCount: entries[selectedDate]!.length,
      itemBuilder: (context, index) {
        final foodEntry = entries[selectedDate]![index];

        return ListTile(
          title: Text(foodEntry.name),
          subtitle: Text('Calories: ${foodEntry.calories}'),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: Icon(Icons.edit),
                onPressed: () {
                  _showUpdateEntryDialog(context, foodEntry, selectedDate!, index);
                },
              ),
              IconButton(
                icon: Icon(Icons.delete),
                onPressed: () {
                  _deleteEntry(selectedDate!, index);
                },
              ),
            ],
          ),
        );
      },
    );
  } else {
    // If there are no entries, show a message
    return Center(
      child: Text('No details available for the selected date.'),
    );
  }
}

void _deleteEntry(DateTime date, int entryIndex) {
  setState(() {
    totalCalories -= entries[date]![entryIndex].calories;
    entries[date]!.removeAt(entryIndex);
  });
}

void _showUpdateEntryDialog(BuildContext context, FoodEntry foodEntry, DateTime date, int entryIndex) {
  TextEditingController nameController = TextEditingController(text: foodEntry.name);
  TextEditingController caloriesController = TextEditingController(text: foodEntry.calories.toString());

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Update Entry'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Food Name'),
            ),
            TextField(
              controller: caloriesController,
              decoration: InputDecoration(labelText: 'Calories'),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close the dialog
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _updateEntry(date, entryIndex, nameController.text, int.parse(caloriesController.text));
              Navigator.of(context).pop(); // Close the dialog
            },
            child: Text('Update'),
          ),
        ],
      );
    },
  );
}

void _updateEntry(DateTime date, int entryIndex, String newName, int newCalories) {
  setState(() {
    totalCalories = totalCalories - entries[date]![entryIndex].calories + newCalories;
    entries[date]![entryIndex] = FoodEntry(name: newName, calories: newCalories);
  });
}

  Widget _buildSearch() {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'Search date (YYYY-MM-DD)',
            ),
          ),
        ),
        SizedBox(width: 8),
        ElevatedButton(
          onPressed: () {
            _searchEntries();
          },
          child: Text('Search'),
        ),
      ],
    );
  }

  void _showFoodSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        List<Map<String, dynamic>> availableFoods = foodDatabase
            .where((food) => food['calories'] <= selectedCalories - totalCalories)
            .toList();

        return AlertDialog(
          title: Text('Select Food'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                for (var food in availableFoods)
                  ListTile(
                    title: Text(food['name']),
                    subtitle: Text('Calories: ${food['calories']}'),
                    onTap: () {
                      if (!entries.containsKey(selectedDate)) {
                        entries[selectedDate!] = [];
                      }
                      entries[selectedDate!]?.add(FoodEntry(
                        name: food['name'],
                        calories: food['calories'],
                      ));
                      // Deduct the calories of the selected food from the remaining calorie goal
                      setState(() {
                        totalCalories += (food['calories'] as int);
                      });
                      Navigator.of(context).pop(); // Close the dialog
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _saveEntries() {
  print('Entries saved: $entries');
  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
     content: Text("Meal plan saved!"),
));
}

  void _searchEntries() {
  try {
    DateTime searchDate = DateTime.parse(searchController.text);
    if (entries.containsKey(searchDate) && entries[searchDate]!.isNotEmpty) {
      // If there are entries for the selected date, show them
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Entries for ${DateFormat('yyyy-MM-dd').format(searchDate)}'),
            content: Column(
              children: [
                for (var entryIndex = 0; entryIndex < entries[searchDate]!.length; entryIndex++)
                  ListTile(
                    title: Text(entries[searchDate]![entryIndex].name),
                    subtitle: Text('Calories: ${entries[searchDate]![entryIndex].calories}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit),
                          onPressed: () {
                            _showUpdateEntryDialog(
                              context,
                              entries[searchDate]![entryIndex],
                              searchDate,
                              entryIndex,
                            );
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () {
                            _deleteEntry(searchDate, entryIndex);
                            Navigator.of(context).pop(); // Close the dialog after deleting
                          },
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      );
    } else {
      // If there are no entries, show a message
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('No entries for ${DateFormat('yyyy-MM-dd').format(searchDate)}'),
            content: Text('No details available for the selected date.'),
          );
        },
      );
    }
  } catch (e) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text('Invalid date format. Please enter a valid date in YYYY-MM-DD format.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
}
}

class FoodEntry {
  final String name;
  final int calories;

  FoodEntry({required this.name, required this.calories});
}
