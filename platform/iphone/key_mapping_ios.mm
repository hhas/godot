/**************************************************************************/
/*  key_mapping_ios.mm                                                    */
/**************************************************************************/
/*                         This file is part of:                          */
/*                             GODOT ENGINE                               */
/*                        https://godotengine.org                         */
/**************************************************************************/
/* Copyright (c) 2014-present Godot Engine contributors (see AUTHORS.md). */
/* Copyright (c) 2007-2014 Juan Linietsky, Ariel Manzur.                  */
/*                                                                        */
/* Permission is hereby granted, free of charge, to any person obtaining  */
/* a copy of this software and associated documentation files (the        */
/* "Software"), to deal in the Software without restriction, including    */
/* without limitation the rights to use, copy, modify, merge, publish,    */
/* distribute, sublicense, and/or sell copies of the Software, and to     */
/* permit persons to whom the Software is furnished to do so, subject to  */
/* the following conditions:                                              */
/*                                                                        */
/* The above copyright notice and this permission notice shall be         */
/* included in all copies or substantial portions of the Software.        */
/*                                                                        */
/* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,        */
/* EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF     */
/* MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. */
/* IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY   */
/* CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,   */
/* TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE      */
/* SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.                 */
/**************************************************************************/

// Wheeels: copied from 4.1.1 so we can use its new -pressesBegan:withEvent: implementation

#import "key_mapping_ios.h"

#include "core/hash_map.h"

struct HashMapHasherKeys {
	static _FORCE_INLINE_ uint32_t hash(const Key p_key) { return hash_fmix32(static_cast<uint32_t>(p_key)); }
	static _FORCE_INLINE_ uint32_t hash(const CFIndex p_key) { return hash_fmix32(p_key); }
};

HashMap<CFIndex, Key, HashMapHasherKeys> keyusage_map;

