// Wheeels:

// Problem: iOS's physical keyboard support does not generate -pressesBegan:withEvent: when physical Arrow keys are pressed and, unlike macOS, there are no public NSEvent/Quarts-like APIs to hook into the low-level input events

// Workaround: kludge UITextField, which does receive arrow key presses, to pass those presses on to our code

// add a KeyWatcher instance to the responder chain to intercept hardware key presses, specifically Arrow and Spacebar keys; Arrow keys are not normally detected by -pressesBegan:withEvent:, hence this kludge which relies on UITextField's internal behavior to make those key presses visible to our code

// caution: as this kludge relies on tricky undocumented behavior, it is possible future changes in iOS may break it

// important: -[keyWatcher keyCommands] must return UIKeyCommands for all keys being monitored; these must invoke an existing method (-keyPressed:) although the method itself is a no-op (UIKit also dispatches the key presses being to -pressesBegan:withEvent:, which is what Godot 4.1.1 uses); keys which are not defined in -keyCommands will not be detected as those are handled by the UITextField itself (UIKeyCommand does not provide a wildcard option for matching any key)

// TO DO: it may be possible to handle keys not declared in -keyCommands by processing the replacement string in -textField:shouldChangeCharactersInRange:replacementString: but that will require additional logic to detect when a key press begins and ends as those are the inputs expected by OSIPhone's key() method

// TO DO: the UITextField appears to lose 'focus' when Home is pressed to suspend the game and the app icon tapped to resume it; as a workaround, the ViewController resigns and restores the text field as its first responder when the game becomes active again; it is also possible via combination key presses (e.g. Cmd-Shift-Space) to trigger iOS's own text handling menus which steal focus from the text field and stop the game responding to key presses - there might or might not be a way to prevent that but for now if the keyboard stops responding the workaround is for user to press Home and tap app icon

// TO DO: the first time Spacebar is pressed, it does not activate the hand, requiring a second press; not sure why or if there's a way to fix this (oddly, that first press generates a -touchesBegan:withEvent: message, though it's unclear why it should do that)

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol KeyWatcher <NSObject>

- (void)keyPressed: (UIKeyCommand *)key;

@end


// UITextField seems the least troublesome to use for this kludge

@interface KeyWatcher : UITextField <KeyWatcher, UITextFieldDelegate>

@end

NS_ASSUME_NONNULL_END
