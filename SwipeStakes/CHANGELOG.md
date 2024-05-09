#  SwipeStakes
### TVI, Corporation (C) 2024, All Rights Reserved
### D. Anderson - Swift for iOS devices v15.0 and up, Portrait mode 


### [05-09-2024] - Moved to TVI Repos, Optimized Looping Video, Added SplashScreen Animation, Fixed Vertical Toolbar
- Moved From: https://github.com/DrewAnderson/SwipeStakes/ To:https://github.com/TVICorp/SwipeStakes
- Connecting to tapi: https://github.com/TVICorp/tviapi
- Added Splash Screen with animation and sound
- Moved related functions to extensions
- Stubbed out tviAPI extension
- Moved GameConfiguration into a Struct - provides constant configuration values that can be accessed anywhere in your application without needing to instantiate the struct. This approach is beneficial for data that doesn't change at runtime, such as URLs for APIs or media resources.


### [05/07/2024] - Initial Build: Lobby View, Swipe UP/DN, Tik Tok UX
- Basic video playlist for Lobby of 5 CMWRX.tv videos from the TVI channel 1
- CMD+Drag Up to Simulate Swipe Up to next video, CMD+Drag Down for Swipe Down to next video
- Initilize and UX controls in Extensions
- Branch tvi-base

