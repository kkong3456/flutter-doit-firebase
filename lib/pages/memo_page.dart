import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_doit_firebase/models/push_model.dart';
import 'package:flutter_doit_firebase/pages/memo_add_page.dart';
import 'package:flutter_doit_firebase/pages/memo_detail.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:overlay_support/overlay_support.dart';

class MemoPage extends StatefulWidget {
  const MemoPage({super.key});

  @override
  State<MemoPage> createState() => _MemoPageState();
}

class _MemoPageState extends State<MemoPage> {
  final Stream<QuerySnapshot> _memoStream =
      FirebaseFirestore.instance.collection('memos').snapshots();

  CollectionReference memosRef = FirebaseFirestore.instance.collection('memos');

  FirebaseMessaging _messaging = FirebaseMessaging.instance;
  PushNotification? _notificationInfo;

  late AdWidget adWidget;

//ca-app-pub-3940256099942544/6300978111 : 테스트 광고단위
  final BannerAd bannerAd = BannerAd(
    adUnitId: 'ca-app-pub-3940256099942544/6300978111',
    size: AdSize.banner,
    request: AdRequest(),
    listener: BannerAdListener(),
  );

  final BannerAdListener listener = BannerAdListener(
    onAdLoaded: (Ad ad) => print('Ad loaded'),
    onAdFailedToLoad: (Ad ad, LoadAdError error) {
      ad.dispose();
      print('Ad failed to load : $error');
    },
    onAdOpened: (Ad ad) => print('Ad opened.'),
    onAdClosed: (Ad ad) => print('Ad closed'),
    onAdImpression: (Ad ad) => print('Ad impression.'),
  );

  @override
  void initState() {
    bannerAd.load();
    adWidget = AdWidget(ad: bannerAd);

    //google push기능은 앱이백그라운드에 있을때, 앱이 꺼저 있을때는 동작했고, 앱이실행중일때는 동작 안함
    //앱이 실행중일때
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      PushNotification notification = PushNotification(
        title: message.notification?.title,
        body: message.notification?.body,
      );
      setState(() {
        _notificationInfo = notification;
      });
      print(
          'The Push Message is arrived at App is aliving!==> ${_notificationInfo?.title}');
    });

    //앱이 백그라운드에 있다가 유저가 탭했을 경우
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      PushNotification notification = PushNotification(
        title: message.notification?.title,
        body: message.notification?.body,
      );

      setState(() {
        _firebaseMessagingBackgroundHandler(message);
        _notificationInfo = notification;
        print(
            'background에 있을때 푸시가 왔습니다. : ${_notificationInfo!.title} : message : $message');
      });
      //앱이 완전히 꺼져 있을때
      checkForInitialMessage();
    });

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  //앱이 완전이 꺼저있을때
  void checkForInitialMessage() async {
    RemoteMessage? initialMessage =
        await FirebaseMessaging.instance.getInitialMessage();

    if (initialMessage != null) {
      PushNotification notification = PushNotification(
        title: initialMessage.notification?.title,
        body: initialMessage.notification?.body,
      );

      setState(() {
        _notificationInfo = notification;
        print('앱이 완전히 꺼저 있을때 푸시가 왔습니다.');
      });
    }
  }

  void registerNotification() async {
    await Firebase.initializeApp();

    //앱이 백그라운드에 있을때 푸시메시지 받음
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    //requestPermision() only for IOS, not Android
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        PushNotification notification = PushNotification(
          title: message.notification?.title,
          body: message.notification?.body,
        );
        setState(() {
          _notificationInfo = notification;
        });
        if (_notificationInfo != null) {
          showSimpleNotification(
            Text(_notificationInfo!.title!),
            leading: const Text('하이'),
            subtitle: Text(_notificationInfo!.body!),
            background: Colors.cyan.shade700,
            duration: Duration(seconds: 2),
          );
        }
      });
    } else {
      print('User declined or has not accepted permission');
    }

    print('User granted permission is  : ${settings.authorizationStatus}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('메모 앱'),
      ),
      body: Column(
        children: [
          Container(
            child: adWidget,
            alignment: Alignment.center,
            width: bannerAd.size.width.toDouble(),
            height: bannerAd.size.height.toDouble(),
          ),
          SizedBox(
            height: 20,
          ),
          Flexible(
            child: StreamBuilder<QuerySnapshot<Object?>>(
              //실시간 CRUD가 가능
              stream: _memoStream,
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                final docs = snapshot.data?.docs;

                if (snapshot.hasError) {
                  return Text('Something went wrong');
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }
                return GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2),
                  itemCount: docs?.length,
                  itemBuilder: (context, index) {
                    String docsId = docs![index].reference.id;
                    // print('docId is :$docsId');

                    return Card(
                      child: GridTile(
                        header: Text(docs[index]['title']),
                        // footer: Text(docs[index]['createTime'].substring(0, 10)),
                        footer: _notificationInfo != null
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'TITLE : ${_notificationInfo?.title}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.0,
                                    ),
                                  ),
                                  SizedBox(height: 8.0),
                                  Text(
                                    'BODY : ${_notificationInfo?.body}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16.0,
                                    ),
                                  ),
                                ],
                              )
                            : Container(
                                child: const Text('푸시 메시지가 오지 않았습니다.'),
                              ),
                        child: Container(
                          padding: const EdgeInsets.only(top: 20, bottom: 20),
                          child: SizedBox(
                            child: GestureDetector(
                                onTap: () async {
                                  var xxx = await Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (BuildContext context) =>
                                              MemoDetailPage(
                                                  docs: docs, index: index)));
                                  if (xxx != null) {
                                    setState(() {});
                                  }
                                },
                                onLongPress: () {
                                  print('onLognPress');
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        return AlertDialog(
                                          title: Text(docs[index]['title']),
                                          content: const Text('삭제하시겠습니까?'),
                                          actions: [
                                            TextButton(
                                              onPressed: () {
                                                memosRef
                                                    .doc(docsId)
                                                    .delete()
                                                    .then((_) => print(
                                                        "delete memo success"))
                                                    .catchError((err) => print(
                                                        "Fail to delete"));
                                                Navigator.of(context).pop();
                                              },
                                              child: const Text("Yes"),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                              },
                                              child: Text("No"),
                                            ),
                                          ],
                                        );
                                      });
                                },
                                child: Text(docs[index]['content'])),
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context)
              .push(MaterialPageRoute(builder: (context) => MemoAddPage()));
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

Future _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Handling a background message : ${message.messageId}');
}
