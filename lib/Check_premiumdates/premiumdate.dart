
// FILE: lib/services/Premium_services/Premium_services.dart
// UPDATED with TRIAL DATE LOGIC

import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:new_project_2025/services/API_services/API_services.dart'
show ApiHelper;

/// Premium Status Model with Trial Support
class PremiumStatus {
final bool isActive;
final int daysRemaining;
final String message;
final String? initialDate;
final String? endDate;

// TRIAL FIELDS
final bool isTrialExpired;
final int trialDaysRemaining;
final String? trialEndDate;
final bool isPremium;

PremiumStatus({
required this.isActive,
required this.daysRemaining,
required this.message,
this.initialDate,
this.endDate,
this.isTrialExpired = false,
this.trialDaysRemaining = 0,
this.trialEndDate,
this.isPremium = false,
});

factory PremiumStatus.fromJson(Map<String, dynamic> json) {
// Get premium status - handle both 'status' (int) and 'premium' (string)
final statusValue = json['status'] ?? json['premium'] ?? '0';
int premiumStatus = 0;

if (statusValue is int) {
premiumStatus = statusValue;
} else if (statusValue is String) {
premiumStatus = int.tryParse(statusValue) ?? 0;
}

final trialEndDateStr = json['trialenddate'];
final currentDateStr = json['current_date'];

bool isTrialExpired = false;
int trialDaysRemaining = 0;

print('\n╔════════════════════════════════════════════════════════╗');
print('║         TRIAL DATE CALCULATION                         ║');
print('╚════════════════════════════════════════════════════════╝');
print('Premium Status: $premiumStatus');
print('Current Date from API: $currentDateStr');
print('Trial End Date String: $trialEndDateStr');

// Check if premium is 0 (trial user)
if (premiumStatus == 0 && trialEndDateStr != null && trialEndDateStr.isNotEmpty) {
try {
// Parse trial end date
final trialEndDate = DateTime.parse(trialEndDateStr);

// Use current_date from API if available, otherwise use device DateTime.now()
final now = (currentDateStr != null && currentDateStr.isNotEmpty)
? DateTime.parse(currentDateStr)
    : DateTime.now();

print('\n✓ Parsed Trial End Date: $trialEndDate');
print('✓ Using Current DateTime: $now');

// Calculate difference
final difference = trialEndDate.difference(now);
trialDaysRemaining = difference.inDays;
isTrialExpired = trialDaysRemaining <= 0;

print('\n⏱️ Time Difference:');
print('   Days: $trialDaysRemaining');
print('   Hours: ${difference.inHours % 24}');
print('   Minutes: ${difference.inMinutes % 60}');
print('\nTrial Days Remaining: $trialDaysRemaining');
print('Is Trial Expired: $isTrialExpired');

// Clamp to non-negative for display
if (trialDaysRemaining < 0) {
trialDaysRemaining = 0;
}
} catch (e) {
print('❌ Error parsing trial date: $e');
isTrialExpired = true;
trialDaysRemaining = 0;
}
} else {
print('⚠️ Premium is not 0 or trial end date is empty');
}

print('═══════════════════════════════════════════════════════\n');

return PremiumStatus(
isActive: (premiumStatus == 1) || (premiumStatus == 0 && !isTrialExpired),
daysRemaining: json['pending_days'] ?? 0,
message: json['message'] ?? '',
initialDate: json['save_premium_initialdate'],
endDate: json['save_premium_end_date'],
isTrialExpired: isTrialExpired,
trialDaysRemaining: trialDaysRemaining,
trialEndDate: trialEndDateStr,
isPremium: premiumStatus == 1,
);
}

factory PremiumStatus.expired() {
return PremiumStatus(
isActive: false,
daysRemaining: 0,
message: 'Premium expired',
isTrialExpired: true,
);
}

factory PremiumStatus.active() {
return PremiumStatus(
isActive: true,
daysRemaining: 999,
message: 'Premium active',
isPremium: true,
);
}
}

