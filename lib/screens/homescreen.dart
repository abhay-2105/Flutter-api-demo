import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});

  Future<http.Response> callOverView(String url) {
    return http.get(Uri.parse(url));
  }

  final Map<String, String> overviewList = {
    'Sector': 'Sector',
    'Industry': 'Industry',
    'Market Cap.': 'MCAP',
    'Enterprise Value(EV)': 'EV',
    'Book Value/Share': 'BookNavPerShare',
    'Price-Earning Ratio': 'PEGRatio',
    'PEG Ratio': 'PEGRatio',
    'Dividend Yeild': 'Yield'
  };

  bool isNumeric(String s) {
    return double.tryParse(s) != null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Overview',
                    style: TextStyle(
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  ),
                  Divider()
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 200,
              child: FutureBuilder(
                  future: callOverView(
                      'https://api.stockedge.com/Api/SecurityDashboardApi/GetCompanyEquityInfoForSecurity/5051?lang=en'),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    if (snapshot.connectionState == ConnectionState.done) {
                      final response = jsonDecode(snapshot.data!.body);
                      return ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          itemCount: 8,
                          itemBuilder: (context, index) {
                            String value = overviewList.keys.toList()[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 5),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    value,
                                    style:
                                        TextStyle(color: Colors.blue.shade900),
                                  ),
                                  Text(isNumeric(response[overviewList[value]]
                                          .toString())
                                      ? double.tryParse(
                                              response[overviewList[value]]
                                                  .toString())!
                                          .toStringAsPrecision(2)
                                      : response[value].toString())
                                ],
                              ),
                            );
                          });
                    }
                    return Container();
                  }),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            sliver: SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Performance',
                    style: TextStyle(
                        color: Colors.deepPurple,
                        fontWeight: FontWeight.bold,
                        fontSize: 18),
                  ),
                  Divider()
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 300,
              child: FutureBuilder(
                  future: callOverView(
                      'https://api.stockedge.com/Api/SecurityDashboardApi/GetTechnicalPerformanceBenchmarkForSecurity/5051?lang=en'),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    if (snapshot.connectionState == ConnectionState.done) {
                      final response = jsonDecode(snapshot.data!.body);

                      List<double> changePercent = [];
                      double max = 0;
                      for (int i = 0; i < response.length; i++) {
                        if (response[i]['ChangePercent'] > max) {
                          max = response[i]['ChangePercent'];
                        }
                        changePercent.add(response[i]['ChangePercent']);
                      }
                      return ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          itemCount: 8,
                          itemBuilder: (context, index) {
                            double width = changePercent[index] / max * 120;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  SizedBox(
                                    width: 60,
                                    child: Text(
                                      response[index]['Label'],
                                      style: TextStyle(
                                          color: Colors.blue.shade900),
                                    ),
                                  ),
                                  Container(
                                    width: 120,
                                    height: 25,
                                    decoration: BoxDecoration(
                                        color: Colors.grey.shade200,
                                        borderRadius: BorderRadius.circular(5)),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: width.abs(),
                                          decoration: BoxDecoration(
                                              color: width < 0
                                                  ? Colors.red
                                                  : Colors.green,
                                              borderRadius:
                                                  BorderRadius.circular(5)),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                    width: 70,
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        Text(
                                          response[index]['ChangePercent']
                                              .toStringAsPrecision(2),
                                          style: TextStyle(
                                              color: response[index]
                                                          ['ChangePercent'] >
                                                      0
                                                  ? Colors.green.shade700
                                                  : Colors.red),
                                        ),
                                        Text(
                                          ' %',
                                          style: TextStyle(
                                              color: response[index]
                                                          ['ChangePercent'] >
                                                      0
                                                  ? Colors.green.shade700
                                                  : Colors.red),
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            );
                          });
                    }
                    return Container();
                  }),
            ),
          )
        ],
      ),
    );
  }
}
