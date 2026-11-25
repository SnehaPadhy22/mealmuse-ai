
import 'package:flutter/material.dart';

import 'screens/ai_chef_screen.dart';
import 'screens/favourites_screen.dart';
import 'screens/meal_planner_screen.dart';
import 'screens/grocery_list_screen.dart';
import 'widgets/recipe_card.dart';

void main() {
  runApp(const MealMuseApp());
}

class MealMuseApp extends StatelessWidget {
  const MealMuseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MealMuse AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFFFBF5),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D5B),
        ),
        fontFamily: 'Roboto',
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int selectedIndex = 0;

  final List<String> categories = [
    'All',
    'Breakfast',
    'Lunch',
    'Dinner',
    'Healthy',
  ];

  final List<Map<String, String>> recipes = [
    {
      'name': 'Creamy Avocado Toast',
      'time': '15 min',
      'category': 'Breakfast',
      'emoji': '🥑',
      'image': 'assets/images/breakfast.png',
    },
    {
      'name': 'Fresh Garden Salad',
      'time': '20 min',
      'category': 'Healthy',
      'emoji': '🥗',
      'image': 'assets/images/healthy_bowl.png',
    },
    {
      'name': 'Creamy Pasta',
      'time': '25 min',
      'category': 'Dinner',
      'emoji': '🍝',
      'image': 'assets/images/dinner.png',
    },
    {
      'name': 'Healthy Lunch Bowl',
      'time': '20 min',
      'category': 'Lunch',
      'emoji': '🥙',
      'image': 'assets/images/lunch.png',
    },
    {
      'name': 'Chocolate Dessert',
      'time': '30 min',
      'category': 'Dessert',
      'emoji': '🍫',
      'image': 'assets/images/dessert.png',
    },
  ];

  void openScreen(Widget screen) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredRecipes = recipes.where((recipe) {
      return selectedIndex == 0 ||
          recipe['category'] == categories[selectedIndex];
    }).toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFFBF5),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'MealMuse AI',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF245B43),
              ),
            ),
            Text(
              'Your personal cooking companion',
              style: TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 16),
            child: CircleAvatar(
              backgroundColor: Color(0xFFE1EDE5),
              child: Icon(
                Icons.person,
                color: Color(0xFF245B43),
              ),
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Good day! 👋',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            const Text(
              "What would you like to cook today?",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),

            const SizedBox(height: 20),

            // Search bar
            TextField(
              decoration: InputDecoration(
                hintText: 'Search recipes or ingredients...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // AI Chef banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF245B43),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '✨ YOUR AI CHEF',
                    style: TextStyle(
                      color: Color(0xFFD6F0DD),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Turn your ingredients\ninto delicious meals!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Tell us what you have. Let AI do the magic.',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 18),
                  ElevatedButton.icon(
                    onPressed: () {
                      openScreen(const AIChefScreen());
                    },
                    icon: const Icon(Icons.auto_awesome),
                    label: const Text('Generate Recipe'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFD58A),
                      foregroundColor: const Color(0xFF245B43),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 26),

            // Categories
            const Text(
              'Explore Categories',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            SizedBox(
              height: 42,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final isSelected = selectedIndex == index;

                  return ChoiceChip(
                    label: Text(categories[index]),
                    selected: isSelected,
                    onSelected: (_) {
                      setState(() {
                        selectedIndex = index;
                      });
                    },
                    selectedColor: const Color(0xFF245B43),
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : Colors.black87,
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),

            // Popular recipes
            const Text(
              'Popular Recipes',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            if (filteredRecipes.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: Text('No recipes available in this category.'),
                ),
              )
            else
              ...filteredRecipes.map(
                (recipe) => RecipeCard(
                  name: recipe['name']!,
                  time: recipe['time']!,
                  category: recipe['category']!,
                  emoji: recipe['emoji']!,
                  imageAsset: recipe['image'],
                ),
              ),
          ],
        ),
      ),

      // Bottom navigation
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        backgroundColor: Colors.white,
        onDestinationSelected: (index) {
          switch (index) {
            case 1:
              openScreen(const AIChefScreen());
              break;
            case 2:
              openScreen(const FavouritesScreen());
              break;
            case 3:
              openScreen(const MealPlannerScreen());
              break;
            case 4:
              openScreen(const GroceryListScreen());
              break;
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.auto_awesome),
            label: 'AI Chef',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            label: 'Favourites',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month),
            label: 'Planner',
          ),
          NavigationDestination(
            icon: Icon(Icons.shopping_cart_outlined),
            label: 'Groceries',
          ),
        ],
      ),
    );
  }
}
