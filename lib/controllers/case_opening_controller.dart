import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';
import '../../model/prize_model.dart';

class HomeController extends GetxController {
  final PageController textController = PageController();
  final PageController imageController = PageController(viewportFraction: 0.52);

  Timer? _spinTimer;
  final Random _random = Random();
  final RxBool isSpinning = false.obs;
  final RxInt currentPage = 1.obs;

  final RxList<PrizeModel> prizes = <PrizeModel>[
    PrizeModel(name: "Case1", image: "assets/images/prizes/gift1.png"),
    PrizeModel(name: "Case2", image: "assets/images/prizes/gift2.png"),
    PrizeModel(name: "Case3", image: "assets/images/prizes/gift3.png"),
  ].obs;



  void initializeController() {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (imageController.hasClients) {
        imageController.animateToPage(
          1,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
        currentPage.value = 1;
      }
    });
  }

  void disposeResources() {
    _spinTimer?.cancel();
    imageController.dispose();
    textController.dispose();
  }

  void startSpinning() {
    if (isSpinning.value) return;

    isSpinning.value = true;
    _spinTimer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      if (imageController.hasClients) {
        double currentPageValue = imageController.page ?? 0;
        int nextPage = ((currentPageValue + 1) % prizes.length).round();
        imageController.animateToPage(
          nextPage,
          duration: Duration(milliseconds: 150 + _random.nextInt(50)),
          curve: Curves.easeInOut,
        );
      }
    });

    Timer(const Duration(seconds: 5), () {
      _stopSpinning();
    });
  }

  void _stopSpinning() {
    _spinTimer?.cancel();

    int randomIndex = _random.nextInt(prizes.length);
    imageController.animateToPage(
      randomIndex,
      duration: const Duration(milliseconds: 1200),
      curve: Curves.elasticOut,
    ).then((_) {
      isSpinning.value = false;
      currentPage.value = randomIndex;
    });
  }

  void onPageChanged(int index) {
    if (!isSpinning.value) {
      textController.animateToPage(
        index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      currentPage.value = index;
    }
  }
  bool get shouldShowAnimation => isSpinning.value;
  Color get circleColor => const Color(0xFFBD6CC7);
  Color get animatedCircleColor => const Color(0xFFFF6F61);




}