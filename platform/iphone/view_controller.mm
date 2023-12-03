/**************************************************************************/
/*  view_controller.mm                                                    */
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

#import "view_controller.h"

#include "core/project_settings.h"
#import "godot_view.h"
#import "godot_view_renderer.h"
#import "keyboard_input_view.h"
#import "native_video_view.h"
#include "os_iphone.h"

@interface ViewController () <GodotViewDelegate> {

    KeyWatcher *watcher;

    BOOL isPointerLocked;

}

@property(strong, nonatomic) GodotViewRenderer *renderer;
@property(strong, nonatomic) GodotNativeVideoView *videoView;
//@property(strong, nonatomic) GodotKeyboardInputView *keyboardView;

@property(strong, nonatomic) UIView *godotLoadingOverlay;

@end

@implementation ViewController

- (GodotView *)godotView {
	return (GodotView *)self.view;
}

- (void)loadView {
	GodotView *view = [[GodotView alloc] init];
	[view initializeRendering];

	GodotViewRenderer *renderer = [[GodotViewRenderer alloc] init];

	self.renderer = renderer;
	self.view = view;

	view.renderer = self.renderer;
	view.delegate = self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

	if (self) {
		[self godot_commonInit];
	}

	return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
	self = [super initWithCoder:coder];

	if (self) {
		[self godot_commonInit];
	}

	return self;
}


// Wheeels patches

- (void)godot_commonInit {
	// Initialize view controller values.
	isPointerLocked = NO;
}



- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
	printf("*********** did receive memory warning!\n");
};

- (void)viewDidLoad {
	[super viewDidLoad];

	// Wheeels: disable the on-screen keyboard and pass all physical key presses to KeyWatcher

    if (@available(iOS 14.0, *)) {

		// Wheeels: create a KeyWatcher instance which will receive all physical key presses once it becomes first responder
		watcher = [[KeyWatcher alloc] initWithFrame: CGRectMake(0, 0, 0, 0)];
		[self.view addSubview: watcher];
		watcher.text = @"xx";
		watcher.delegate = watcher;

		// Wheeels: hide the on-screen keyboard bar (this doesn't 100% prevent iOS popping up on-screen keyboard controls, e.g. if user presses Cmd-Shift-Spacebar, but reduces the chances of it happening)
		watcher.autocorrectionType = UITextAutocorrectionTypeNo;
		watcher.inputAssistantItem.leadingBarButtonGroups = @[];
		watcher.inputAssistantItem.trailingBarButtonGroups = @[];

		// if no keyboard is connected, the default on-screen keyboard (inputView=nil) would normally appear when the watcher becomes the first responder; to prevent this - and to ensure key presses are handled by the watcher if/when a keyboard does connect - set the watcher's inputView (on-screen keyboard) to itself
		watcher.inputView = watcher;
	}

	[self displayLoadingOverlay];

	if (@available(iOS 11.0, *)) {
		[self setNeedsUpdateOfScreenEdgesDeferringSystemGestures];
	}
}

// Wheeels: add/remove key watcher to/from responder chain

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear: animated];
    if (@available(iOS 14.0, *)) {
		// Wheeels: we use GameController APIs to process mouse movements and button clicks
        for (GCMouse *mouse in GCMouse.mice) {
            [self registerMouseCallbacks: mouse];
        }

        [NSNotificationCenter.defaultCenter addObserverForName: GCMouseDidConnectNotification
                                                	    object: nil
                                                         queue: nil
                                                    usingBlock: ^(NSNotification *notification) {
                                                 					[self registerMouseCallbacks: notification.object];
                                              				    }];
        [NSNotificationCenter.defaultCenter addObserverForName: GCMouseDidDisconnectNotification
                                                	    object: nil
                                                         queue: nil
                                                    usingBlock: ^(NSNotification *notification) {
                                                 					[self unregisterMouseCallbacks: notification.object];
                                              				    }];
        // Wheeels: if user presses Home to suspend app then taps app icon to resume it, the watcher requires an explicit poke or it will not resume handling key presses
        [NSNotificationCenter.defaultCenter addObserverForName: UIApplicationDidBecomeActiveNotification
                                                	    object: nil
                                                         queue: nil
                                                    usingBlock: ^(NSNotification *notification) {
                                                    				[watcher resignFirstResponder];
                                                 					[watcher becomeFirstResponder];
                                              				    }];
    }
}

