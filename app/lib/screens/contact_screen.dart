import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/api_service.dart';
import '../theme/app_theme.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});
  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _message = TextEditingController();
  String _subject = 'General enquiry';
  bool _sending = false;
  bool _sent = false;
  String? _errorMsg;

  static const _subjects = [
    'General enquiry',
    'News tip',
    'Advertising',
    'Partnership',
    'Careers',
    'Other',
  ];

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _phone.dispose();
    _message.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _sending = true;
      _errorMsg = null;
    });
    try {
      await ApiService.instance.sendContact(
        name: _name.text.trim(),
        email: _email.text.trim(),
        phone: _phone.text.trim(),
        subject: _subject,
        message: _message.text.trim(),
      );
      if (mounted) setState(() => _sent = true);
    } catch (e) {
      if (mounted) setState(() => _errorMsg = 'Failed to send. Try again.');
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Contact us')),
      body: _sent
          ? _successView()
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Text(
                  "Let's talk.",
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'News tip? Advertising? Partnership? Send us a message — we reply within one business day.',
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium
                      ?.copyWith(color: AppColors.textLightDim),
                ),
                const SizedBox(height: 24),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _field(_name, 'Full name *',
                          validator: (v) => (v == null || v.isEmpty)
                              ? 'Required'
                              : null),
                      _field(_email, 'Email *',
                          keyboardType: TextInputType.emailAddress,
                          validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        if (!v.contains('@')) return 'Invalid email';
                        return null;
                      }),
                      _field(_phone, 'Phone (optional)',
                          keyboardType: TextInputType.phone),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: _subject,
                        decoration: _decoration('Subject *'),
                        items: _subjects
                            .map((s) => DropdownMenuItem(
                                value: s, child: Text(s)))
                            .toList(),
                        onChanged: (v) => setState(() => _subject = v!),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _message,
                        maxLines: 5,
                        decoration: _decoration('Message *'),
                        validator: (v) => (v == null || v.isEmpty)
                            ? 'Required'
                            : null,
                      ),
                      if (_errorMsg != null) ...[
                        const SizedBox(height: 12),
                        Text(_errorMsg!,
                            style: const TextStyle(color: AppColors.brandRed)),
                      ],
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: _sending ? null : _submit,
                          style: FilledButton.styleFrom(
                            backgroundColor: AppColors.brandRed,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(999)),
                          ),
                          child: Text(_sending ? 'Sending…' : 'Send message'),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                _contactCard(),
              ],
            ),
    );
  }

  Widget _field(TextEditingController c, String label,
      {TextInputType? keyboardType, String? Function(String?)? validator}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: c,
        keyboardType: keyboardType,
        decoration: _decoration(label),
        validator: validator,
      ),
    );
  }

  InputDecoration _decoration(String label) => InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      );

  Widget _successView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: const BoxDecoration(
                gradient: AppColors.brandGradient,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 20),
            const Text('Message sent',
                style:
                    TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            const Text(
              'Thanks. A member of our team will get back to you within one business day.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: () => setState(() {
                _sent = false;
                _formKey.currentState?.reset();
                _name.clear();
                _email.clear();
                _phone.clear();
                _message.clear();
              }),
              child: const Text('Send another'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _contactCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0F0F14), Color(0xFF1A1A22)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _contactRow(Icons.phone, 'Call the newsroom', '+254 713 176 146',
              () => launchUrl(Uri.parse('tel:+254713176146'))),
          const SizedBox(height: 16),
          _contactRow(Icons.email_outlined, 'Editorial',
              'gotabgaatelevision@gmail.com',
              () => launchUrl(Uri.parse('mailto:gotabgaatelevision@gmail.com'))),
          const SizedBox(height: 16),
          _contactRow(Icons.location_on_outlined, 'Studios',
              'Kericho County, Kenya', null),
        ],
      ),
    );
  }

  Widget _contactRow(
      IconData icon, String label, String value, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, color: AppColors.brandOrange, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(color: Colors.white, fontSize: 15)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
