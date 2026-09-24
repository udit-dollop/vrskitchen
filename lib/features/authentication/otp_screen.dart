import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_dimens.dart';
import '../../core/constants/app_typography.dart';
import '../../core/routes/app_routes.dart';
import '../../core/widgets/vrs_button.dart';
import '../../state/app_state_provider.dart';
import '../customer/customer_main_shell.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  int _resendTimer = 28;
  Timer? _timer;
  bool _isVerifying = false;

  String _displayPhone = "+91 98260 12345";
  String _cleanPhone = "9826012345";
  String _verificationToken = "";
  String _devOtp = "123456";
  bool _initializedArgs = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initializedArgs) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map<String, dynamic>) {
        _displayPhone = args['displayPhone']?.toString() ?? _displayPhone;
        _cleanPhone = args['phone']?.toString() ?? _cleanPhone;
        _verificationToken = args['verificationToken']?.toString() ?? '';
        _devOtp = args['devOtp']?.toString() ?? '123456';
      } else if (args is String) {
        _displayPhone = args;
        _cleanPhone = args.replaceAll(RegExp(r'\D'), '');
      }
      _initializedArgs = true;
    }
  }

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _resendTimer = 28;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_resendTimer > 0) {
        setState(() => _resendTimer--);
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var c in _controllers) {
      c.dispose();
    }
    for (var f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _fillDemoOtp() {
    final code = _devOtp.isNotEmpty ? _devOtp : "123456";
    for (int i = 0; i < 6 && i < code.length; i++) {
      _controllers[i].text = code[i];
    }
    _verify();
  }

  void _verify() async {
    final enteredCode = _controllers.map((c) => c.text).join();
    if (enteredCode.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter the full 6-digit OTP")),
      );
      return;
    }

    setState(() => _isVerifying = true);
    final provider = Provider.of<AppStateProvider>(context, listen: false);

    bool loginSuccess = false;
    if (_verificationToken.isNotEmpty) {
      try {
        loginSuccess = await provider.verifyOtpForLogin(
          phone: _cleanPhone,
          otp: enteredCode,
          token: _verificationToken,
        );
      } catch (_) {}
    }

    if (!mounted) return;
    setState(() => _isVerifying = false);

    if (loginSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Welcome back, ${provider.user.name}!"),
          backgroundColor: AppColors.vegGreen,
        ),
      );
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => CustomerMainShell(),),(route) => false,);
    } else {
      // Fallback transition
      Navigator.pushReplacementNamed(context, AppRoutes.dietarySetup);
    }
  }

  @override
  Widget build(BuildContext context) {
    final phoneArg = _displayPhone;

    return Scaffold(
      backgroundColor: AppColors.surfaceWhite,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.navyPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppDimens.space24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppDimens.space16),

              Text(
                "Verify Your Number",
                style: AppTypography.displayMedium.copyWith(fontSize: 24),
              ),
              const SizedBox(height: AppDimens.space8),
              Row(
                children: [
                  Text(
                    "We have sent a 6-digit OTP to ",
                    style: AppTypography.bodyMedium.copyWith(color: AppColors.textMuted),
                  ),
                  Text(
                    phoneArg,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.navyPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppDimens.space32),

              // OTP Digits Boxes
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(6, (index) {
                  return SizedBox(
                    width: 48,
                    height: 56,
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      maxLength: 1,
                      style: AppTypography.headingLarge.copyWith(
                        color: AppColors.navyPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                      decoration: InputDecoration(
                        counterText: "",
                        contentPadding: EdgeInsets.zero,
                        filled: true,
                        fillColor: AppColors.backgroundLight,
                        border: OutlineInputBorder(
                          borderRadius: AppDimens.borderMD,
                          borderSide: const BorderSide(color: AppColors.borderLight),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: AppDimens.borderMD,
                          borderSide: const BorderSide(color: AppColors.goldPrimary, width: 2),
                        ),
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty && index < 5) {
                          _focusNodes[index + 1].requestFocus();
                        } else if (value.isEmpty && index > 0) {
                          _focusNodes[index - 1].requestFocus();
                        }
                        if (index == 5 && value.isNotEmpty) {
                          _verify();
                        }
                      },
                    ),
                  );
                }),
              ),

              const SizedBox(height: AppDimens.space24),

              // Demo Helper Button
              Center(
                child: TextButton.icon(
                  onPressed: _fillDemoOtp,
                  icon: const Icon(Icons.flash_on_rounded, color: AppColors.goldDark, size: 18),
                  label: Text(
                    "Auto-Fill Demo OTP: 123456",
                    style: AppTypography.button.copyWith(
                      color: AppColors.goldDark,
                      fontSize: 14,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: AppColors.goldBackground,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: AppDimens.borderMD),
                  ),
                ),
              ),

              const SizedBox(height: AppDimens.space24),

              VrsButton(
                text: "Verify & Continue",
                onPressed: _verify,
                isLoading: _isVerifying,
                variant: VrsButtonVariant.gold,
              ),

              const SizedBox(height: AppDimens.space24),

              Center(
                child: _resendTimer > 0
                    ? Text(
                        "Resend code in 00:${_resendTimer.toString().padLeft(2, '0')}",
                        style: AppTypography.bodySmall,
                      )
                    : TextButton(
                        onPressed: _startTimer,
                        child: Text(
                          "Resend OTP",
                          style: AppTypography.button.copyWith(
                            color: AppColors.navyPrimary,
                            fontSize: 14,
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
