import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Color generator',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class RandomColorCombination {
  var color1 = Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);
  var color2 = Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);
  var color3 = Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);
  var color4 = Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);

  RandomColorCombination();

  generate() {
    this.color1 = Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);
    this.color2 = Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);
    this.color3 = Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);
    this.color4 = Color((Random().nextDouble() * 0xFFFFFF).toInt()).withOpacity(1.0);
  }
}

class MyAppState extends ChangeNotifier {
  var combination = RandomColorCombination();
  var likedCombinations = <RandomColorCombination>[];
  var liked = false;

  void getNext() {
    liked = false;
    combination.generate();
    notifyListeners();
  }

  void toggleLike() {
  if (liked) {
    liked = false;
    
    // Find and remove the matching combination
    var matchingIndex = likedCombinations.indexWhere(
      (comb) =>
          comb.color1 == combination.color1 &&
          comb.color2 == combination.color2 &&
          comb.color3 == combination.color3 &&
          comb.color4 == combination.color4,
    );

    if (matchingIndex != -1) {
      likedCombinations.removeAt(matchingIndex);
    }
  } else {
    liked = true;
    // Create a new instance of RandomColorCombination and copy the colors
    var newCombination = RandomColorCombination();
    newCombination.color1 = combination.color1;
    newCombination.color2 = combination.color2;
    newCombination.color3 = combination.color3;
    newCombination.color4 = combination.color4;
    
    likedCombinations.add(newCombination);
  }
  notifyListeners();
}

  void printItems() {
    for (var i = 0; i < likedCombinations.length; i++) {
      var comb = likedCombinations[i];
      print("${i} combination ${comb.color1} ${comb.color2} ${comb.color3} ${comb.color4}");
    }
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
      switch (selectedIndex) {
        case 0:
          page = GeneratorPage();
          break;
        case 1:
          page = FavoritesPage();
          break;
        default:
          throw UnimplementedError('no widget for $selectedIndex');
      }
    return Scaffold(
      body: Column(
        children: [
          SafeArea(
            child: NavigationBar(
              selectedIndex: selectedIndex,
              onDestinationSelected: (value) => {
                setState(() {
                  selectedIndex = value;
                })
              },
              destinations: [
                NavigationDestination(icon: Icon(Icons.home), label: "Home"), 
                NavigationDestination(icon: Icon(Icons.favorite), label: "Favourite colors")
              ],
            )
          ),
          Expanded(
            child: Container(
              color: Theme.of(context).colorScheme.primaryContainer,
              child: page,
            ),
          ),
        ],
      ),
    );
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();

    IconData favoriteIcon;
    if (appState.liked) {
      favoriteIcon = Icons.favorite;
    }
    else {
      favoriteIcon = Icons.favorite_border;
    }
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Generated colors..."),
          SizedBox(height: 30),
          BigCard(),
          SizedBox(height: 65),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: Text('Generate'),
              ),
              SizedBox(width: 15),
              ElevatedButton.icon(
                  onPressed: () {
                    appState.toggleLike();
                    appState.printItems();
                  },
                  icon: Icon(favoriteIcon),
                  label: Text('Like'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var favList = appState.likedCombinations;

    if (favList.isEmpty) {
      return Center(
        child: Text('No favorites yet.'),
      );
    }

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text('You have '
              '${favList.length} favorites:'),
        ),
        for (var colors in favList)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                color: colors.color1,
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Text(" 1 "),
                ),
              ),
              Card(
                color: colors.color2,
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Text(" 2 "),
                ),
              ),
              Card(
                color: colors.color3,
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Text(" 3 "),
                ),
              ),
              Card(
                color: colors.color4,
                child: Padding(
                  padding: const EdgeInsets.all(5.0),
                  child: Text(" 4 "),
                ),
              )
          ],)
      ],
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    final theme = Theme.of(context);
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Card(
          color: appState.combination.color1,
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Text(" 1 ", style: style),
          ),
        ),
        Card(
          color: appState.combination.color2,
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Text(" 2 ", style: style),
          ),
        ),
        Card(
          color: appState.combination.color3,
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Text(" 3 ", style: style),
          ),
        ),
        Card(
          color: appState.combination.color4,
          child: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Text(" 4 ", style: style),
          ),
        )
      ],
    );
  }
}