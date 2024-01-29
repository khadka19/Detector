import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:object_detection/home_page.dart';
import 'package:object_detection/main.dart';

List<CameraDescription>? cameras;

Future<Null> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {
    print('Error: $e.code\nError Message: $e.message');
  }
  runApp(new MyApp());
}
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required String title});

  @override
  // ignore: library_private_types_in_public_api
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  
 String baseURL = "BaseURL";
 String loggedIn="encryptedCompanyName";

  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  @override
  void initState() {
    super.initState();
     _initialize();
    
  }

  Future<void> _initialize()  async {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(_animationController);

    _animationController.forward();
Timer(Duration(seconds: 2), () async{ 
  Navigator.push(context, MaterialPageRoute(builder: (context)=>MyHomePage(title: "Detection" , cameras: [],)));
});
    
  }


  @override
  Widget build(BuildContext context) {
    
    var screenHeight=MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(""),

          ScaleTransition(
            scale: _scaleAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SizedBox(
                height: screenHeight*0.2,
                width: double.maxFinite,
                child: 
                Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: Image.asset(
                    "assets/H.png",
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(bottom: 50),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: const Text(
                "Powered By : Hari Jung Khadka",
                style: TextStyle(fontSize: 14, color: Color.fromARGB(255, 197, 119, 3)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }
}