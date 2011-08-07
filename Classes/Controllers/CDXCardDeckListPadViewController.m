//
//
// CDXCardDeckListPadViewController.m
//
//
// Copyright (c) 2009-2011 Arne Harren <ah@0xc0.de>
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

#import "CDXCardDeckListPadViewController.h"
#import "CDXCardDeckCardViewController.h"
#import "CDXCardDeckListViewController.h"
#import "CDXCardDeckCardEditPadViewController.h"
#import "CDXImageFactory.h"
#import "CDXAppSettings.h"
#import "CDXSettingsViewController.h"
#import "CDXCardDecks.h"
#import <QuartzCore/QuartzCore.h>

#undef ql_component
#define ql_component lcl_cController


@implementation CDXCardDeckListPadViewController

- (id)initWithCardDeckViewContext:(CDXCardDeckViewContext *)aCardDeckViewContext {
    if ((self = [super initWithCardDeckViewContext:aCardDeckViewContext nibName:@"CDXCardDeckListPadView" bundle:nil])) {
    }
    return self;
}

- (void)dealloc {
    ivar_release_and_clear(viewTableViewContainer);
    ivar_release_and_clear(navigationItem);
    ivar_release_and_clear(viewNoTableView);
    ivar_release_and_clear(tableCellBackgroundImage);
    ivar_release_and_clear(tableCellBackgroundImageAlt);
    [super dealloc];
}

- (void)viewDidLoad {
    qltrace();
    [super viewDidLoad];
    
    viewTableViewContainer.layer.cornerRadius = 6;
    viewTableView.backgroundView = [[[UIImageView alloc] initWithImage:[[CDXImageFactory sharedImageFactory] imageForLinearGradientWithTopColor:[CDXColor colorWhite] bottomColor:[CDXColor colorWithRed:0xf0 green:0xf0 blue:0xf0 alpha:0xff] height:1024]] autorelease];
    
    viewTableView.hidden = cardDeck == nil;
    viewNoTableView.hidden = !viewTableView.hidden;
    navigationItem.title = cardDeck.name;
    
    ivar_assign_and_retain(tableCellBackgroundImage, [[CDXImageFactory sharedImageFactory] imageForLinearGradientWithTopColor:[CDXColor colorWhite] bottomColor:[CDXColor colorWithRed:0xf9 green:0xf9 blue:0xf9 alpha:0xff] height:44]);
    ivar_assign_and_retain(tableCellBackgroundImageAlt, [[CDXImageFactory sharedImageFactory] imageForLinearGradientWithTopColor:[CDXColor colorWithRed:0xf0 green:0xf0 blue:0xf0 alpha:0xff] bottomColor:[CDXColor colorWithRed:0xe9 green:0xe9 blue:0xe9 alpha:0xff] height:44]);
    ivar_assign_and_retain(tableCellBackgroundColorAction, [UIColor clearColor]);
}

- (void)viewDidUnload {
    qltrace();
    ivar_release_and_clear(viewTableViewContainer);
    ivar_release_and_clear(navigationItem);
    ivar_release_and_clear(viewNoTableView);
    ivar_release_and_clear(tableCellBackgroundImage);
    ivar_release_and_clear(tableCellBackgroundImageAlt);
    [super viewDidUnload];
}

- (void)updateNotificationForCardDeck:(id)object {
    qltrace();
    if (!ignoreCardDeckUpdateNotifications) {
        [viewTableView reloadSections:[NSIndexSet indexSetWithIndex:1] withRowAnimation:UITableViewRowAnimationNone];
        self.navigationItem.title = cardDeck.name;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    qltrace();
    [super viewWillAppear:animated];
    if (!viewNoTableView.hidden) {
        settingsButton.enabled = YES;
        actionButton.enabled = YES;
        shuffleButton.enabled = YES;
        editButton.enabled = YES;
        addButton.enabled = YES;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    qltrace();
    [super viewDidAppear:animated];
    ignoreCardDeckUpdateNotifications = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateNotificationForCardDeck:) name:CDXCardDeckUpdateNotification object:cardDeck];
    ignoreCardDeckUpdateNotifications = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    qltrace();
    ignoreCardDeckUpdateNotifications = YES;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [super viewWillDisappear:animated];
    [CDXStorage drainAllDeferredActions];
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [super tableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath];
    UIColor *clearColor = [UIColor clearColor];
    cell.textLabel.backgroundColor = clearColor;
    cell.detailTextLabel.backgroundColor = clearColor;
    cell.backgroundColor = clearColor;
    if (indexPath.section == 1) {
        NSUInteger groupSize = [cardDeck groupSize];
        if (groupSize > 0 && (indexPath.row / groupSize) % 2 == 0) {
            cell.backgroundView	= [[[UIImageView alloc] initWithImage:tableCellBackgroundImageAlt] autorelease];
        } else {
            cell.backgroundView	= [[[UIImageView alloc] initWithImage:tableCellBackgroundImage] autorelease];
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForSection:(NSUInteger)section {
    switch (section) {
        case 0:
            return nil;
        case 1: {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifierSection1];
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:reuseIdentifierSection1] autorelease];
                cell.accessoryType = UITableViewCellAccessoryDetailDisclosureButton;
                cell.backgroundView	= [[[UIImageView alloc] initWithImage:tableCellBackgroundImage] autorelease];
                cell.selectionStyle = UITableViewCellSelectionStyleGray;
            }
            return cell;
        }
        case 2: {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifierSection2];
            if (cell == nil) {
                cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifierSection2] autorelease];
                cell.textLabel.font = tableCellTextFontAction;
                cell.textLabel.textAlignment = UITextAlignmentCenter;
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.backgroundView	= [[[UIImageView alloc] initWithImage:tableCellBackgroundImage] autorelease];
                cell.selectionStyle = UITableViewCellSelectionStyleGray;
            }
            cell.textLabel.textColor = self.editing ? tableCellTextTextColorActionInactive : tableCellTextTextColorAction;
            return cell;
        }
        default:
            return nil;
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    ignoreCardDeckUpdateNotifications = YES;
    [super tableView:tableView commitEditingStyle:editingStyle forRowAtIndexPath:indexPath];
    ignoreCardDeckUpdateNotifications = NO;
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
    ignoreCardDeckUpdateNotifications = YES;
    [super tableView:tableView moveRowAtIndexPath:fromIndexPath toIndexPath:toIndexPath];
    ignoreCardDeckUpdateNotifications = NO;
}

- (IBAction)addButtonPressedDelayed {
    ignoreCardDeckUpdateNotifications = YES;
    [super addButtonPressedDelayed];
    ignoreCardDeckUpdateNotifications = NO;
}

- (void)pushCardDeckEditViewController {
    CDXCardDeckCardEditPadViewController *vc = [[[CDXCardDeckCardEditPadViewController alloc] initWithCardDeckViewContext:cardDeckViewContext editDefaults:NO] autorelease];
    [[CDXAppWindowManager sharedAppWindowManager] presentModalViewController:vc animated:YES];
    [self performBlockingSelectorEnd];
}

- (void)pushCardDeckEditViewControllerForDefaults {
    CDXCardDeckCardEditPadViewController *vc = [[[CDXCardDeckCardEditPadViewController alloc] initWithCardDeckViewContext:cardDeckViewContext editDefaults:YES] autorelease];
    [[CDXAppWindowManager sharedAppWindowManager] presentModalViewController:vc animated:YES];
    [self performBlockingSelectorEnd];
}

@end

