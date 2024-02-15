import 'package:flutter/material.dart';
import 'package:meals/data/dummy_data.dart';
import 'package:meals/models/meal.dart';
import 'package:meals/screens/categories.dart';
import 'package:meals/screens/filters.dart';
import 'package:meals/screens/meals.dart';
import 'package:meals/widgets/main_drawer.dart';

const kInitialVariables = {
    Filter.glutenFree:false,
    Filter.lactoseFree:false,
    Filter.vegetarian:false,
    Filter.vegan:false,
  };

class TabsScreen extends StatefulWidget {
  const TabsScreen({super.key});

  @override
  State<TabsScreen> createState() {
    return _TabsScreenState();
  }
}

class _TabsScreenState extends State<TabsScreen> {
  int _selectedPageIndex = 0;
  final List<Meal> _favouriteMeals = [];
  Map<Filter, bool>_selectedFilters = kInitialVariables;

  void _showInfoMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
      ),
    );
  }

  void toggleMealFavouriteStatus(Meal meal) {
    final isExisting = _favouriteMeals.contains(meal);
    setState(() {
      if (isExisting) {
        _favouriteMeals.remove(meal);
        _showInfoMessage('Item deleted from favourite.');
      } else {
        _favouriteMeals.add(meal);
        _showInfoMessage('Item added to favourite!');
      }
    });
  }

  void _selectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  void _setScreen(String identifier) async {
    Navigator.of(context).pop();
    if (identifier == 'filters') {
      final result = await Navigator.of(context).push<Map<Filter, bool>>(
        MaterialPageRoute(
          builder: (ctx) => FiltersScreen(currentMeals: _selectedFilters),
        ),
      );

      setState(() {
        _selectedFilters = result ?? kInitialVariables;
      });
    } 
  }

  @override
  Widget build(BuildContext context) {
    final availableMeals = dummyMeals.where((meal){
      if(_selectedFilters[Filter.glutenFree]! && !meal.isGlutenFree)
      {
        return false;
      }
      if(_selectedFilters[Filter.lactoseFree]! && !meal.isLactoseFree)
      {
        return false;
      }
      if(_selectedFilters[Filter.vegetarian]! && !meal.isVegetarian)
      {
        return false;
      }
      if(_selectedFilters[Filter.vegan]! && !meal.isVegan)
      {
        return false;
      }
      return true;
    }).toList();
    Widget activePage = CategoryScreen(
      onToggleFavourite: toggleMealFavouriteStatus,
      availableMeals: availableMeals,
    );

    var activePageTitle = 'Categories';

    if (_selectedPageIndex == 1) {
      activePage = MealsScreen(
        meals: _favouriteMeals,
        onToggleFavourite: toggleMealFavouriteStatus,
      );
      activePageTitle = 'Your Favourites';
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(activePageTitle),
      ),
      drawer: MainDrawer(
        onSelectScreen: _setScreen,
      ),
      body: activePage,
      bottomNavigationBar: BottomNavigationBar(
        onTap: _selectPage,
        currentIndex: _selectedPageIndex,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.set_meal),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: 'Favourite',
          ),
        ],
      ),
    );
  }
}
