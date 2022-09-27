import 'dart:collection';

import 'package:arc/src/config/app_themes.dart';
import 'package:arc/src/utils/bluetooth_utils.dart';
import 'package:arc/ui/log_console/log_bar.dart';
import 'package:arc/ui/log_console/rendered_event.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

import 'ansi_parser.dart';

List<OutputEvent> _outputEventBuffer = [];

class LogConsole extends StatefulWidget {
  const LogConsole({Key? key}) : super(key: key);

  @override
  createState() => _LogConsoleState();
}

class _LogConsoleState extends State<LogConsole>
    with AutomaticKeepAliveClientMixin<LogConsole> {
  @override
  bool get wantKeepAlive => true;

  final ListQueue<RenderedEvent> _renderedBuffer = ListQueue();
  List<RenderedEvent> _filteredBuffer = [];
  bool _autoScroll = true;

  final _scrollController = ScrollController();
  final _filterController = TextEditingController();

  Level _filterLevel = Level.verbose;
  double _logFontSize = 14;

  var _currentId = 0;
  bool _scrollListenerEnabled = true;
  bool _followBottom = true;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (!_scrollListenerEnabled) return;
      var scrolledToBottom = _scrollController.offset >=
          _scrollController.position.maxScrollExtent;
      setState(() {
        _followBottom = scrolledToBottom;
      });
    });
    BluetoothUtils.onListerLog = (s) {
      setState(() {
        _outputEventBuffer.add(OutputEvent(Level.info, [s]));
      });
      didChangeDependencies();
    };
    BluetoothUtils.connectAddress();
  }

  @override
  void dispose() {
    BluetoothUtils.onListerLog = null;
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _renderedBuffer.clear();

    for (var event in _outputEventBuffer) {
      _renderedBuffer.add(_renderEvent(event));
    }
    int maxLine = 100;
    if (_outputEventBuffer.length > maxLine) {
      _outputEventBuffer = _outputEventBuffer.sublist(
          _outputEventBuffer.length - maxLine, _outputEventBuffer.length);
    }
    _refreshFilter();
  }

  void _refreshFilter() {
    var newFilteredBuffer = _renderedBuffer.where((it) {
      var logLevelMatches = it.level.index >= _filterLevel.index;
      if (!logLevelMatches) {
        return false;
      } else if (_filterController.text.isNotEmpty) {
        var filterText = _filterController.text.toLowerCase();
        return it.lowerCaseText.contains(filterText);
      } else {
        return true;
      }
    }).toList();
    setState(() {
      _filteredBuffer = newFilteredBuffer;
    });

    if (_autoScroll) {
      Future.delayed(Duration.zero, _scrollToBottom);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppThemes.darkTheme,
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Log紀錄"),
          actions: [
            if (_autoScroll)
              IconButton(
                icon: const Icon(Icons.stop),
                onPressed: () {
                  setState(() {
                    _autoScroll = false;
                  });
                },
              ),
            IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _outputEventBuffer.clear();
                didChangeDependencies();
              },
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                setState(() {
                  _logFontSize++;
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.remove),
              onPressed: () {
                setState(() {
                  _logFontSize--;
                });
              },
            )
          ],
        ),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                child: Container(
                  color: Colors.grey[150],
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      width: MediaQuery.of(context).size.width,
                      child: ListView.builder(
                        shrinkWrap: true,
                        controller: _scrollController,
                        itemBuilder: (context, index) {
                          var logEntry = _filteredBuffer[index];
                          return Text.rich(
                            logEntry.span,
                            key: Key(logEntry.id.toString()),
                            style: TextStyle(fontSize: _logFontSize),
                          );
                        },
                        itemCount: _filteredBuffer.length,
                      ),
                    ),
                  ),
                ),
              ),
              _buildBottomBar(),
            ],
          ),
        ),
        floatingActionButton: AnimatedOpacity(
          opacity: _followBottom ? 0 : 1,
          duration: const Duration(milliseconds: 150),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 60),
            child: FloatingActionButton(
              mini: true,
              clipBehavior: Clip.antiAlias,
              onPressed: () {
                _autoScroll = true;
                _scrollToBottom();
              },
              child: Icon(
                Icons.arrow_downward,
                color: Colors.lightBlue[900],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return LogBar(
      dark: true,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: <Widget>[
          Expanded(
            child: TextField(
              style: const TextStyle(fontSize: 20),
              controller: _filterController,
              onChanged: (s) => _refreshFilter(),
              decoration: const InputDecoration(
                labelText: "Filter log output",
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(width: 20),
          DropdownButton<Level>(
            value: _filterLevel,
            items: const [
              DropdownMenuItem(
                value: Level.verbose,
                child: Text("Verbose"),
              ),
              DropdownMenuItem(
                value: Level.debug,
                child: Text("Debug"),
              ),
              DropdownMenuItem(
                value: Level.info,
                child: Text("Info"),
              ),
              DropdownMenuItem(
                value: Level.warning,
                child: Text("Warning"),
              ),
              DropdownMenuItem(
                value: Level.error,
                child: Text("Error"),
              ),
              DropdownMenuItem(
                value: Level.wtf,
                child: Text("WTF"),
              ),
              DropdownMenuItem(
                value: Level.nothing,
                child: Text("Nothing"),
              )
            ],
            onChanged: (value) {
              _filterLevel = value!;
              _refreshFilter();
            },
          )
        ],
      ),
    );
  }

  void _scrollToBottom() async {
    _scrollListenerEnabled = false;

    setState(() {
      _followBottom = true;
    });
    var scrollPosition = _scrollController.position;

    await _scrollController.animateTo(
      scrollPosition.maxScrollExtent,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOut,
    );

    _scrollListenerEnabled = true;
  }

  RenderedEvent _renderEvent(OutputEvent event) {
    var parser = AnsiParser(true);
    var text = event.lines.join('\n');
    parser.parse(text);
    return RenderedEvent(
      _currentId++,
      event.level,
      TextSpan(children: parser.spans),
      text.toLowerCase(),
    );
  }
}
