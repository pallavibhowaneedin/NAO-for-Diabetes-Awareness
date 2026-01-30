import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/services.dart';
import 'dart:convert'; // Import for JSON decoding
import 'package:http/http.dart' as http; // Import for making HTTP requests
import 'package:nao/pages/settings.dart'; // Import the Settings page
import 'package:nao/pages/edit_profile.dart'; // Import the EditProfile page
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

class Connected extends StatefulWidget {
  const Connected({super.key});

  @override
  _ConnectedState createState() => _ConnectedState();
}

class _ConnectedState extends State<Connected> {
  int _currentQuestionIndex = 0;
  String localHost = 'http://172.27.160.1:5000';
  String _generatedText = "";
  List<Map<String, String>> _questions = [];
  bool _isFirstSend = true; // Track if it's the first time the SEND button is pressed
  final TextEditingController _textController = TextEditingController();

  // Speech recognition properties
  stt.SpeechToText? _speech;
  bool _isListening = false;
  String _recognizedText = "Press the button and start speaking";  // Declare _recognizedText
  final String _response = ''; // Hold the quiz answer response

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _checkConnection();
    _loadQuestions();
    requestMicrophonePermission();  // Request microphone permission when the app starts
  }

  Future<void> requestMicrophonePermission() async {
    var status = await Permission.microphone.request();
    if (status.isGranted) {
      print("Microphone permission granted.");
    } else {
      print("Microphone permission denied.");
    }
  }

  void _startListening() async {
    print("Initializing speech recognition...");

    bool available = await _speech!.initialize(
      onStatus: (status) {
        print('Speech status: $status');
        if (status == 'notListening' || status == 'done') {
          setState(() => _isListening = false);
        }
      },
      onError: (errorNotification) {
        print('Error: $errorNotification');
        if (errorNotification.errorMsg == 'error_speech_timeout') {
          print("Speech timeout occurred. Restarting listening...");
          _startListening();  // Optionally restart listening if there's a timeout
        }
      },
    );

    if (available) {
      print("Speech recognition is available. Starting to listen...");
      setState(() => _isListening = true);

      _speech!.listen(
        onResult: (result) {
          print("Recognition result received");
          setState(() {
            _recognizedText = result.recognizedWords;
          });
          if (result.finalResult) {
            print("Final recognized text: $_recognizedText");
          } else {
            print("Interim recognized text: $_recognizedText");
          }
        },
        listenMode: stt.ListenMode.dictation,
        partialResults: true,
        localeId: 'en_US',
        listenFor: const Duration(minutes: 2),
        pauseFor: const Duration(minutes: 2),
      );
    } else {
      print("Speech recognition is not available.");
      setState(() => _isListening = false);
    }
  }




  void _stopListening() {
    setState(() => _isListening = false);
    _speech!.stop();
    print("Stopped listening.");
  }

  Future<void> _checkConnection() async {
    try {
      final response = await http.get(Uri.parse('$localHost/check_connection'));
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        if (jsonResponse['status'] != 'connected') {
          _showErrorDialog('NAO robot is not connected. Please reconnect.');
        }
      } else {
        _showErrorDialog('Failed to check NAO robot connection status.');
      }
    } catch (e) {
      _showErrorDialog('Connection error: $e');
    }
  }

  Future<void> _loadQuestions() async {
    try {
      String data = await rootBundle.loadString('assets/questions.json');
      final jsonResult = json.decode(data);

      setState(() {
        _questions = (jsonResult['questions'] as List<dynamic>)
            .map((q) => {
          "question": q['question'].toString(),
          "answer": q['answer'].toString()
        }).toList();

        if (_questions.isNotEmpty) {
          _generatedText =
          "1. Question:\n${_questions[0]['question']}\n\nRéponse:\n${_questions[0]['answer']}";
        }
      });
    } catch (e) {
      _showErrorDialog("Failed to load questions.");
    }
  }

  Future<void> _sendQuestionsToNao() async {
    if (_isFirstSend) {
      final introResponse = await http.post(
        Uri.parse('$localHost/send_text'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"text": "Time to take a quiz. Let's play!"}),
      );

      if (introResponse.statusCode == 200) {
        print("Intro message sent to NAO.");
        _isFirstSend = false;
      } else {
        _showErrorDialog('Failed to send intro message to NAO.');
        return;
      }

      await Future.delayed(const Duration(seconds: 3));
    }

    final response = await http.post(
      Uri.parse('$localHost/send_text'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"text": _questions[_currentQuestionIndex]['question']}),
    );

    if (response.statusCode == 200) {
      print("Question sent to NAO: ${_questions[_currentQuestionIndex]['question']}");
    } else {
      _showErrorDialog('Failed to send question to NAO.');
    }
  }

  Future<void> _sendTextToNao() async {
    final response = await http.post(
      Uri.parse('$localHost/send_text'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"text": _textController.text}),
    );

    if (response.statusCode == 200) {
      print("Text sent to NAO.");
    } else {
      _showErrorDialog('Failed to send text to NAO.');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF00C6FF), Color(0xFF0072FF)],
            stops: [0.0, 1.0],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                const SizedBox(height: 74),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    IconButton(
                      icon: SvgPicture.asset(
                        'assets/vectors/user_square_1_x2.svg',
                        width: 40,
                        height: 40,
                      ),
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const EditProfile()),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings, color: Colors.white),
                      iconSize: 40,
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Settings()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFE9CEDB), Color(0xFFE6F7FF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    width: 305,
                    height: 313,
                    child: Column(
                      children: <Widget>[
                        const SizedBox(height: 10),
                        Text(
                          "Bonjour. Je suis NAO!",
                          style: GoogleFonts.alatsi(
                            fontWeight: FontWeight.w400,
                            fontSize: 20,
                            height: 1.2,
                            letterSpacing: -0.3,
                            color: const Color(0xFF0F4C7D),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Image.asset(
                              'assets/images/nao_turned_on_1.png',
                              fit: BoxFit.cover,
                              width: double.infinity,
                              alignment: Alignment.bottomCenter,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  "Dit moi quoi dire :",
                  style: GoogleFonts.alatsi(
                    fontWeight: FontWeight.w400,
                    fontSize: 20,
                    height: 1.2,
                    letterSpacing: -0.3,
                    color: const Color(0xFFFFFFFF),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD9D9D9),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: TextField(
                    controller: _textController,
                    minLines: 1,
                    maxLines: null,
                    expands: false,
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: "Entrez votre texte...",
                      hintStyle: GoogleFonts.alatsi(
                        color: Colors.grey,
                      ),
                    ),
                    style: GoogleFonts.alatsi(
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: 133,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF72C6FF), Color(0xFF004E8F)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: ElevatedButton(
                    onPressed: _sendTextToNao,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: Text(
                      "ENVOI",
                      style: GoogleFonts.alatsi(
                        fontWeight: FontWeight.w400,
                        fontSize: 20,
                        height: 1.2,
                        letterSpacing: -0.3,
                        color: const Color(0xFFFFFFFF),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: 250,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF72C6FF), Color(0xFF004E8F)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: ElevatedButton(
                    onPressed: _isListening ? _stopListening : _startListening,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                    child: Text(
                      _isListening ? "Arrêter d'écouter" : "Commencer à écouter",
                      style: GoogleFonts.alatsi(
                        fontWeight: FontWeight.w400,
                        fontSize: 18,
                        letterSpacing: -0.3,
                        color: const Color(0xFFFFFFFF),
                      ),
                    ),
                  ),


                ),
                const SizedBox(height: 30),
                Text(
                  "Questions",
                  style: GoogleFonts.alatsi(
                    fontWeight: FontWeight.w400,
                    fontSize: 20,
                    height: 1.2,
                    letterSpacing: -0.3,
                    color: const Color(0xFF0F4C7D),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFFE9CEDB), Color(0xFFE6F7FF)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    width: double.infinity,
                    constraints: const BoxConstraints(minHeight: 400), // Increased height
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start, // Align text to start
                      children: [
                        Text(
                          _generatedText.isNotEmpty
                              ? _generatedText
                              : "Aucune questions.",
                          style: GoogleFonts.alatsi(
                            fontSize: 18,
                            color: const Color(0xFF0F4C7D),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                child: ElevatedButton(
                                  onPressed: _currentQuestionIndex > 0
                                      ? () {
                                    setState(() {
                                      _currentQuestionIndex--;
                                      _generatedText =
                                      "${_currentQuestionIndex + 1}. Question:\n${_questions[_currentQuestionIndex]['question']}\n\nRéponse:\n${_questions[_currentQuestionIndex]['answer']}";
                                    });
                                  }
                                      : null, // Disable if at the first question
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    backgroundColor: Colors.blueAccent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                  ),
                                  child: Text(
                                    "Avant",
                                    style: GoogleFonts.alatsi(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                child: ElevatedButton(
                                  onPressed: () async {
                                    // Make NAO say "C'était une mauvaise réponse. Essayons encore"
                                    final response = await http.post(
                                      Uri.parse('$localHost/send_text'),
                                      headers: {"Content-Type": "application/json"},
                                      body: jsonEncode({
                                        "text": "C'était une mauvaise réponse. Essayons encore."
                                      }),
                                    );

                                    if (response.statusCode == 200) {
                                      print("Incorrect response message sent to NAO.");
                                    } else {
                                      _showErrorDialog(
                                          'Failed to send incorrect response message to NAO.');
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    backgroundColor: Colors.orangeAccent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                  ),
                                  child: Text(
                                    "Essaie encore",
                                    style: GoogleFonts.alatsi(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                                child: ElevatedButton(
                                  onPressed: _currentQuestionIndex <
                                      _questions.length - 1
                                      ? () async {
                                    // Make NAO say "Bonne réponse ! Passons à la question suivante"
                                    final response = await http.post(
                                      Uri.parse(
                                          '$localHost/send_text'),
                                      headers: {
                                        "Content-Type": "application/json"
                                      },
                                      body: jsonEncode({
                                        "text":
                                        "Bonne réponse ! Passons à la question suivante."
                                      }),
                                    );

                                    if (response.statusCode == 200) {
                                      print(
                                          "Transition message sent to NAO.");

                                      // Move to the next question
                                      setState(() {
                                        _currentQuestionIndex++;
                                        _generatedText =
                                        "${_currentQuestionIndex + 1}. Question:\n${_questions[_currentQuestionIndex]['question']}\n\nRéponse:\n${_questions[_currentQuestionIndex]['answer']}";
                                      });

                                      // Send only the next question to NAO
                                      await http.post(
                                        Uri.parse(
                                            'http://172.27.160.1:5000/send_text'),
                                        headers: {
                                          "Content-Type": "application/json"
                                        },
                                        body: jsonEncode({
                                          "text": _questions[
                                          _currentQuestionIndex]
                                          ['question']
                                        }),
                                      );
                                    } else {
                                      _showErrorDialog(
                                          'Failed to send transition message to NAO.');
                                    }
                                  }
                                      : () async {
                                    // If it's the last question, send the final message to NAO
                                    final response = await http.post(
                                      Uri.parse(
                                          '$localHost/send_text'),
                                      headers: {
                                        "Content-Type": "application/json"
                                      },
                                      body: jsonEncode({
                                        "text": "Bien joué. Le quiz est terminé."
                                      }),
                                    );

                                    if (response.statusCode == 200) {
                                      print("Final message sent to NAO.");
                                      setState(() {
                                        _generatedText =
                                        "Bien joué. Le quiz est terminé.";
                                      });
                                    } else {
                                      _showErrorDialog(
                                          'Failed to send final message to NAO.');
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                    backgroundColor: Colors.blueAccent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(24),
                                    ),
                                  ),
                                  child: Text(
                                    "Prochain",
                                    style: GoogleFonts.alatsi(
                                      fontWeight: FontWeight.w400,
                                      fontSize: 16,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Align(
                          alignment: Alignment.center, // Center the button
                          child: Container(
                            width: 133,
                            height: 48,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF72C6FF), Color(0xFF004E8F)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: ElevatedButton(
                              onPressed: _sendQuestionsToNao, // Call the new function
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                              ),
                              child: Text(
                                "ENVOI",
                                style: GoogleFonts.alatsi(
                                  fontWeight: FontWeight.w400,
                                  fontSize: 20,
                                  height: 1.2,
                                  letterSpacing: -0.3,
                                  color: const Color(0xFFFFFFFF),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
