UIViewController-Transitions-Example
====================================

An example of how to use the new iOS 7 APIs to create custom view controller transitions. 

How to Use
----------------

There are three custom transitions: 

- `TLTransitionAnimator` is a non-interactive transition that presents a new view controller while keeping the presenting view controller on screen (impossible in iOS 6).
- `TLMenuInteractor` is an transition that shows how to use interactive and non-interactive transitions together using traditional UIKit animations.
- `TLMenuDynamicInteractor` is a transition that shows how to use interactive and non-interactive transitions together using *UIKit Dynamics*. 

Tapping a row in the table view will present a new view controller using the `TLTransitionAnimator`. Swiping from the left edge of the screen will present an orange menu view controller. Change the `USE_UIKIT_DYNAMICS` macro in `TLMasterViewController.m` to switch between `TLMenuInteractor` and `TLMenuDynamicInteractor`. 

![Faux Modal](http://f.cl.ly/items/2p2Y0n252l0c2z2b3G2D/Faux-Modal.gif)

![Menu](http://f.cl.ly/items/200T2b1O0A1D2u3k2W3h/Menu.gif)

License
----------------

This software is released under the MIT license.
