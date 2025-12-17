import 'package:flutter/material.dart';
import 'package:sakina/models/hadeth_model.dart';

class HadethDetailsScreen extends StatefulWidget {
  static const String routeName = "HadethDetailsScreen";

  const HadethDetailsScreen({super.key});

  @override
  State<HadethDetailsScreen> createState() => _HadethDetailsScreenState();
}

class _HadethDetailsScreenState extends State<HadethDetailsScreen> {
  late HadethModel model;
  late int hadithIndex;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)!.settings.arguments;
    if (args is Map) {
      model = args['hadith'];
      hadithIndex = args['index'] ?? 1;
    } else {
      model = args as HadethModel;
      hadithIndex = 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        backgroundColor: const Color(0xFF313207),
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: Padding(
            padding: const EdgeInsets.only(left: 16, top: 8),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Color(0xFFE2BE7F)),
              onPressed: () => Navigator.pop(context),
            ),
          ),
         
          centerTitle: true,
          actions: const [SizedBox(width: 56)], // Balance left icon
        ),
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/sura_details_bg.png"),
              fit: BoxFit.cover,
              opacity: 0.07,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: GlassHadithCard(model: model),
            ),
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────
// IPHONE-STYLE GLASS CARD – TITLE IN MIDDLE, BACK ON LEFT
// ──────────────────────────────────────────────────────────────
class GlassHadithCard extends StatelessWidget {
  final HadethModel model;

  const GlassHadithCard({
    super.key,
    required this.model,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      // iPhone 15 Pro border radius
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(38),
        color: Colors.white.withOpacity(0.1),
        border: Border.all(
          color: const Color(0xFFE2BE7F).withOpacity(0.4),
          width: 1.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(38),
        child: Stack(
          children: [
            // Frosted glass
            Positioned.fill(
              child: Container(color: Colors.white.withOpacity(0.13)),
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  // Title centered in the middle
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2BE7F),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      model.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'ElMessiri',
                        color: Color(0xFF0A2B1E),
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Hadith Text
                  Expanded(
                    child: ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      itemCount: model.content.length,
                      separatorBuilder: (context, index) => const Divider(
                        color: Color(0xFFE2BE7F),
                        thickness: 1.3,
                        indent: 50,
                        endIndent: 50,
                        height: 36,
                      ),
                      itemBuilder: (context, index) {
                        return Text(
                          model.content[index],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'ElMessiri',
                            color: Colors.white,
                            fontSize: 18,
                            height: 2.1,
                            fontWeight: FontWeight.w500,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}