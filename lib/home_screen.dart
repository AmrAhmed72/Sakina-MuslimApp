import 'package:flutter/material.dart';
import 'package:sakina/features/islamicEvents/islamic_events_screen';
import 'package:sakina/features/prayer_times/presentation/pages/azan_control_screen.dart';
import 'package:sakina/features/prayer_times/presentation/pages/home_prayer_times_screen.dart';
import 'package:sakina/features/qibla/presentation/pages/qibla_screen.dart';
import 'package:sakina/tabs/ahadeth_tab.dart';
import 'package:sakina/tabs/quran_tab.dart';
import 'package:sakina/tabs/AzkarTap.dart';
import 'package:sakina/tabs/sebha_tab.dart';

class HomeScreen extends StatefulWidget {
  static const String routeName = "HomeScreen";

  final int initialIndex;

  HomeScreen({super.key, this.initialIndex = 0});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    currentIndex = widget.initialIndex;
  }

  List<String> bgName = [
    'home_bg',
    'radio_bg',
    'sebha_bg',
    "time_bg",
    "ahadeth_bg"
  ];
  List<Widget> tabs = [
    HomePrayerTimesScreen(),
    QuranTab(),
    SebhaTab(),
    AzkarTab(),
    AhadethTab(),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage("assets/images/${bgName[currentIndex]}.png"),
                fit: BoxFit.fill)),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          bottomNavigationBar: BottomNavigationBar(
              showSelectedLabels: true,
              showUnselectedLabels: false,
              currentIndex: currentIndex,
              onTap: (value) {
                currentIndex = value;
                setState(() {});
              },
              type: BottomNavigationBarType.fixed,
              iconSize: 25,
              backgroundColor: Color(0xFFE2BE7F),
              selectedItemColor: Colors.white,
              unselectedItemColor: Color(0xFF202020),
              selectedIconTheme: IconThemeData(
                color: Colors.white,
              ),
              items: [
                BottomNavigationBarItem(
                  icon: _buildImage("home", 0),
                  label: "Home",
                ),
                BottomNavigationBarItem(
                  icon: _buildImage("quran", 1),
                  label: "Quran",
                ),
                BottomNavigationBarItem(
                  icon: _buildImage("sebha", 2),
                  label: "Sebha",
                ),
                BottomNavigationBarItem(
                    icon: _buildImage("azkar", 3), label: "azkar"),
                BottomNavigationBarItem(
                    icon: _buildImage("ahadeth", 4), label: "Ahadeth"),
              ]),
          body: Column(
            children: [
              Expanded(child: tabs[currentIndex]),
            ],
          ),
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            title: Image.asset("assets/images/islami_header.png",
                height: 65, fit: BoxFit.fitWidth),
            centerTitle: true,
            leading: IconButton(
                onPressed: () {
                  setState(() {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const QiblaScreen(),
                      ),
                    );
                  });
                },
                icon: const ImageIcon(
                  AssetImage("assets/images/compass.png"),
                  color: Color(0xFFE2BE7F),
                  size: 30,
                )),
            actions: [
              IconButton(
                  onPressed: () {
                    setState(() {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const IslamicEventsScreen(),
                        ),
                      );
                    });
                  },
                  icon: const Icon(
                    Icons.calendar_month,
                    size: 30,
                    color: Color(0xFFE2BE7F),
                  )),
              IconButton(
                  onPressed: () {
                    setState(() {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AzanControlScreen(),
                        ),
                      );
                    });
                  },
                  icon: const Icon(
                    Icons.settings,
                    size: 30,
                    color: Color(0xFFE2BE7F),
                  )),
            ],
          ),
        ));
  }

  _buildImage(String name, int index) {
    return index == currentIndex
        ? Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(66),
                color: Color(0xFF202020).withOpacity(.6)),
            child: ImageIcon(AssetImage(
              "assets/images/$name.png",
            )),
          )
        : ImageIcon(AssetImage(
            "assets/images/$name.png",
          ));
  }
}
