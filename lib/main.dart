import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize(); // AdMob'u başlat
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final String appName = '{{APP_NAME}}'; // Bu metin sed ile değiştirilecek

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appName,
      home: MyHomePage(appName: appName),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String appName;

  const MyHomePage({Key? key, required this.appName}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late BannerAd _bannerAd;
  bool _isBannerAdReady = false;

  @override
  void initState() {
    super.initState();

    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/6300978111', // Test Banner ID
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) => setState(() {
          _isBannerAdReady = true;
        }),
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          print('Banner reklam yüklenemedi: $error');
        },
      ),
    );

    _bannerAd.load();
  }

  @override
  void dispose() {
    _bannerAd.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.appName),
      ),
      body: Column(
        children: [
          if (_isBannerAdReady)
            Container(
              width: _bannerAd.size.width.toDouble(),
              height: _bannerAd.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd),
            ),
          Expanded(
            child: Center(
              child: Text('Welcome to ${widget.appName}!'),
            ),
          ),
        ],
      ),
    );
  }
}
