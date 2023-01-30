import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MemoAddPage extends StatefulWidget {
  MemoAddPage({super.key});

  @override
  State<MemoAddPage> createState() => _MemoAddPageState();
}

class _MemoAddPageState extends State<MemoAddPage> {
  var db = FirebaseFirestore.instance;
  TextEditingController titleController = TextEditingController();
  TextEditingController contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('메모추가'),
      ),
      body: Container(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: Column(
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: '제목',
                    fillColor: Colors.blueAccent,
                  ),
                ),
                Expanded(
                  child: TextField(
                    controller: contentController,
                    keyboardType: TextInputType.multiline,
                    maxLines: 100,
                    decoration: InputDecoration(labelText: '내용'),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    db.collection('memos').doc('aaa').set({
                      'title': titleController.value.text,
                      'content': contentController.value.text,
                      'createTime': DateTime.now().toIso8601String()
                    });
                    Navigator.of(context).pop();
                  },
                  child: const Text('저장하기'),
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ),
              ],
            ),
          )),
    );
  }
}
