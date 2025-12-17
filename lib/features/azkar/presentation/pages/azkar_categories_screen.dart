import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sakina/core/di/injection_container.dart';
import 'package:sakina/features/azkar/presentation/bloc/azkar_bloc.dart';
import 'package:sakina/features/azkar/presentation/bloc/azkar_event.dart';
import 'package:sakina/features/azkar/presentation/bloc/azkar_state.dart';
import 'package:sakina/features/azkar/presentation/pages/azkar_detail_screen.dart';
import 'package:sakina/features/daily_activity/presentation/bloc/daily_activity_bloc.dart';
import 'package:sakina/features/daily_activity/presentation/bloc/daily_activity_event.dart';

class AzkarCategoriesScreen extends StatelessWidget {
  const AzkarCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AzkarBloc>()..add(GetAllAzkarEvent()),
      child: Scaffold(
        backgroundColor: const Color(0xFF202020),
        appBar: AppBar(
          backgroundColor: const Color(0xFFE2BE7F),
          title: const Text(
            'الأذكار',
            style: TextStyle(
              color: Color(0xFF202020),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          iconTheme: const IconThemeData(color: Color(0xFF202020)),
        ),
        body: BlocBuilder<AzkarBloc, AzkarState>(
          builder: (context, state) {
            if (state is AzkarLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFE2BE7F),
                ),
              );
            } else if (state is AzkarLoaded) {
              // Group azkar by category
              final Map<String, int> categories = {};
              for (var zekr in state.azkar) {
                if (zekr.category != 'stop') {
                  categories[zekr.category] = (categories[zekr.category] ?? 0) + 1;
                }
              }

              final categoryList = categories.keys.toList();

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: categoryList.length,
                itemBuilder: (context, index) {
                  final category = categoryList[index];
                  final count = categories[category] ?? 0;

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AzkarDetailScreen(
                            category: category,
                            azkar: state.azkar
                                .where((z) => z.category == category)
                                .toList(),
                          ),
                        ),
                      ).then((_) {
                        try {
                          context
                              .read<DailyActivityBloc>()
                              .add(const LoadDailyActivityEvent());
                        } catch (_) {}
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            const Color(0xFFE2BE7F),
                            Color(0xFFB18843),

                         
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFE2BE7F).withOpacity(0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.arrow_back_ios,
                            color: Color(0xFF202020),
                            size: 20,
                          ),

                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  category,
                                  style: const TextStyle(
                                    color: Color(0xFF202020),
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$count ذكر',
                                  style: TextStyle(
                                    color: const Color(0xFF202020).withOpacity(0.7),
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF202020),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.menu_book_rounded,
                              color: Color(0xFFE2BE7F),
                              size: 28,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            } else if (state is AzkarError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Color(0xFFE2BE7F),
                      size: 64,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'حدث خطأ: ${state.message}',
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<AzkarBloc>().add(GetAllAzkarEvent());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE2BE7F),
                        foregroundColor: const Color(0xFF202020),
                      ),
                      child: const Text('إعادة المحاولة'),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
