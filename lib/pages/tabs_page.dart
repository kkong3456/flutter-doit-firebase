import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/material.dart';

class TabPage extends StatefulWidget {
  const TabPage(this.observer);

  final FirebaseAnalyticsObserver observer;

  @override
  State<TabPage> createState() => _TabPageState(observer);
}

class _TabPageState extends State<TabPage>
    with SingleTickerProviderStateMixin, RouteAware {
  _TabPageState(this.observer);

  late TabController _controller;
  int selectedIndex = 0;
  final FirebaseAnalyticsObserver observer;

  final List<Tab> tabs = [
    const Tab(
      text: '1번',
      icon: Icon(Icons.looks_one),
    ),
    const Tab(
      text: '2번',
      icon: Icon(Icons.looks_two),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _controller = TabController(
      vsync: this,
      length: tabs.length,
      initialIndex: selectedIndex,
    );

    _controller.addListener(() {
      setState(() {
        if (selectedIndex != _controller.index) {
          selectedIndex = _controller.index;
          _sendCurrentTab();
        }
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    observer.subscribe(this, ModalRoute.of(context) as ModalRoute<Object?>);
  }

  @override
  void dispose() {
    observer.unsubscribe(this);
    super.dispose();
  }

  void _sendCurrentTab() {
    observer.analytics.setCurrentScreen(
      screenName: 'tab/$selectedIndex',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: TabBar(
          controller: _controller,
          tabs: tabs,
        ),
      ),
      body: TabBarView(
        controller: _controller,
        children: tabs.map((Tab tab) {
          return Center(child: Text(tab.text ?? ''));
        }).toList(),
      ),
    );
  }
}
