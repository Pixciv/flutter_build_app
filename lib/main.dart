import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize(); // AdMob'u başlat
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final String appName = '{{APP_NAME}}'; // sed ile değiştirilecek

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

  final TextEditingController _num1Controller = TextEditingController();
  final TextEditingController _num2Controller = TextEditingController();
  String _result = '';

  @override
  void initState() {
    super.initState();

    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-3940256099942544/6300978111', // Test Banner ID
      size: AdSize.banner,
      request: AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          setState(() {
            _isBannerAdReady = true;
          });
        },
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
    _num1Controller.dispose();
    _num2Controller.dispose();
    super.dispose();
  }

  void _calculate(String operation) {
    final double? num1 = double.tryParse(_num1Controller.text);
    final double? num2 = double.tryParse(_num2Controller.text);

    if (num1 == null || num2 == null) {
      setState(() => _result = 'Geçersiz sayı');
      return;
    }

    double res;
    switch (operation) {
      case '+':
        res = num1 + num2;
        break;
      case '-':
        res = num1 - num2;
        break;
      case '×':
        res = num1 * num2;
        break;
      case '÷':
        if (num2 == 0) {
          setState(() => _result = 'Sıfıra bölünemez');
          return;
        }
        res = num1 / num2;
        break;
      default:
        res = 0;
    }

    setState(() => _result = 'Sonuç: $res');
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _num1Controller,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: '1. Sayı'),
                  ),
                  TextField(
                    controller: _num2Controller,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(labelText: '2. Sayı'),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 10,
                    children: [
                      ElevatedButton(onPressed: () => _calculate('+'), child: Text('+')),
                      ElevatedButton(onPressed: () => _calculate('-'), child: Text('-')),
                      ElevatedButton(onPressed: () => _calculate('×'), child: Text('×')),
                      ElevatedButton(onPressed: () => _calculate('÷'), child: Text('÷')),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(_result, style: TextStyle(fontSize: 20)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
