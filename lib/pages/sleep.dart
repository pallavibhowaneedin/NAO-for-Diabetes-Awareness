import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'connected.dart';
import 'edit_profile.dart';
import 'settings.dart';

class Sleep extends StatelessWidget {
  const Sleep({super.key});

  final String localHost = 'http://172.27.160.1:5000';

  Future<void> connectToNao(BuildContext context) async {
    try {
      print("Attempting to connect to NAO robot...");
      final response = await http.get(Uri.parse('$localHost/connect_nao'));

      print("Response status: ${response.statusCode}");
      if (response.statusCode == 200) {
        var jsonResponse = jsonDecode(response.body);
        print("JSON response: $jsonResponse");
        if (jsonResponse['status'] == 'connected') {
          // Navigate to the connected screen
          if (context.mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const Connected()),
            );
          }
        } else {
          print("Connection failed. Status: ${jsonResponse['status']}");
          if (context.mounted) {
            _showErrorDialog(context, 'Failed to connect to NAO robot.');
          }
        }
      } else {
        print("Server error: ${response.statusCode}");
        if (context.mounted) {
          _showErrorDialog(context, 'Server error: ${response.statusCode}');
        }
      }
    } catch (e) {
      print("Connection error: $e");
      if (context.mounted) {
        _showErrorDialog(context, 'Connection error: $e');
      }
    }
  }



  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Erreur'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[Color(0xFF00C6FF), Color(0xFF0072FF)],
            stops: <double>[0.5, 1],
          ),
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: SvgPicture.asset(
                        'assets/vectors/user_square_x2.svg',
                        width: 40,
                        height: 40,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const EditProfile()),
                        );
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.settings),
                      iconSize: 40, 
                      color: Colors.white, 
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const Settings()),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'EN TRAIN DE DORMIR...',
                  style: GoogleFonts.alatsi(
                    fontWeight: FontWeight.w600,
                    fontSize: 28,
                    color: const Color(0xE80F4C7D),
                  ),
                ),
                const SizedBox(height: 30),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: SvgPicture.asset(
                        'assets/vectors/rectangle_12_x2.svg',
                        width: 254,
                        height: 269,
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      child: SizedBox(
                        width: 254,
                        height: 200,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Container(
                              width: 200,
                              height: 200,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                image: const DecorationImage(
                                  fit: BoxFit.cover,
                                  image: AssetImage('assets/images/rectangle_11.png'),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  "Veuillez vous connecter pour utilier l'application!",
                  textAlign: TextAlign.center,
                  style: GoogleFonts.alatsi(
                    fontWeight: FontWeight.w500,
                    fontSize: 24,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 30),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(5), 
                      child: Container(
                        width: 300, 
                        height: 450, 
                        color: Colors.white.withOpacity(0.1),
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          'Pour se connecter au robot NAO :\n\n'
                          '1. Pré-requis :\n'
                          '   - Terminal, Robot NAO\n'
                          '2. Connexion :\n'
                          '   - Appuyez sur le bouton sur la poitrine de NAO pour démarrer le robot, appuyez une nouvelle fois pour connaître l\'adresse IP de NAO\n'
                          '   - Ouvrez le Terminal : Ping l\'adresse IP de NAO\n'
                          '   - Si la connexion est réussie, vous êtes connecté.\n'
                          '3. Entrez dans le dossier de connexion et exécutez le script python (connect.py).\n'
                          '4. Utilisez l\'application !',
                          style: GoogleFonts.alatsi(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            color: const Color(0xE80F4C7D),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  width: 200,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF000046), Color(0xFF1CB5E0)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: ElevatedButton(
                    onPressed: () => connectToNao(context), 
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent, 
                      shadowColor: Colors.transparent, 
                    ),
                    child: Text(
                      'Connexion réussie ?',
                      style: GoogleFonts.alatsi(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20), 
              ],
            ),
          ),
        ),
      ),
    );
  }
}
