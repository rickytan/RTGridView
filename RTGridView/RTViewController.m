//
//  RTViewController.m
//  RTGridView
//
//  Created by ricky on 13-9-14.
//  Copyright (c) 2013年 ricky. All rights reserved.
//

#import "RTViewController.h"
#import "RTGridView.h"

@interface RTViewController () <RTGridViewDelegate>
@property (nonatomic, assign) IBOutlet RTGridView *gridView;
- (IBAction)onInsertText:(id)sender;
- (IBAction)onInsertImage:(id)sender;
- (IBAction)onInsertCustomView:(id)sender;
- (IBAction)onRemoveLast:(id)sender;
- (IBAction)onRemoveFirst:(id)sender;
- (IBAction)onItemMargin:(UISlider*)slider;
- (IBAction)onLineMargin:(UISlider*)slider;
- (IBAction)onLayout:(UISegmentedControl*)segment;
- (IBAction)onAllowEditing:(UISwitch*)swith;
@end

@implementation RTViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.gridView.itemSize = CGSizeMake(64, 80);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)gridView:(RTGridView *)grdiView didTapOnItem:(RTGridItem *)item
{
    NSString *text = nil;
    if ([item.customView isKindOfClass:[UILabel class]])
        text = ((UILabel*)item.customView).text;
    else if ([item.customView isKindOfClass:[UIImageView class]])
        text = @"Image";
    else
        text = @"Custom View";
    [[[[UIAlertView alloc] initWithTitle:@"alert"
                                 message:[NSString stringWithFormat:@"did tap on %@", text]
                                delegate:nil
                       cancelButtonTitle:@"OK"
                       otherButtonTitles:nil] autorelease] show];
}

- (IBAction)onInsertText:(id)sender
{
    static int count = 0;
    [self.gridView insertItem:[RTGridItem gridItemWithTitle:[NSString stringWithFormat:@"Text %d", count++]] atIndex:0];
}

- (IBAction)onInsertImage:(id)sender
{
    [self.gridView insertItem:[RTGridItem gridItemWithImage:[UIImage imageNamed:@"apple.png"]] atIndex:0];
}

- (IBAction)onInsertCustomView:(id)sender
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 64, 64)];
    view.backgroundColor = [UIColor orangeColor];
    [self.gridView insertItem:[RTGridItem gridItemWithCustomView:view]
                      atIndex:0];
    [view release];
}

- (IBAction)onRemoveFirst:(id)sender
{
    [self.gridView removeItemAtIndex:0];
}

- (IBAction)onRemoveLast:(id)sender
{
    [self.gridView removeLastItem];
}

- (IBAction)onItemMargin:(UISlider *)slider
{
    self.gridView.minItemMargin = slider.value;
}

- (IBAction)onLineMargin:(UISlider *)slider
{
    self.gridView.lineMargin = slider.value;
}

- (IBAction)onLayout:(UISegmentedControl *)segment
{
    self.gridView.layoutType = segment.selectedSegmentIndex;
}

- (IBAction)onAllowEditing:(UISwitch *)swith
{
    self.gridView.allowEditing = swith.isOn;
}

@end