void KeyMappingIOS::initialize() {
	if (@available(iOS 13.4, *)) {
		keyusage_map[UIKeyboardHIDUsageKeyboardA] = KEY_A;
		keyusage_map[UIKeyboardHIDUsageKeyboardB] = KEY_B;
		keyusage_map[UIKeyboardHIDUsageKeyboardC] = KEY_C;
		keyusage_map[UIKeyboardHIDUsageKeyboardD] = KEY_D;
		keyusage_map[UIKeyboardHIDUsageKeyboardE] = KEY_E;
		keyusage_map[UIKeyboardHIDUsageKeyboardF] = KEY_F;
		keyusage_map[UIKeyboardHIDUsageKeyboardG] = KEY_G;
		keyusage_map[UIKeyboardHIDUsageKeyboardH] = KEY_H;
		keyusage_map[UIKeyboardHIDUsageKeyboardI] = KEY_I;
		keyusage_map[UIKeyboardHIDUsageKeyboardJ] = KEY_J;
		keyusage_map[UIKeyboardHIDUsageKeyboardK] = KEY_K;
		keyusage_map[UIKeyboardHIDUsageKeyboardL] = KEY_L;
		keyusage_map[UIKeyboardHIDUsageKeyboardM] = KEY_M;
		keyusage_map[UIKeyboardHIDUsageKeyboardN] = KEY_N;
		keyusage_map[UIKeyboardHIDUsageKeyboardO] = KEY_O;
		keyusage_map[UIKeyboardHIDUsageKeyboardP] = KEY_P;
		keyusage_map[UIKeyboardHIDUsageKeyboardQ] = KEY_Q;
		keyusage_map[UIKeyboardHIDUsageKeyboardR] = KEY_R;
		keyusage_map[UIKeyboardHIDUsageKeyboardS] = KEY_S;
		keyusage_map[UIKeyboardHIDUsageKeyboardT] = KEY_T;
		keyusage_map[UIKeyboardHIDUsageKeyboardU] = KEY_U;
		keyusage_map[UIKeyboardHIDUsageKeyboardV] = KEY_V;
		keyusage_map[UIKeyboardHIDUsageKeyboardW] = KEY_W;
		keyusage_map[UIKeyboardHIDUsageKeyboardX] = KEY_X;
		keyusage_map[UIKeyboardHIDUsageKeyboardY] = KEY_Y;
		keyusage_map[UIKeyboardHIDUsageKeyboardZ] = KEY_Z;
		keyusage_map[UIKeyboardHIDUsageKeyboard0] = KEY_0;
		keyusage_map[UIKeyboardHIDUsageKeyboard1] = KEY_1;
		keyusage_map[UIKeyboardHIDUsageKeyboard2] = KEY_2;
		keyusage_map[UIKeyboardHIDUsageKeyboard3] = KEY_3;
		keyusage_map[UIKeyboardHIDUsageKeyboard4] = KEY_4;
		keyusage_map[UIKeyboardHIDUsageKeyboard5] = KEY_5;
		keyusage_map[UIKeyboardHIDUsageKeyboard6] = KEY_6;
		keyusage_map[UIKeyboardHIDUsageKeyboard7] = KEY_7;
		keyusage_map[UIKeyboardHIDUsageKeyboard8] = KEY_8;
		keyusage_map[UIKeyboardHIDUsageKeyboard9] = KEY_9;
		keyusage_map[UIKeyboardHIDUsageKeyboardBackslash] = KEY_BACKSLASH;
		keyusage_map[UIKeyboardHIDUsageKeyboardCloseBracket] = KEY_BRACKETRIGHT;
		keyusage_map[UIKeyboardHIDUsageKeyboardComma] = KEY_COMMA;
		keyusage_map[UIKeyboardHIDUsageKeyboardEqualSign] = KEY_EQUAL;
		keyusage_map[UIKeyboardHIDUsageKeyboardHyphen] = KEY_MINUS;
		keyusage_map[UIKeyboardHIDUsageKeyboardNonUSBackslash] = KEY_SECTION;
		keyusage_map[UIKeyboardHIDUsageKeyboardNonUSPound] = KEY_ASCIITILDE;
		keyusage_map[UIKeyboardHIDUsageKeyboardOpenBracket] = KEY_BRACKETLEFT;
		keyusage_map[UIKeyboardHIDUsageKeyboardPeriod] = KEY_PERIOD;
		keyusage_map[UIKeyboardHIDUsageKeyboardQuote] = KEY_QUOTEDBL;
		keyusage_map[UIKeyboardHIDUsageKeyboardSemicolon] = KEY_SEMICOLON;
		keyusage_map[UIKeyboardHIDUsageKeyboardSeparator] = KEY_SECTION;
		keyusage_map[UIKeyboardHIDUsageKeyboardSlash] = KEY_SLASH;
		keyusage_map[UIKeyboardHIDUsageKeyboardSpacebar] = KEY_SPACE;
		keyusage_map[UIKeyboardHIDUsageKeyboardCapsLock] = KEY_CAPSLOCK;
		keyusage_map[UIKeyboardHIDUsageKeyboardLeftAlt] = KEY_ALT;
		keyusage_map[UIKeyboardHIDUsageKeyboardLeftControl] = KEY_CONTROL;
		keyusage_map[UIKeyboardHIDUsageKeyboardLeftShift] = KEY_SHIFT;
		keyusage_map[UIKeyboardHIDUsageKeyboardRightAlt] = KEY_ALT;
		keyusage_map[UIKeyboardHIDUsageKeyboardRightControl] = KEY_CONTROL;
		keyusage_map[UIKeyboardHIDUsageKeyboardRightShift] = KEY_SHIFT;
		keyusage_map[UIKeyboardHIDUsageKeyboardScrollLock] = KEY_SCROLLLOCK;

		keyusage_map[UIKeyboardHIDUsageKeyboardLeftArrow] = KEY_LEFT;
		keyusage_map[UIKeyboardHIDUsageKeyboardRightArrow] = KEY_RIGHT;
		keyusage_map[UIKeyboardHIDUsageKeyboardUpArrow] = KEY_UP;
		keyusage_map[UIKeyboardHIDUsageKeyboardDownArrow] = KEY_DOWN;

		keyusage_map[UIKeyboardHIDUsageKeyboardPageUp] = KEY_PAGEUP;
		keyusage_map[UIKeyboardHIDUsageKeyboardPageDown] = KEY_PAGEDOWN;
		keyusage_map[UIKeyboardHIDUsageKeyboardHome] = KEY_HOME;
		keyusage_map[UIKeyboardHIDUsageKeyboardEnd] = KEY_END;

		keyusage_map[UIKeyboardHIDUsageKeyboardDeleteForward] = KEY_DELETE;
		keyusage_map[UIKeyboardHIDUsageKeyboardDeleteOrBackspace] = KEY_BACKSPACE;
		keyusage_map[UIKeyboardHIDUsageKeyboardEscape] = KEY_ESCAPE;
		keyusage_map[UIKeyboardHIDUsageKeyboardInsert] = KEY_INSERT;
		keyusage_map[UIKeyboardHIDUsageKeyboardReturn] = KEY_ENTER;
		keyusage_map[UIKeyboardHIDUsageKeyboardTab] = KEY_TAB;
		keyusage_map[UIKeyboardHIDUsageKeyboardF1] = KEY_F1;
		keyusage_map[UIKeyboardHIDUsageKeyboardF2] = KEY_F2;
		keyusage_map[UIKeyboardHIDUsageKeyboardF3] = KEY_F3;
		keyusage_map[UIKeyboardHIDUsageKeyboardF4] = KEY_F4;
		keyusage_map[UIKeyboardHIDUsageKeyboardF5] = KEY_F5;
		keyusage_map[UIKeyboardHIDUsageKeyboardF6] = KEY_F6;
		keyusage_map[UIKeyboardHIDUsageKeyboardF7] = KEY_F7;
		keyusage_map[UIKeyboardHIDUsageKeyboardF8] = KEY_F8;
		keyusage_map[UIKeyboardHIDUsageKeyboardF9] = KEY_F9;
		keyusage_map[UIKeyboardHIDUsageKeyboardF10] = KEY_F10;
		keyusage_map[UIKeyboardHIDUsageKeyboardF11] = KEY_F11;
		keyusage_map[UIKeyboardHIDUsageKeyboardF12] = KEY_F12;
		keyusage_map[UIKeyboardHIDUsageKeyboardF13] = KEY_F13;
		keyusage_map[UIKeyboardHIDUsageKeyboardF14] = KEY_F14;
		keyusage_map[UIKeyboardHIDUsageKeyboardF15] = KEY_F15;
		keyusage_map[UIKeyboardHIDUsageKeyboardF16] = KEY_F16;
//		keyusage_map[UIKeyboardHIDUsageKeyboardF17] = KEY_F17;
//		keyusage_map[UIKeyboardHIDUsageKeyboardF18] = KEY_F18;
//		keyusage_map[UIKeyboardHIDUsageKeyboardF19] = KEY_F19;
//		keyusage_map[UIKeyboardHIDUsageKeyboardF20] = KEY_F20;
//		keyusage_map[UIKeyboardHIDUsageKeyboardF21] = KEY_F21;
//		keyusage_map[UIKeyboardHIDUsageKeyboardF22] = KEY_F22;
//		keyusage_map[UIKeyboardHIDUsageKeyboardF23] = KEY_F23;
//		keyusage_map[UIKeyboardHIDUsageKeyboardF24] = KEY_F24;
		keyusage_map[UIKeyboardHIDUsageKeypad0] = KEY_KP_0;
		keyusage_map[UIKeyboardHIDUsageKeypad1] = KEY_KP_1;
		keyusage_map[UIKeyboardHIDUsageKeypad2] = KEY_KP_2;
		keyusage_map[UIKeyboardHIDUsageKeypad3] = KEY_KP_3;
		keyusage_map[UIKeyboardHIDUsageKeypad4] = KEY_KP_4;
		keyusage_map[UIKeyboardHIDUsageKeypad5] = KEY_KP_5;
		keyusage_map[UIKeyboardHIDUsageKeypad6] = KEY_KP_6;
		keyusage_map[UIKeyboardHIDUsageKeypad7] = KEY_KP_7;
		keyusage_map[UIKeyboardHIDUsageKeypad8] = KEY_KP_8;
		keyusage_map[UIKeyboardHIDUsageKeypad9] = KEY_KP_9;
		keyusage_map[UIKeyboardHIDUsageKeypadAsterisk] = KEY_KP_MULTIPLY;
		keyusage_map[UIKeyboardHIDUsageKeyboardGraveAccentAndTilde] = KEY_BAR;
		keyusage_map[UIKeyboardHIDUsageKeypadEnter] = KEY_KP_ENTER;
		keyusage_map[UIKeyboardHIDUsageKeypadHyphen] = KEY_KP_SUBTRACT;
		keyusage_map[UIKeyboardHIDUsageKeypadNumLock] = KEY_NUMLOCK;
		keyusage_map[UIKeyboardHIDUsageKeypadPeriod] = KEY_KP_PERIOD;
		keyusage_map[UIKeyboardHIDUsageKeypadPlus] = KEY_KP_ADD;
		keyusage_map[UIKeyboardHIDUsageKeypadSlash] = KEY_KP_DIVIDE;
		keyusage_map[UIKeyboardHIDUsageKeyboardPause] = KEY_PAUSE;
		keyusage_map[UIKeyboardHIDUsageKeyboardStop] = KEY_STOP;
		keyusage_map[UIKeyboardHIDUsageKeyboardMute] = KEY_VOLUMEMUTE;
		keyusage_map[UIKeyboardHIDUsageKeyboardVolumeUp] = KEY_VOLUMEUP;
		keyusage_map[UIKeyboardHIDUsageKeyboardVolumeDown] = KEY_VOLUMEDOWN;
		keyusage_map[UIKeyboardHIDUsageKeyboardFind] = KEY_SEARCH;
		keyusage_map[UIKeyboardHIDUsageKeyboardHelp] = KEY_HELP;
		keyusage_map[UIKeyboardHIDUsageKeyboardLeftGUI] = KEY_META;
		keyusage_map[UIKeyboardHIDUsageKeyboardRightGUI] = KEY_META;
		keyusage_map[UIKeyboardHIDUsageKeyboardMenu] = KEY_MENU;
		keyusage_map[UIKeyboardHIDUsageKeyboardPrintScreen] = KEY_PRINT;
		keyusage_map[UIKeyboardHIDUsageKeyboardReturnOrEnter] = KEY_ENTER;
		keyusage_map[UIKeyboardHIDUsageKeyboardSysReqOrAttention] = KEY_SYSREQ;
//		keyusage_map[0x01AE] = KEY_KEYBOARD; // On-screen keyboard key on smart connector keyboard.
//		keyusage_map[0x029D] = KEY_GLOBE; // "Globe" key on smart connector / Mac keyboard.
//		keyusage_map[UIKeyboardHIDUsageKeyboardLANG1] = KEY_JIS_EISU;
//		keyusage_map[UIKeyboardHIDUsageKeyboardLANG2] = KEY_JIS_KANA;
	}
}

Key KeyMappingIOS::remap_key(CFIndex p_keycode) {
	if (@available(iOS 13.4, *)) {
		const Key *key = keyusage_map.getptr(p_keycode);
		if (key) {
			return *key;
		}
	}
	printf("remap_key: no mapping for %04lx \n", (unsigned long)p_keycode);
	return 0;
}
