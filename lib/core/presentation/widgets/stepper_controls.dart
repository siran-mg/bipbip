import 'package:flutter/material.dart';

/// Custom controls for stepper
class StepperControls extends StatelessWidget {
  /// Current step index
  final int currentStep;

  /// Total number of steps
  final int totalSteps;

  /// Callback when continue button is pressed
  final VoidCallback? onStepContinue;

  /// Callback when cancel button is pressed
  final VoidCallback? onStepCancel;

  /// Whether the form is in loading state
  final bool isLoading;

  /// Text for continue button
  final String continueText;

  /// Text for cancel button
  final String cancelText;

  /// Creates a new StepperControls
  const StepperControls({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    this.onStepContinue,
    this.onStepCancel,
    this.continueText = 'CONTINUER',
    this.cancelText = 'RETOUR',
    this.isLoading = false,
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
              onPressed: isLoading ? null : onStepContinue,
              child: isLoading && isLastStep
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      isLastStep ? 'S\'INSCRIRE' : continueText,
                    ),
            ),
          ),
          if (currentStep > 0) ...[
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: isLoading ? null : onStepCancel,
                child: Text(cancelText),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
