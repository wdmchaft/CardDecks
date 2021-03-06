//
//
// CDXListViewControllerBase.m
//
//
// Copyright (c) 2009-2012 Arne Harren <ah@0xc0.de>
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

#import "CDXListViewControllerBase.h"
#import "CDXDevice.h"
#import "CDXImageFactory.h"

#undef ql_component
#define ql_component lcl_cController


@implementation CDXListViewControllerBase

#pragma mark -
#pragma mark Init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil titleText:(NSString*)aTitleText backButtonText:(NSString *)aBackButtonText {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        useReducedGraphicsEffects = [[CDXDevice sharedDevice] useReducedGraphicsEffects];
        ivar_assign_and_copy(titleText, aTitleText);
        ivar_assign_and_copy(backButtonText, aBackButtonText);
        ivar_assign_and_retain(reuseIdentifierSection1, @"Section1Cell");
        ivar_assign_and_retain(reuseIdentifierSection2, @"Section2Cell");
        performActionState = CDXListViewControllerBasePerformActionStateNone;
    }
    return self;
}

- (void)detachViewObjects {
    qltrace();
    ivar_release_and_clear(viewTableView);
    ivar_release_and_clear(viewToolbar);
    ivar_release_and_clear(editButton);
    ivar_release_and_clear(settingsButton);
    ivar_release_and_clear(activityIndicator);
    ivar_release_and_clear(tableCellTextFont);
    ivar_release_and_clear(tableCellTextFontAction);
    ivar_release_and_clear(tableCellTextTextColor);
    ivar_release_and_clear(tableCellTextTextColorNoCards);
    ivar_release_and_clear(tableCellTextTextColorAction);
    ivar_release_and_clear(tableCellTextTextColorActionInactive);
    ivar_release_and_clear(tableCellDetailTextFont);
    ivar_release_and_clear(tableCellDetailTextTextColor);
    ivar_release_and_clear(tableCellBackgroundImage);
    ivar_release_and_clear(tableCellBackgroundImageAlt);
    ivar_release_and_clear(viewTableViewLongPressRecognizer);
    ivar_release_and_clear(viewToolbarLongPressRecognizer);
    ivar_release_and_clear(performActionTableViewIndexPath);
    ivar_release_and_clear(performActionToolbarBarButtonItem);
}

- (void)dealloc {
    qltrace();
    [self detachViewObjects];
    ivar_release_and_clear(titleText);
    ivar_release_and_clear(backButtonText);
    ivar_release_and_clear(reuseIdentifierSection1);
    ivar_release_and_clear(reuseIdentifierSection2);
    [super dealloc];
}

#pragma mark -
#pragma mark View

