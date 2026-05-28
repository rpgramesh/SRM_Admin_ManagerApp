import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../providers/cart_provider.dart';
import '../models/menu_item.dart';

class VoiceOrderService {
  final stt.SpeechToText _speech = stt.SpeechToText();
  
  // Getters
  bool get isListening => _speech.isListening;

  // Initialize the speech engine
  Future<bool> init() async {
    return await _speech.initialize(
      onStatus: (status) => print('onStatus: $status'),
      onError: (errorNotification) => print('onError: $errorNotification'),
    );
  }

  // Start listening
  void startListening(Function(String, bool) onResult) {
    _speech.listen(
      onResult: (val) => onResult(val.recognizedWords, val.finalResult),
      listenFor: const Duration(seconds: 30),
      pauseFor: const Duration(seconds: 3),
      partialResults: true,
      cancelOnError: true,
      listenMode: stt.ListenMode.search,
    );
  }

  // Stop listening
  Future<void> stopListening() async {
    await _speech.stop();
  }

  // Process the text command
  String processCommand(String text, List<MenuItem> menuItems, CartProvider cart) {
    text = text.toLowerCase();
    String feedback = '';
    List<String> addedItems = [];
    
    // Basic logic: iterate through menu items and check if their name is in the spoken text
    for (var item in menuItems) {
      // Check both full name and simple name variations if needed
      // For now, we check if the item name is contained in the text
      if (text.contains(item.name.toLowerCase())) {
         // Check for quantity words before the item name
         int quantity = _extractQuantity(text, item.name.toLowerCase());
         
         // Add to cart
         for(int i=0; i < quantity; i++) {
            cart.addItem(item);
         }
         
         addedItems.add('$quantity ${item.name}');
      }
    }

    if (addedItems.isNotEmpty) {
      feedback = 'Added to cart: ${addedItems.join(", ")}';
    } else {
      feedback = 'Could not find any items in your command.';
    }
    
    return feedback;
  }

  int _extractQuantity(String fullText, String itemName) {
    // Find the position of the item name
    int index = fullText.indexOf(itemName);
    if (index == -1) return 1;
    
    // Look at the words immediately preceding the item name
    // This is a simple heuristic. A more robust NLP approach would use dependency parsing.
    String precedingText = fullText.substring(0, index).trim();
    List<String> words = precedingText.split(' ');
    
    if (words.isEmpty) return 1;
    
    // Check the last word before the item name
    String lastWord = words.last;
    
    // Map number words to digits
    Map<String, int> numberMap = {
      'one': 1, 'a': 1, 'an': 1, 
      'two': 2, 'to': 2, 'too': 2, 
      'three': 3, 
      'four': 4, 'for': 4,
      'five': 5,
      'six': 6,
      'seven': 7,
      'eight': 8,
      'nine': 9,
      'ten': 10
    };
    
    if (numberMap.containsKey(lastWord)) {
      return numberMap[lastWord]!;
    }
    
    // Try parsing as integer
    int? parsedArgs = int.tryParse(lastWord);
    return parsedArgs ?? 1;
  }
}
