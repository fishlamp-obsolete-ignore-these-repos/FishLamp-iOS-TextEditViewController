//
//  FLTextEditViewController.m
//  FishLamp
//
//  Created by Mike Fullerton on 6/4/11.
//  Copyright (c) 2013 GreenTongue Software LLC, Mike Fullerton.
//  The FishLamp Framework is released under the MIT License: http://fishlamp.com/license 
//

#import "FLTextEditViewController.h"
#import "FLGradientView.h"
#import "FLSingleColumnRowArrangement.h"
#import "FLAlert.h"
#import "FLButtons.h"

@implementation FLTextEditViewController

@synthesize textEditView = _textEditView;
@synthesize returnKeyBeginsSave = _returnKeyBeginsSave;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	if((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]))
	{
    }
	
	return self;
}

+ (FLTextEditViewController*) textEditViewController
{
	return FLAutorelease([[FLTextEditViewController alloc] initWithNibName:nil bundle:nil]);
}

- (NSInteger) maxSize
{
	return _maxSize;
}

- (void) setMaxSize:(NSInteger) maxSize
{
    _maxSize = maxSize;
	if(_textEditView)
    {
        _textEditView.maxSize = maxSize;
    }
}

- (NSString*) text
{
	return _text;
}

- (void) setText:(NSString*) text
{
    FLSetObjectWithRetain(_text, text);
    
    if(_textEditView)
    {
        _textEditView.text = _text;
    }
}

- (void) dealloc
{
    FLRelease(_placeholderText);
    FLRelease(_text);
    _textEditView.delegate = nil;
	FLRelease(_textEditView);
	FLSuperDealloc();
}

- (void) hideViewController:(BOOL)animated 
{
    _textEditView.delegate = nil;
    [super hideViewController:animated];
}

- (NSUInteger) textLength
{
    return _text.length;
}

- (BOOL) textIsTooLong
{
    return self.maxSize > 0 && self.maxSize < (NSInteger) _text.length;
}

- (void) willBeginSaving
{
    if(self.textIsTooLong)
    {
        [self presentTextIsTooLongMessage];
    }
    else
    {
        [self beginSaving];
    }
}

- (void) presentTextIsTooLongMessage
{
    FLAlert* alert = [FLAlert alertViewController:NSLocalizedString(@"The text is too long.", nil)
                                                                      message:[NSString stringWithFormat:(NSLocalizedString(@"The maximum length is %d characters.", nil)), self.maxSize]];
    [alert addButton:[FLConfirmButton okButton]];
    [alert showViewControllerAnimated:YES];
}

- (NSString*) truncatedText
{
    return self.textIsTooLong ? [_text substringToIndex:self.maxSize - 1]: _text;
}

- (void) truncateText
{
    if(self.textIsTooLong)
    {   
        [self setText:self.truncatedText];
    }
}

- (void) stopEditing
{
    [_textEditView stopEditing];
}

- (void) startEditing
{
    [_textEditView startEditing];
}

- (BOOL) canUpdateSaveButtonEnabledState
{
	return YES;
}

- (void) updateSaveButtonState
{
	if(self.canUpdateSaveButtonEnabledState)
	{
		self.saveButtonEnabled = FLStringIsNotEmpty(self.text);
	}
}

- (void) textEditView:(FLTextEditView*) textEditView userTappedReturnKey:(NSString*) text
{
    if(self.returnKeyBeginsSave)
    {
        [self willBeginSaving];
    }
    else
    {
        FLSetObjectWithRetain(_text, text);
        [self updateSaveButtonState];
    }
}

- (void) textEditView:(FLTextEditView*) textEditView textDidChange:(NSString*) text
{
    FLSetObjectWithRetain(_text, text);
	[self updateSaveButtonState];
}

- (void) viewDidUnload
{
    [super viewDidUnload];
   
    _textEditView.delegate = nil;
	FLReleaseWithNil(_textEditView);
}

- (NSString*) placeholderText
{
    return _textEditView ? _textEditView.placeholderText : _placeholderText;
}

- (void) setPlaceholderText:(NSString *)placeholderText
{
    FLSetObjectWithRetain(_placeholderText, placeholderText);
    if(_textEditView)
    {
        _textEditView.placeholderText = placeholderText;
    }
}

- (void) setReturnKeyBeginsSave:(BOOL)returnKeyBeginsSave
{
    _returnKeyBeginsSave = returnKeyBeginsSave;
    if(_textEditView)
    {
        _textEditView.dissallowReturnKey = _returnKeyBeginsSave;
    }
}

- (void) viewDidLoad
{
    _textEditView = [[FLTextEditView alloc] initWithFrame:CGRectMake(0,0,200,80)];
    _textEditView.delegate = self;
    _textEditView.maxSize = _maxSize;
    _textEditView.dissallowReturnKey = self.returnKeyBeginsSave;
    if(FLStringIsNotEmpty(_text))
    {
        _textEditView.text = _text;
    }
    if(FLStringIsNotEmpty(_placeholderText))
    {
        _textEditView.placeholderText = _placeholderText;
    }

    [super viewDidLoad];
}

- (void) configureContentView
{
    self.contentView.arrangement = [FLSingleColumnRowArrangement arrangement];
    self.contentView.arrangement.outerInsets = FLEdgeInsets10;
	[self.contentView addSubview:_textEditView];
}

- (void) viewDidAppear:(BOOL) animated
{
	[super viewDidAppear:animated];
	[self updateSaveButtonState];
	[self startEditing];
}

@end
