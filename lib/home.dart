// ignore_for_file: must_be_immutable

import 'dart:io';

import 'package:FlipNSort/core/custom_debug_print.dart';
import 'package:FlipNSort/helper/contants.dart';
import 'package:FlipNSort/helper/mixpanel_manager.dart';
import 'package:FlipNSort/main_menu.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:lottie/lottie.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
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
  bool purchaseIsLoading = false;

  String currentActivePlayer = "playerOne";

  BannerAd? _bannerAd;

  List<StoreProduct> products = [];

  getInAppProducts() async {
    products = await Purchases.getProducts(
      [
        "3can",
      ],
    );
    setState(() {});
  }

  AnchoredAdaptiveBannerAdSize? bannerSize;
  String bannerAdUnitId = Contants.ADMOB_BANNER_ADD_ID;
  AdSize adSize = const AdSize(width: 100, height: 100);

  RewardedAd? _rewardedAd;

  void loadPrizeAd() {
    RewardedAd.load(
      adUnitId: Contants.ADMOB_PRIZE_ADD_ID,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (x) {
          setState(() {
            _rewardedAd = x;
          });
        },
        onAdFailedToLoad: (x) {},
      ),
    );
  }

  void loadBanner() async {
    // Get an AnchoredAdaptiveBannerAdSize before loading the ad.
    bannerSize = await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
        MediaQuery.sizeOf(context).width.truncate());

    setState(() {
      customDebugPrint("BANNER ID :$bannerAdUnitId");
      _bannerAd = BannerAd(
        adUnitId: bannerAdUnitId,
        request: const AdRequest(),
        size: adSize,
        listener: BannerAdListener(
          // Called when an ad is successfully received.
          onAdLoaded: (ad) {
            debugPrint('$ad loaded.');
            setState(() {});
          },
          // Called when an ad request failed.
          onAdFailedToLoad: (ad, err) {
            customDebugPrint(
                'BannerAd  failed to load: ıd : ${ad.adUnitId} $err');
            // Dispose the ad here to free resources.
            ad.dispose();
          },
        ),
      )..load();
    });
  }

  firstAppOpen() async {
    await SharedPreferences.getInstance().then((prefs) {
      bool? firstAppOpen = prefs.getBool('firstAppOpen');
      customDebugPrint("firstAppOpen $firstAppOpen");
      if (firstAppOpen == null) {
        prefs.setBool('firstAppOpen', false);
        prefs.setInt('tipCount', 3);
        MixpanelManager().sendAnalyticToMixPanel("FirstAppOpen", properties: {
          "firstAppOpen": "true",
        });
        setState(() {
          tipCount = 3;
        });
      } else {
        customDebugPrint("APP OPENED BEFORE");
        setState(() {
          tipCount = prefs.getInt('tipCount') ?? 0;
        });
      }
    });
  }

  int tipCount = 0;

  @override
  void initState() {
    super.initState();
    firstAppOpen();
    getInAppProducts();

    WidgetsBinding.instance.addPostFrameCallback((e) {
      _loadLevel(); // Seviyeyi yükle
      loadAd();
      loadBanner();
      loadPrizeAd();
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
        adUnitId: Contants.ADMOB_TRANFORM_ADD_ID,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          // Called when an ad is successfully received.
          onAdLoaded: (ad) {
            customDebugPrint('$ad loaded.');
            // Keep a reference to the ad so you can show it later.
            interstitialAd = ad;
          },
          // Called when an ad request failed.
          onAdFailedToLoad: (LoadAdError error) {
            customDebugPrint('InterstitialAd failed to load: $error');
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
    if (countDown == 0) {
      setState(() {
        countDown = 6;
      });
    }

    int totalCells = calculateTotalCells(level);
    numbers = List.generate(totalCells, (index) => index);
    numbers.shuffle(Random());
    isOpen = List.generate(totalCells, (index) => true);
    currentNumber = 0;

    countDownAndCloseAll();
  }

  int countDown = 3;

  countDownAndCloseAll() {
    // Start countdown and update countDown value every second
    for (int i = countDown; i >= 0; i--) {
      Future.delayed(Duration(seconds: countDown - i), () {
        setState(() {
          countDown = i;
        });

        // Once countdown reaches 0, close all elements
        if (i == 0) {
          for (int j = 0; j < numbers.length; j++) {
            setState(() {
              isOpen[j] = false;
            });
          }
        }
      });
    }
  }

  int calculateGridSize(int level) {
    if (level <= 3) return 2; // İlk 3 seviyede 2x2 grid
    if (level <= 5) return 3; // 4-6 seviyeleri 3x3 grid
    if (level <= 10) return 4; // 7-10 seviyeleri 4x4 grid
    return 5 + ((level - 10) ~/ 5); // 10'dan sonra daha yavaş artış
  }

  int calculateTotalCells(int level) {
    int gridSize = calculateGridSize(level);
    return gridSize * gridSize;
  }

  @override
  Widget build(BuildContext context) {
    int gridSize = calculateGridSize(level);

    return Scaffold(
      backgroundColor: Colors.black.withOpacity(.8),
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
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                automaticallyImplyLeading: false,
                title: Text("LEVEL $level",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                    )),
              ),
              8.h.verticalSpace,
              if (widget.gameType == "single")
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        8.h.verticalSpace,
                        Container(
                          width: 40.w,
                          height: 40.w,
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
              if (widget.gameType == "multi")
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        if (currentActivePlayer == "playerOne") ...[
                          const Text(
                            "Your Turn",
                            style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                        3.h.verticalSpace,
                        Container(
                          width:
                              currentActivePlayer == "playerOne" ? 50.w : 40.w,
                          height:
                              currentActivePlayer == "playerOne" ? 50.w : 40.w,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: currentActivePlayer == "playerOne"
                                  ? Colors.green
                                  : Colors.transparent,
                              width: 5.w,
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
                                      color: Colors.green.withOpacity(0.5),
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
                          const Text(
                            "Your Turn",
                            style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                        3.h.verticalSpace,
                        Container(
                          width:
                              currentActivePlayer == "playerTwo" ? 50.w : 40.w,
                          height:
                              currentActivePlayer == "playerTwo" ? 50.w : 40.w,
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
                                      color: Colors.green.withOpacity(0.5),
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
              12.h.verticalSpace,
              if (countDown > 0)
                Center(
                  child: Text(
                    "$countDown",
                    style: const TextStyle(color: Colors.white, fontSize: 64),
                  ),
                ),
              12.h.verticalSpace,
              Container(
                width: 1.sw,
                height: .5.sh,
                padding: EdgeInsets.only(left: 8.w, right: 8.w),
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
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
                            animation: animation,
                            child: child,
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
              12.h.verticalSpace,
              SizedBox(
                width: 1.sw,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    GestureDetector(
                      onTap: () {
                        MixpanelManager().sendAnalyticToMixPanel(
                            "BackToMainButtonClicked",
                            properties: {});

                        _controller.dispose();
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const MainMenu()),
                            (route) => false);
                      },
                      child: SizedBox(
                        width: 80,
                        height: 80,
                        child: Image.asset(
                          "assets/home.png",
                          height: 70,
                        ),
                      ),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () async {
                            if (tipCount == 0) {
                              MixpanelManager().sendAnalyticToMixPanel(
                                  "PurchaseModalOpened",
                                  properties: {
                                    "tip": tipCount,
                                  });

                              await _showPurchaseModal();
                            } else {
                              for (int i = 0; i < numbers.length; i++) {
                                if (numbers[i] == currentNumber && !isOpen[i]) {
                                  setState(() {
                                    MixpanelManager().sendAnalyticToMixPanel(
                                        "TipDecremented",
                                        properties: {
                                          "tip": tipCount,
                                        });
                                    tipCount--;

                                    isOpen[i] = true;
                                    currentNumber++;
                                  });
                                  SharedPreferences prefs =
                                      await SharedPreferences.getInstance();

                                  prefs.setInt('tipCount', tipCount);

                                  if (currentNumber == numbers.length) {
                                    Future.delayed(const Duration(seconds: 1),
                                        () {
                                      setState(() async {
                                        showCong = true;
                                        if (soundEffect) {
                                          audioPlayer
                                              .play(AssetSource("sucsess.mp3"));
                                        }

                                        MixpanelManager()
                                            .sendAnalyticToMixPanel(
                                                "GameCompletedWithTip",
                                                properties: {
                                              "tip": tipCount,
                                            });

                                        await interstitialAd?.show();

                                        level++;

                                        await Future.delayed(
                                            const Duration(seconds: 3), () {
                                          setState(() {
                                            showCong = false;
                                          });
                                        });
                                        _initializeLevel();
                                        _saveLevel();
                                      });
                                    });
                                  }
                                  return; // Bir kart açıldıktan sonra döngüyü sonlandır
                                }
                              }
                            }
                          },
                          child: Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: tipCount == 0
                                  ? Colors.redAccent
                                  : Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: tipCount == 0
                                  ? const Icon(
                                      Icons.shop,
                                      color: Colors.white,
                                    )
                                  : Text(
                                      "${tipCount}X",
                                      style: TextStyle(
                                          color: tipCount == 0
                                              ? Colors.white
                                              : Colors.redAccent,
                                          fontSize: 36,
                                          fontWeight: FontWeight.bold),
                                    ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        MixpanelManager().sendAnalyticToMixPanel(
                          "SettingsClicked",
                        );

                        openSettings();
                      },
                      child: SizedBox(
                        width: 80,
                        height: 80,
                        child: Image.asset(
                          "assets/setting.png",
                          height: 70,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 0,
            child: Container(
              color: Colors.transparent,
              width: MediaQuery.of(context).size.width,
              height: 100,
              child: _bannerAd == null
                  ? const SizedBox()
                  : SizedBox(
                      width: _bannerAd!.size.width.toDouble(),
                      height: _bannerAd!.size.height.toDouble(),
                      child: AdWidget(ad: _bannerAd!),
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
                  const Text(
                    "Congratulations",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 36,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (widget.gameType == "single")
                    const Text(
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
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  16.h.verticalSpace,
                  Container(
                    width: 80.w,
                    height: 80.w,
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
          if (purchaseIsLoading)
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              color: Colors.black.withOpacity(.8),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            )
        ],
      ),
    );
  }

  Future<void> _handlePurchase() async {
    setState(() {
      purchaseIsLoading = true;
    });
    try {
      Purchases.purchaseStoreProduct(products[0]);
      await Future.delayed(
          const Duration(seconds: 2)); // Simulating purchase delay
      SharedPreferences prefs = await SharedPreferences.getInstance();

      setState(() {
        tipCount = 3;
        purchaseIsLoading = false;
      });

      prefs.setInt('tipCount', 3);
      customDebugPrint("Satın alma başarılı!");
    } catch (e) {
      customDebugPrint("Satın alma hatası: $e");
      setState(() {
        purchaseIsLoading = false;
      });
    }
  }

  Future<void> _showAd() async {
    _rewardedAd?.show(onUserEarnedReward: (x, y) {
      customDebugPrint("Ödül kazanıldı");
      setState(() {
        tipCount = 3;
      });
      SharedPreferences.getInstance().then((prefs) {
        prefs.setInt('tipCount', 3);
      });
    });
  }

  Future<void> _showPurchaseModal() async {
    showDialog(
      context: context,
      barrierDismissible:
          true, // Kullanıcının dışına dokunarak kapatabilmesi için
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          child: Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
              color: Colors.white,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () {
                        MixpanelManager().sendAnalyticToMixPanel(
                          "PurchaseModalCloseClicked",
                        );

                        Navigator.pop(context);
                      },
                      child: const Icon(
                        Icons.close,
                        color: Colors.black,
                        size: 24,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10.0),
                const Divider(),
                const SizedBox(height: 10.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    GestureDetector(
                      onTap: () {
                        MixpanelManager().sendAnalyticToMixPanel(
                          "PurchaseModalAdClicked",
                        );

                        Navigator.pop(context);
                        _showAd();
                      },
                      child: Image.asset(
                        "assets/paid-media.png",
                        height: 70,
                      ),
                    ),
                    GestureDetector(
                        onTap: () {
                          MixpanelManager().sendAnalyticToMixPanel(
                              "PurchaseModalPurchaseClicked",
                              properties: {
                                "platform": Platform.isIOS ? "ios" : "android"
                              });
                          Navigator.pop(context);
                          _handlePurchase();
                        },
                        child: Image.asset(
                          Platform.isAndroid
                              ? "assets/google-pay.png"
                              : "assets/apple-pay.png",
                          height: Platform.isAndroid ? 60.sp : 45.sp,
                        )),
                  ],
                ),
                8.h.verticalSpace,
              ],
            ),
          ),
        );
      },
    );
  }

  openSettings() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Settings"),
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
                  MixpanelManager().sendAnalyticToMixPanel(
                      "SoundEfffectOnOffClicked",
                      properties: {"soundEffect": "$soundEffect"});
                },
                child: Text(
                  "Sound Effect ${soundEffect ? "ON" : "OFF"}",
                  style: const TextStyle(
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

                  MixpanelManager()
                      .sendAnalyticToMixPanel("MusicOnOffClicked", properties: {
                    "music": _controller.value.volume > 0 ? "Muted" : "Opened"
                  });
                },
                child: Text(
                  "Music ${_controller.value.volume > 0 ? "ON" : "OFF"}",
                  style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(context);
                  _resetAllLevel();
                  _controller.dispose();

                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (context) => const MainMenu()),
                      (route) => false);

                  SharedPreferences prefs =
                      await SharedPreferences.getInstance();

                  MixpanelManager().sendAnalyticToMixPanel(
                      "ResetAllLevelClicked",
                      properties: {"level": prefs.getInt('level')});
                },
                child: const Text("Reset All Level"),
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
          style: TextStyle(
            fontSize: 24.sp,
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

  bool isProcessing = false;

  void _onCardTap(int index) {
    if (countDown > 0) return;
    if (soundEffect) {
      audioPlayer.play(AssetSource("flipcard.mp3"));
    }

    if (!isOpen[index] && !isProcessing) {
      if (numbers[index] == currentNumber) {
        customDebugPrint("EVET İNDEX UYUYOR");
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
        customDebugPrint("YANLIŞ KART");
        setState(() {
          isOpen[index] = true;
          isProcessing = true; // İşlem devam ederken başka tıklamaları engelle
        });

        Future.delayed(const Duration(milliseconds: 500), () {
          setState(() {
            _resetGame();
            isProcessing =
                false; // İşlem tamamlandıktan sonra tıklamaları yeniden aç
          });
        });
      }
    } else {
      customDebugPrint("Zaten açık veya işlem devam ediyor");
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