/// Premium Service - Singleton Pattern
class PremiumService {
static final PremiumService _instance = PremiumService._internal();
factory PremiumService() => _instance;
PremiumService._internal();

PremiumStatus? _cachedStatus;
DateTime? _lastChecked;
final Duration _cacheExpiration = const Duration(minutes: 5);

/// Check premium status from API
Future<PremiumStatus> checkPremiumStatus({bool forceRefresh = false}) async {
if (!forceRefresh &&
_cachedStatus != null &&
_lastChecked != null &&
DateTime.now().difference(_lastChecked!) < _cacheExpiration) {
return _cachedStatus!;
}

try {
final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
final response = await ApiHelper().postApiResponse(
'checkPremiumDates.php',
{'timestamp': timestamp},
);

final data = json.decode(response);
_cachedStatus = PremiumStatus.fromJson(data);
_lastChecked = DateTime.now();

return _cachedStatus!;
} catch (e) {
print('Error checking premium status: $e');
return PremiumStatus.expired();
}
}

PremiumStatus? getCachedStatus() => _cachedStatus;

void clearCache() {
_cachedStatus = null;
_lastChecked = null;
}

Future<bool> isPremiumActive({bool forceRefresh = false}) async {
final status = await checkPremiumStatus(forceRefresh: forceRefresh);
return status.isActive;
}

// CHECK IF USER CAN ADD DATA (handles both premium and trial)
Future<bool> canAddData({bool forceRefresh = false}) async {
final status = await checkPremiumStatus(forceRefresh: forceRefresh);
return status.isActive && !status.isTrialExpired;
}

/// Modern Premium Status Banner - Compact & Beautiful
static Widget buildPremiumBanner({
required BuildContext context,
required PremiumStatus status,
required bool isChecking,
VoidCallback? onRefresh,
}) {
final size = MediaQuery.of(context).size;
final isSmallScreen = size.width < 360;

if (isChecking) {
return _buildCheckingBanner(size, isSmallScreen);
}

// TRIAL LOGIC: If trial and 15 days or less remaining
if (!status.isPremium &&
!status.isTrialExpired &&
status.trialDaysRemaining <= 15 &&
status.trialDaysRemaining > 0) {
return _buildTrialWarningBanner(
size,
isSmallScreen,
status,
onRefresh,
);
}

// TRIAL EXPIRED
if (status.isTrialExpired) {
return _buildTrialExpiredBanner(size, isSmallScreen, status, onRefresh);
}

// PREMIUM ACTIVE
if (status.isActive) {
return _buildActiveBanner(size, isSmallScreen, status, onRefresh);
}

return const SizedBox.shrink();
}

static Widget _buildCheckingBanner(Size size, bool isSmallScreen) {
return TweenAnimationBuilder(
tween: Tween<double>(begin: 0, end: 1),
duration: const Duration(milliseconds: 600),
curve: Curves.easeOut,
builder: (context, double value, child) {
return Transform.translate(
offset: Offset(0, -20 * (1 - value)),
child: Opacity(
opacity: value,
child: Container(
margin: EdgeInsets.symmetric(
horizontal: size.width * 0.04,
vertical: size.height * 0.008,
),
padding: EdgeInsets.symmetric(
horizontal: size.width * 0.04,
vertical: size.height * 0.012,
),
decoration: BoxDecoration(
gradient: LinearGradient(
colors: [Colors.blue[50]!, Colors.cyan[50]!],
),
borderRadius: BorderRadius.circular(14),
border: Border.all(color: Colors.blue[200]!, width: 1.5),
boxShadow: [
BoxShadow(
color: Colors.blue.withOpacity(0.15),
blurRadius: 10,
offset: const Offset(0, 4),
),
],
),
child: Row(
children: [
SizedBox(
width: 24,
height: 24,
child: CircularProgressIndicator(
strokeWidth: 2.5,
valueColor: AlwaysStoppedAnimation(Colors.blue[600]),
),
),
SizedBox(width: size.width * 0.03),
Expanded(
child: Text(
'Checking premium status...',
style: TextStyle(
fontSize: isSmallScreen ? 13 : 14,
fontWeight: FontWeight.w600,
color: Colors.blue[700],
),
),
),
],
),
),
),
);
},
);
}

// TRIAL WARNING BANNER (15 days or less)
static Widget _buildTrialWarningBanner(
Size size,
bool isSmallScreen,
PremiumStatus status,
VoidCallback? onRefresh,
) {
return TweenAnimationBuilder(
tween: Tween<double>(begin: 0, end: 1),
duration: const Duration(milliseconds: 600),
curve: Curves.easeOut,
builder: (context, double value, child) {
return Transform.translate(
offset: Offset(0, -20 * (1 - value)),
child: Opacity(
opacity: value,
child: Container(
margin: EdgeInsets.symmetric(
horizontal: size.width * 0.04,
vertical: size.height * 0.008,
),
padding: EdgeInsets.symmetric(
horizontal: size.width * 0.04,
vertical: size.height * 0.012,
),
decoration: BoxDecoration(
gradient: LinearGradient(
colors: [Colors.orange[50]!, Colors.yellow[50]!],
),
borderRadius: BorderRadius.circular(14),
border: Border.all(color: Colors.orange[300]!, width: 1.5),
boxShadow: [
BoxShadow(
color: Colors.orange.withOpacity(0.15),
blurRadius: 10,
offset: const Offset(0, 4),
),
],
),
child: Row(
children: [
Container(
padding: const EdgeInsets.all(8),
decoration: BoxDecoration(
color: Colors.orange[600],
shape: BoxShape.circle,
),
child: Icon(
Icons.warning_rounded,
color: Colors.white,
size: 20,
),
),
SizedBox(width: size.width * 0.03),
Expanded(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
'Trial Ending Soon',
style: TextStyle(
fontSize: isSmallScreen ? 13 : 14,
fontWeight: FontWeight.w800,
color: Colors.orange[800],
),
),
Text(
'${status.trialDaysRemaining} days left in your trial',
style: TextStyle(
fontSize: isSmallScreen ? 11 : 12,
fontWeight: FontWeight.w600,
color: Colors.grey[600],
),
),
],
),
),
if (onRefresh != null)
GestureDetector(
onTap: onRefresh,
child: Container(
padding: const EdgeInsets.all(6),
decoration: BoxDecoration(
color: Colors.white.withOpacity(0.6),
shape: BoxShape.circle,
),
child: Icon(
Icons.refresh_rounded,
size: 16,
color: Colors.orange[700],
),
),
),
],
),
),
),
);
},
);
}