- (void)viewDidLoad {
    qltrace();
    [super viewDidLoad];
    UINavigationItem *navigationItem = self.navigationItem;
    navigationItem.title = titleText;
    navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc]
                                         initWithTitle:backButtonText
                                         style:UIBarButtonItemStylePlain
                                         target:nil
                                         action:nil]
                                        autorelease];
    
    ivar_assign(activityIndicator, [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite]);
    activityIndicator.hidesWhenStopped = YES;
    if ([[CDXDevice sharedDevice] deviceUIIdiom] == CDXDeviceUIIdiomPad) {
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;
    }
    navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc]
                                          initWithCustomView:activityIndicator]
                                         autorelease];
    self.toolbarItems = viewToolbar.items;
    ivar_assign_and_retain(tableCellTextFont, [UIFont boldSystemFontOfSize:18]);
    ivar_assign_and_retain(tableCellTextFontAction, [UIFont boldSystemFontOfSize:11]);
    ivar_assign_and_retain(tableCellTextTextColor, [UIColor blackColor]);
    ivar_assign_and_retain(tableCellTextTextColorNoCards, [UIColor grayColor]);
    ivar_assign_and_retain(tableCellTextTextColorAction, [UIColor grayColor]);
    ivar_assign_and_retain(tableCellTextTextColorActionInactive, [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1.0]);
    ivar_assign_and_retain(tableCellDetailTextFont, [UIFont systemFontOfSize:10]);
    ivar_assign_and_retain(tableCellDetailTextTextColor, [UIColor grayColor]);
    CGFloat rowHeight = viewTableView.rowHeight;
    CGFloat base = useReducedGraphicsEffects ? 1.0 : 0.75;
    if (!useReducedGraphicsEffects) {
        ivar_assign_and_retain(tableCellBackgroundImage, [[CDXImageFactory sharedImageFactory] imageForLinearGradientWithTopColor:[CDXColor colorWhite] bottomColor:[CDXColor colorWithRed:0xf8 green:0xf8 blue:0xf8 alpha:0xff] height:rowHeight base:base]);
    }
    ivar_assign_and_retain(tableCellBackgroundImageAlt, [[CDXImageFactory sharedImageFactory] imageForLinearGradientWithTopColor:[CDXColor colorWithRed:0xf0 green:0xf0 blue:0xf0 alpha:0xff] bottomColor:[CDXColor colorWithRed:0xe8 green:0xe8 blue:0xe8 alpha:0xff] height:rowHeight base:base]);
    tableCellImageSize = CGSizeMake(10, 10);
    
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    viewTableView.backgroundView = [[[UIImageView alloc] initWithImage:[[CDXImageFactory sharedImageFactory] imageForLinearGradientWithTopColor:[CDXColor colorWhite] bottomColor:[CDXColor colorWithRed:0xf8 green:0xf8 blue:0xf8 alpha:0xff] height:screenHeight base:0.0]] autorelease];
    
    ivar_assign(viewTableViewLongPressRecognizer, [[UILongPressGestureRecognizer alloc]
                                                   initWithTarget:self action:@selector(handleTableViewLongPressGesture:)]);
    ivar_assign(viewToolbarLongPressRecognizer, [[UILongPressGestureRecognizer alloc]
                                                 initWithTarget:self action:@selector(handleToolbarLongPressGesture:)]);
}

