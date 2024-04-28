import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

const double _kSize = 70;

class QuickNews extends StatefulWidget {
  const QuickNews({super.key});

  @override
  State<QuickNews> createState() => _QuickNewsState();
}

class _QuickNewsState extends State<QuickNews> {
  int cindex = 0;
  dynamic data;
  bool isDataFetched = false;
  late PageController pageController;

  @override
  void initState() {
    super.initState();
    getNews();
  }

  _launchURLApp() async {
    var url = Uri.parse(data['articles'][cindex]['url']);
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  Future getNews() async {
    final response = await http.get(
      Uri.parse(
        'https://newsapi.org/v2/top-headlines?country=us&apiKey=92b0d30aa4c941d18bec50e86abdd320',
      ),
    );
    setState(() {
      data = jsonDecode(response.body);
      isDataFetched = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white.withOpacity(0.9),
      body: (!isDataFetched)
          ? Center(
              child: LoadingAnimationWidget.flickr(
                leftDotColor: const Color(0xFF0063DC),
                rightDotColor: const Color(0xFFFF0084),
                size: _kSize,
              ),
            )
          : PageView.builder(
              scrollDirection: Axis.vertical,
              itemBuilder: (context, index) {
                cindex = index;
                return SafeArea(
                  child: Column(
                    children: [
                      ClipRRect(
                        child: (data['articles'][index]['urlToImage'] == '')
                            ? const SizedBox(
                                height: 100,
                                width: 100,
                              )
                            : Image.network(
                                data['articles'][index]['urlToImage'],
                                errorBuilder: (BuildContext context,
                                    Object error, StackTrace? stackTrace) {
                                  return const Column(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.only(top: 20),
                                        child: Center(
                                          child: Icon(
                                            Icons.error_outline,
                                            color: Colors.red,
                                            size: 48.0,
                                          ),
                                        ),
                                      ),
                                      Text('Unable to load image')
                                    ],
                                  );
                                },
                              ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Column(
                          children: [
                            Text(
                              data['articles'][index]['title'],
                              style: const TextStyle(
                                fontSize: 30,
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            Text(
                              data['articles'][index]['description'],
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
      bottomNavigationBar: GestureDetector(
        onTap: _launchURLApp,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.7),
          ),
          height: 70,
          width: double.infinity,
          child: const Padding(
            padding: EdgeInsets.all(10.0),
            child: Row(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'To read more',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    Text(
                      'Tap here',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.white,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
                Spacer(),
                Icon(
                  Icons.arrow_forward,
                  color: Colors.yellow,
                  size: 30,
                ),
                SizedBox(
                  width: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
