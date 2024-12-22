import 'package:FlipNSort/main_menu.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lottie/lottie.dart';
import 'package:video_player/video_player.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Eklenen kütüphane
import 'dart:math';

class HomePage extends StatefulWidget {
  String singleAvatar = "";
  String playerOneAvatar = "";
  String playerTwoAvatar = "";
  String gameType = "";
  HomePage({
    super.key,
    required this.singleAvatar,
    required this.playerOneAvatar,
    required this.playerTwoAvatar,
    required this.gameType,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  InterstitialAd? interstitialAd;

  late VideoPlayerController _controller;
  late AudioPlayer audioPlayer; // Ses oynatıcı
  int level = 1;
  List<int> numbers = [];
  List<bool> isOpen = [];
  int currentNumber = 0;
  bool soundEffect = true;

  bool showCong = false;

  String currentActivePlayer = "playerOne";

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((e) {
      _loadLevel(); // Seviyeyi yükle
      loadAd();
    });

    audioPlayer = AudioPlayer(); // Ses oynatıcıyı başlat

    // VideoPlayerController'i başlat
    _controller = VideoPlayerController.asset('assets/back.mp4')
      ..initialize().then((_) {
        _controller.setVolume(.3);
        _controller.setLooping(true);
        _controller.play();
        setState(() {}); // Yeniden build etmek için
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void loadAd() {
    InterstitialAd.load(
        adUnitId: "ca-app-pub-6269735754809810/9687079521",
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          // Called when an ad is successfully received.
          onAdLoaded: (ad) {
            debugPrint('$ad loaded.');
            // Keep a reference to the ad so you can show it later.
            interstitialAd = ad;
          },
          // Called when an ad request failed.
          onAdFailedToLoad: (LoadAdError error) {
            debugPrint('InterstitialAd failed to load: $error');
          },
        ));
  }

  Future<void> _loadLevel() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      level = prefs.getInt('level') ?? 1;
    });
    _initializeLevel();
  }

