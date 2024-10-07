import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';

class InsertView extends StatefulWidget {
  const InsertView({super.key});

  @override
  State<StatefulWidget> createState() => InsertViewState();
}

class InsertViewState extends State<InsertView>
    with AutomaticKeepAliveClientMixin {
  final _text = TextEditingController();
  final _author = TextEditingController();
  final _source = TextEditingController();
  final _pages = TextEditingController();
  final _digests = [TextEditingController()];

  void submit() async {
    var needSubmit = true;

    if (_text.text.isEmpty) {
      log('Text is empty');
      needSubmit = false;
    }

    if (_author.text.isEmpty) {
      log('Author is empty');
      needSubmit = false;
    }

    if (_source.text.isEmpty) {
      log('Source is empty');
      needSubmit = false;
    }

    if (_pages.text.isEmpty || int.tryParse(_pages.text) == null) {
      log('Pages is empty or not a number');
      needSubmit = false;
    }

    for (var digest in _digests) {
      if (digest.text.isEmpty) {
        log('Digest ${_digests.indexOf(digest)} is empty');
        needSubmit = false;
      }
    }

    if (!needSubmit) {
      log('Some fields are empty or invalid, command not submitted',
          level: 900);
      return;
    }

    Process.run('insert', [
      _text.text,
      _author.text,
      _source.text,
      _pages.text,
      ..._digests.map((e) => e.text)
    ]).then((result) {
      if (result.stderr.toString().isNotEmpty) {
        log('Insert error: ${result.stderr}');
        return;
      }
      _text.clear();
      _author.clear();
      _source.clear();
      _pages.clear();
      for (var digest in _digests) {
        digest.clear();
      }
      log('Insert with:');
      log('Text: ${_text.text}, Author: ${_author.text}, Source: ${_source.text}, Pages: ${_pages.text}, Digests: ${_digests.map((e) => e.text).join(" ")}');
      log('Insert result: ${result.stdout}');
    }).catchError((e) {
      log('Insert error: $e', level: 900);
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    var screenHeight = MediaQuery.of(context).size.height;
    var screenWidth = MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Padding(padding: EdgeInsets.all(16.0)),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text("Text"),
              TextField(
                maxLines: 8,
                controller: _text,
                decoration: const InputDecoration(
                  hintText: 'Text',
                  hintStyle: TextStyle(
                    fontSize: 12.0,
                    color: Colors.grey,
                  ),
                ),
              ),
            ]),
          ),
          const Padding(padding: EdgeInsets.all(16.0)),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text("Author"),
              TextField(
                controller: _author,
                decoration: const InputDecoration(
                  hintText: 'Author',
                  hintStyle: TextStyle(
                    fontSize: 12.0,
                    color: Colors.grey,
                  ),
                ),
              ),
              const Padding(padding: EdgeInsets.all(4.0)),
              const Text("Source"),
              TextField(
                controller: _source,
                decoration: const InputDecoration(
                  hintText: 'Source',
                  hintStyle: TextStyle(
                    fontSize: 12.0,
                    color: Colors.grey,
                  ),
                ),
              ),
              const Padding(padding: EdgeInsets.all(4.0)),
              const Text("Pages"),
              TextField(
                controller: _pages,
                decoration: const InputDecoration(
                    hintText: 'Pages',
                    hintStyle: TextStyle(
                      fontSize: 12.0,
                      color: Colors.grey,
                    )),
              ),
            ]),
          ),
          const Padding(padding: EdgeInsets.all(16.0)),
        ]),
        const Padding(padding: EdgeInsets.all(16.0)),
        const Row(
          children: [
            Padding(padding: EdgeInsets.all(16.0)),
            Text('Digests'),
          ],
        ),
        SizedBox(
          height: screenHeight - 468,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: (_digests.length / 2).ceil(),
            itemBuilder: (context, index) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                children: [
                  const Padding(padding: EdgeInsets.all(16.0)),
                  SizedBox(
                    width: (screenWidth - 96) / 2,
                    child: TextField(
                      controller: _digests[index * 2],
                      decoration: InputDecoration(
                        hintText: 'Digest ${index * 2 + 1}',
                        hintStyle: const TextStyle(
                          fontSize: 12.0,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                  const Padding(padding: EdgeInsets.all(16.0)),
                  if (_digests.length > index * 2 + 1)
                    Expanded(
                      child: TextField(
                        controller: _digests[index * 2 + 1],
                        decoration: InputDecoration(
                          hintText: 'Digest ${index * 2 + 2}',
                          hintStyle: const TextStyle(
                            fontSize: 12.0,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                  if (_digests.length > index * 2 + 1)
                    const Padding(padding: EdgeInsets.all(16.0)),
                ],
              ),
            ),
          ),
        ),
        const Padding(padding: EdgeInsets.all(16.0)),
        Row(children: [
          const Padding(padding: EdgeInsets.all(16.0)),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _digests.add(TextEditingController());
              });
            },
            child: const Text('Add digest'),
          ),
          const Padding(padding: EdgeInsets.all(16.0)),
          ElevatedButton(
              onPressed: () {
                setState(() {
                  if (_digests.length > 1) {
                    _digests.removeLast();
                  }
                });
              },
              child: const Text('Remove digest')),
          const Padding(padding: EdgeInsets.all(16.0)),
          ElevatedButton(
            onPressed: () {
              submit();
            },
            child: const Text('Submit'),
          ),
        ]),
      ],
    );
  }

  @override
  bool get wantKeepAlive => true;
}
