import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import 'package:http/http.dart' as http;
import 'package:image/image.dart' as img;
import '../services/firebase_service.dart';
import '../widgets/custom_button.dart';
import '../widgets/text_field.dart';
import '../model/user_model.dart';
import '../providers/user_provider.dart';
import '../utils/helpers.dart';
import 'home_screen.dart';
import 'cosmic_background.dart';
import 'cosmic_progress_bar.dart';
import 'animated_success.dart';
import 'animated_failure.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  XFile? _documentImage;
  XFile? _liveImage;
  bool _isMatching = false;
  bool _isRegistering = false;
  String? _dob;
  int? _matchedAge;
  String _selectedDocType = 'Aadhaar';
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  late AnimationController _progressController;
  int _currentStep = 0;

  final String aadhaarApiUrl = 'http://3.219.45.128/api/verify/aadhaar/';
  final String panApiUrl = 'http://3.219.45.128/api/verify/pan/';

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOutBack),
    );
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _fadeController.forward();
    _scaleController.repeat(reverse: true); // For fingerprint pulse effect
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _fadeController.dispose();
    _scaleController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  int _extractAgeFromDOB(String dob) {
    try {
      final parts = dob.split('/');
      if (parts.length == 3) {
        final day = int.parse(parts[0]);
        final month = int.parse(parts[1]);
        final year = int.parse(parts[2]);
        final birthDate = DateTime(year, month, day);
        final now = DateTime.now();
        int age = now.year - birthDate.year;
        if (now.month < birthDate.month ||
            (now.month == birthDate.month && now.day < birthDate.day)) {
          age--;
        }
        return age;
      }
    } catch (_) {}
    return 0;
  }

  Future<void> _pickDocumentImage() async {
    final status =
        kIsWeb ? PermissionStatus.granted : await Permission.photos.request();
    if (status.isGranted) {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 100,
        maxWidth: 1920,
        maxHeight: 1080,
      );
      if (pickedFile != null) {
        setState(() {
          _documentImage = pickedFile;
          _currentStep = _currentStep < 3 ? 3 : _currentStep;
          _progressController.forward();
        });
        if (kDebugMode) {
          print('Document image selected: ${pickedFile.path}');
        }
        _scaleController.forward(from: 0.0);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gallery permission denied')),
      );
    }
  }

  Future<void> _pickLiveImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: kIsWeb ? ImageSource.gallery : ImageSource.camera,
      imageQuality: 100,
      maxWidth: 1920,
      maxHeight: 1080,
    );
    if (pickedFile != null) {
      setState(() {
        _liveImage = pickedFile;
        _currentStep = _currentStep < 4 ? 4 : _currentStep;
        _progressController.forward();
      });
      if (kDebugMode) {
        print('Live image selected: ${pickedFile.path}');
      }
      _scaleController.forward(from: 0.0);
    } else if (!kIsWeb) {
      final status = await Permission.camera.request();
      if (!status.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Camera permission denied')),
        );
      }
    }
  }

  Future<File> _preprocessImage(XFile imageFile) async {
    final file = File(imageFile.path);
    if (!await file.exists()) {
      throw Exception('Image file does not exist: ${imageFile.path}');
    }

    final imageBytes = await file.readAsBytes();
    img.Image? image = img.decodeImage(imageBytes);
    if (image == null) {
      throw Exception('Failed to decode image: ${imageFile.path}');
    }

    image = img.bakeOrientation(image);

    final tempDir = Directory.systemTemp;
    final tempFile = File('${tempDir.path}/${imageFile.name}.jpg');
    await tempFile.writeAsBytes(img.encodeJpg(image, quality: 100));

    return tempFile;
  }

  Future<void> _matchImages() async {
    if (_documentImage == null || _liveImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload both images')),
      );
      return;
    }

    setState(() {
      _isMatching = true;
      _currentStep = _currentStep < 5 ? 5 : _currentStep;
      _progressController.forward();
    });

    try {
      final apiUrl = _selectedDocType == 'Aadhaar' ? aadhaarApiUrl : panApiUrl;
      final uri = Uri.parse(apiUrl);
      final request = http.MultipartRequest('POST', uri);

      final documentField =
          _selectedDocType == 'Aadhaar' ? 'aadhaar_image' : 'pan_image';

      final documentFile = await _preprocessImage(_documentImage!);
      final selfieFile = await _preprocessImage(_liveImage!);

      request.files.add(
        await http.MultipartFile.fromPath(documentField, documentFile.path),
      );
      request.files.add(
        await http.MultipartFile.fromPath('selfie_image', selfieFile.path),
      );
      request.headers['Accept'] = 'application/json';

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 50),
      );
      final response = await http.Response.fromStream(streamedResponse);

      if (kDebugMode) {
        print('API response: ${response.statusCode}, body: ${response.body}');
      }

      if (response.statusCode != 200) {
        throw Exception('Server error: ${response.statusCode}');
      }

      final Map<String, dynamic> data = jsonDecode(response.body);
      if (data['verified'] == true) {
        setState(() {
          _dob = data['dob'];
          _matchedAge = _extractAgeFromDOB(_dob!);
          _currentStep = _currentStep < 6 ? 6 : _currentStep;
          _progressController.forward();
        });
        showDialog(
          context: context,
          builder: (_) => AnimatedSuccess(age: _matchedAge!),
        );
      } else {
        showDialog(
          context: context,
          builder:
              (_) =>
                  AnimatedFailure(message: data['message'] ?? 'Unknown error'),
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error in _matchImages: $e');
      }
      showDialog(
        context: context,
        builder: (_) => AnimatedFailure(message: 'Error: $e'),
      );
    }

    setState(() => _isMatching = false);
  }

  Future<void> _register() async {
    if (_formKey.currentState!.validate() &&
        _matchedAge != null &&
        _liveImage != null) {
      setState(() {
        _isRegistering = true;
        _currentStep = _currentStep < 7 ? 7 : _currentStep;
        _progressController.forward();
      });
      try {
        final imageFile = File(_liveImage!.path);
        final bytes = await imageFile.readAsBytes();
        final imageUrl = 'data:image/jpeg;base64,${base64Encode(bytes)}';

        final user = UserModel(
          id: const Uuid().v4(),
          name: _nameController.text,
          email: _emailController.text,
          password: _passwordController.text,
          age: _matchedAge,
          imageUrl: imageUrl,
        );

        await FirebaseService().registerUser(user, imageFile);
        Provider.of<UserProvider>(context, listen: false).setUser(user);
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const HomeScreen(),
            transitionsBuilder: (_, animation, __, child) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(1.0, 0.0),
                  end: Offset.zero,
                ).animate(
                  CurvedAnimation(parent: animation, curve: Curves.easeInOut),
                ),
                child: child,
              );
            },
          ),
        );
      } catch (e) {
        if (kDebugMode) {
          print('Error in _register: $e');
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
      setState(() => _isRegistering = false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Complete form and match images first')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Initiate Identity Protocol',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(
                blurRadius: 10.0,
                color: Colors.cyanAccent,
                offset: Offset(0, 0),
              ),
            ],
          ),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Stack(
        children: [
          const CosmicBackground(),
          Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                colors: [Colors.transparent, Colors.black.withOpacity(0.7)],
                radius: 1.5,
                center: Alignment.center,
              ),
            ),
          ),
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    CosmicProgressBar(
                      currentStep: _currentStep,
                      totalSteps: 7,
                      controller: _progressController,
                    ),
                    const SizedBox(height: 16),
                    AnimatedBuilder(
                      animation: _scaleAnimation,
                      builder:
                          (context, child) => Transform.scale(
                            scale: _scaleAnimation.value,
                            child: child,
                          ),
                      child: DropdownButtonFormField<String>(
                        value: _selectedDocType,
                        decoration: InputDecoration(
                          labelText: 'Select Document Type',
                          labelStyle: const TextStyle(color: Colors.white70),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.1),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Colors.cyan,
                              width: 2,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Colors.cyan,
                              width: 2,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: Colors.cyanAccent,
                              width: 3,
                            ),
                          ),
                        ),
                        dropdownColor: Colors.black87,
                        items: const [
                          DropdownMenuItem(
                            value: 'Aadhaar',
                            child: Text(
                              'Aadhaar',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          DropdownMenuItem(
                            value: 'PAN',
                            child: Text(
                              'PAN',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedDocType = value;
                              _currentStep =
                                  _currentStep < 1 ? 1 : _currentStep;
                              _progressController.forward();
                            });
                            _scaleController.forward(from: 0.0);
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    AnimatedBuilder(
                      animation: _scaleAnimation,
                      builder:
                          (context, child) => Transform.scale(
                            scale: _scaleAnimation.value,
                            child: child,
                          ),
                      child: CustomTextField(
                        label: 'Name',
                        controller: _nameController,
                        validator: Helpers.validateName,
                      ),
                    ),
                    const SizedBox(height: 16),
                    AnimatedBuilder(
                      animation: _scaleAnimation,
                      builder:
                          (context, child) => Transform.scale(
                            scale: _scaleAnimation.value,
                            child: child,
                          ),
                      child: CustomTextField(
                        label: 'Email',
                        controller: _emailController,
                        validator: Helpers.validateEmail,
                      ),
                    ),
                    const SizedBox(height: 16),
                    AnimatedBuilder(
                      animation: _scaleAnimation,
                      builder:
                          (context, child) => Transform.scale(
                            scale: _scaleAnimation.value,
                            child: child,
                          ),
                      child: CustomTextField(
                        label: 'Password',
                        controller: _passwordController,
                        obscureText: true,
                        validator: Helpers.validatePassword,
                      ),
                    ),
                    const SizedBox(height: 16),
                    AnimatedBuilder(
                      animation: _scaleAnimation,
                      builder:
                          (context, child) => Transform.scale(
                            scale: _scaleAnimation.value,
                            child: child,
                          ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                decoration: const BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.cyanAccent,
                                      blurRadius: 5,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: const Icon(
                                  Icons.document_scanner,
                                  color: Colors.white,
                                  size: 24.0,
                                ),
                              ),
                              const SizedBox(width: 8),
                              CustomButton(
                                text: 'Scan $_selectedDocType',
                                onPressed: () {
                                  if (kDebugMode) {
                                    print(
                                      'Scan $_selectedDocType button tapped',
                                    );
                                  }
                                  _pickDocumentImage();
                                },
                              ),
                            ],
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                decoration: const BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.cyanAccent,
                                      blurRadius: 5,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: AnimatedBuilder(
                                  animation: _scaleController,
                                  builder:
                                      (context, child) => Transform.scale(
                                        scale:
                                            0.9 +
                                            0.2 *
                                                (0.5 *
                                                    (1 +
                                                        sin(
                                                          _scaleController
                                                                  .value *
                                                              2 *
                                                              pi,
                                                        ))),
                                        child: const Icon(
                                          Icons.fingerprint,
                                          color: Colors.cyanAccent,
                                          size: 24.0,
                                        ),
                                      ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              CustomButton(
                                text: 'Authorize Biometrics',
                                onPressed: () {
                                  if (kDebugMode) {
                                    print('Authorize Biometrics button tapped');
                                  }
                                  _pickLiveImage();
                                },
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_documentImage != null)
                      AnimatedBuilder(
                        animation: _scaleAnimation,
                        builder:
                            (context, child) => Transform.scale(
                              scale: _scaleAnimation.value,
                              child: child,
                            ),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: LinearGradient(
                              colors: [
                                Colors.cyan.withOpacity(0.3),
                                Colors.blue.withOpacity(0.3),
                              ],
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.cyanAccent,
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: Text(
                            '$_selectedDocType Scanned',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    if (_liveImage != null)
                      AnimatedBuilder(
                        animation: _scaleAnimation,
                        builder:
                            (context, child) => Transform.scale(
                              scale: _scaleAnimation.value,
                              child: child,
                            ),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: LinearGradient(
                              colors: [
                                Colors.cyan.withOpacity(0.3),
                                Colors.blue.withOpacity(0.3),
                              ],
                            ),
                            boxShadow: const [
                              BoxShadow(
                                color: Colors.cyanAccent,
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Text(
                            'Biometrics Authorized',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          decoration: const BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.cyanAccent,
                                blurRadius: 5,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.verified_user,
                            color: Colors.white,
                            size: 24.0,
                          ),
                        ),
                        const SizedBox(width: 8),
                        CustomButton(
                          text: 'Verify Identity',
                          onPressed: () {
                            if (kDebugMode) {
                              print('Verify Identity button tapped');
                            }
                            _matchImages();
                          },
                          isLoading: _isMatching,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          decoration: const BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.cyanAccent,
                                blurRadius: 5,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.check_circle,
                            color: Colors.cyanAccent,
                            size: 24.0,
                          ),
                        ),
                        const SizedBox(width: 8),
                        CustomButton(
                          text: 'Confirm Registration',
                          onPressed: () {
                            if (kDebugMode) {
                              print('Confirm Registration button tapped');
                            }
                            _register();
                          },
                          isLoading: _isRegistering,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          decoration: const BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                color: Colors.cyanAccent,
                                blurRadius: 5,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.vpn_key,
                            color: Colors.cyanAccent,
                            size: 24.0,
                          ),
                        ),
                        const SizedBox(width: 8),
                        CustomButton(
                          text: 'Bypass Protocol',
                          onPressed: () {
                            if (kDebugMode) {
                              print('Bypass Protocol button tapped');
                            }
                            final user = UserModel(
                              id: const Uuid().v4(),
                              name: 'Dummy User',
                              email: 'dummy@example.com',
                              password: 'DummyPass123!',
                              age: 35,
                            );
                            Provider.of<UserProvider>(
                              context,
                              listen: false,
                            ).setUser(user);
                            Navigator.pushReplacement(
                              context,
                              PageRouteBuilder(
                                pageBuilder: (_, __, ___) => const HomeScreen(),
                                transitionsBuilder: (_, animation, __, child) {
                                  return SlideTransition(
                                    position: Tween<Offset>(
                                      begin: const Offset(1.0, 0.0),
                                      end: Offset.zero,
                                    ).animate(
                                      CurvedAnimation(
                                        parent: animation,
                                        curve: Curves.easeInOut,
                                      ),
                                    ),
                                    child: child,
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
