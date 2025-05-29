import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/case_opening_controller.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  final HomeController controller = Get.put(HomeController());


  AnimationController? _animationController;
  Animation<double>? _scaleAnimation;
  Animation<Color?>? _circleColorAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    controller.initializeController();
  }

  @override
  void dispose() {
    _animationController?.dispose();
    controller.disposeResources();
    super.dispose();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController!, curve: Curves.elasticOut),
    );

    _circleColorAnimation = ColorTween(
      begin: controller.circleColor,
      end: controller.animatedCircleColor,
    ).animate(
      CurvedAnimation(parent: _animationController!, curve: Curves.easeInOut),
    );
  }

  void _startSpinning() {
    controller.startSpinning();
    _animationController?.forward();
    ever(controller.isSpinning, (isSpinning) {
      if (!isSpinning) {
        _animationController?.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    const Color bottomBgColor = Color(0xFF5C3561);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 35, top: 10),
              child: Text(
                "Case Opening",
                style: TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: Container(
                width: width,
                decoration: const BoxDecoration(color: bottomBgColor),
                child: Stack(
                  children: [
                    _buildPrizeCarousel(),
                    _buildPrizeText(),
                    _buildStartButton(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrizeCarousel() {
    return Positioned.fill(
      top: 100,
      child: PageView.builder(
        controller: controller.imageController,
        itemCount: controller.prizes.length,
        onPageChanged: controller.onPageChanged,
        itemBuilder: (_, i) {
          return Align(
            alignment: Alignment.center,
            child: AnimatedBuilder(
              animation: Listenable.merge([controller.imageController, _animationController]),
              builder: (context, child) {
                return Obx(() => _buildPrizeItem(i));
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildPrizeItem(int index) {
    double value = 0.0;
    double rotation = 0.0;

    if (controller.imageController.position.haveDimensions) {
      value = ((index - (controller.imageController.page ?? 0)) * 0.7).clamp(-1, 1);
      rotation = controller.isSpinning.value ? value * 0.1 : 0.0;
    }

    final scale = controller.isSpinning.value && value.abs() < 0.1
        ? _scaleAnimation!.value
        : 1.0;

    return Transform.translate(
      offset: Offset(0, -(value.abs() * 150)),
      child: Transform.rotate(
        angle: rotation,
        child: Transform.scale(
          scale: scale * (1 - (value.abs() * 0.05)),
          child: InkWell(
            onTap: () {},
            child: SizedBox(
              width: 190,
              height: 180,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  _buildCircleBackground(value),
                  _buildPrizeImage(index),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCircleBackground(double value) {
    return Container(
      width: 320,
      height: 320,
      decoration: BoxDecoration(
        color: controller.isSpinning.value && value.abs() < 0.1
            ? _circleColorAnimation!.value
            : controller.circleColor,
        shape: BoxShape.circle,
        boxShadow: controller.isSpinning.value && value.abs() < 0.1
            ? [
          BoxShadow(
            color: _circleColorAnimation!.value!.withOpacity(0.5),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ]
            : null,
      ),
    );
  }

  Widget _buildPrizeImage(int index) {
    return Positioned(
      child: Hero(
        tag: controller.prizes[index].name,
        child: Image.asset(
          controller.prizes[index].image,
          fit: BoxFit.cover,
          height: 100,
        ),
      ),
    );
  }

  Widget _buildPrizeText() {
    return Positioned(
      top: 10,
      left: 100,
      right: 100,
      child: Column(
        children: [
          SizedBox(
            height: 100,
            child: PageView.builder(
              controller: controller.textController,
              itemCount: controller.prizes.length,
              scrollDirection: Axis.vertical,
              physics: const NeverScrollableScrollPhysics(),
              itemBuilder: (_, i) => Center(
                child: Text(
                  controller.prizes[i].name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    height: 1.1,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStartButton() {
    return Positioned(
      bottom: 50,
      left: 0,
      right: 0,
      child: Center(
        child: Obx(() => ElevatedButton(
          onPressed: controller.isSpinning.value ? null : _startSpinning,
          style: ElevatedButton.styleFrom(
            backgroundColor: controller.isSpinning.value ? Colors.grey : Colors.amber,
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            elevation: 5,
          ),
          child: Text(
            controller.isSpinning.value ? "SPINNING..." : "START",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        )),
      ),
    );
  }
}