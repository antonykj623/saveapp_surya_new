
import 'package:flutter/foundation.dart' show listEquals;
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';
import 'package:pattern_lock/pattern_lock.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_settings/app_settings.dart';

import 'package:new_project_2025/view/home/widget/More_page/snackbarextension.dart';

import '../setting_page/setting_page.dart';

class SetPattern extends StatefulWidget {
  const SetPattern({super.key});

  @override
  State<SetPattern> createState() => _SetPatternState();
}

class _SetPatternState extends State<SetPattern> {
  final LocalAuthentication auth = LocalAuthentication();

  bool isConfirm = false;
  bool isVerifyingOldPattern = false;

  bool isBiometricAvailable = false;
  bool biometricEnabled = false;

  int wrongAttempts = 0;

  List<int>? pattern;
  List<int>? savedPattern;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  // ================= INITIALIZE =================

  Future<void> initialize() async {
    await loadSavedPattern();
    await checkBiometric();
  }

  // ================= CHECK BIOMETRIC =================

  Future<void> checkBiometric() async {
    try {
      bool canCheck = await auth.canCheckBiometrics;

      bool supported = await auth.isDeviceSupported();

      setState(() {
        isBiometricAvailable = canCheck && supported;
      });
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  // ================= ENABLE BIOMETRIC =================

  Future<void> enableBiometric() async {
    try {
      bool authenticated = await auth.authenticate(
        localizedReason: 'Enable Fingerprint Authentication',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (authenticated) {
        final prefs = await SharedPreferences.getInstance();

        await prefs.setBool(
          "biometric_enabled",
          true,
        );

        setState(() {
          biometricEnabled = true;
        });

        if (mounted) {
          context.replaceSnackbar(
            content: const Text(
              "Fingerprint Enabled",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            color: Colors.green,
          );
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => SettingsScreen(),
          ),
        );
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  // ================= DISABLE BIOMETRIC =================

  Future<void> disableBiometric() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(
      "biometric_enabled",
      false,
    );

    setState(() {
      biometricEnabled = false;
    });

    if (mounted) {
      context.replaceSnackbar(
        content: const Text(
          "Fingerprint Disabled",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        color: Colors.red,
      );
    }
  }

  // ================= RESET BIOMETRIC =================

  Future<void> resetBiometric() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool("biometric_enabled", false);

    setState(() {
      biometricEnabled = false;
    });

    if (mounted) {
      context.replaceSnackbar(
        content: const Text(
          "Biometric Reset Successfully",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        color: Colors.orange,
      );
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Row(
          children: [
            Icon(Icons.fingerprint, color: Colors.blue),
            SizedBox(width: 10),
            Text("Reset Biometrics"),
          ],
        ),
        content: const Text(
          "Go to your phone settings and add/change fingerprint or Face ID.\n\nThen return and enable biometric again in this app.",
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);

              AppSettings.openAppSettings(
                type: AppSettingsType.security,
              );
            },
            child: const Text("OPEN SETTINGS"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text("CANCEL"),
          ),
        ],
      ),
    );
  }

  // ================= NAVIGATE HOME =================

  void goToHome() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => SettingsScreen(),
      ),
          (route) => false,
    );
  }

  // ================= BIOMETRIC AUTH =================

  Future<void> authenticateWithBiometric() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      bool enabled =
          prefs.getBool("biometric_enabled") ?? false;

      if (!enabled) return;

