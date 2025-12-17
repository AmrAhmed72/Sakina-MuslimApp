import 'dart:convert';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:sakina/core/services/local_storage_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sakina/features/daily_activity/presentation/bloc/daily_activity_bloc.dart';
import 'package:sakina/features/daily_activity/presentation/bloc/daily_activity_event.dart';
import 'package:sakina/features/quran/data/models/surah_model.dart';

class QuranReaderScreen extends StatefulWidget {
  final int surahNumber;
  final String surahNameAr;
  final String surahNameEn;

  const QuranReaderScreen({
    super.key,
    required this.surahNumber,
    required this.surahNameAr,
    required this.surahNameEn,
  });

  @override
  State<QuranReaderScreen> createState() => _QuranReaderScreenState();
}

class _QuranReaderScreenState extends State<QuranReaderScreen> {
  SurahModel? surah;
  bool isLoading = true;
  String? error;
  int? bookmarkedPage;
  final PageController _pageController = PageController();
  int currentPage = 0;
  List<List<String>> pages = [];

  // Audio player
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isPlaying = false;
  bool isLoadingAudio = false;
  String currentReciter = 'ahmad_nu';
  Duration? totalDuration;
  Duration currentPosition = Duration.zero;

  final Map<String, String> reciters = {
    'ahmad_nu': 'أحمد نعينع',
    'basit': 'عبد الباسط عبد الصمد',
    'minsh': 'محمد صديق المنشاوي',
    'husr': 'محمود خليل الحصري',
    'bsfr': 'عبد الله بصفر',
    'maher': 'ماهر المعيقلي',
    'sds': 'عبد الرحمن السديس',
    'shur': 'سعود الشريم',
    'yasser': 'ياسر الدوسري',
    's_gmd': 'سعد الغامدي',
  };

  // Server mapping for reciters
  final Map<String, String> reciterServers = {
    'ahmad_nu': 'server11',
    'basit': 'server7',
    'minsh': 'server10',
    'husr': 'server8',
    'bsfr': 'server6',
    'maher': 'server12',
    'sds': 'server11',
    'shur': 'server7',
    'yasser': 'server11',
    's_gmd': 'server7',
  };

  @override
  void initState() {
    super.initState();
    _loadSurah();
    _setupAudioPlayer();
  }

