import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'Utils/global.dart';
import 'services/connectivity_Handler.dart';

class LeaderBoard extends StatefulWidget {
  @override
  LeaderBoardState createState() => new LeaderBoardState();
}

class LeaderBoardState extends State<LeaderBoard> {
  StreamSubscription _connectionChangeStream;
  bool isOffline = false;

  @override
  initState() {
    super.initState();
    ConnectionStatusSingleton connectionStatus =
        ConnectionStatusSingleton.getInstance();
    _connectionChangeStream =
        connectionStatus.connectionChange.listen(connectionChanged);
  }

  void connectionChanged(dynamic hasConnection) {
    setState(() {
      isOffline = !hasConnection;
    });
  }

  @override
  Widget build(BuildContext context) {
    return !isOffline
        ? Scaffold(
            resizeToAvoidBottomPadding: false,
            appBar: PreferredSize(
              preferredSize: Size.fromHeight(0),
              child: AppBar(
                backgroundColor: primaryColor,
                elevation: 0,
              ),
            ),
            body: Stack(children: <Widget>[
              Container(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage('assets/bgm1.png'),
                          fit: BoxFit.fitWidth))),
              homeButton(context),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8 * wm),
                child: Column(
                  children: <Widget>[
                    title(),
                    Padding(
                      padding: EdgeInsets.all(16),
                    ),
                    LeaderBoardList()
                  ],
                ),
              )
            ]))
        : noNetwork();
  }

  homeButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 24.0 * hm),
      child: FlatButton(
        onPressed: () {
          Navigator.pop(context);
        },
        child:
            Icon(Icons.arrow_back_ios, size: 42 * wm, color: Colors.pink[200]),
      ),
    );
  }

  title() {
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        padding: EdgeInsets.only(top: 100 * hm),
        child: Column(
          children: <Widget>[
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              color: Colors.pink[200],
              child: Text(
                "LeaderBoards",
                textScaleFactor: wm,
                style: TextStyle(
                    fontSize: 40,
                    fontFamily: "poppins",
                    color: primaryColor,
                    fontWeight: FontWeight.w700),
              ),
            ),
            Container(
              color: primaryColor,
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              margin: EdgeInsets.only(top: 8),
              child: Text(
                "The Most Searched Celebrities",
                textScaleFactor: wm,
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'poppins',
                    color: Colors.pink[200]),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class LeaderBoardList extends StatefulWidget {
  @override
  LeaderBoardListState createState() => LeaderBoardListState();
}

class LeaderBoardListState extends State<LeaderBoardList> {
  bool isLoading = true;
  List<Map<String, dynamic>> dataMap = List<Map<String, dynamic>>();

  @override
  void initState() {
    super.initState();
    listRetriever();
  }

  @override
  Widget build(BuildContext context) {
    return !isLoading
        ? Container(
            height: (550) * hm,
            child: NotificationListener<OverscrollIndicatorNotification>(
              onNotification: (overscroll) {
                overscroll.disallowGlow();
                return true;
              },
              child: ListView.builder(
                  itemCount: dataMap.length ?? 0,
                  itemBuilder: (BuildContext context, int index) {
                    String imageUrl = lowNoSpacedText(dataMap[index]["name"]);
                    return Card(
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16 * wm)),
                      color: Color(0xcc210c45),
                      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      child: Container(
                        padding: EdgeInsets.fromLTRB(
                            24 * wm, 16 * hm, 28 * wm, 16 * hm),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: <Widget>[
                            CircleAvatar(
                              backgroundColor: primaryColor,
                              maxRadius: 22 * wm,
                              child: CircleAvatar(
                                backgroundColor: primaryColor,
                                maxRadius: 20 * wm,
                                child: CachedNetworkImage(
                                  imageUrl:
                                      "https://projectinterference.000webhostapp.com/$imageUrl.jpeg",
                                  placeholder: (context, url) =>
                                      CircularProgressIndicator(),
                                  errorWidget: (context, url, error) =>
                                      new Icon(
                                    Icons.person_outline,
                                    size: 80,
                                  ),
                                  imageBuilder: (context, imageProvider) =>
                                      Container(
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        image: DecorationImage(
                                            image: imageProvider,
                                            fit: BoxFit.cover)),
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              width: 210 * wm,
                              child: Text(
                                " ${dataMap[index]["name"]}",
                                overflow: TextOverflow.ellipsis,
                                textScaleFactor: wm,
                                style: TextStyle(
                                    fontFamily: "poppins",
                                    fontSize: 22,
                                    color: Colors.pink[200],
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                            Row(
                              children: <Widget>[
                                Container(
                                  height: 40 * hm,
                                  width: 3,
                                  margin: EdgeInsets.symmetric(horizontal: 20),
                                  color: Colors.pink[200],
                                ),
                                Text(
                                  "${dataMap[index]["score"]}",
                                  textScaleFactor: wm,
                                  style: TextStyle(
                                      fontFamily: "poppins",
                                      fontSize: 24,
                                      color: Colors.pink[200],
                                      fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
            ),
          )
        : Center(
            child: CircularProgressIndicator(),
          );
  }

  listRetriever() async {
    var url = "https://mecinatorapi.herokuapp.com/leaderboard/";
    Response response =
        await get(Uri.encodeFull(url), headers: {"Accept": "application/json"});
    var map = json.decode(response.body);
    print("${response.statusCode}.");

    for (int i = 0; i < map.length; i++) {
      Map<String, dynamic> newValue = {
        "name": map[i]["name"],
        "score": map[i]["score"],
      };
      dataMap.add(newValue);
    }

    setState(() {
      dataMap.sort((a, b) => (b["score"]).compareTo(a["score"]));
      isLoading = false;
    });
  }
}