      bool authenticated = await auth.authenticate(
        localizedReason:
        'Unlock using Fingerprint or Face',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
        ),
      );

      if (authenticated) {
        setState(() {
          wrongAttempts = 0;

          isVerifyingOldPattern = false;

          isConfirm = false;

          pattern = null;
        });

        if (mounted) {
          context.replaceSnackbar(
            content: const Text(
              "Authentication Successful",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            color: Colors.green,
          );
        }

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => SettingsScreen(),
          ),
        );
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  // ================= LOAD PATTERN =================

  Future<void> loadSavedPattern() async {
    final prefs = await SharedPreferences.getInstance();

    final patternString =
    prefs.getString('lock_pattern');

    biometricEnabled =
        prefs.getBool("biometric_enabled") ?? false;

    if (patternString != null) {
      savedPattern = patternString
          .split(',')
          .map((e) => int.parse(e))
          .toList();

      setState(() {
        isVerifyingOldPattern = true;
      });
    }
  }

  // ================= SAVE PATTERN =================

  Future<void> savePatternToPrefs(
      List<int> pattern,
      ) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      'lock_pattern',
      pattern.join(','),
    );
  }

  // ================= RESET PATTERN =================

  Future<void> resetPattern() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('lock_pattern');

    setState(() {
      pattern = null;
      savedPattern = null;
      isConfirm = false;
      isVerifyingOldPattern = false;
      wrongAttempts = 0;
    });

    if (mounted) {
      context.replaceSnackbar(
        content: const Text(
          "Pattern Reset Successful",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
          ),
        ),
        color: Colors.orange,
      );
    }
  }

  // ================= MAIN UI =================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: Text(
          isVerifyingOldPattern
              ? "Verify Old Pattern"
              : isConfirm
              ? "Confirm Pattern"
              : "Set New Pattern",
        ),
        actions: [
          // ENABLE / DISABLE BIOMETRIC
          if (isBiometricAvailable)
            IconButton(
              icon: Icon(
                biometricEnabled
                    ? Icons.fingerprint
                    : Icons.fingerprint_outlined,
              ),
              onPressed: () async {
                if (biometricEnabled) {
                  await disableBiometric();
                } else {
                  await enableBiometric();
                }
              },
            ),

          // RESET BIOMETRIC
          if (isBiometricAvailable)
            IconButton(
              icon: const Icon(
                Icons.settings_backup_restore,
              ),
              onPressed: resetBiometric,
            ),

          // RESET PATTERN
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: resetPattern,
          ),
        ],
      ),

      body: Column(
        mainAxisAlignment:
        MainAxisAlignment.spaceEvenly,
        children: [
          // TITLE
          Padding(
            padding:
            const EdgeInsets.symmetric(
              horizontal: 20,
            ),
            child: Text(
              isVerifyingOldPattern
                  ? "Draw your existing pattern"
                  : isConfirm
                  ? "Confirm your new pattern"
                  : "Draw a new pattern",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          // WRONG ATTEMPTS
          if (wrongAttempts > 0)
            Text(
              "Wrong Attempts : $wrongAttempts / 3",
              style: const TextStyle(
                color: Colors.red,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

          // PATTERN LOCK
          Expanded(
            child: Center(
              child: PatternLock(
                selectedColor: Colors.amber,
                notSelectedColor: Colors.grey,
                pointRadius: 12,
                onInputComplete:
                    (List<int> input) async {
                  // MINIMUM POINTS
                  if (input.length < 3) {
                    if (mounted) {
                      context.replaceSnackbar(
                        content: const Text(
                          "Minimum 3 points required",
                          textAlign:
                          TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        color: Colors.red,
                      );
                    }

                    return;
                  }

                  // VERIFY OLD PATTERN
                  if (isVerifyingOldPattern) {
                    if (listEquals(
                      input,
                      savedPattern,
                    )) {
                      setState(() {
                        wrongAttempts = 0;

                        isVerifyingOldPattern =
                        false;

                        isConfirm = false;

                        pattern = null;
                      });

                      if (mounted) {
                        context.replaceSnackbar(
                          content: const Text(
                            "Pattern Verified",
                            textAlign:
                            TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                          color: Colors.green,
                        );
                      }

                      goToHome();
                    } else {
                      wrongAttempts++;

                      if (mounted) {
                        context.replaceSnackbar(
                          content: Text(
                            "Incorrect Pattern ($wrongAttempts/3)",
                            textAlign:
                            TextAlign.center,
                            style:
                            const TextStyle(
                              color:
                              Colors.white,
                            ),
                          ),
                          color: Colors.red,
                        );
                      }

                      // AUTO BIOMETRIC AFTER 3 WRONG ATTEMPTS
                      if (wrongAttempts >= 3) {
                        await authenticateWithBiometric();
                      }
                    }
                  }

                  // CONFIRM NEW PATTERN
                  else if (isConfirm) {
                    if (listEquals(
                      input,
                      pattern,
                    )) {
                      await savePatternToPrefs(
                        pattern!,
                      );

                      if (mounted) {
                        context.replaceSnackbar(
                          content: const Text(
                            "Pattern Saved Successfully",
                            textAlign:
                            TextAlign.center,
                            style: TextStyle(
                              color:
                              Colors.white,
                            ),
                          ),
                          color: Colors.green,
                        );
                      }

                      goToHome();
                    } else {
                      setState(() {
                        pattern = null;
                        isConfirm = false;
                      });

                      if (mounted) {
                        context.replaceSnackbar(
                          content: const Text(
                            "Patterns Do Not Match",
                            textAlign:
                            TextAlign.center,
                            style: TextStyle(
                              color:
                              Colors.white,
                            ),
                          ),
                          color: Colors.red,
                        );
                      }
                    }
                  }

                  // CREATE NEW PATTERN
                  else {
                    setState(() {
                      pattern = input;
                      isConfirm = true;
                    });

                    if (mounted) {
                      context.replaceSnackbar(
                        content: const Text(
                          "Please Confirm Pattern",
                          textAlign:
                          TextAlign.center,
                          style: TextStyle(
                            color:
                            Colors.white,
                          ),
                        ),
                        color: Colors.blue,
                      );
                    }
                  }
                },
              ),
            ),
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
//biometric enables

// import 'package:flutter/foundation.dart' show listEquals;
// import 'package:flutter/material.dart';
// import 'package:local_auth/local_auth.dart';
// import 'package:pattern_lock/pattern_lock.dart';
// import 'package:shared_preferences/shared_preferences.dart';
//
// import 'package:new_project_2025/view/home/widget/More_page/snackbarextension.dart';
// import 'package:new_project_2025/view/home/widget/home_screen.dart';
//
// import '../setting_page/setting_page.dart';
//
// class SetPattern extends StatefulWidget {
//   const SetPattern({super.key});
//
//   @override
//   State<SetPattern> createState() => _SetPatternState();
// }
//
// class _SetPatternState extends State<SetPattern> {
//   final LocalAuthentication auth = LocalAuthentication();
//
//   bool isConfirm = false;
//   bool isVerifyingOldPattern = false;
//
//   bool isBiometricAvailable = false;
//   bool biometricEnabled = false;
//
//   int wrongAttempts = 0;
//
//   List<int>? pattern;
//   List<int>? savedPattern;
//
//   @override
//   void initState() {
//     super.initState();
//     initialize();
//   }
//
//   // ================= INITIALIZE =================
//
//   Future<void> initialize() async {
//    await loadSavedPattern();
//    await checkBiometric();
//   }
//
//   // ================= CHECK BIOMETRIC =================
//
//   Future<void> checkBiometric() async {
//     try {
//       bool canCheck =
//       await auth.canCheckBiometrics;
//
//       bool supported =
//       await auth.isDeviceSupported();
//
//       setState(() {
//         isBiometricAvailable =
//             canCheck && supported;
//       });
//     } catch (e) {
//       debugPrint(e.toString());
//     }
//   }
//
//   // ================= ENABLE BIOMETRIC =================
//   Future<void> enableBiometric() async {
//     try {
//       bool authenticated =
//       await auth.authenticate(
//         localizedReason:
//         'Enable Fingerprint Authentication',
//         options: const AuthenticationOptions(
//           biometricOnly: true,
//           stickyAuth: true,
//         ),
//       );
//
//       if (authenticated) {
//         final prefs =
//         await SharedPreferences.getInstance();
//
//         await prefs.setBool(
//           "biometric_enabled",
//           true,
//         );
//
//         setState(() {
//           biometricEnabled = true;
//         });
//
//         if (mounted) {
//           context.replaceSnackbar(
//             content: const Text(
//               "Fingerprint Enabled",
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 color: Colors.white,
//               ),
//             ),
//             color: Colors.green,
//           );
//         }
//
//         // GO TO SETTINGS SCREEN
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//             builder: (_) => SettingsScreen(),
//           ),
//         );
//       }
//     } catch (e) {
//       debugPrint(e.toString());
//     }
//   }
//   // Future<void> enableBiometric() async {
//   //   try {
//   //     bool authenticated =
//   //     await auth.authenticate(
//   //       localizedReason:
//   //       'Enable Fingerprint Authentication',
//   //       options: const AuthenticationOptions(
//   //         biometricOnly: true,
//   //         stickyAuth: true,
//   //       ),
//   //     );
//   //
//   //     if (authenticated) {
//   //       final prefs =
//   //       await SharedPreferences.getInstance();
//   //
//   //       await prefs.setBool(
//   //         "biometric_enabled",
//   //         true,
//   //       );
//   //
//   //       setState(() {
//   //         biometricEnabled = true;
//   //       });
//   //
//   //       if (mounted) {
//   //         context.replaceSnackbar(
//   //           content: const Text(
//   //             "Fingerprint Enabled",
//   //             textAlign: TextAlign.center,
//   //             style: TextStyle(
//   //               color: Colors.white,
//   //             ),
//   //           ),
//   //           color: Colors.green,
//   //         );
//   //       }
//   //     }
//   //   } catch (e) {
//   //     debugPrint(e.toString());
//   //   }
//   // }
//
//   // ================= DISABLE BIOMETRIC =================
//
//   Future<void> disableBiometric() async {
//     final prefs =
//     await SharedPreferences.getInstance();
//
//     await prefs.setBool(
//       "biometric_enabled",
//       false,
//     );
//
//     setState(() {
//       biometricEnabled = false;
//     });
//
//     if (mounted) {
//       context.replaceSnackbar(
//         content: const Text(
//           "Fingerprint Disabled",
//           textAlign: TextAlign.center,
//           style: TextStyle(
//             color: Colors.white,
//           ),
//         ),
//         color: Colors.red,
//       );
//     }
//   }
//
//   // ================= NAVIGATE HOME =================
//
//   void goToHome() {
//     Navigator.pushAndRemoveUntil(
//       context,
//       MaterialPageRoute(
//         builder: (_) => SettingsScreen(),
//       ),
//           (route) => false,
//     );
//   }
//
//   // ================= BIOMETRIC AUTH =================
//   Future<void> authenticateWithBiometric() async {
//     try {
//       final prefs =
//       await SharedPreferences.getInstance();
//
//       bool enabled =
//           prefs.getBool("biometric_enabled") ??
//               false;
//
//       if (!enabled) return;
//
//       bool authenticated =
//       await auth.authenticate(
//         localizedReason:
//         'Unlock using Fingerprint or Face',
//         options: const AuthenticationOptions(
//           biometricOnly: true,
//           stickyAuth: true,
//         ),
//       );
//
//       if (authenticated) {
//         setState(() {
//           wrongAttempts = 0;
//
//           isVerifyingOldPattern = false;
//
//           isConfirm = false;
//
//           pattern = null;
//         });
//
//         if (mounted) {
//           context.replaceSnackbar(
//             content: const Text(
//               "Authentication Successful",
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 color: Colors.white,
//               ),
//             ),
//             color: Colors.green,
//           );
//         }
//
//         // GO TO SETTINGS SCREEN
//         Navigator.pushReplacement(
//           context,
//           MaterialPageRoute(
//             builder: (_) => SettingsScreen(),
//           ),
//         );
//       }
//     } catch (e) {
//       debugPrint(e.toString());
//     }
//   }
//   // Future<void> authenticateWithBiometric() async {
//   //   try {
//   //     final prefs =
//   //     await SharedPreferences.getInstance();
//   //
//   //     bool enabled =
//   //         prefs.getBool("biometric_enabled") ??
//   //             false;
//   //
//   //     if (!enabled) return;
//   //
//   //     bool authenticated =
//   //     await auth.authenticate(
//   //       localizedReason:
//   //       'Unlock using Fingerprint or Face',
//   //       options: const AuthenticationOptions(
//   //         biometricOnly: true,
//   //         stickyAuth: true,
//   //       ),
//   //     );
//   //
//   //     if (authenticated) {
//   //       setState(() {
//   //         wrongAttempts = 0;
//   //
//   //         isVerifyingOldPattern = false;
//   //
//   //         isConfirm = false;
//   //
//   //         pattern = null;
//   //       });
//   //
//   //       if (mounted) {
//   //         context.replaceSnackbar(
//   //           content: const Text(
//   //             "Authentication Successful",
//   //             textAlign: TextAlign.center,
//   //             style: TextStyle(
//   //               color: Colors.white,
//   //             ),
//   //           ),
//   //           color: Colors.green,
//   //         );
//   //       }
//   //
//   //       // GO TO HOME
//   //       goToHome();
//   //     }
//   //   } catch (e) {
//   //     debugPrint(e.toString());
//   //   }
//   // }
//
//   // ================= LOAD PATTERN =================
//
//   Future<void> loadSavedPattern() async {
//     final prefs =
//     await SharedPreferences.getInstance();
//
//     final patternString =
//     prefs.getString('lock_pattern');
//
//     biometricEnabled =
//         prefs.getBool("biometric_enabled") ??
//             false;
//
//     if (patternString != null) {
//       savedPattern = patternString
//           .split(',')
//           .map((e) => int.parse(e))
//           .toList();
//
//       setState(() {
//         isVerifyingOldPattern = true;
//       });
//     }
//   }
//
//   // ================= SAVE PATTERN =================
//
//   Future<void> savePatternToPrefs(
//       List<int> pattern,
//       ) async {
//     final prefs =
//     await SharedPreferences.getInstance();
//
//     await prefs.setString(
//       'lock_pattern',
//       pattern.join(','),
//     );
//   }
//
//   // ================= RESET PATTERN =================
//
//   Future<void> resetPattern() async {
//     final prefs =
//     await SharedPreferences.getInstance();
//
//     await prefs.remove('lock_pattern');
//
//     setState(() {
//       pattern = null;
//       savedPattern = null;
//       isConfirm = false;
//       isVerifyingOldPattern = false;
//       wrongAttempts = 0;
//     });
//
//     if (mounted) {
//       context.replaceSnackbar(
//         content: const Text(
//           "Pattern Reset Successful",
//           textAlign: TextAlign.center,
//           style: TextStyle(
//             color: Colors.white,
//           ),
//         ),
//         color: Colors.orange,
//       );
//     }
//   }
//
//   // ================= MAIN UI =================
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           isVerifyingOldPattern
//               ? "Verify Old Pattern"
//               : isConfirm
//               ? "Confirm Pattern"
//               : "Set New Pattern",
//         ),
//
//         actions: [
//           // BIOMETRIC BUTTON
//           if (isBiometricAvailable)
//             IconButton(
//               icon: Icon(
//                 biometricEnabled
//                     ? Icons.fingerprint
//                     : Icons.fingerprint_outlined,
//               ),
//               onPressed: () async {
//                 if (biometricEnabled) {
//                   await disableBiometric();
//                 } else {
//                   await enableBiometric();
//                 }
//               },
//             ),
//
//           // RESET BUTTON
//           IconButton(
//             icon: const Icon(Icons.refresh),
//             onPressed: resetPattern,
//           ),
//         ],
//       ),
//
//       body: Column(
//         mainAxisAlignment:
//         MainAxisAlignment.spaceEvenly,
//         children: [
//           // TITLE
//           Padding(
//             padding:
//             const EdgeInsets.symmetric(
//               horizontal: 20,
//             ),
//             child: Text(
//               isVerifyingOldPattern
//                   ? "Draw your existing pattern"
//                   : isConfirm
//                   ? "Confirm your new pattern"
//                   : "Draw a new pattern",
//
//               textAlign: TextAlign.center,
//
//               style: const TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//
//           // WRONG ATTEMPTS
//           if (wrongAttempts > 0)
//             Text(
//               "Wrong Attempts : $wrongAttempts / 3",
//               style: const TextStyle(
//                 color: Colors.red,
//                 fontSize: 16,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//
//           // PATTERN LOCK
//           Expanded(
//             child: Center(
//               child: PatternLock(
//                 selectedColor: Colors.amber,
//                 notSelectedColor: Colors.grey,
//                 pointRadius: 12,
//
//                 onInputComplete:
//                     (List<int> input) async {
//                   // MINIMUM POINTS
//                   if (input.length < 3) {
//                     if (mounted) {
//                       context.replaceSnackbar(
//                         content: const Text(
//                           "Minimum 3 points required",
//                           textAlign:
//                           TextAlign.center,
//                           style: TextStyle(
//                             color:
//                             Colors.white,
//                           ),
//                         ),
//                         color: Colors.red,
//                       );
//                     }
//
//                     return;
//                   }
//
//                   // VERIFY OLD PATTERN
//                   if (isVerifyingOldPattern) {
//                     if (listEquals(
//                       input,
//                       savedPattern,
//                     )) {
//                       setState(() {
//                         wrongAttempts = 0;
//
//                         isVerifyingOldPattern =
//                         false;
//
//                         isConfirm = false;
//
//                         pattern = null;
//                       });
//
//                       if (mounted) {
//                         context.replaceSnackbar(
//                           content: const Text(
//                             "Pattern Verified",
//                             textAlign:
//                             TextAlign.center,
//                             style: TextStyle(
//                               color: Colors.white,
//                             ),
//                           ),
//                           color: Colors.green,
//                         );
//                       }
//
//                       // GO HOME
//                       goToHome();
//                     } else {
//                       wrongAttempts++;
//
//                       if (mounted) {
//                         context.replaceSnackbar(
//                           content: Text(
//                             "Incorrect Pattern ($wrongAttempts/3)",
//                             textAlign:
//                             TextAlign.center,
//                             style:
//                             const TextStyle(
//                               color:
//                               Colors.white,
//                             ),
//                           ),
//                           color: Colors.red,
//                         );
//                       }
//
//                       // AUTO OPEN BIOMETRIC
//                       if (wrongAttempts >= 3) {
//                         await authenticateWithBiometric();
//                       }
//                     }
//                   }
//
//                   // CONFIRM NEW PATTERN
//                   else if (isConfirm) {
//                     if (listEquals(
//                       input,
//                       pattern,
//                     )) {
//                       await savePatternToPrefs(
//                         pattern!,
//                       );
//
//                       if (mounted) {
//                         context.replaceSnackbar(
//                           content: const Text(
//                             "Pattern Saved Successfully",
//                             textAlign:
//                             TextAlign.center,
//                             style: TextStyle(
//                               color:
//                               Colors.white,
//                             ),
//                           ),
//                           color: Colors.green,
//                         );
//                       }
//
//                       // GO HOME
//                       goToHome();
//                     } else {
//                       setState(() {
//                         pattern = null;
//                         isConfirm = false;
//                       });
//
//                       if (mounted) {
//                         context.replaceSnackbar(
//                           content: const Text(
//                             "Patterns Do Not Match",
//                             textAlign:
//                             TextAlign.center,
//                             style: TextStyle(
//                               color:
//                               Colors.white,
//                             ),
//                           ),
//                           color: Colors.red,
//                         );
//                       }
//                     }
//                   }
//
//                   // CREATE NEW PATTERN
//                   else {
//                     setState(() {
//                       pattern = input;
//                       isConfirm = true;
//                     });
//
//                     if (mounted) {
//                       context.replaceSnackbar(
//                         content: const Text(
//                           "Please Confirm Pattern",
//                           textAlign:
//                           TextAlign.center,
//                           style: TextStyle(
//                             color:
//                             Colors.white,
//                           ),
//                         ),
//                         color: Colors.blue,
//                       );
//                     }
//                   }
//                 },
//               ),
//             ),
//           ),
//
//           const SizedBox(height: 20),
//         ],
//       ),
//     );
//   }
// }
//old code
// import 'package:flutter/material.dart';
// import 'package:pattern_lock/pattern_lock.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:new_project_2025/view/home/widget/More_page/snackbarextension.dart';
// import 'package:flutter/foundation.dart' show listEquals;
//
// class SetPattern extends StatefulWidget {
//   @override
//   _SetPatternState createState() => _SetPatternState();
// }
//
// class _SetPatternState extends State<SetPattern> {
//   bool isConfirm = false;
//   bool isVerifyingOldPattern = false;
//   List<int>? pattern;
//   List<int>? savedPattern;
//   final scaffoldKey = GlobalKey<ScaffoldState>();
//
//   @override
//   void initState() {
//     super.initState();
//     loadSavedPattern();
//   }
//
//   Future<void> loadSavedPattern() async {
//     final prefs = await SharedPreferences.getInstance();
//     final patternString = prefs.getString('lock_pattern');
//     if (patternString != null) {
//       setState(() {
//         savedPattern = patternString.split(',').map((e) => int.parse(e)).toList();
//         isVerifyingOldPattern = true;
//       });
//     }
//   }
//
//   Future<void> savePatternToPrefs(List<int> pattern) async {
//     final prefs = await SharedPreferences.getInstance();
//     final patternString = pattern.join(',');
//     await prefs.setString('lock_pattern', patternString);
//     print("Saved pattern: $patternString");
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       key: scaffoldKey,
//       appBar: AppBar(
//         title: Text(isVerifyingOldPattern ? "Verify Old Pattern" : isConfirm ? "Confirm New Pattern" : "Set New Pattern"),
//       ),
//       body: Column(
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         children: <Widget>[
//           Flexible(
//             child: Text(
//               isVerifyingOldPattern ? "Draw your existing pattern" : isConfirm ? "Confirm new pattern" : "Draw new pattern",
//               style: TextStyle(fontSize: 26),
//             ),
//           ),
//           Flexible(
//             child: PatternLock(
//               selectedColor: Colors.amber,
//               pointRadius: 12,
//               onInputComplete: (List<int> input) async {
//                 if (input.length < 3) {
//                   context.replaceSnackbar(
//                     content: Text(
//                       "At least 3 points required",
//                       textAlign: TextAlign.center,
//                       style: TextStyle(color: Colors.white, fontSize: 12),
//                     ),
//                     color: Colors.red,
//                   );
//                   return;
//                 }
//
//                 if (isVerifyingOldPattern) {
//                   if (listEquals<int>(input, savedPattern)) {
//                     setState(() {
//                       isVerifyingOldPattern = false;
//                       pattern = null;
//                       isConfirm = false;
//                     });
//                     context.replaceSnackbar(
//                       content: Text(
//                         "Old pattern verified",
//                         textAlign: TextAlign.center,
//                         style: TextStyle(color: Colors.white, fontSize: 12),
//                       ),
//                       color: Colors.green,
//                     );
//                   } else {
//                     context.replaceSnackbar(
//                       content: Text(
//                         "Incorrect pattern",
//                         textAlign: TextAlign.center,
//                         style: TextStyle(color: Colors.white, fontSize: 12),
//                       ),
//                       color: Colors.red,
//                     );
//                   }
//                 } else if (isConfirm) {
//                   if (listEquals<int>(input, pattern)) {
//                     await savePatternToPrefs(pattern!);
//                     context.replaceSnackbar(
//                       content: Text(
//                         "Pattern saved successfully",
//                         textAlign: TextAlign.center,
//                         style: TextStyle(color: Colors.white, fontSize: 12),
//                       ),
//                       color: Colors.green,
//                     );
//                     Navigator.of(context).pop(pattern);
//                   } else {
//                     context.replaceSnackbar(
//                       content: Text(
//                         "Patterns do not match",
//                         textAlign: TextAlign.center,
//                         style: TextStyle(color: Colors.white, fontSize: 12),
//                       ),
//                       color: Colors.red,
//                     );
//                     setState(() {
//                       pattern = null;
//                       isConfirm = false;
//                     });
//                   }
//                 } else {
//                   setState(() {
//                     pattern = input;
//                     isConfirm = true;
//                   });
//                 }
//               },
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// // import 'package:flutter/foundation.dart';
// // import 'package:flutter/material.dart';
// //
// // import 'package:new_project_2025/view/home/widget/More_page/snackbarextension.dart';
// // import 'package:pattern_lock/pattern_lock.dart';
// // import 'package:shared_preferences/shared_preferences.dart';
// //
// // class SetPattern extends StatefulWidget {
// //   @override
// //   _SetPatternState createState() => _SetPatternState();
// // }
// // Future<void> savePatternToPrefs(List<int> pattern) async {
// //   final prefs = await SharedPreferences.getInstance();
// //   final patternString = pattern.join(',');
// //   await prefs.setString('lock_pattern', patternString);
// //
// //   // ✅ Print the saved pattern
// //   print("Saved pattern: $patternString");
// // }
// //
// // class _SetPatternState extends State<SetPattern> {
// //   bool isConfirm = false;
// //   List<int>? pattern;
// //
// //   final scaffoldKey = GlobalKey<ScaffoldState>();
// //
// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       key: scaffoldKey,
// //       appBar: AppBar(
// //         title: Text("Check Pattern"),
// //       ),
// //       body: Column(
// //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
// //         children: <Widget>[
// //           Flexible(
// //             child: Text(
// //               isConfirm ? "Confirm pattern" : "Draw pattern",
// //               style: TextStyle(fontSize: 26),
// //             ),
// //           ),
// //           Flexible(
// //             child: PatternLock(
// //               selectedColor: Colors.amber,
// //               pointRadius: 12,
// //               onInputComplete: (List<int> input) async {
// //                 if (input.length < 3) {
// //                   context.replaceSnackbar(
// //                     content: Text("At least 3 points required",
// //                         textAlign: TextAlign.center,
// //                         style: TextStyle(color: Colors.white, fontSize: 12)),
// //                     color: Colors.red,
// //                   );
// //                   return;
// //                 }
// //
// //                 if (isConfirm) {
// //                   if (listEquals<int>(input, pattern)) {
// //                     // ✅ Save to SharedPreferences
// //                     await savePatternToPrefs(pattern!);
// //
// //                     context.replaceSnackbar(
// //                       content: Text("Pattern saved successfully",
// //                           textAlign: TextAlign.center,
// //                           style: TextStyle(color: Colors.white, fontSize: 12)),
// //                       color: Colors.green,
// //                     );
// //
// //                     Navigator.of(context).pop(pattern);
// //                   } else {
// //                     context.replaceSnackbar(
// //                       content: Text("Patterns do not match",
// //                           textAlign: TextAlign.center,
// //                           style: TextStyle(color: Colors.white, fontSize: 12)),
// //                       color: Colors.red,
// //                     );
// //                     setState(() {
// //                       pattern = null;
// //                       isConfirm = false;
// //                     });
// //                   }
// //                 } else {
// //                   setState(() {
// //                     pattern = input;
// //                     isConfirm = true;
// //                   });
// //                 }
// //               },
// //
// //
// //             ),
// //           ),
// //         ],
// //       ),
// //     );
// //   }
// // }