- (void)viewDidDisappear:(BOOL)animated { // redundant as we never unload the view
    [super viewDidDisappear: animated];

    if (@available(iOS 14.0, *)) {
		[watcher resignFirstResponder];

        [NSNotificationCenter.defaultCenter removeObserver: self name: GCMouseDidConnectNotification object: self];
        [NSNotificationCenter.defaultCenter removeObserver: self name: GCMouseDidDisconnectNotification object: self];
        [NSNotificationCenter.defaultCenter removeObserver: self name: UIApplicationDidBecomeActiveNotification object: self];
    }
}

// note: this will detect all connected mice; unlike keyboard they are non consolidated into a single device

// TO DO: if Assistive Touch is enabled, it interferes with leftButton detection; this smells of iOS bug

- (void)registerMouseCallbacks: (GCMouse *)mouse API_AVAILABLE(ios(14.0)) {
    //NSLog(@"registerMouseCallbacks %@", mouse);
    mouse.mouseInput.mouseMovedHandler = ^(GCMouseInput * _Nonnull mouse, float deltaX, float deltaY) {
		OSIPhone::get_singleton()->mouse_moved(deltaX, deltaY);
    };
    mouse.mouseInput.leftButton.pressedChangedHandler = ^(GCControllerButtonInput * _Nonnull button, float value, BOOL pressed) {
        OSIPhone::get_singleton()->mouse_pressed(BUTTON_LEFT, BUTTON_MASK_LEFT, pressed);
    };
    mouse.mouseInput.rightButton.pressedChangedHandler = ^(GCControllerButtonInput * _Nonnull button, float value, BOOL pressed) {
        OSIPhone::get_singleton()->mouse_pressed(BUTTON_RIGHT, BUTTON_MASK_RIGHT, pressed);
    };
}

- (void)unregisterMouseCallbacks: (GCMouse*)mouse API_AVAILABLE(ios(14.0)) {
	//NSLog(@"unregisterMouseCallbacks %@", mouse);
    mouse.mouseInput.mouseMovedHandler = nil;
    mouse.mouseInput.leftButton.pressedChangedHandler = nil;
    mouse.mouseInput.rightButton.pressedChangedHandler = nil;
}


// Wheeels: hide and lock [mouse/trackball] pointer so we can measure its speed of movement

// TO DO: when AssistiveTouch is enabled, changing prefersPointerLocked from YES to NO doesn't seem to work: pointerLockState.locked remains YES and the pointer stays locked; smells like iOS bug

- (void)setPointerLocked: (BOOL)isLocked {
	if (isLocked) {
		watcher.inputView = watcher;
		// Wheeels: always add watcher to the responder chain as GCKeyboardDidConnectNotification doesn't seem to fire when a Bluetooth keyboard wakes (i.e. don't rely on Notifications to set/unset watcher as first responder)
        [watcher resignFirstResponder];
	    [watcher becomeFirstResponder];
	} else {
		[watcher resignFirstResponder];
		watcher.inputView = nil;
	}
    if (@available(iOS 14.0, *)) {
		isPointerLocked = isLocked;
		[self setNeedsUpdateOfPrefersPointerLocked];
		((GodotView *)self.view).mouseButtonSendsTouchEvents = !isLocked; // ick; it might be cleaner if touchesBegan:withEvent: &co were moved from GodotView to ViewController, though all this code is a mass of hacks anyway
		//NSLog(@"setPointerLocked: %i -> %i   %@", self.view.window.windowScene.pointerLockState.locked, isPointerLocked, self.view.window.windowScene.pointerLockState);
	}
}

- (BOOL)prefersPointerLocked {
	//NSLog(@"prefersPointerLocked = %i", isPointerLocked);
    return isPointerLocked;
}

// end of Wheeels patches


- (void)observeKeyboard {
	// Wheeels: Godot 3.5 implements GodotKeyboardInputView which looks like it calls OSIPhone::key(), suggesting it monitors key presses; however, it doesn't detect Arrow key presses so disable it as we have enough fragile kludges to contend with as it is
	/*
	printf("******** setting up keyboard input view\n");
	self.keyboardView = [GodotKeyboardInputView new];
	[self.view addSubview:self.keyboardView];

	printf("******** adding observer for keyboard show/hide\n");
	[[NSNotificationCenter defaultCenter]
			addObserver:self
			   selector:@selector(keyboardOnScreen:)
				   name:UIKeyboardDidShowNotification
				 object:nil];
	[[NSNotificationCenter defaultCenter]
			addObserver:self
			   selector:@selector(keyboardHidden:)
				   name:UIKeyboardDidHideNotification
				 object:nil];
	*/
}

