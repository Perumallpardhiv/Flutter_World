import 'package:flutter/material.dart';
import 'package:rxdart/src/streams/value_stream.dart';
import 'package:stop_watch_timer/stop_watch_timer.dart';

class stopWatch extends StatefulWidget {
  const stopWatch({super.key});

  @override
  State<stopWatch> createState() => _stopWatchState();
}

class _stopWatchState extends State<stopWatch> {
  final StopWatchTimer _stopWatchTimer = StopWatchTimer(
    mode: StopWatchMode.countUp,
  );

  @override
  void dispose() async {
    super.dispose();
    await _stopWatchTimer.dispose();
  }

  int start = 0;
  var isActive1 = true, isActive2 = false, isActive3 = false;
  final _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 64),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Flexible(
              child: Padding(
                padding: EdgeInsets.only(left: 25),
                child: Text(
                  'StopWatch',
                  style: TextStyle(
                    fontFamily: 'Gentium',
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    fontSize: 28,
                  ),
                ),
              ),
            ),
            Flexible(
              flex: 18,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Flexible(
                    flex: 1,
                    child: StreamBuilder<int>(
                      stream: _stopWatchTimer.rawTime,
                      initialData: _stopWatchTimer.rawTime.value,
                      builder: (context, snap) {
                        final value = snap.data!;
                        final displayTime = StopWatchTimer.getDisplayTime(value,
                            hours: true, milliSecond: false);
                        final displayMillTime = StopWatchTimer.getDisplayTime(
                            value,
                            hours: true,
                            minute: false,
                            second: false);
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              displayTime,
                              style: const TextStyle(
                                fontSize: 60,
                                fontFamily: 'Gentium',
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(5, 0, 0, 13),
                              child: Text(
                                displayMillTime.substring(2),
                                style: const TextStyle(
                                    fontSize: 25,
                                    fontFamily: 'Gentium',
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  // Lap time.
                  Flexible(
                    flex: 3,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 8),
                      child: SizedBox(
                        height: 200,
                        child: StreamBuilder<List<StopWatchRecord>>(
                          stream: _stopWatchTimer.records,
                          initialData: _stopWatchTimer.records.value,
                          builder: (context, snap) {
                            final value = snap.data!;
                            if (value.isEmpty) {
                              return const SizedBox.shrink();
                            }
                            Future.delayed(const Duration(milliseconds: 100),
                                () {
                              _scrollController.animateTo(
                                  _scrollController.position.maxScrollExtent,
                                  duration: const Duration(milliseconds: 200),
                                  curve: Curves.easeOut);
                            });
                            print('Listen records. $value');
                            return ListView.builder(
                              controller: _scrollController,
                              scrollDirection: Axis.vertical,
                              itemBuilder: (BuildContext context, int index) {
                                final data = value[index];
                                final diff = index == 0
                                    ? value[index].rawValue!
                                    : value[index].rawValue! -
                                        value[index - 1].rawValue!;
                                var d = int.parse(diff.toString());
                                var e =
                                    '+${((d / (1000 * 60 * 60)) % 24).toInt()}:${((d / (1000 * 60)) % 60).toInt()}:${((d / 1000) % 60).toInt()}:${(d % 1000) ~/ 10}';
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Padding(
                                      padding: const EdgeInsets.all(6),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Text(
                                            '${index + 1}.  ${data.displayTime}',
                                            style: const TextStyle(
                                                fontSize: 18,
                                                fontFamily: 'Gentium',
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            e,
                                            style: const TextStyle(
                                                fontSize: 15,
                                                fontFamily: 'Helvetica',
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Divider(
                                      height: 1,
                                      color: Colors.black,
                                    )
                                  ],
                                );
                              },
                              itemCount: value.length,
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                  //Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (start == 0) {
                            _stopWatchTimer.onStartTimer();
                            setState(() {
                              start = 1;
                            });
                          } else {
                            _stopWatchTimer.onStopTimer();
                            setState(() {
                              start = 0;
                            });
                          }
                        },
                        child: Container(
                          height: 200,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                width: 2.0,
                                color: Colors.black,
                              )),
                          child: Icon(
                            start == 0 ? Icons.play_arrow : Icons.pause,
                            size: 45.0,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          if (start == 1) {
                            _stopWatchTimer.onAddLap();
                          } else {
                            _stopWatchTimer.onResetTimer();
                          }
                        },
                        child: Container(
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                width: 2.5,
                                color: Colors.black,
                              )),
                          child: Icon(
                            start == 1 ? Icons.flag : Icons.repeat,
                            size: 45.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

StreamBuilder<int> buildStreamBuilder(title, myStream) {
  return StreamBuilder<int>(
    stream: myStream,
    initialData: myStream.value,
    builder: (context, snap) {
      final value = snap.data;
      return Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(left: 8),
            child: Text(
              '$title :',
              style: const TextStyle(
                fontSize: 16,
                fontFamily: 'Gentium',
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: Text(
              value.toString(),
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontFamily: 'Gentium',
                  fontWeight: FontWeight.bold),
            ),
          ),
        ],
      );
    },
  );
}
