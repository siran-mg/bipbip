import 'package:flutter/material.dart';

/// Custom controls for stepper
class StepperControls extends StatelessWidget {
  /// Current step index
  final int currentStep;
  
  /// Total number of steps
  final int totalSteps;
  
  /// Callback when continue button is pressed
  final VoidCallback onStepContinue;
  
  /// Callback when cancel button is pressed
  final VoidCallback onStepCancel;
  
  /// Text for continue button
  final String continueText;
  
  /// Text for cancel button
  final String cancelText;

  /// Creates a new StepperControls
  const StepperControls({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.onStepContinue,
    required this.onStepCancel,
    this.continueText = 'CONTINUER',
    this.cancelText = 'RETOUR',
  });

  @override
  Widget build(BuildContext context) {
    final isLastStep = currentStep == totalSteps - 1;
    
    return Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Row(
        children: [
          Expanded(
            child: FilledButton(
              onPressed: onStepContinue,
              child: Text(
                isLastStep ? 'S\'INSCRIRE' : continueText,
              ),
            ),
          ),
          if (currentStep > 0) ...[
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: onStepCancel,
                child: Text(cancelText),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
