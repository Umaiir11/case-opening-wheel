import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../../model/prize_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  final _textController = PageController();
  final _imageController = PageController(viewportFraction: 0.52);
  AnimationController? _animationController;
  Animation<double>? _scaleAnimation;
  Animation<Color?>? _circleColorAnimation;

  Timer? _spinTimer;
  bool _isSpinning = false;
  final Random _random = Random();

  final List<PrizeModel> prizes = [
    PrizeModel(name: "Case1", image: "assets/images/prizes/gift1.png"),
    PrizeModel(name: "Case2", image: "assets/images/prizes/gift2.png"),
    PrizeModel(name: "Case3", image: "assets/images/prizes/gift3.png"),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController!, curve: Curves.elasticOut),
    );
    _circleColorAnimation = ColorTween(
      begin: const Color(0xFFBD6CC7),
      end: const Color(0xFFFF6F61),
    ).animate(
      CurvedAnimation(parent: _animationController!, curve: Curves.easeInOut),
    );

    Future.delayed(const Duration(milliseconds: 300), () {
      _imageController.animateToPage(
        1,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _spinTimer?.cancel();
    _imageController.dispose();
    _textController.dispose();
    _animationController?.dispose();
    super.dispose();
  }


  void _startSpinning() {
    if (_isSpinning) return;

    setState(() {
      _isSpinning = true;
    });
    _animationController?.forward();

    // Start continuous spinning with smoother transitions
    _spinTimer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      if (_imageController.hasClients) {
        double currentPage = _imageController.page ?? 0;
        int nextPage = ((currentPage + 1) % prizes.length).round();
        _imageController.animateToPage(
          nextPage,
          duration: Duration(milliseconds: 150 + _random.nextInt(50)), // Random duration for organic feel
          curve: Curves.easeInOut,
        );
      }
    });

    // Stop after 5 seconds
    Timer(const Duration(seconds: 5), () {
      _stopSpinning();
    });
  }

  void _stopSpinning() {
    _spinTimer?.cancel();

    // Choose random final position
    int randomIndex = _random.nextInt(prizes.length);

    // Animate to final position with elastic bounce
    _imageController.animateToPage(
      randomIndex,
      duration: const Duration(milliseconds: 1200),
      curve: Curves.elasticOut,
    ).then((_) {
      setState(() {
        _isSpinning = false;
      });
      _animationController?.reverse();
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
                    Positioned.fill(
                      top: 100,
                      child: PageView.builder(
                        controller: _imageController,
                        itemCount: prizes.length,
                        onPageChanged: (i) {
                          if (!_isSpinning) {
                            _textController.animateToPage(
                              i,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          }
                        },
                        itemBuilder: (_, i) {
                          return Align(
                            alignment: Alignment.center,
                            child: AnimatedBuilder(
                              animation: Listenable.merge([_imageController, _animationController]),
                              builder: (context, child) {
                                double value = 0.0;
                                double rotation = 0.0;
                                if (_imageController.position.haveDimensions) {
                                  value = ((i - (_imageController.page ?? 0)) * 0.7).clamp(-1, 1);
                                  rotation = _isSpinning ? value * 0.1 : 0.0; // Subtle rotation during spin
                                }
                                final scale = _isSpinning && value.abs() < 0.1 ? _scaleAnimation!.value : 1.0;
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
                                              Container(
                                                width: 320,
                                                height: 320,
                                                decoration: BoxDecoration(
                                                  color: _isSpinning && value.abs() < 0.1
                                                      ? _circleColorAnimation!.value
                                                      : const Color(0xFFBD6CC7),
                                                  shape: BoxShape.circle,
                                                  boxShadow: _isSpinning && value.abs() < 0.1
                                                      ? [
                                                    BoxShadow(
                                                      color: _circleColorAnimation!.value!.withOpacity(0.5),
                                                      blurRadius: 20,
                                                      spreadRadius: 5,
                                                    ),
                                                  ]
                                                      : null,
                                                ),
                                              ),
                                              Positioned(
                                                child: Hero(
                                                  tag: prizes[i].name,
                                                  child: Image.asset(
                                                    prizes[i].image,
                                                    fit: BoxFit.cover,
                                                    height: 100,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    Positioned(
                      top: 10,
                      left: 100,
                      right: 100,
                      child: Column(
                        children: [
                          SizedBox(
                            height: 100,
                            child: PageView.builder(
                              controller: _textController,
                              itemCount: prizes.length,
                              scrollDirection: Axis.vertical,
                              physics: const NeverScrollableScrollPhysics(),
                              itemBuilder: (_, i) => Center(
                                child: Text(
                                  prizes[i].name,
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
                    ),
                    Positioned(
                      bottom: 50,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: ElevatedButton(
                          onPressed: _isSpinning ? null : _startSpinning,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isSpinning ? Colors.grey : Colors.amber,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            elevation: 5,
                          ),
                          child: Text(
                            _isSpinning ? "SPINNING..." : "START",
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}