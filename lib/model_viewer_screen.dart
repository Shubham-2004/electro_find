import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:cloudinary_url_gen/cloudinary.dart';

class ModelViewerScreen extends StatefulWidget {
  const ModelViewerScreen({super.key});

  @override
  State<ModelViewerScreen> createState() => _ModelViewerScreenState();
}

class _ModelViewerScreenState extends State<ModelViewerScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late final Cloudinary cloudinary;

  @override
  void initState() {
    super.initState();
    // Initialize Cloudinary with your cloud name
    cloudinary = Cloudinary.fromCloudName(cloudName: 'dk7te6qfq');
  }

  String getCloudinaryUrl(String publicId) {
    // Generate properly constructed Cloudinary URL
    return cloudinary
        .image(publicId)
        .toString();
  }

  final List<ModelInfo> models = [
    // Cloudinary URLs for models
    ModelInfo(
      path: 'https://res.cloudinary.com/dk7te6qfq/image/upload/v1745511398/Pump_quvgtk.glb',
      name: 'Cloudinary Pump (quvgtk)',
      isRemote: true,
    ),
    ModelInfo(
      path: 'https://res.cloudinary.com/dk7te6qfq/image/upload/Pump_rkq5b2.glb',
      name: 'Cloudinary Pump (rkq5b2)',
      isRemote: true,
    ),
    // Local assets
    ModelInfo(
      path: 'assets/models/pump.glb',
      name: 'Local Pump Model',
      isRemote: false,
    ),
    ModelInfo(
      path: 'assets/models/pump2.glb',
      name: 'Local Pump Model 2',
      isRemote: false,
    ),
    ModelInfo(
      path: 'assets/models/man.glb',
      name: 'Human Model',
      isRemote: false,
    ),
    ModelInfo(
      path: 'assets/models/earth.glb',
      name: 'Earth Model',
      isRemote: false,
    ),
  ];

  final Map<String, String> cameraSettings = {
    'front': '0deg 75deg 105%',
    'side': '90deg 75deg 105%',
    'top': '0deg 0deg 105%',
    'back': '180deg 75deg 105%',
    'bottom': '0deg 180deg 105%',
  };

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('3D Model Viewer'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed:
              _currentPage > 0
                  ? () {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  }
                  : null,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed:
                _currentPage < models.length - 1
                    ? () {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    }
                    : null,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (int page) {
                setState(() {
                  _currentPage = page;
                });
              },
              itemCount: models.length,
              itemBuilder: (context, index) {
                return ModelViewerPage(
                  model: models[index],
                  cameraSettings: cameraSettings['front']!,
                  modelNumber: index + 1,
                  totalModels: models.length,
                );
              },
            ),
          ),
          // Camera controls
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: cameraSettings.entries.map((entry) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          // Update camera angle
                          // This would need a more complex implementation to actually change
                          // the camera angle of the current model viewer
                        });
                      },
                      child: Text(entry.key.toUpperCase()),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Generate and display a dynamic Cloudinary URL
          final dynamicUrl = cloudinary
              .image('Pump_rkq5b2')
              .toString();
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Dynamic URL generated: $dynamicUrl'),
              duration: const Duration(seconds: 3),
            ),
          );
        },
        child: const Icon(Icons.cloud),
      ),
    );
  }
}

class ModelInfo {
  final String path;
  final String name;
  final bool isRemote;

  const ModelInfo({
    required this.path,
    required this.name,
    required this.isRemote,
  });
}

class ModelViewerPage extends StatelessWidget {
  final ModelInfo model;
  final String cameraSettings;
  final int modelNumber;
  final int totalModels;

  const ModelViewerPage({
    super.key,
    required this.model,
    required this.cameraSettings,
    required this.modelNumber,
    required this.totalModels,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ModelViewer(
            src: model.path,
            alt: model.name,
            ar: true,
            autoRotate: false,
            cameraControls: true,
            cameraOrbit: cameraSettings,
            backgroundColor: const Color.fromARGB(255, 245, 245, 245),
            loading: Loading.eager,
            reveal: Reveal.auto,
            arModes: const ['scene-viewer', 'quick-look'],
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                model.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Model ${modelNumber} of ${totalModels}',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              if (model.isRemote)
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Chip(
                    label: Text('Cloudinary'),
                    backgroundColor: Colors.blue,
                    labelStyle: TextStyle(color: Colors.white),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}