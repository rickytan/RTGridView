//
//  RTViewController.m
//  RTGridView
//
//  Created by ricky on 13-9-14.
//  Copyright (c) 2013年 ricky. All rights reserved.
//

#import "RTViewController.h"
#import "RTGridView.h"

@interface RTViewController ()
@property (nonatomic, assign) IBOutlet RTGridView *gridView;
- (IBAction)onInsertText:(id)sender;
- (IBAction)onInsertImage:(id)sender;
- (IBAction)onInsertCustomView:(id)sender;
- (IBAction)onRemoveLast:(id)sender;
- (IBAction)onRemoveFirst:(id)sender;
- (IBAction)onItemMargin:(UISlider*)slider;
- (IBAction)onLineMargin:(UISlider*)slider;
- (IBAction)onLayout:(UISegmentedControl*)segment;
@end

@implementation RTViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    self.gridView.minLineMargin = slider.value;
}

- (IBAction)onLayout:(UISegmentedControl *)segment
{
    self.gridView.layoutType = segment.selectedSegmentIndex + 2;
}

@end