- (void)viewDidUnload {
    qltrace();
    [self detachViewObjects];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated {
    qltrace();
    [super viewWillAppear:animated];
    [self performBlockingSelectorEnd];
    [viewTableView reloadData];
    [self updateToolbarButtons];
    viewTableView.contentOffset = CGPointMake(0, MAX(0, viewTableViewContentOffsetY));
    performActionState = CDXListViewControllerBasePerformActionStateNone;
    ivar_release_and_clear(performActionTableViewIndexPath);
    ivar_release_and_clear(performActionToolbarBarButtonItem);
    [viewTableView addGestureRecognizer:viewTableViewLongPressRecognizer];
    [self.navigationController.toolbar addGestureRecognizer:viewToolbarLongPressRecognizer];
}

- (void)viewWillDisappear:(BOOL)animated {
    qltrace();
    [super viewWillDisappear:animated];
    [self performBlockingSelectorEnd];
    viewTableViewContentOffsetY = viewTableView.contentOffset.y;
    [viewTableView removeGestureRecognizer:viewTableViewLongPressRecognizer];
    [self.navigationController.toolbar removeGestureRecognizer:viewToolbarLongPressRecognizer];
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {
    if ([self isEditing] == editing) {
        return;
    }
    [super setEditing:editing animated:animated];
    [viewTableView setEditing:editing animated:animated];
    [viewTableView reloadSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationNone];
    [viewTableView reloadSections:[NSIndexSet indexSetWithIndex:2] withRowAnimation:UITableViewRowAnimationNone];
    if (editing) {
        [viewTableView removeGestureRecognizer:viewTableViewLongPressRecognizer];
    } else {
        [viewTableView addGestureRecognizer:viewTableViewLongPressRecognizer];
    }
}

- (void)updateToolbarButtons {
    editButton.enabled = ([self tableView:viewTableView numberOfRowsInSection:1] != 0);
}

#pragma mark -
#pragma mark WindowView

- (void)setUserInteractionEnabled:(BOOL)enabled {
}

- (void)deviceOrientationDidChange:(UIDeviceOrientation)orientation {
}

- (void)menuControllerWillHideMenu {
    if (performActionState == CDXListViewControllerBasePerformActionStateTableView) {
        UITableViewCell *cell = [viewTableView cellForRowAtIndexPath:performActionTableViewIndexPath];
        cell.selected = NO;
    }
    performActionState = CDXListViewControllerBasePerformActionStateNone;
    ivar_release_and_clear(performActionTableViewIndexPath);
    ivar_release_and_clear(performActionToolbarBarButtonItem);
}

#pragma mark -
#pragma mark TableView

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath  marked:(BOOL)marked {
    if (marked || !useReducedGraphicsEffects) {
        UIColor *backgroundColor = [UIColor clearColor];
        cell.textLabel.backgroundColor = backgroundColor;
        cell.detailTextLabel.backgroundColor = backgroundColor;
        cell.backgroundColor = backgroundColor;
        cell.backgroundView = [[[UIImageView alloc] initWithImage:marked ? tableCellBackgroundImageAlt : tableCellBackgroundImage] autorelease];
    } else {
        UIColor *backgroundColor = [UIColor whiteColor];
        cell.textLabel.backgroundColor = backgroundColor;
        cell.detailTextLabel.backgroundColor = backgroundColor;
        cell.backgroundColor = backgroundColor;
        cell.backgroundView = nil;
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [self tableView:tableView willDisplayCell:cell forRowAtIndexPath:indexPath marked:NO];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForSection:(NSUInteger)section {
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section == 1;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return indexPath.section == 1;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    return self.editing ? UITableViewCellEditingStyleDelete : UITableViewCellEditingStyleDelete;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

- (NSIndexPath *)tableView:(UITableView *)tableView targetIndexPathForMoveFromRowAtIndexPath:(NSIndexPath *)sourceIndexPath toProposedIndexPath:(NSIndexPath *)proposedDestinationIndexPath {
    switch (proposedDestinationIndexPath.section) {
        default:
        case 0: {
            return [NSIndexPath indexPathForRow:0 inSection:1];
            break;
        }
        case 1: {
            return proposedDestinationIndexPath;
            break;
        }
        case 2: {
            return [NSIndexPath indexPathForRow:[self tableView:tableView numberOfRowsInSection:1]-1 inSection:1];
            break;
        }
    }
}

#pragma mark -
#pragma mark Gesture

- (void)handleTableViewLongPressGesture:(UILongPressGestureRecognizer *)sender {
    qltrace(@"%@", sender);
    if (sender.state == UIGestureRecognizerStateBegan) {
        NSIndexPath *indexPath = [viewTableView indexPathForRowAtPoint:[sender locationInView:viewTableView]];
        UITableViewCell *cell = [viewTableView cellForRowAtIndexPath:indexPath];
        // ignore gesture if not inside the cell content
        if (cell.accessoryType == UITableViewCellAccessoryDetailDisclosureButton) {
            if (cell.frame.origin.x + cell.frame.size.width - 44 < [sender locationInView:cell].x) {
                return;
            }
        }
        // ignore gesture if not in section 1
        if (indexPath.section != 1) {
            return;
        }
        
        // keep state
        performActionState = CDXListViewControllerBasePerformActionStateTableView;
        ivar_assign_and_retain(performActionTableViewIndexPath, indexPath);
        
        // show menu
        [self becomeFirstResponder];
        UIMenuController *menu = [UIMenuController sharedMenuController];
        [menu setTargetRect:cell.frame inView:sender.view];
        [menu setMenuVisible:YES animated:YES];
        
        // keep cell selected
        cell.selected = YES;
    }
}

- (void)handleToolbarLongPressGesture:(UILongPressGestureRecognizer *)sender {
    qltrace(@"%@", sender);
    if (sender.state == UIGestureRecognizerStateBegan) {
        // find the control which was touched
        CGPoint point = [sender locationInView:sender.view];
        for (UIView *view in [sender.view subviews]) {
            CGRect frame = view.frame;
            frame.origin.x -= 21;
            frame.size.width += 42;
            if (CGRectContainsPoint(frame, point) && ([view isKindOfClass:[UIControl class]])) {
                // find the corresponding bar-button item
                for (UIBarButtonItem *item in [viewToolbar items]) {
                    if ([[(UIControl *)view allTargets] containsObject:item]) {
                        // keep state
                        performActionState = CDXListViewControllerBasePerformActionStateToolbar;
                        ivar_assign_and_retain(performActionToolbarBarButtonItem, item);
                        
                        // show menu
                        [self becomeFirstResponder];
                        UIMenuController *menu = [UIMenuController sharedMenuController];
                        [menu setTargetRect:view.frame inView:sender.view];
                        [menu setMenuVisible:YES animated:YES];
                        
                        return;
                    }
                }
            }
        }
    }
}

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender tableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath {
    qltrace();
    return NO;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender barButtonItem:(UIBarButtonItem *)barButtonItem {
    qltrace();
    return NO;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender {
    qltrace(@"%@", sender);
    // dispatch to specialized canPerformAction method of sub-class
    if (performActionState == CDXListViewControllerBasePerformActionStateTableView) {
        if (performActionTableViewIndexPath != nil) {
            return [self canPerformAction:action withSender:sender tableView:viewTableView indexPath:performActionTableViewIndexPath];
        } else {
            return NO;
        }
    } else if (performActionState == CDXListViewControllerBasePerformActionStateToolbar) {
        if (performActionToolbarBarButtonItem != nil) {
            return [self canPerformAction:action withSender:sender barButtonItem:performActionToolbarBarButtonItem];
        } else {
            return NO;
        }
    } else {
        return NO;
    }
}

- (void)performAction:(SEL)action withSender:(id)sender tableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath {
    qltrace();
}

- (void)performAction:(SEL)action withSender:(id)sender barButtonItem:(UIBarButtonItem *)barButtonItem {
    qltrace();
}

- (void)copy:(id)sender {
    qltrace(@"%@", sender);
    // dispatch to specialized performAction method of sub-class
    if (performActionState == CDXListViewControllerBasePerformActionStateTableView) {
        if (performActionTableViewIndexPath != nil) {
            [self performAction:@selector(copy:) withSender:sender tableView:viewTableView indexPath:performActionTableViewIndexPath];
            return;
        }
    }
}

- (void)paste:(id)sender {
    qltrace(@"%@", sender);
    // dispatch to specialized performAction method of sub-class
    if (performActionState == CDXListViewControllerBasePerformActionStateTableView) {
        if (performActionTableViewIndexPath != nil) {
            [self performAction:@selector(paste:) withSender:sender tableView:viewTableView indexPath:performActionTableViewIndexPath];
            return;
        }
    } else if (performActionState == CDXListViewControllerBasePerformActionStateToolbar) {
        if (performActionToolbarBarButtonItem != nil) {
            [self performAction:@selector(paste:) withSender:sender barButtonItem:performActionToolbarBarButtonItem];
            return;
        }
    }
}

#pragma mark -
#pragma mark Action

- (IBAction)editButtonPressed {
    qltrace();
    [self setEditing:!self.editing animated:YES];
}

#pragma mark -
#pragma mark Blocking

- (void)performBlockingSelector:(SEL)selector withObject:(NSObject *)object {
    [self setUserInteractionEnabled:NO];
    [activityIndicator startAnimating];
    [self performSelector:selector withObject:object afterDelay:0.001];
}

- (void)performBlockingSelectorEnd {
    [self setUserInteractionEnabled:YES];
    [activityIndicator stopAnimating];
}

@end

