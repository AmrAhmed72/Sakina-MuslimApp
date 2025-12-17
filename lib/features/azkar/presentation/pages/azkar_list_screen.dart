import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sakina/core/di/injection_container.dart';
import 'package:sakina/features/azkar/presentation/bloc/azkar_bloc.dart';
import 'package:sakina/features/azkar/presentation/bloc/azkar_event.dart';
import 'package:sakina/features/azkar/presentation/bloc/azkar_state.dart';

class AzkarListScreen extends StatelessWidget {
  const AzkarListScreen({super.key});

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
              final azkar = state.azkar;
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: azkar.length,
                itemBuilder: (context, index) {
                  final zekr = azkar[index];
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE2BE7F),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF202020),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                zekr.count,
                                style: const TextStyle(
                                  color: Color(0xFFE2BE7F),
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                             Text(
                                zekr.category,
                                style: const TextStyle(
                                  color: Color(0xFF202020),
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            

                          ],
                        ),
                        const SizedBox(height: 12),
                        Center(
                          child: Text(
                            zekr.content,
                            style: const TextStyle(
                              color: Color(0xFF202020),
                              fontSize: 16,
                              height: 1.8,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        if (zekr.description.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Center(
                            child: Text(
                              zekr.description,
                              style: TextStyle(
                                color:  Color(0xFF202020).withOpacity(0.7),
                                fontSize: 12,

                              ),
                            ),
                          ),
                        ],
                        if (zekr.reference.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            zekr.reference,
                            style: TextStyle(
                              color: const Color(0xFF202020).withOpacity(0.6),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                },
              );
            } else if (state is AzkarError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Error: ${state.message}',
                      style: const TextStyle(color: Colors.red),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<AzkarBloc>().add(GetAllAzkarEvent());
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE2BE7F),
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
