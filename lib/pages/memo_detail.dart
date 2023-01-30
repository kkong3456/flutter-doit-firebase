import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MemoDetailPage extends StatefulWidget {
  MemoDetailPage({this.docs, required this.index});

  var docs;
  int index;

  @override
  State<MemoDetailPage> createState() => _MemoDetailPageState();
}

class _MemoDetailPageState extends State<MemoDetailPage> {
  late TextEditingController titleController;
  late TextEditingController contentController;

  CollectionReference memosRef = FirebaseFirestore.instance.collection('memos');

  @override
  void initState() {
    super.initState();
    titleController =
        TextEditingController(text: widget.docs[widget.index]['title']);
    contentController =
        TextEditingController(text: widget.docs[widget.index]['content']);

    print('xxxx is ${widget.docs[widget.index].reference.id}');
  }

  @override
  Widget build(BuildContext context) {
    var docsId = widget.docs[widget.index].reference.id;

    return Scaffold(
        appBar: AppBar(
          title: const Text(''),
        ),
        body: Container(
            padding: const EdgeInsets.all(20),
            child: Center(
                child: Column(
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                      labelText: '제목', fillColor: Colors.blueAccent),
                ),
                Expanded(
                  child: TextField(
                    controller: contentController,
                    keyboardType: TextInputType.multiline,
                    maxLines: 100,
                    decoration: InputDecoration(labelText: '내용'),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    memosRef
                        .doc(docsId)
                        .update({
                          'title': titleController.text,
                          'content': contentController.text
                        })
                        .then((value) => print("memos updated"))
                        .catchError(
                            (error) => print("Failed to update memos: $error"));
                    Navigator.of(context).pop();
                  },
                  child: const Text('수정하기'),
                ),
              ],
            ))));
  }
}
