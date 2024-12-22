import 'package:FlipNSort/home.dart';
import 'package:FlipNSort/models/user.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:video_player/video_player.dart';

class MainMenu extends StatefulWidget {
  @override
  State<MainMenu> createState() => _MainMenuState();
}

class _MainMenuState extends State<MainMenu> {
  late VideoPlayerController _controller;
  String? singlePlayerName;

  List<String> avatars = [
    "https://firebasestorage.googleapis.com/v0/b/custom-voice-ai-app-736c1.appspot.com/o/userPhotos%2FmbFoaH1F9eZypiwMKgtsXpjrw0l1%2F2024-12-21%2014%3A29%3A49.938316..jpg?alt=media&token=dc7f1795-c860-4aad-919d-16387efde8de",
    "https://firebasestorage.googleapis.com/v0/b/custom-voice-ai-app-736c1.appspot.com/o/userPhotos%2FmbFoaH1F9eZypiwMKgtsXpjrw0l1%2F2024-12-21%2014%3A31%3A16.464637..jpg?alt=media&token=ca7b1ec8-d250-4152-9ea1-6dc291988811",
    "https://firebasestorage.googleapis.com/v0/b/custom-voice-ai-app-736c1.appspot.com/o/userPhotos%2FmbFoaH1F9eZypiwMKgtsXpjrw0l1%2F2024-12-21%2014%3A31%3A14.984907..jpg?alt=media&token=f90b0870-e74f-4496-935d-c464f424e7ed",
    "https://firebasestorage.googleapis.com/v0/b/custom-voice-ai-app-736c1.appspot.com/o/userPhotos%2FmbFoaH1F9eZypiwMKgtsXpjrw0l1%2F2024-12-21%2014%3A31%3A13.401914..jpg?alt=media&token=232bdf36-e43b-4e5d-a4a6-e4be7f3f5473",
    "https://firebasestorage.googleapis.com/v0/b/custom-voice-ai-app-736c1.appspot.com/o/userPhotos%2FmbFoaH1F9eZypiwMKgtsXpjrw0l1%2F2024-12-21%2014%3A31%3A10.930603..png?alt=media&token=3f30dd9a-3474-4117-be9e-92b986bb2e80",
    "https://firebasestorage.googleapis.com/v0/b/custom-voice-ai-app-736c1.appspot.com/o/userPhotos%2FmbFoaH1F9eZypiwMKgtsXpjrw0l1%2F2024-12-21%2014%3A31%3A08.821785..jpg?alt=media&token=71cb46d8-c17d-4a7d-b01c-71ec46cffcf5",
    "https://firebasestorage.googleapis.com/v0/b/custom-voice-ai-app-736c1.appspot.com/o/userPhotos%2FmbFoaH1F9eZypiwMKgtsXpjrw0l1%2F2024-12-21%2014%3A31%3A05.885129..jpg?alt=media&token=31dfcc6d-15f7-4ed2-a320-c3dd367fa518",
    "https://firebasestorage.googleapis.com/v0/b/custom-voice-ai-app-736c1.appspot.com/o/userPhotos%2FmbFoaH1F9eZypiwMKgtsXpjrw0l1%2F2024-12-21%2014%3A31%3A04.034016..jpg?alt=media&token=5b79570b-1748-48c7-a2a0-32489ae04279",
  ];

  String gameType = "";

  String singleAvatar = "";
  String playerOne = "";
  String playerTwo = "";

  String selectedPlayer = "playerOne";

  changePlayer(String player) {
    setState(() {
      selectedPlayer = player;
    });
  }

