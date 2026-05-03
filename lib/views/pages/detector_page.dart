import 'dart:typed_data';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'package:flutter_tts/flutter_tts.dart';

class DetectorPage extends StatefulWidget {
  const DetectorPage({Key? key}) : super(key: key);

  @override
  State<DetectorPage> createState() => _DetectorPageState();
}

class _DetectorPageState extends State<DetectorPage>
    with SingleTickerProviderStateMixin {
  Interpreter? _interpreter;
  final picker = ImagePicker();

  Uint8List? _imageBytes;
  String _result = "";
  double _confidence = 0.0;
  bool _loading = false;
  String _statusMessage = "";

  final FlutterTts _tts = FlutterTts();
  AnimationController? _scanController;

  final List<String> _labels = [
    "no_tumor",
    "pituitary_tumor",
    "meningioma_tumor",
    "glioma_tumor"
  ];

  

  Widget _buildConfidenceBar(double value) {
  return Column(
    children: [
      const SizedBox(height: 10),

      // Confidence Text
      Text(
        "Confidence: ${value.toStringAsFixed(2)}%",
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),

      const SizedBox(height: 10),

      // Background bar
      Container(
        width: 260,
        height: 14,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Stack(
          children: [
            // Animated fill
            AnimatedContainer(
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOutCubic,
              width: (value / 100) * 260,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: const LinearGradient(
                  colors: [
                    Colors.greenAccent,
                    Colors.green,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withValues(alpha: 0.6),
                    blurRadius: 10,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

Color _getResultColor(String result) {
  if (result == "NO TUMOR") {
    return Colors.green;
  } else if (result == "Invalid Scan") {
    return const Color.fromARGB(255, 213, 222, 94);
  } else if (result.contains("GLIOMA")) {
    return Colors.redAccent;
  } else if (result.contains("MENINGIOMA")) {
    return Colors.deepPurple;
  } else if (result.contains("PITUITARY")) {
    return Colors.blue;
  } else {
    return Colors.red;
  }
}

  @override
  void initState() {
    super.initState();
    _loadModel();
    _initTTS();

    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
  }

  Future<void> _initTTS() async {
    await _tts.setLanguage("en-US");
    await _tts.setSpeechRate(0.45);
  }

  Future<void> _speak(String text) async {
    await _tts.stop();
    await _tts.speak(text);
  }

  @override
  void dispose() {
    _scanController?.dispose();
    _interpreter?.close();
    _tts.stop();
    super.dispose();
  }

  Future<void> _loadModel() async {
    try {
      _interpreter =
          await Interpreter.fromAsset('assets/model.tflite');
    } catch (e) {
      debugPrint("Model load error: $e");
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await picker.pickImage(source: source);
    if (pickedFile == null) return;

    final bytes = await pickedFile.readAsBytes();

    setState(() {
      _imageBytes = bytes;
      _loading = true;
      _result = "";
      _statusMessage = "Analyzing image...";
    });

    await Future.delayed(const Duration(seconds: 3));

    setState(() {
      _statusMessage = "Identifying tumor type...";
    });

    await Future.delayed(const Duration(seconds: 4));

    await _runInference(bytes);
  }

  Future<void> _runInference(Uint8List bytes) async {
    try {
      img.Image? image = img.decodeImage(bytes);
      img.Image resized =
          img.copyResize(image!, width: 150, height: 150);

      var input = Float32List(1 * 150 * 150 * 3);
      int index = 0;

      for (int y = 0; y < 150; y++) {
        for (int x = 0; x < 150; x++) {
          var pixel = resized.getPixel(x, y);

          input[index++] = pixel.r / 255.0;
          input[index++] = pixel.g / 255.0;
          input[index++] = pixel.b / 255.0;
        }
      }

      var output = List.filled(4, 0.0).reshape([1, 4]);

      _interpreter!.run(input.reshape([1, 150, 150, 3]), output);

      List<double> scores = output[0];
      double maxScore = scores.reduce((a, b) => a > b ? a : b);
      int maxIndex = scores.indexOf(maxScore);

      String finalResult;

      if (maxScore < 0.80) {
        finalResult = "Invalid Scan";
      } else {
        finalResult =
            _labels[maxIndex].replaceAll('_', ' ').toUpperCase();
      }
    

      // 🧠 DOCTOR ADVICE LOGIC (NO UI YET)
      String speechText;

      double confidenceValue;

      if (finalResult == "Invalid Scan") {
           confidenceValue = 0.0;
        } else {
          confidenceValue = maxScore * 100;
        }

      if (finalResult == "Invalid Scan") {
        speechText = "Scanning failed. Please upload a valid MRI scan";
      } else if (finalResult == "NO TUMOR") {
        speechText = "No tumor has been detected with ${confidenceValue.toStringAsFixed(1)} percent confidence. You are healthy. No medical attention required.";
      } else {
        speechText =
            "Possible $finalResult detected with ${confidenceValue.toStringAsFixed(1)} percent confidence. Please see your report below and consult a neurologist asap.";
      }


      setState(() {
        _result = finalResult;
        _confidence = confidenceValue;
        _loading = false;
        _statusMessage = "";
      });

      // 🔊 VOICE OUTPUT
      await _speak(speechText);

    } catch (e) {
      setState(() {
        _loading = false;
        _result = "ERROR";
      });
    }
  }

  void _showScanReport() async{
    showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pop(context); // close loading
        _showFinalReport();     // open your real report
      });

      return const AlertDialog(
        content: SizedBox(
          height: 120,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text("Generating Report..."),
              Text("Just a moment"),
            ],
          ),
        ),
      );
    },
  );
}

void _showFinalReport() {
  String riskLevel;
  String note;
  Color color;
  String cause;
  String symptoms;
  String treatment;
  String specialist;


 if (_result == "NO TUMOR") {
  cause = "No abnormal tumor activity detected.";
  symptoms = "No symptoms associated with tumor conditions.";
  treatment = "No treatment required.";
  specialist = "General Physician (if needed)";
} 
else if (_result == "Invalid Scan") {
  cause = "Not applicable.";
  symptoms = "Not applicable.";
  treatment = "Not applicable.";
  specialist = "Not applicable.";
} 
else if (_result.contains("GLIOMA")) {
  cause = "Uncontrolled glial cell growth in brain tissue.";
  symptoms = "Headache, nausea, vision problems, seizures.";
  treatment = "Surgery + Radiotherapy + Chemotherapy (based on severity)";
  specialist = "Neuro-oncologist / Neurosurgeon";
} 
else if (_result.contains("MENINGIOMA")) {
  cause = "Abnormal growth in meninges (brain lining).";
  symptoms = "Headache, hearing loss, memory issues.";
  treatment = "Surgical removal or monitoring.";
  specialist = "Neurosurgeon";
} 
else if (_result.contains("PITUITARY")) {
  cause = "Hormonal imbalance due to pituitary gland tumor.";
  symptoms = "Vision changes, hormonal imbalance, fatigue.";
  treatment = "Medication or minimally invasive surgery.";
  specialist = "Endocrinologist + Neurosurgeon";
} 
else {
  cause = "Abnormal brain cell activity detected.";
  symptoms = "Varies depending on tumor type.";
  treatment = "Further diagnostic evaluation required.";
  specialist = "Neurologist";
}

  if (_result == "NO TUMOR") {
    riskLevel = "NO RISK";
    note = "No abnormal tumor detected in the MRI scan.";
    color = Colors.green;
  } 
  else if (_result == "Invalid Scan") {
    riskLevel = "INVALID";
    note = "The uploaded image is not a valid MRI scan.";
    color = Colors.orange;
  } 
  else if (_confidence >= 80) {
    riskLevel = "HIGH RISK";
    note = "Strong indicators of $_result detected. Immediate consultation recommended.";
    color = Colors.red;
  } 
  else if(_confidence >=50 && _confidence < 80){
    riskLevel = "MODERATE RISK";
    note = "Possible $_result detected. Further medical review advised.";
    color = Colors.amber;
  }
  else {
    riskLevel = "LOW RISK";
    note = "Some signs of $_result detected, but confidence is low. Monitor symptoms and consult if concerned.";
    color = Colors.yellow;
  }

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        title: Text(
          "SCAN REPORT",
          style: TextStyle(color: color, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Finding: $_result"),
            const SizedBox(height: 5),
            Text("Confidence: ${_confidence.toStringAsFixed(2)}%"),
            const SizedBox(height: 5),
            Text(
              "Risk Level: $riskLevel",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),

            const SizedBox(height: 10),
            Text(note),

            const SizedBox(height: 15),

            const Text(
              "Cause of Occurrence:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(cause),

            const SizedBox(height: 10),
            const Text(
              "Symptoms:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(symptoms),

            const SizedBox(height: 15),
            const Text(
              "Recommended Treatment:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(treatment),

            const SizedBox(height: 10),

            const Text(
              "Specialist to Consult:",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(specialist),
          ],
        ),

        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Close"),
          )
        ],
      );
    },
  );
}

  @override
 @override
@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: const Color(0xFFF8F9FA),
    appBar: AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      centerTitle: true,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/logo.png',
            height: 34,
            width: 30,
          ),
          const SizedBox(width: 8),
          const Text(
            "Brain Tumor Detector",
            style: TextStyle(
              color: Color(0xFF388E3C),
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ),

    body: Column(
      children: [
        const SizedBox(height: 30),

        Center(
          child: Stack(
            children: [
              Container(
                width: 300,
                height: 240,
                decoration: BoxDecoration(
                  color: const Color(0xFF121212),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: _imageBytes != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.memory(
                          _imageBytes!,
                          fit: BoxFit.contain,
                        ),
                      )
                    : Icon(
                        Icons.image_outlined,
                        size: 150,
                        color: Colors.white.withValues(alpha: 128),
                      ),
              ),

              if (_loading && _scanController != null)
                AnimatedBuilder(
                  animation: _scanController!,
                  builder: (context, child) {
                    return Positioned(
                      top: _scanController!.value * 280,
                      left: 10,
                      right: 10,
                      child: Container(
                        height: 3,
                        color: Colors.greenAccent,
                      ),
                    );
                  },
                ),
            ],
          ),
        ),

        // ✅ ONLY ADDITION (WARNING TEXT)
        if (_imageBytes == null)
          const Padding(
            padding: EdgeInsets.only(top: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange,
                  size: 24,
                ),
                SizedBox(width: 8),
                Text(
                  "Please upload an MRI image",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

        const SizedBox(height: 25),

        if (_loading) ...[
          const CircularProgressIndicator(),
          const SizedBox(height: 10),
          Text(_statusMessage),
        ],

        if (!_loading && _result.isNotEmpty) ...[
          Text(
            "RESULT = $_result",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: _getResultColor(_result),
            ),
          ),
          const SizedBox(height: 5),
            _buildConfidenceBar(_confidence),
          
          const SizedBox(height: 25),

          ElevatedButton.icon(
              onPressed: _showScanReport,
              icon: const Icon(Icons.description),
              label: const Text(
                "Scan Report",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 33, 139, 210),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
       ],

        const Spacer(),

        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Row(
            children: [
              _buildActionButton(
                icon: Icons.camera_alt_outlined,
                label: "Pick From Camera",
                onTap: () => _pickImage(ImageSource.camera),
              ),
              const SizedBox(width: 20),
              _buildActionButton(
                icon: Icons.photo_library_outlined,
                label: "Pick From Gallery",
                onTap: () => _pickImage(ImageSource.gallery),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Material(
        color: const Color(0xFF4CAF50),
        borderRadius: BorderRadius.circular(15),
        elevation: 3,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 25),
            child: Column(
              children: [
                Icon(icon, color: Colors.white, size: 50),
                const SizedBox(height: 10),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}