// TRIAL EXPIRED BANNER
static Widget _buildTrialExpiredBanner(
Size size,
bool isSmallScreen,
PremiumStatus status,
VoidCallback? onRefresh,
) {
return TweenAnimationBuilder(
tween: Tween<double>(begin: 0, end: 1),
duration: const Duration(milliseconds: 600),
curve: Curves.easeOut,
builder: (context, double value, child) {
return Transform.translate(
offset: Offset(0, -20 * (1 - value)),
child: Opacity(
opacity: value,
child: Container(
margin: EdgeInsets.symmetric(
horizontal: size.width * 0.04,
vertical: size.height * 0.008,
),
padding: EdgeInsets.symmetric(
horizontal: size.width * 0.04,
vertical: size.height * 0.012,
),
decoration: BoxDecoration(
gradient: LinearGradient(
colors: [Colors.red[50]!, Colors.pink[50]!],
),
borderRadius: BorderRadius.circular(14),
border: Border.all(color: Colors.red[300]!, width: 1.5),
boxShadow: [
BoxShadow(
color: Colors.red.withOpacity(0.15),
blurRadius: 10,
offset: const Offset(0, 4),
),
],
),
child: Row(
children: [
Container(
padding: const EdgeInsets.all(8),
decoration: BoxDecoration(
color: Colors.red[600],
shape: BoxShape.circle,
),
child: const Icon(
Icons.lock_rounded,
color: Colors.white,
size: 20,
),
),
SizedBox(width: size.width * 0.03),
Expanded(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
'Trial Expired',
style: TextStyle(
fontSize: isSmallScreen ? 13 : 14,
fontWeight: FontWeight.w800,
color: Colors.red[800],
),
),
Text(
'Upgrade to continue',
style: TextStyle(
fontSize: isSmallScreen ? 11 : 12,
fontWeight: FontWeight.w600,
color: Colors.grey[600],
),
),
],
),
),
if (onRefresh != null)
GestureDetector(
onTap: onRefresh,
child: Container(
padding: const EdgeInsets.all(6),
decoration: BoxDecoration(
color: Colors.white.withOpacity(0.6),
shape: BoxShape.circle,
),
child: Icon(
Icons.refresh_rounded,
size: 16,
color: Colors.red[700],
),
),
),
],
),
),
),
);
},
);
}