  selectSingleUserAvatar(String url) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('singleAvatar', url);
    print("KAYIT EDİLDİ :$url");
  }

  selectMultiUserAvatar(String playerOne, String playerTwo) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('playerOne', playerOne);
    await prefs.setString('playerTwo', playerTwo);
    print("KAYIT EDİLDİ :$playerOne - $playerTwo");
  }

  @override
  void initState() {
    super.initState();
    getAvatarsFromShared();
    _controller = VideoPlayerController.asset('assets/back.mp4')
      ..initialize().then((_) {
        _controller.setVolume(.5);
        _controller.setLooping(true);
        _controller.play();
        setState(() {});
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  getAvatarsFromShared() {
    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        singleAvatar = prefs.getString('singleAvatar') ?? "";
        playerOne = prefs.getString('playerOne') ?? "";
        playerTwo = prefs.getString('playerTwo') ?? "";

        print(singleAvatar);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
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
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Column(
                    children: [
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
                    ],
                  ),
                  SizedBox(
                    height: 36,
                  ),
                  if (gameType != "") ...[
                    Column(
                      children: [
                        Text(
                          "Choose an Avatar",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (gameType == "multi")
                          Container(
                            width: MediaQuery.of(context).size.width,
                            height: 60,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GestureDetector(
                                  onTap: () => changePlayer("playerOne"),
                                  child: Container(
                                    width: 120,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: selectedPlayer == "playerOne"
                                          ? Colors.green
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "Player 1",
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 20),
                                GestureDetector(
                                  onTap: () => changePlayer("playerTwo"),
                                  child: Container(
                                    width: 120,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: selectedPlayer == "playerTwo"
                                          ? Colors.green
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(100),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "Player 2",
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        SizedBox(height: 20),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          height: 500,
                          margin: EdgeInsets.only(left: 16, right: 16),
                          child: GridView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: avatars.length,
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 3, // 3 sütun
                              childAspectRatio: 1, // Kare hücreler için oran
                            ),
                            itemBuilder: (context, index) {
                              return GestureDetector(
                                onTap: () {
                                  if (gameType == "single") {
                                    setState(() {
                                      singleAvatar = avatars[index];
                                    });
                                  }
                                  if (gameType == "multi") {
                                    if (selectedPlayer == "playerOne") {
                                      setState(() {
                                        playerOne = avatars[index];
                                      });
                                    } else {
                                      setState(() {
                                        playerTwo = avatars[index];
                                      });
                                    }
                                  }
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: gameType == "single" &&
                                            singleAvatar == avatars[index]
                                        ? Border.all(
                                            color: Colors.green, width: 5)
                                        : gameType == "multi" &&
                                                selectedPlayer == "playerOne" &&
                                                playerOne == avatars[index]
                                            ? Border.all(
                                                color: Colors.green, width: 5)
                                            : gameType == "multi" &&
                                                    selectedPlayer ==
                                                        "playerTwo" &&
                                                    playerTwo == avatars[index]
                                                ? Border.all(
                                                    color: Colors.green,
                                                    width: 5)
                                                : Border.all(),
                                    image: DecorationImage(
                                      image: NetworkImage(avatars[index]),
                                      fit: BoxFit
                                          .cover, // Resmin alanı kaplamasını sağlar
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            if (gameType == "single") {
                              selectSingleUserAvatar(singleAvatar);

                              if (singleAvatar != "") {
                                _controller.dispose();
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return HomePage(
                                    singleAvatar: singleAvatar,
                                    playerOneAvatar: playerOne,
                                    playerTwoAvatar: playerTwo,
                                    gameType: gameType,
                                  );
                                }));
                              }
                            }
                            if (gameType == "multi") {
                              selectMultiUserAvatar(playerOne, playerTwo);

                              if (playerOne != "" && playerTwo != "") {
                                _controller.dispose();
                                Navigator.push(context,
                                    MaterialPageRoute(builder: (context) {
                                  return HomePage(
                                    singleAvatar: singleAvatar,
                                    playerOneAvatar: playerOne,
                                    playerTwoAvatar: playerTwo,
                                    gameType: gameType,
                                  );
                                }));
                              }
                            }
                          },
                          child: Container(
                            width: 200,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Center(
                              child: Text("START GAME",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  )),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (gameType == "") ...[
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          gameType = "single";
                        });
                      },
                      child: Container(
                        width: 230,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.deepPurpleAccent,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.person,
                              color: Colors.white,
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Single Player',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          gameType = "multi";
                        });
                      },
                      child: Container(
                        width: 230,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.deepOrangeAccent,
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.people,
                              color: Colors.white,
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Multi Player',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 20),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Ayarlar Ekranı
class SettingsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ayarlar'),
      ),
      body: Center(
        child: Text('Ayarlar Sayfası'),
      ),
    );
  }
}
