//

#import "key_watcher.h"

#include "os_iphone.h"

#import "key_mapping_ios.h" // Wheeels: copied from 4.1.1


Key fix_keycode_2(char32_t p_char, Key p_key) { // Wheeels: copied from 4.1.1, core/os/keyboard.cpp
	if (p_char >= 0x20 && p_char <= 0x7E) {
		return (Key)String::char_uppercase(p_char);
	}
	return p_key;
}



@implementation KeyWatcher

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
	return NO;
}


- (NSArray*)keyCommands {
	// important: all keys which are used as main screen/in-game controls MUST be listed here for UIKit to send UIPress events to -pressesBegan:withEvent: (presumably text field takes other key presses itself)
    static NSArray *watchesKeys = nil;
    if (!watchesKeys) {
        watchesKeys = @[
            [UIKeyCommand keyCommandWithInput: @"\r" // Enter (since iOS keyboards typically don't have an Escape key)
            					modifierFlags: 0
            						   action: @selector(keyPressed:)],
            [UIKeyCommand keyCommandWithInput: @" " // Spacebar
            					modifierFlags: 0
            						   action: @selector(keyPressed:)],
            [UIKeyCommand keyCommandWithInput: UIKeyInputUpArrow
            					modifierFlags: 0
            						   action: @selector(keyPressed:)],
            [UIKeyCommand keyCommandWithInput: UIKeyInputDownArrow
            					modifierFlags: 0
            					       action: @selector(keyPressed:)],
            [UIKeyCommand keyCommandWithInput: UIKeyInputLeftArrow
            					modifierFlags: 0
            						   action: @selector(keyPressed:)],
            [UIKeyCommand keyCommandWithInput: UIKeyInputRightArrow
            					modifierFlags: 0
            						   action: @selector(keyPressed:)],
            [UIKeyCommand keyCommandWithInput: UIKeyInputEscape
            					modifierFlags: 0
            						   action: @selector(keyPressed:)],
        ];
        if (@available(iOS 15, *)) {
            for (UIKeyCommand *command in watchesKeys) {
                command.wantsPriorityOverSystemBehavior = YES;
            }
        }
    }
    return watchesKeys;
}

- (void)keyPressed: (UIKeyCommand *)key {
	NSLog(@"keyPressed: %@", key); // this is defined as no-op; key presses are handled in pressesBegan:withEvent:
}

// from 4.1.1; these pick up key presses for keys defined in -keyCommands
- (void)pressesBegan:(NSSet<UIPress *> *)presses withEvent:(UIPressesEvent *)event {
	if (@available(iOS 14.0, *)) {
		for (UIPress *press in presses) {

			String u32lbl = String::utf8([press.key.charactersIgnoringModifiers UTF8String]);
			String u32text = String::utf8([press.key.characters UTF8String]);

			Key key = KeyMappingIOS::remap_key(press.key.keyCode);

			if (press.key.keyCode == 0 && u32text.empty() && u32lbl.empty()) {
				continue;
			}

			char32_t us = 0;
			if (!u32lbl.empty() && !u32lbl.begins_with("UIKey")) { // special keys, e.g. Arrows, use "UIKey..." names
				us = u32lbl[0];
			}

			if (!u32text.empty() && !u32text.begins_with("UIKey")) {
				for (int i = 0; i < u32text.length(); i++) {
					OSIPhone::get_singleton()->key(fix_keycode_2(us, key), true);
				}

			} else {
				OSIPhone::get_singleton()->key(fix_keycode_2(us, key), true);
			}
		}
	}
}

- (void)pressesEnded:(NSSet<UIPress *> *)presses withEvent:(UIPressesEvent *)event {
	if (@available(iOS 14.0, *)) {
		for (UIPress *press in presses) {

			String u32lbl = String::utf8([press.key.charactersIgnoringModifiers UTF8String]);
			Key key = KeyMappingIOS::remap_key(press.key.keyCode);

			if (press.key.keyCode == 0 && u32lbl.empty()) {
				continue;
			}

			char32_t us = 0;
			if (!u32lbl.empty() && !u32lbl.begins_with("UIKey")) {
				us = u32lbl[0];
			}

			OSIPhone::get_singleton()->key(fix_keycode_2(us, key), false);
		}
	}
}



@end