- (void)displayLoadingOverlay {
	NSBundle *bundle = [NSBundle mainBundle];
	NSString *storyboardName = @"Launch Screen";

	if ([bundle pathForResource:storyboardName ofType:@"storyboardc"] == nil) {
		return;
	}

	UIStoryboard *launchStoryboard = [UIStoryboard storyboardWithName:storyboardName bundle:bundle];

	UIViewController *controller = [launchStoryboard instantiateInitialViewController];
	self.godotLoadingOverlay = controller.view;
	self.godotLoadingOverlay.frame = self.view.bounds;
	self.godotLoadingOverlay.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;

	[self.view addSubview:self.godotLoadingOverlay];
}

- (BOOL)godotViewFinishedSetup:(GodotView *)view {
	[self.godotLoadingOverlay removeFromSuperview];
	self.godotLoadingOverlay = nil;

	return YES;
}

- (void)dealloc {
	[self.videoView stopVideo];
	self.videoView = nil;

	//self.keyboardView = nil;

	self.renderer = nil;

	if (self.godotLoadingOverlay) {
		[self.godotLoadingOverlay removeFromSuperview];
		self.godotLoadingOverlay = nil;
	}

	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

// MARK: Orientation

- (UIRectEdge)preferredScreenEdgesDeferringSystemGestures {
	return UIRectEdgeAll;
}

- (BOOL)shouldAutorotate {
	if (!OSIPhone::get_singleton()) {
		return NO;
	}

	switch (OS::get_singleton()->get_screen_orientation()) {
		case OS::SCREEN_SENSOR:
		case OS::SCREEN_SENSOR_LANDSCAPE:
		case OS::SCREEN_SENSOR_PORTRAIT:
			return YES;
		default:
			return NO;
	}
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
	if (!OSIPhone::get_singleton()) {
		return UIInterfaceOrientationMaskAll;
	}

	switch (OS::get_singleton()->get_screen_orientation()) {
		case OS::SCREEN_PORTRAIT:
			return UIInterfaceOrientationMaskPortrait;
		case OS::SCREEN_REVERSE_LANDSCAPE:
			return UIInterfaceOrientationMaskLandscapeRight;
		case OS::SCREEN_REVERSE_PORTRAIT:
			return UIInterfaceOrientationMaskPortraitUpsideDown;
		case OS::SCREEN_SENSOR_LANDSCAPE:
			return UIInterfaceOrientationMaskLandscape;
		case OS::SCREEN_SENSOR_PORTRAIT:
			return UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown;
		case OS::SCREEN_SENSOR:
			return UIInterfaceOrientationMaskAll;
		case OS::SCREEN_LANDSCAPE:
			return UIInterfaceOrientationMaskLandscapeLeft;
	}
}

- (BOOL)prefersStatusBarHidden {
	return YES;
}

- (BOOL)prefersHomeIndicatorAutoHidden {
	if (GLOBAL_GET("display/window/ios/hide_home_indicator")) {
		return YES;
	} else {
		return NO;
	}
}

// MARK: Keyboard

- (void)keyboardOnScreen:(NSNotification *)notification {
	NSDictionary *info = notification.userInfo;
	NSValue *value = info[UIKeyboardFrameEndUserInfoKey];

	CGRect rawFrame = [value CGRectValue];
	CGRect keyboardFrame = [self.view convertRect:rawFrame fromView:nil];

	if (OSIPhone::get_singleton()) {
		OSIPhone::get_singleton()->set_virtual_keyboard_height(keyboardFrame.size.height);
	}
}

- (void)keyboardHidden:(NSNotification *)notification {
	if (OSIPhone::get_singleton()) {
		OSIPhone::get_singleton()->set_virtual_keyboard_height(0);
	}
}

// MARK: Native Video Player

- (BOOL)playVideoAtPath:(NSString *)filePath volume:(float)videoVolume audio:(NSString *)audioTrack subtitle:(NSString *)subtitleTrack {
	// If we are showing some video already, reuse existing view for new video.
	if (self.videoView) {
		return [self.videoView playVideoAtPath:filePath volume:videoVolume audio:audioTrack subtitle:subtitleTrack];
	} else {
		// Create autoresizing view for video playback.
		GodotNativeVideoView *videoView = [[GodotNativeVideoView alloc] initWithFrame:self.view.bounds];
		videoView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
		[self.view addSubview:videoView];

		self.videoView = videoView;

		return [self.videoView playVideoAtPath:filePath volume:videoVolume audio:audioTrack subtitle:subtitleTrack];
	}
}

@end