static Widget _buildActiveBanner(
Size size,
bool isSmallScreen,
PremiumStatus status,
VoidCallback? onRefresh,
) {
final daysLeft = status.daysRemaining;
final percentage = math.min((daysLeft / 30) * 100, 100);
final isWarning = daysLeft <= 7;

return TweenAnimationBuilder(
tween: Tween<double>(begin: 0, end: 1),
duration: const Duration(milliseconds: 600),
curve: Curves.easeOut,
builder: (context, double value, child) {
return Transform.translate(
offset: Offset(0, -20 * (1 - value)),
child: Opacity(
opacity: value,
child: Container(
margin: EdgeInsets.symmetric(
horizontal: size.width * 0.04,
vertical: size.height * 0.008,
),
padding: EdgeInsets.symmetric(
horizontal: size.width * 0.04,
vertical: size.height * 0.012,
),
decoration: BoxDecoration(
gradient: LinearGradient(
colors:
isWarning
? [Colors.orange[50]!, Colors.yellow[50]!]
    : [Colors.green[50]!, Colors.green[100]!],
),
borderRadius: BorderRadius.circular(14),
border: Border.all(
color: isWarning ? Colors.orange[300]! : Colors.green[300]!,
width: 1.5,
),
boxShadow: [
BoxShadow(
color: (isWarning ? Colors.orange : Colors.green)
    .withOpacity(0.15),
blurRadius: 10,
offset: const Offset(0, 4),
),
],
),
child: Row(
children: [
Container(
padding: const EdgeInsets.all(8),
decoration: BoxDecoration(
color:
(isWarning ? Colors.orange : Colors.green)[600],
shape: BoxShape.circle,
),
child: Icon(
isWarning
? Icons.warning_rounded
    : Icons.check_circle,
color: Colors.white,
size: 20,
),
),
SizedBox(width: size.width * 0.03),
Expanded(
child: Column(
crossAxisAlignment: CrossAxisAlignment.start,
children: [
Text(
'Premium Active',
style: TextStyle(
fontSize: isSmallScreen ? 13 : 14,
fontWeight: FontWeight.w800,
color:
isWarning
? Colors.orange[800]
    : Colors.green[800],
),
),
Text(
'$daysLeft days remaining',
style: TextStyle(
fontSize: isSmallScreen ? 11 : 12,
fontWeight: FontWeight.w600,
color: Colors.grey[600],
),
),
],
),
),
if (onRefresh != null)
GestureDetector(
onTap: onRefresh,
child: Container(
padding: const EdgeInsets.all(6),
decoration: BoxDecoration(
color: Colors.white.withOpacity(0.6),
shape: BoxShape.circle,
),
child: Icon(
Icons.refresh_rounded,
size: 16,
color:
isWarning
? Colors.orange[700]
    : Colors.green[700],
),
),
),
],
),
),
),
);
},
);
}

/// Show premium expired dialog
static void showPremiumExpiredDialog(
BuildContext context, {
String? customMessage,
VoidCallback? onUpgrade,
}) {
final size = MediaQuery.of(context).size;
final isSmallScreen = size.width < 360;

showGeneralDialog(
context: context,
barrierDismissible: true,
barrierLabel: '',
barrierColor: Colors.black.withOpacity(0.6),
transitionDuration: const Duration(milliseconds: 400),
pageBuilder: (context, anim1, anim2) => const SizedBox.shrink(),
transitionBuilder: (context, anim1, anim2, child) {
return ScaleTransition(
scale: Tween<double>(
begin: 0.7,
end: 1.0,
).animate(CurvedAnimation(parent: anim1, curve: Curves.elasticOut)),
child: FadeTransition(
opacity: anim1,
child: Dialog(
shape: RoundedRectangleBorder(
borderRadius: BorderRadius.circular(28),
),
child: Container(
padding: EdgeInsets.all(size.width * 0.06),
decoration: BoxDecoration(
gradient: LinearGradient(
colors: [Colors.white, Colors.red[50]!, Colors.orange[50]!],
),
borderRadius: BorderRadius.circular(28),
boxShadow: [
BoxShadow(
color: Colors.red.withOpacity(0.3),
blurRadius: 20,
offset: const Offset(0, 10),
),
],
),
child: Column(
mainAxisSize: MainAxisSize.min,
children: [
TweenAnimationBuilder(
tween: Tween<double>(begin: 0, end: 1),
duration: const Duration(milliseconds: 600),
curve: Curves.elasticOut,
builder: (context, double value, child) {
return Transform.scale(
scale: value,
child: Container(
padding: EdgeInsets.all(
isSmallScreen ? 16.0 : 20.0,
),
decoration: BoxDecoration(
gradient: LinearGradient(
colors: [Colors.red[500]!, Colors.orange[500]!],
),
shape: BoxShape.circle,
boxShadow: [
BoxShadow(
color: Colors.red.withOpacity(0.5),
blurRadius: 20,
spreadRadius: 3,
),
],
),
child: Icon(
Icons.lock_rounded,
color: Colors.white,
size: isSmallScreen ? 36 : 40,
),
),
);
},
),
const SizedBox(height: 20),
Text(
'Premium Expired',
style: TextStyle(
fontSize: isSmallScreen ? 20 : 22,
fontWeight: FontWeight.w900,
color: Colors.red[700],
),
),
const SizedBox(height: 12),
Text(
customMessage ??
'Your trial or premium has ended.\nPlease upgrade to continue.',
textAlign: TextAlign.center,
style: TextStyle(
fontSize: isSmallScreen ? 14 : 15,
color: Colors.grey[700],
height: 1.5,
),
),
const SizedBox(height: 24),
],
),
),
),
),
);
},
);
}
}
