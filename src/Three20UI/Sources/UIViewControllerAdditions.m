//
// Copyright 2009-2010 Facebook
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "Three20UI/UIViewControllerAdditions.h"

// UI
#import "Three20UI/TTGlobalUI.h"
#import "Three20UI/TTNavigator.h"

// Network
#import "Three20UI/TTURLMap.h"

// Core
#import "Three20Core/TTGlobalCore.h"
#import "Three20Core/TTDebug.h"
#import "Three20Core/TTDebugFlags.h"

static NSMutableDictionary* gNavigatorURLs = nil;
static NSMutableDictionary* gSuperControllers = nil;
static NSMutableDictionary* gPopupViewControllers = nil;


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@interface TTPopupView : UIView {
  UIViewController* _popupViewController;
}

@property (nonatomic, retain) UIViewController* popupViewController;

@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation TTPopupView

@synthesize popupViewController = _popupViewController;


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
  [_popupViewController release];

  [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)didAddSubview:(UIView*)subview {
  TTDCONDITIONLOG(TTDFLAG_VIEWCONTROLLERS, @"ADD %@", subview);
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)willRemoveSubview:(UIView*)subview {
  TTDCONDITIONLOG(TTDFLAG_VIEWCONTROLLERS, @"REMOVE %@", subview);
  [self removeFromSuperview];
}


@end


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation UIViewController (TTCategory)


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithNavigatorURL:(NSURL*)URL query:(NSDictionary*)query {
  if (self = [self init]) {
  }

  return self;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
/**
 * Swapped with dealloc by TTURLMap (only if you're using TTURLMap)
 */
- (void)ttdealloc {
  NSString* URL = self.originalNavigatorURL;
  if (URL) {
    [[TTNavigator navigator].URLMap removeObjectForURL:URL];
    self.originalNavigatorURL = nil;
  }

  self.superController = nil;
  self.popupViewController = nil;

  // Calls the original dealloc, swizzled away
  [self ttdealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark Public


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)navigatorURL {
  return self.originalNavigatorURL;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)originalNavigatorURL {
  NSString* key = [NSString stringWithFormat:@"%d", self.hash];
  return [gNavigatorURLs objectForKey:key];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setOriginalNavigatorURL:(NSString*)URL {
  NSString* key = [NSString stringWithFormat:@"%d", self.hash];
  if (URL) {
    if (!gNavigatorURLs) {
      gNavigatorURLs = [[NSMutableDictionary alloc] init];
    }
    [gNavigatorURLs setObject:URL forKey:key];
  } else {
    [gNavigatorURLs removeObjectForKey:key];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSDictionary*)frozenState {
  return nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setFrozenState:(NSDictionary*)frozenState {
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)canContainControllers {
  return NO;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIViewController*)superController {
  UIViewController* parent = self.parentViewController;
  if (parent) {
    return parent;
  } else {
    NSString* key = [NSString stringWithFormat:@"%d", self.hash];
    return [gSuperControllers objectForKey:key];
  }
}

- (void)setSuperController:(UIViewController*)viewController {
  NSString* key = [NSString stringWithFormat:@"%d", self.hash];
  if (viewController) {
    if (!gSuperControllers) {
      gSuperControllers = TTCreateNonRetainingDictionary();
    }
    [gSuperControllers setObject:viewController forKey:key];
  } else {
    [gSuperControllers removeObjectForKey:key];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIViewController*)topSubcontroller {
  return nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIViewController*)ttPreviousViewController {
  NSArray* viewControllers = self.navigationController.viewControllers;
  if (viewControllers.count > 1) {
    NSUInteger controllerIndex = [viewControllers indexOfObject:self];
    if (controllerIndex != NSNotFound && controllerIndex > 0) {
      return [viewControllers objectAtIndex:controllerIndex-1];
    }
  }

  return nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIViewController*)nextViewController {
  NSArray* viewControllers = self.navigationController.viewControllers;
  if (viewControllers.count > 1) {
    NSUInteger controllerIndex = [viewControllers indexOfObject:self];
    if (controllerIndex != NSNotFound && controllerIndex+1 < viewControllers.count) {
      return [viewControllers objectAtIndex:controllerIndex+1];
    }
  }
  return nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIViewController*)popupViewController {
  NSString* key = [NSString stringWithFormat:@"%d", self.hash];
  return [gPopupViewControllers objectForKey:key];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)setPopupViewController:(UIViewController*)viewController {
  NSString* key = [NSString stringWithFormat:@"%d", self.hash];
  if (viewController) {
    if (!gPopupViewControllers) {
      gPopupViewControllers = TTCreateNonRetainingDictionary();
    }
    [gPopupViewControllers setObject:viewController forKey:key];
  } else {
    [gPopupViewControllers removeObjectForKey:key];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)addSubcontroller:(UIViewController*)controller animated:(BOOL)animated
        transition:(UIViewAnimationTransition)transition {
  if (self.navigationController) {
    [self.navigationController addSubcontroller:controller animated:animated
                               transition:transition];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)removeFromSupercontroller {
  [self removeFromSupercontrollerAnimated:YES];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)removeFromSupercontrollerAnimated:(BOOL)animated {
  if (self.navigationController) {
    [self.navigationController popViewControllerAnimated:animated];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)bringControllerToFront:(UIViewController*)controller animated:(BOOL)animated {
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (NSString*)keyForSubcontroller:(UIViewController*)controller {
  return nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (UIViewController*)subcontrollerForKey:(NSString*)key {
  return nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)persistView:(NSMutableDictionary*)state {
  return YES;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)restoreView:(NSDictionary*)state {
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)persistNavigationPath:(NSMutableArray*)path {
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)delayDidEnd {
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)showBars:(BOOL)show animated:(BOOL)animated {
  [[UIApplication sharedApplication] setStatusBarHidden:!show animated:animated];

  if (animated) {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:TT_TRANSITION_DURATION];
  }
  self.navigationController.navigationBar.alpha = show ? 1 : 0;
  if (animated) {
    [UIView commitAnimations];
  }
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dismissModalViewController {
  [self dismissModalViewControllerAnimated:YES];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)canBeTopViewController {
  return YES;
}


@end
