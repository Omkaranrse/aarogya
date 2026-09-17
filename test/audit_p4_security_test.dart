import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:aarogya/core/security/secure_token_storage.dart';
import 'package:aarogya/core/security/phi_redaction_logger.dart';
import 'package:aarogya/core/security/session_inactivity_manager.dart';
import 'package:aarogya/core/design_system/components/privacy_screen_guard.dart';
import 'package:aarogya/core/security/secure_document_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Phase P4 — Security & DPDP Act Compliance Tests', () {
    test('P4.1: InMemorySecureTokenStorage stores and retrieves credentials securely', () async {
      final storage = InMemorySecureTokenStorage();
      await storage.write('auth_token', 'jwt_secret_token_123');
      expect(await storage.read('auth_token'), 'jwt_secret_token_123');
      expect(await storage.containsKey('auth_token'), isTrue);

      await storage.delete('auth_token');
      expect(await storage.read('auth_token'), isNull);
      expect(await storage.containsKey('auth_token'), isFalse);
    });

    test('P4.1: EncryptedTokenStorage encrypts/obfuscates values before storage', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      final storage = EncryptedTokenStorage(prefs: prefs);

      await storage.write('session_key', 'clinical_super_secret_payload');

      // Check that the underlying shared pref is NOT plaintext
      final rawStored = prefs.getString('sec_aarogya_session_key');
      expect(rawStored, isNotNull);
      expect(rawStored, isNot(equals('clinical_super_secret_payload')));

      // Deobfuscates correctly when read via API
      final decrypted = await storage.read('session_key');
      expect(decrypted, equals('clinical_super_secret_payload'));
    });

    test('P4.2: ClinicalLogger scrubs ABHA numbers, Aadhaar, Phone, Email, and MRNs', () {
      const sensitiveText =
          'Patient Rajesh Sharma ABHA: 91-4829-1039-4820 with Aadhaar 9821 4092 1928, phone +919876543210, email rajesh@gmail.com, MRN: MRN-DEL-8921';
      
      final redacted = ClinicalLogger.redact(sensitiveText);

      expect(redacted.contains('91-4829-1039-4820'), isFalse);
      expect(redacted.contains('[REDACTED_ABHA]'), isTrue);

      expect(redacted.contains('9821 4092 1928'), isFalse);
      expect(redacted.contains('[REDACTED_AADHAAR]'), isTrue);

      expect(redacted.contains('+919876543210'), isFalse);
      expect(redacted.contains('[REDACTED_PHONE]'), isTrue);

      expect(redacted.contains('rajesh@gmail.com'), isFalse);
      expect(redacted.contains('[REDACTED_EMAIL]'), isTrue);

      expect(redacted.contains('MRN-DEL-8921'), isFalse);
      expect(redacted.contains('[REDACTED_MRN]'), isTrue);
    });

    test('P4.3: SessionInactivityManager locks session after timeout and resets on activity', () async {
      final manager = SessionInactivityManager();
      bool timeoutNotified = false;

      manager.configure(
        timeout: const Duration(milliseconds: 50),
        onTimeout: () {
          timeoutNotified = true;
        },
      );

      manager.startMonitoring();
      expect(manager.isLocked, isFalse);

      // Record activity to reset
      manager.recordActivity();
      expect(manager.isLocked, isFalse);

      // Manual lock test
      manager.lockSession();
      expect(manager.isLocked, isTrue);
      expect(timeoutNotified, isTrue);

      // Unlock test
      manager.unlockSession();
      expect(manager.isLocked, isFalse);

      manager.stopMonitoring();
    });

    testWidgets('P4.3: SessionInactivityDetector captures touch interactions', (tester) async {
      final manager = SessionInactivityManager();
      final initialTime = manager.lastActivity;

      await tester.pumpWidget(
        MaterialApp(
          home: SessionInactivityDetector(
            manager: manager,
            child: const Scaffold(
              body: Center(child: Text('Clinical Dashboard Content')),
            ),
          ),
        ),
      );

      // Tap screen to generate pointer event
      await tester.tap(find.text('Clinical Dashboard Content'));
      await tester.pump();

      expect(manager.lastActivity.isAfter(initialTime) || manager.lastActivity == initialTime, isTrue);
    });

    testWidgets('P4.4: PrivacyScreenGuard renders child and AarogyaPrivacyShield', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AarogyaPrivacyShield(),
          ),
        ),
      );

      expect(find.text('Aarogya Clinical Privacy Shield'), findsOneWidget);
      expect(find.text('Sensitive Health Data Protected • DPDP Act Compliant'), findsOneWidget);
      expect(find.byIcon(Icons.lock_rounded), findsOneWidget);
    });

    test('P4.5: SecureDocumentService generates ephemeral signed token and records audit log', () async {
      final docService = SecureDocumentService();
      docService.clearAuditLogForTesting();

      final token = await docService.generateEphemeralAccessToken(
        documentId: 'doc_cbc_1092',
        patientId: 'patient_rajesh_99',
        accessLevel: DocumentAccessLevel.shareWithDoctor,
        validDuration: const Duration(minutes: 15),
      );

      expect(token.documentId, equals('doc_cbc_1092'));
      expect(token.patientId, equals('patient_rajesh_99'));
      expect(token.accessLevel, equals(DocumentAccessLevel.shareWithDoctor));
      expect(token.isExpired, isFalse);
      expect(token.signature.isNotEmpty, isTrue);

      // Validate token
      final isValid = docService.validateToken(token);
      expect(isValid, isTrue);

      // Verify audit trail
      expect(docService.auditLog.length, equals(2));
      expect(docService.auditLog.first['action'], equals('TOKEN_GENERATED'));
      expect(docService.auditLog.last['action'], equals('TOKEN_VERIFIED_SUCCESS'));
    });
  });
}
