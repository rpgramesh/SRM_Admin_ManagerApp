import 'package:flutter/material.dart';
import '../theme/design_tokens.dart';

class VoiceListeningDialog extends StatelessWidget {
  final bool isListening;
  final String text;

  const VoiceListeningDialog({
    super.key,
    required this.isListening,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: DesignTokens.neutralWhite,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(DesignTokens.radiusLarge),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(DesignTokens.space24),
            decoration: BoxDecoration(
              color: isListening
                  ? DesignTokens.primaryOrange.withOpacity(0.1)
                  : DesignTokens.neutralGrey100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isListening ? Icons.mic : Icons.mic_none,
              size: 48,
              color: isListening
                  ? DesignTokens.primaryOrange
                  : DesignTokens.neutralGrey600,
            ),
          ),
          const SizedBox(height: DesignTokens.space24),
          Text(
            isListening ? 'Listening...' : 'Processing...',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: DesignTokens.neutralBlack,
            ),
          ),
          const SizedBox(height: DesignTokens.space16),
          Text(
            text.isEmpty ? 'Say something like "Two burgers and a coke"' : text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: DesignTokens.neutralGrey700,
            ),
          ),
          const SizedBox(height: DesignTokens.space24),
          if (isListening)
            LinearProgressIndicator(
              backgroundColor: DesignTokens.neutralGrey200,
              valueColor:
                  AlwaysStoppedAnimation<Color>(DesignTokens.primaryOrange),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Cancel',
            style: TextStyle(color: DesignTokens.neutralGrey600),
          ),
        ),
      ],
    );
  }
}
