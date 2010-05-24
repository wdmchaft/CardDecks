//
//
// CDXAppDelegate.m
//
//
// Copyright (c) 2009-2010 Arne Harren <ah@0xc0.de>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "CDXAppDelegate.h"
#import "CDXCardDeckURLSerializer.h"
#import "CDXCardDecksListViewController.h"


@implementation CDXAppDelegate

#undef ql_component
#define ql_component lcl_cCDXAppDelegate

- (void)applicationDidFinishLaunching:(UIApplication *)application {
    qltrace();
    CDXCardDecks *decks = [[[CDXCardDecks alloc] init] autorelease];
    {
        CDXCardDeck *deck = [CDXCardDeckURLSerializer cardDeckFromString:@"0%2C%20...%2C%2010,ffffff,666666&0&1&2&3&4&5&6&7&8&9&10"];
        deck.displayStyle = CDXCardDeckDisplayStyleSideBySide;
        deck.wantsPageControl = YES;
        deck.wantsAutoRotate = NO;
        deck.cornerStyle = CDXCardCornerStyleCornered;
        [decks addCardDeck:deck];
    }
    {
        CDXCardDeck *deck = [CDXCardDeckURLSerializer cardDeckFromString:@"Estimation%201,000000,ffffff&0&1&2&4&8&16&32&64&%E2%88%9E"];
        deck.displayStyle = CDXCardDeckDisplayStyleStack;
        deck.fontSize = 200.0;
        [decks addCardDeck:deck];
    }
    {
        CDXCardDeck *deck = [CDXCardDeckURLSerializer cardDeckFromString:@"Estimation%202,000044,ffffff&XXS&XS&S&M&L&XL&XXL&%E2%88%9E"];
        deck.displayStyle = CDXCardDeckDisplayStyleSwipeStack;
        deck.fontSize = 180.0;
        deck.wantsAutoRotate = NO;
        [decks addCardDeck:deck];
    }
    {
        CDXCardDeck *deck = [CDXCardDeckURLSerializer cardDeckFromString:@"Count%20Down,ffffff,000000&15,000000,00ff00&10,000000,ffff00&5,000000,ff0000&0,ff0000"];
        deck.displayStyle = CDXCardDeckDisplayStyleSwipeStack;
        deck.fontSize = 270.0;
        deck.wantsAutoRotate = NO;
        [decks addCardDeck:deck];
    }
    {
        CDXCardDeck *deck = [CDXCardDeckURLSerializer cardDeckFromString:@"Test%201,ffffff,000000&ONE&ONE%0dTWO&ONE%0dTWO%0dTHREE&one%0dtwo%0dthree,00000088,ff0000&1%202%0d3%204,000000,ffffff88"];
        deck.displayStyle = CDXCardDeckDisplayStyleSwipeStack;
        deck.fontSize = 200.0;
        [decks addCardDeck:deck];
    }
    {
        CDXCardDeck *deck = [CDXCardDeckURLSerializer cardDeckFromString:@"Test%202,ffffff,000000&ONE&ONE%0dTWO&ONE%0dTWO%0dTHREE&one%0dtwo%0dthree,00000088,ff0000&1%202%0d3%204,000000,ffffff88"];
        deck.displayStyle = CDXCardDeckDisplayStyleSideBySide;
        deck.wantsPageControl = YES;
        [decks addCardDeck:deck];
    }
    {
        // default card deck
        CDXCardDeck *deck = [CDXCardDeckURLSerializer cardDeckFromString:@"New%20Card%20Deck,ffffff,000000"];
        deck.displayStyle = CDXCardDeckDisplayStyleSwipeStack;
        deck.wantsPageControl = YES;
        deck.wantsAutoRotate = NO;
        deck.wantsIdleTimer = NO;
        deck.wantsShakeRandom = NO;
        deck.cornerStyle = CDXCardCornerStyleCornered;
        decks.cardDeckDefaults = deck;
    }
    
    CDXCardDecksListViewController *vc = [[[CDXCardDecksListViewController alloc] initWithCardDecks:decks] autorelease];
    
    [appWindowManager pushViewController:vc animated:NO];
    [appWindowManager makeWindowKeyAndVisible];
}

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    qltrace();
}

@end

