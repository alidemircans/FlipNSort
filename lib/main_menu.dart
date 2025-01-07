import 'package:FlipNSort/helper/mixpanel_manager.dart';
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
    "https://firebasestorage.googleapis.com/v0/b/custom-voice-ai-app-736c1.appspot.com/o/userPhotos%2FmbFoaH1F9eZypiwMKgtsXpjrw0l1%2F2024-12-23%2017%3A47%3A59.059517..png?alt=media&token=897e39d3-7901-4786-b065-eebea7bdd6fd",
    "https://firebasestorage.googleapis.com/v0/b/custom-voice-ai-app-736c1.appspot.com/o/userPhotos%2FmbFoaH1F9eZypiwMKgtsXpjrw0l1%2F2024-12-23%2017%3A47%3A56.803204..png?alt=media&token=011447ae-d1c1-4ce1-ab1d-bc06eaa3177e",
    "https://firebasestorage.googleapis.com/v0/b/custom-voice-ai-app-736c1.appspot.com/o/userPhotos%2FmbFoaH1F9eZypiwMKgtsXpjrw0l1%2F2024-12-23%2017%3A47%3A54.844568..png?alt=media&token=05f0c242-0f29-432a-9bd0-1d6b3122b891",
    "https://firebasestorage.googleapis.com/v0/b/custom-voice-ai-app-736c1.appspot.com/o/userPhotos%2FmbFoaH1F9eZypiwMKgtsXpjrw0l1%2F2024-12-23%2017%3A52%3A11.990766..png?alt=media&token=6a376588-400a-4f0b-a903-eac4cd646448",
    "https://firebasestorage.googleapis.com/v0/b/custom-voice-ai-app-736c1.appspot.com/o/userPhotos%2FmbFoaH1F9eZypiwMKgtsXpjrw0l1%2F2024-12-23%2017%3A52%3A09.108061..png?alt=media&token=bd06f42b-63c9-4329-9731-e841306fad04",
    "https://firebasestorage.googleapis.com/v0/b/custom-voice-ai-app-736c1.appspot.com/o/userPhotos%2FmbFoaH1F9eZypiwMKgtsXpjrw0l1%2F2024-12-23%2017%3A52%3A07.637162..png?alt=media&token=d85a726a-2d02-4ad1-9b12-5b3883ff786d",
    "https://firebasestorage.googleapis.com/v0/b/custom-voice-ai-app-736c1.appspot.com/o/userPhotos%2FmbFoaH1F9eZypiwMKgtsXpjrw0l1%2F2024-12-23%2017%3A52%3A06.129270..png?alt=media&token=b33376a8-b165-4a2e-9b8c-ee9a736cccf3",
    "https://firebasestorage.googleapis.com/v0/b/custom-voice-ai-app-736c1.appspot.com/o/userPhotos%2FmbFoaH1F9eZypiwMKgtsXpjrw0l1%2F2024-12-23%2017%3A52%3A04.685405..png?alt=media&token=6f43348b-db36-4438-9a06-1863bc957260",
    "https://firebasestorage.googleapis.com/v0/b/custom-voice-ai-app-736c1.appspot.com/o/userPhotos%2FmbFoaH1F9eZypiwMKgtsXpjrw0l1%2F2024-12-23%2017%3A52%3A02.799341..png?alt=media&token=24fbff12-ef3c-487c-9ba3-a0ec36287994",
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

  initMixPanel() {
    MixpanelManager().init();

    MixpanelManager().sendAnalyticToMixPanel("APP_OPENED", properties: {
      "app_opened": "true",
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
    initMixPanel();

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
                                  MixpanelManager().sendAnalyticToMixPanel(
                                      "AvatarSelected",
                                      properties: {
                                        "avatar": avatars[index].toString(),
                                      });
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
                          MixpanelManager()
                              .sendAnalyticToMixPanel("GameType", properties: {
                            "type": "signle",
                          });
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
                        MixpanelManager()
                            .sendAnalyticToMixPanel("GameType", properties: {
                          "type": "multi",
                        });
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