  void _setupAudioPlayer() {
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (!mounted) return;
      setState(() {
        isPlaying = state == PlayerState.playing;
      });
    });

    _audioPlayer.onPlayerComplete.listen((event) {
      if (!mounted) return;
      setState(() {
        isPlaying = false;
      });
    });

    _audioPlayer.onPositionChanged.listen((position) {
      if (!mounted) return;
      setState(() {
        currentPosition = position;
      });
    });

    _audioPlayer.onDurationChanged.listen((duration) {
      if (!mounted) return;
      setState(() {
        totalDuration = duration;
      });
    });
  }

  Future<void> _loadSurah() async {
    try {
      final String response = await rootBundle.loadString(
        'assets/quran/surah_${widget.surahNumber}.json',
      );
      final Map<String, dynamic> data = json.decode(response);
      final loadedSurah = SurahModel.fromJson(data);

      pages = _splitIntoPages(loadedSurah);

      if (!mounted) return;
      setState(() {
        surah = loadedSurah;
        isLoading = false;
      });

      _loadBookmark();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = 'فشل تحميل السورة: $e';
        isLoading = false;
      });
    }
  }

  List<List<String>> _splitIntoPages(SurahModel surah) {
    List<List<String>> pagesList = [];
    List<String> currentPageVerses = [];

    if (surah.verses.length <= 15) {
      return [surah.verses.map((v) => v.text).toList()];
    }

    if (surah.verses.length <= 50) {
      for (int i = 0; i < surah.verses.length; i++) {
        currentPageVerses.add(surah.verses[i].text);
        if (currentPageVerses.length == 10 || i == surah.verses.length - 1) {
          pagesList.add(List.from(currentPageVerses));
          currentPageVerses.clear();
        }
      }
      return pagesList;
    }

    for (int i = 0; i < surah.verses.length; i++) {
      currentPageVerses.add(surah.verses[i].text);
      if (currentPageVerses.length == 15 || i == surah.verses.length - 1) {
        pagesList.add(List.from(currentPageVerses));
        currentPageVerses.clear();
      }
    }
    return pagesList;
  }

  void _loadBookmark() {
    final bookmarkedPageNumber =
        LocalStorageService.getBookmark(widget.surahNumber);
    if (bookmarkedPageNumber != null && bookmarkedPageNumber < pages.length) {
      if (!mounted) return;

      // تأخير التنقل لضمان اكتمال البناء
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        setState(() {
          bookmarkedPage = bookmarkedPageNumber;
          currentPage = bookmarkedPageNumber;
        });

        if (_pageController.hasClients) {
          _pageController.jumpToPage(bookmarkedPageNumber);
        }
      });
    }
  }

  Future<void> _toggleBookmark() async {
    if (bookmarkedPage == currentPage) {
      await LocalStorageService.removeBookmark(widget.surahNumber);
      if (!mounted) return;
      setState(() {
        bookmarkedPage = null;
      });
      _showSnackBar('تم إزالة العلامة المرجعية');
    } else {
      await LocalStorageService.saveBookmark(widget.surahNumber, currentPage);
      if (!mounted) return;
      setState(() {
        bookmarkedPage = currentPage;
      });
      _showSnackBar('تم حفظ الصفحة ${currentPage + 1}');
    }
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: GoogleFonts.elMessiri(),
          textAlign: TextAlign.center,
        ),
        backgroundColor: const Color(0xFFE2BE7F),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _playAudio() async {
    if (isPlaying) {
      await _audioPlayer.pause();
      return;
    }

    if (!mounted) return;
    setState(() {
      isLoadingAudio = true;
    });

    try {
      final surahNum = widget.surahNumber.toString().padLeft(3, '0');
      final server = reciterServers[currentReciter] ?? 'server11';
      final audioUrl =
          'https://$server.mp3quran.net/$currentReciter/$surahNum.mp3';

      await _audioPlayer.play(UrlSource(audioUrl));

      if (!mounted) return;
      setState(() {
        isLoadingAudio = false;
      });
    } catch (e) {
      if (!mounted) return;
      _showSnackBar('خطأ في تشغيل الصوت');
      setState(() {
        isLoadingAudio = false;
      });
    }
  }

  void _showReciterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF202020),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'اختر القارئ',
          style: GoogleFonts.elMessiri(
            color: const Color(0xFFE2BE7F),
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: reciters.entries.map((entry) {
            final isSelected = currentReciter == entry.key;
            return ListTile(
              title: Text(
                entry.value,
                style: GoogleFonts.elMessiri(
                  color: isSelected ? const Color(0xFFE2BE7F) : Colors.white,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                textAlign: TextAlign.center,
              ),
              leading: isSelected
                  ? const Icon(Icons.check_circle, color: Color(0xFFE2BE7F))
                  : const Icon(Icons.radio_button_unchecked,
                      color: Colors.white54),
              onTap: () {
                if (!mounted) return;
                setState(() {
                  currentReciter = entry.key;
                });
                Navigator.pop(context);
                if (isPlaying) {
                  _audioPlayer.stop().then((_) => _playAudio());
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  void _skipBackward() {
    final newPosition = currentPosition - const Duration(seconds: 10);
    _audioPlayer
        .seek(newPosition < Duration.zero ? Duration.zero : newPosition);
  }

  void _skipForward() {
    final newPosition = currentPosition + const Duration(seconds: 10);
    _audioPlayer.seek(newPosition > (totalDuration ?? Duration.zero)
        ? (totalDuration ?? Duration.zero)
        : newPosition);
  }

  void _seekToPosition(double value) {
    final position = Duration(seconds: value.toInt());
    _audioPlayer.seek(position);
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEFFE8),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE2BE7F),
        elevation: 0,
        centerTitle: true,
        title: Column(
          children: [
            Text(
              widget.surahNameAr,
              style: GoogleFonts.elMessiri(
                color: const Color(0xFF202020),
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              widget.surahNameEn,
              style: GoogleFonts.elMessiri(
                color: const Color(0xFF202020),
                fontSize: 14,
              ),
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: Color(0xFF202020)),
        actions: [
          IconButton(
            icon: Icon(
              bookmarkedPage == currentPage
                  ? Icons.bookmark
                  : Icons.bookmark_border,
              size: 28,
            ),
            onPressed: _toggleBookmark,
          ),
          if (isLoadingAudio)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Color(0xFF202020),
                ),
              ),
            )
          else
            IconButton(
              icon: Icon(isPlaying ? Icons.pause_circle : Icons.play_circle,
                  size: 32),
              onPressed: _playAudio,
            ),
          IconButton(
              icon: const Icon(Icons.person), onPressed: _showReciterDialog),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFE2BE7F)))
          : error != null
              ? Center(
                  child: Text(
                    error!,
                    style:
                        GoogleFonts.elMessiri(color: Colors.red, fontSize: 16),
                  ),
                )
              : surah == null || pages.isEmpty
                  ? const SizedBox.shrink()
                  : Column(
                      children: [
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: const BoxDecoration(
                            color: Color(0xFFE2BE7F),
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(30),
                              bottomRight: Radius.circular(30),
                            ),
                          ),
                          child: Column(
                            children: [
                              if (widget.surahNumber != 1 &&
                                  widget.surahNumber != 9)
                                Text(
                                  'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ',
                                  style: GoogleFonts.amiriQuran(
                                    color: const Color(0xFF202020),
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              const SizedBox(height: 12),
                              Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        '${surah!.count} آية',
                                        style: GoogleFonts.elMessiri(
                                            color: const Color(0xFF202020),
                                            fontSize: 14),
                                      ),
                                      if (pages.length > 1) ...[
                                        const SizedBox(width: 16),
                                        Text('•',
                                            style: GoogleFonts.elMessiri(
                                                color: const Color(0xFF202020),
                                                fontSize: 14)),
                                        const SizedBox(width: 16),
                                        Text(
                                          'صفحة ${currentPage + 1} من ${pages.length}',
                                          style: GoogleFonts.elMessiri(
                                              color: const Color(0xFF202020),
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ],
                                  ),
                                  if (isPlaying && totalDuration != null)
                                    Container(
                                      margin: const EdgeInsets.only(top: 12, bottom: 0,right: 10,left: 10)
                                      ,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 16, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: Colors.transparent,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              IconButton(
                                                icon: const Icon(
                                                  size: 27,
                                                    Icons.replay_10,
                                                    color: Colors.black),
                                                onPressed: _skipBackward,
                                              ),
                                              Expanded(
                                                child: Slider(
                                                  value: currentPosition
                                                      .inSeconds
                                                      .toDouble(),
                                                  min: 0,
                                                  max: totalDuration!.inSeconds
                                                      .toDouble(),
                                                  onChanged: _seekToPosition,
                                                  activeColor:
                                                      Colors.black.withOpacity(0.8),
                                                  inactiveColor: Colors.white54,
                                                ),
                                              ),
                                              IconButton(
                                                icon: const Icon(
                                                  size: 27,
                                                    Icons.forward_10,
                                                    color: Colors.black),
                                                onPressed: _skipForward,
                                              ),
                                            ],
                                          ),
                                          Text(
                                            '${_formatDuration(currentPosition)} / ${_formatDuration(totalDuration!)}',
                                            style: GoogleFonts.elMessiri(
                                              color: Colors.black,
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: PageView.builder(
                            controller: _pageController,
                            reverse: true,
                            onPageChanged: (page) async {
                              if (!mounted) return;
                              setState(() {
                                currentPage = page;
                              });

                              // Mark this exact page as read and compute cumulative daily pages read
                              try {
                                // mark this page for this surah
                                await LocalStorageService.markQuranPageRead(
                                    widget.surahNumber, page);

                                // compute total pages read today across all surahs
                                final total = LocalStorageService
                                    .getDailyQuranPagesRead();

                                // persist the aggregate value for older code paths / manual edits
                                await LocalStorageService.saveQuranProgress(
                                    total);

                                // notify DailyActivityBloc if it exists in context
                                try {
                                  final bloc =
                                      context.read<DailyActivityBloc>();
                                  bloc.add(SetQuranProgressEvent(total));
                                } catch (_) {
                                  // no bloc available — that's fine
                                }
                              } catch (_) {
                                // ignore storage errors silently
                              }
                            },
                            itemCount: pages.length,
                            itemBuilder: (context, pageIndex) {
                              return _buildPage(pages[pageIndex], pageIndex);
                            },
                          ),
                        ),
                        if (pages.length > 1)
                          Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              textDirection: TextDirection.rtl,
                              children: List.generate(
                                pages.length > 10 ? 10 : pages.length,
                                (index) {
                                  if (pages.length > 10) {
                                    if (currentPage < 5) {
                                      if (index < 7 ||
                                          index == pages.length - 1) {
                                        return _buildPageDot(index);
                                      }
                                    } else if (currentPage > pages.length - 6) {
                                      if (index == 0 ||
                                          index > pages.length - 8) {
                                        return _buildPageDot(index);
                                      }
                                    } else {
                                      if (index == 0 ||
                                          (index >= currentPage - 2 &&
                                              index <= currentPage + 2) ||
                                          index == pages.length - 1) {
                                        return _buildPageDot(index);
                                      }
                                    }
                                    return const SizedBox.shrink();
                                  }
                                  return _buildPageDot(index);
                                },
                              ),
                            ),
                          ),
                      ],
                    ),
    );
  }

  Widget _buildPageDot(int index) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      width: currentPage == index ? 12 : 8,
      height: currentPage == index ? 12 : 8,
      decoration: BoxDecoration(
        color: currentPage == index
            ? const Color(0xFFE2BE7F)
            : const Color(0xFFE2BE7F).withOpacity(0.3),
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildPage(List<String> verses, int pageIndex) {
    int startVerseNumber = 0;
    for (int i = 0; i < pageIndex; i++) {
      startVerseNumber += pages[i].length;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            RichText(
              textAlign: TextAlign.justify,
              textDirection: TextDirection.rtl,
              text: TextSpan(
                style: const TextStyle(
                  fontFamily: 'AmiriQuran',
                  color: Color(0xFF202020),
                  fontSize: 25,
                  height: 2.2,
                  letterSpacing: 0.5,
                ),
                children:
                    _buildFullTextWithRedTashkeel(verses, startVerseNumber),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  List<TextSpan> _buildFullTextWithRedTashkeel(
      List<String> verses, int startNumber) {
    List<TextSpan> spans = [];

    for (int i = 0; i < verses.length; i++) {
      final verseNumber = startNumber + i + 1;
      final verseText = verses[i];

      // نضيف الآية مع تشكيل أحمر
      spans.addAll(_parseVerseWithRedTashkeel(verseText));

      // نضيف رقم الآية
      spans.add(
        TextSpan(
          text: ' ﴿$verseNumber﴾ ',
          style: const TextStyle(
            color: Color(0xFF202020),
            fontSize: 20,
          ),
        ),
      );
    }

    return spans;
  }

  List<TextSpan> _parseVerseWithRedTashkeel(String text) {
    List<TextSpan> spans = [];
    String buffer = '';

    for (int i = 0; i < text.length; i++) {
      String char = text[i];

      // لو تشكيل (حركة)
      if ('ًٌٍَُِّْٰٓ'.contains(char)) {
        if (buffer.isNotEmpty) {
          spans.add(TextSpan(text: buffer));
          buffer = '';
        }
        spans.add(TextSpan(
          text: char,
          style: const TextStyle(color: Colors.red),
        ));
      }
      // لو حرف عادي
      else {
        buffer += char;
      }
    }

    if (buffer.isNotEmpty) {
      spans.add(TextSpan(text: buffer));
    }

    return spans;
  }
}


/*
* */