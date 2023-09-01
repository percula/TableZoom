import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Table Zoom',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Table Zoom'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _rowCount = 200;
  final _columnCount = 200;

  double _scaleFactor = 1.0;
  double _baseScaleFactor = 1.0;

  double cellWidth() => 100.0 * (_scaleFactor);

  late final ScaleGestureRecognizer recognizer;

  @override
  void initState() {
    super.initState();
    recognizer = ScaleGestureRecognizer()
      ..onStart = _onScaleStart
      ..onUpdate = _onScaleUpdate
      ..onEnd = _onScaleEnd;
  }

  void _onScaleStart(ScaleStartDetails details) {
    debugPrint('onStart');
    _baseScaleFactor = _scaleFactor;
  }

  void _onScaleUpdate(ScaleUpdateDetails details) {
    debugPrint('onUpdate');
    setState(() {
      _scaleFactor = _baseScaleFactor * details.scale;
    });
  }

  void _onScaleEnd(ScaleEndDetails details) {
    debugPrint('onEnd');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 0),
        // child: Listener(
        // onPointerDown: recognizer.addPointer,
        // onPointerPanZoomStart: recognizer.addPointerPanZoom,
        child: RawGestureDetector(
          gestures: <Type, GestureRecognizerFactory>{
            MyScaleGestureRecognizer: GestureRecognizerFactoryWithHandlers<MyScaleGestureRecognizer>(
              () => MyScaleGestureRecognizer(),
              (ScaleGestureRecognizer t) {
                t.onStart = _onScaleStart;
                t.onUpdate = _onScaleUpdate;
              },
            ),
          },
          child: TableView.builder(
            diagonalDragBehavior: DiagonalDragBehavior.free,
            cellBuilder: _buildCell,
            columnCount: _columnCount,
            columnBuilder: _buildColumnSpan,
            rowCount: _rowCount,
            rowBuilder: _buildRowSpan,
            // ),
          ),
        ),
      ),
    );
  }

  Widget _buildCell(BuildContext context, TableVicinity vicinity) {
    return Center(
      child: Text('C: ${vicinity.column}, R: ${vicinity.row}'),
    );
  }

  TableSpan _buildColumnSpan(int index) {
    const TableSpanDecoration decoration = TableSpanDecoration(
      border: TableSpanBorder(
        trailing: BorderSide(),
      ),
    );

    return TableSpan(
      foregroundDecoration: decoration,
      extent: FixedTableSpanExtent(cellWidth()),
      onEnter: (_) => print('Entered column $index'),
      // recognizerFactories: <Type, GestureRecognizerFactory>{
      //   ScaleGestureRecognizer:
      //       GestureRecognizerFactoryWithHandlers<ScaleGestureRecognizer>(
      //             () => ScaleGestureRecognizer(),
      //             (ScaleGestureRecognizer t) {
      //               t.onStart = _onScaleStart;
      //               t.onUpdate = _onScaleUpdate;
      //             },
      //       ),
      // },
    );
  }

  TableSpan _buildRowSpan(int index) {
    final TableSpanDecoration decoration = TableSpanDecoration(
      color: index.isEven ? Colors.purple[100] : null,
      border: const TableSpanBorder(
        trailing: BorderSide(
          width: 3,
        ),
      ),
    );

    return TableSpan(
      backgroundDecoration: decoration,
      extent: FixedTableSpanExtent(cellWidth()),
      // recognizerFactories: <Type, GestureRecognizerFactory>{
      //   ScaleGestureRecognizer:
      //   GestureRecognizerFactoryWithHandlers<ScaleGestureRecognizer>(
      //         () => ScaleGestureRecognizer(),
      //         (ScaleGestureRecognizer t) {
      //           t.onStart = _onScaleStart;
      //           t.onUpdate = _onScaleUpdate;
      //     },
      //   ),
      // },
    );
  }
}

// Custom Gesture Recognizer.
// rejectGesture() is overridden. When a gesture is rejected, this is the function that is called. By default, it disposes of the
// Recognizer and runs clean up. However we modified it so that instead the Recognizer is disposed of, it is actually manually added.
// The result is instead you have one Recognizer winning the Arena, you have two. It is a win-win.
class MyScaleGestureRecognizer extends ScaleGestureRecognizer {
  @override
  void rejectGesture(int pointer) {
    acceptGesture(pointer);
  }
}