  Future<void> _saveLevel() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('level', level ?? 1); // Seviyeyi kaydet
  }

  void _initializeLevel() {
    int totalCells = calculateTotalCells(level);
    numbers = List.generate(totalCells, (index) => index);
    numbers.shuffle(Random());
    isOpen = List.generate(totalCells, (index) => false);
    currentNumber = 0;
  }

  int calculateGridSize(int level) {
    return ((level + 1));
  }

  int calculateTotalCells(int level) {
    int gridSize = calculateGridSize(level);
    return gridSize * gridSize;
  }

  @override
  Widget build(BuildContext context) {
    int gridSize = calculateGridSize(level);

    return Scaffold(
      body: Stack(
        children: [
          if (_controller.value.isInitialized)
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.7),
                    BlendMode.darken,
                  ),
                  child: SizedBox(
                    width: _controller.value.size.width,
                    height: _controller.value.size.height,
                    child: VideoPlayer(_controller),
                  ),
                ),
              ),
            ),
          Container(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      SizedBox(height: 50),
                      Image.asset(
                        "assets/flipnsort-nonbe.png",
                        height: 120,
                      ),
                      Text(
                        "Flip N' Sort",
                        style: TextStyle(
                          fontSize: 36,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Level $level",
                        style: TextStyle(
                          fontSize: 24,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  if (widget.gameType == "single")
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              SizedBox(
                                height: 20,
                              ),
                              Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.green,
                                      width: 5,
                                    ),
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                      fit: BoxFit.cover,
                                      image: NetworkImage(widget.singleAvatar),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.green.withOpacity(0.5),
                                        blurRadius: 10,
                                        spreadRadius: 2,
                                      )
                                    ]),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  if (widget.gameType == "multi")
                    Container(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Column(
                            children: [
                              if (currentActivePlayer == "playerOne") ...[
                                Text(
                                  "Your Turn",
                                  style: TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                              SizedBox(
                                height: 3,
                              ),
                              Container(
                                width: currentActivePlayer == "playerOne"
                                    ? 90
                                    : 80,
                                height: currentActivePlayer == "playerOne"
                                    ? 90
                                    : 80,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: currentActivePlayer == "playerOne"
                                        ? Colors.green
                                        : Colors.transparent,
                                    width: 5,
                                  ),
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: NetworkImage(widget.playerOneAvatar),
                                  ),
                                  boxShadow: currentActivePlayer == "playerOne"
                                      ? [
                                          BoxShadow(
                                            color:
                                                Colors.green.withOpacity(0.5),
                                            blurRadius: 10,
                                            spreadRadius: 2,
                                          )
                                        ]
                                      : [],
                                ),
                              ),
                            ],
                          ),
                          Column(
                            children: [
                              if (currentActivePlayer == "playerTwo") ...[
                                Text(
                                  "Your Turn",
                                  style: TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                              SizedBox(
                                height: 3,
                              ),
                              Container(
                                width: currentActivePlayer == "playerTwo"
                                    ? 90
                                    : 80,
                                height: currentActivePlayer == "playerTwo"
                                    ? 90
                                    : 80,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: currentActivePlayer == "playerTwo"
                                        ? Colors.green
                                        : Colors.transparent,
                                    width: 5,
                                  ),
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  image: DecorationImage(
                                    fit: BoxFit.cover,
                                    image: NetworkImage(widget.playerTwoAvatar),
                                  ),
                                  boxShadow: currentActivePlayer == "playerTwo"
                                      ? [
                                          BoxShadow(
                                            color:
                                                Colors.green.withOpacity(0.5),
                                            blurRadius: 10,
                                            spreadRadius: 2,
                                          )
                                        ]
                                      : [],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  SizedBox(height: 20),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    margin: EdgeInsets.only(left: 16, right: 16),
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: GridView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      padding: EdgeInsets.zero,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: gridSize,
                      ),
                      itemCount: numbers.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () => _onCardTap(index),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 500),
                            transitionBuilder: (child, animation) {
                              return RotationYTransition(
                                child: child,
                                animation: animation,
                              );
                            },
                            child: isOpen[index]
                                ? _buildCardFront(index)
                                : _buildCardBack(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 50,
            right: 10,
            child: GestureDetector(
              onTap: openSettings,
              child: Container(
                width: 80,
                height: 80,
                child: Icon(
                  Icons.settings,
                  size: 40,
                ),
                decoration:
                    BoxDecoration(color: Colors.white, shape: BoxShape.circle),
              ),
            ),
          ),
          if (showCong)
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              color: Colors.black.withOpacity(.9),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.1,
                  ),
                  Text(
                    "Congratulations",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 36,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (widget.gameType == "single")
                    Text(
                      "\n You won the level",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  if (widget.gameType == "multi")
                    Text(
                      "\n ${currentActivePlayer == "playerOne" ? "Player 1" : "Player 2"} won the level",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  SizedBox(
                    height: 16,
                  ),
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.transparent,
                        width: 5,
                      ),
                      color: Colors.white,
                      shape: BoxShape.circle,
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: NetworkImage(widget.gameType == "single"
                            ? widget.singleAvatar
                            : currentActivePlayer == "playerOne"
                                ? widget.playerOneAvatar
                                : widget.playerTwoAvatar),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.5),
                          blurRadius: 10,
                          spreadRadius: 2,
                        )
                      ],
                    ),
                  ),
                  Lottie.asset("assets/cong.json"),
                ],
              ),
            ),
        ],
      ),
    );
  }

  openSettings() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Settings"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: soundEffect ? Colors.green : Colors.grey,
                ),
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    soundEffect = !soundEffect;
                  });
                },
                child: Text(
                  "Sound Effect ${soundEffect ? "ON" : "OFF"}",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      _controller.value.volume > 0 ? Colors.green : Colors.grey,
                ),
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    if (_controller.value.volume > 0) {
                      _controller.setVolume(0);
                    } else {
                      _controller.setVolume(0.3);
                    }
                  });
                },
                child: Text(
                  "Music ${_controller.value.volume > 0 ? "ON" : "OFF"}",
                  style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _resetAllLevel();
                  _controller.dispose();

                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => MainMenu()),
                      (route) => false);
                },
                child: Text("Reset All Level"),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _controller.dispose();
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => MainMenu()),
                      (route) => false);
                },
                child: Text("Return to Main Menu"),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCardFront(int index) {
    return Container(
      key: ValueKey("front-$index"),
      decoration: BoxDecoration(
        color: Colors.primaries[index % Colors.primaries.length],
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Center(
        child: Text(
          "${numbers[index] + 1}",
          style: const TextStyle(
            fontSize: 24,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildCardBack() {
    return Container(
      key: const ValueKey("back"),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(.8),
        border: Border.all(color: Colors.white, width: 2),
      ),
    );
  }

  void _onCardTap(int index) {
    if (soundEffect) {
      audioPlayer.play(AssetSource("flipcard.mp3"));
    }

    if (!isOpen[index]) {
      if (numbers[index] == currentNumber) {
        setState(() {
          isOpen[index] = true;
          currentNumber++;
        });

        if (currentNumber == numbers.length) {
          Future.delayed(const Duration(seconds: 1), () {
            setState(() {
              showCong = true;
              if (soundEffect) {
                audioPlayer.play(AssetSource("sucsess.mp3"));
              }

              interstitialAd?.show();

              level++;
              _initializeLevel();
              _saveLevel();
              Future.delayed(const Duration(seconds: 3), () {
                setState(() {
                  showCong = false;
                });
              });
            });
          });
        }
      } else {
        setState(() {
          isOpen[index] = true;
        });
        Future.delayed(const Duration(seconds: 1), () {
          setState(() => _resetGame());
        });
      }
    }
  }

  void _resetGame() {
    isOpen = List.generate(numbers.length, (index) => false);
    currentNumber = 0;
    currentActivePlayer =
        currentActivePlayer == "playerOne" ? "playerTwo" : "playerOne";
  }

  void _resetAllLevel() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('level', 1); // Seviyeyi kaydet
  }
}

class RotationYTransition extends StatelessWidget {
  final Widget child;
  final Animation<double> animation;

  const RotationYTransition(
      {required this.child, required this.animation, super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final angle = (1 - animation.value) * 3.14 / 2; // Y ekseni dönüşü
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(angle),
          child: animation.value > 0.5 ? this.child : null,
        );
      },
    );
  }
}
