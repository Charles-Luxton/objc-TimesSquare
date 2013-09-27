//
//  TSQCalendarRowCell.m
//  TimesSquare
//
//  Created by Jim Puls on 11/14/12.
//  Licensed to Square, Inc. under one or more contributor license agreements.
//  See the LICENSE file distributed with this work for the terms under
//  which Square, Inc. licenses this file to you.

#import "TSQCalendarRowCell.h"
#import "TSQCalendarView.h"


@interface TSQCalendarRowCell ()

@property (nonatomic, strong) NSArray *dayButtons;
@property (nonatomic, strong) NSArray *notThisMonthButtons;

@property (nonatomic, strong) UIButton *todayButton;
@property (nonatomic, strong) UIButton *selectedButton;
@property (nonatomic, strong) UIButton *highlightTerminatorButton;

@property (nonatomic, assign) NSInteger indexOfTodayButton;
@property (nonatomic, assign) NSInteger indexOfSelectedButton;
@property (nonatomic, assign) NSInteger indexOfHighlightTerminatorButton;

@property (nonatomic, strong) NSDateFormatter *dayFormatter;
@property (nonatomic, strong) NSDateFormatter *accessibilityFormatter;

@property (nonatomic, strong) NSDateComponents *todayDateComponents;
@property (nonatomic, strong) NSDateComponents *highlightTerminatorDateComponents;
@property (nonatomic) NSInteger monthOfBeginningDate;


@property (nonatomic, strong) UIColor *todayBackgroundColor;
@property (nonatomic, strong) UIColor *selectedBackgroundColor;
@property (nonatomic, strong) UIColor *highlightedBackgroundColor;
@property (nonatomic, strong) UIColor *notThisMonthBackgroundColor;
@property (nonatomic, strong) UIColor *cellTextColor;
@property (nonatomic, strong) UIColor *notThisMonthTextColor;

@end


@implementation TSQCalendarRowCell

- (id)initWithCalendar:(NSCalendar *)calendar reuseIdentifier:(NSString *)reuseIdentifier;
{
    self = [super initWithCalendar:calendar reuseIdentifier:reuseIdentifier];
    if (!self) {
        return nil;
    }
    
    self.todayBackgroundColor = [UIColor colorWithRed:0.78f green:0.78f blue:0.78f alpha:1.0f];
    self.selectedBackgroundColor = [UIColor colorWithRed:0.24f green:0.5f blue:0.49f alpha:1.0f];
    self.notThisMonthBackgroundColor = [UIColor colorWithRed:0.90f green:0.91f blue:0.92f alpha:0.0f];
    self.textColor = [UIColor colorWithRed:0.53f green:0.53f blue:0.53f alpha:1.0f];
    self.notThisMonthTextColor = [UIColor colorWithRed:0.82f green:0.83f blue:0.83f alpha:1.0f];
    self.highlightedBackgroundColor = [UIColor colorWithRed:0.57f green:0.76f blue:0.75f alpha:1.0f];
    return self;
}

- (void)configureButton:(UIButton *)button;
{
    button.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:19.f];
    button.titleLabel.shadowOffset = self.shadowOffset;
    button.adjustsImageWhenDisabled = NO;
    [button setTitleColor:self.textColor forState:UIControlStateNormal];
    [button setTitleShadowColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

- (void)createDayButtons;
{
    NSMutableArray *dayButtons = [NSMutableArray arrayWithCapacity:self.daysInWeek];
    for (NSUInteger index = 0; index < self.daysInWeek; index++) {
        UIButton *button = [[UIButton alloc] initWithFrame:self.contentView.bounds];
        [button addTarget:self action:@selector(dateButtonPressed:) forControlEvents:UIControlEventTouchDown];
        [dayButtons addObject:button];
        [self.contentView addSubview:button];
        [self configureButton:button];
        [button setTitleColor:[self.textColor colorWithAlphaComponent:0.5f] forState:UIControlStateDisabled];
    }
    self.dayButtons = dayButtons;
}

- (void)createNotThisMonthButtons;
{
    NSMutableArray *notThisMonthButtons = [NSMutableArray arrayWithCapacity:self.daysInWeek];
    for (NSUInteger index = 0; index < self.daysInWeek; index++) {
        UIButton *button = [[UIButton alloc] initWithFrame:self.contentView.bounds];
        [button addTarget:self action:@selector(notThisMonthDateButtonPressed:) forControlEvents:UIControlEventTouchDown];
        [notThisMonthButtons addObject:button];
        [self.contentView addSubview:button];
        [self configureButton:button];
        
        button.enabled = YES;
        button.backgroundColor = [self notThisMonthBackgroundColor];
        [button setTitleColor:[self notThisMonthTextColor] forState:UIControlStateNormal];
        //button.titleLabel.textColor = [self notThisMonthTextColor];
        //button.titleLabel.backgroundColor = backgroundPattern;
    }
    self.notThisMonthButtons = notThisMonthButtons;
}

- (void)createTodayButton;
{
    self.todayButton = [[UIButton alloc] initWithFrame:self.contentView.bounds];
    [self.contentView addSubview:self.todayButton];
    [self configureButton:self.todayButton];
    [self.todayButton addTarget:self action:@selector(todayButtonPressed:) forControlEvents:UIControlEventTouchDown];
    
    [self.todayButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //[self.todayButton setBackgroundImage:[self todayBackgroundImage] forState:UIControlStateNormal];
    [self.todayButton setBackgroundColor: [self todayBackgroundColor]];
    //[self.todayButton setTitleShadowColor:[UIColor colorWithWhite:0.0f alpha:0.75f] forState:UIControlStateNormal];

     self.todayButton.titleLabel.font = [UIFont systemFontOfSize:19.0f];
    //self.todayButton.titleLabel.shadowOffset = CGSizeMake(0.0f, -1.0f / [UIScreen mainScreen].scale);
}

- (void)createSelectedButton;
{
    self.selectedButton = [[UIButton alloc] initWithFrame:self.contentView.bounds];
    [self.contentView addSubview:self.selectedButton];
    [self configureButton:self.selectedButton];
    
    [self.selectedButton setAccessibilityTraits:UIAccessibilityTraitSelected|self.selectedButton.accessibilityTraits];
    
    self.selectedButton.enabled = NO;
    [self.selectedButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.selectedButton.titleLabel.font = [UIFont systemFontOfSize:19.0f];
    //[self.selectedButton setBackgroundImage:[self selectedBackgroundImage] forState:UIControlStateNormal];
    [self.selectedButton setBackgroundColor:[self selectedBackgroundColor]];
    //[self.selectedButton setTitleShadowColor:[UIColor colorWithWhite:0.0f alpha:0.75f] forState:UIControlStateNormal];
    
    self.selectedButton.titleLabel.shadowOffset = CGSizeMake(0.0f, -1.0f / [UIScreen mainScreen].scale);
    self.indexOfSelectedButton = -1;
}

- (void)createHighlightTerminatorButton;
{
    self.highlightTerminatorButton = [[UIButton alloc] initWithFrame:self.contentView.bounds];
    [self.contentView addSubview:self.highlightTerminatorButton];
    [self configureButton:self.highlightTerminatorButton];
    
    [self.highlightTerminatorButton setAccessibilityTraits:UIAccessibilityTraitSelected|self.highlightTerminatorButton.accessibilityTraits];
    
    self.highlightTerminatorButton.enabled = NO;
    [self.highlightTerminatorButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.highlightTerminatorButton.titleLabel.font = [UIFont systemFontOfSize:19.0f];
    //[self.highlightTerminatorButton setBackgroundImage:[self selectedBackgroundImage] forState:UIControlStateNormal];
    [self.highlightTerminatorButton setBackgroundColor:[self selectedBackgroundColor]];
    //[self.highlightTerminatorButton setTitleShadowColor:[UIColor colorWithWhite:0.0f alpha:0.75f] forState:UIControlStateNormal];
    
    self.highlightTerminatorButton.titleLabel.shadowOffset = CGSizeMake(0.0f, -1.0f / [UIScreen mainScreen].scale);
    self.indexOfHighlightTerminatorButton = -1;
}

- (void)setBeginningDate:(NSDate *)date;
{
    _beginningDate = date;
    
    if (!self.dayButtons) {
        [self createDayButtons];
        [self createNotThisMonthButtons];
        [self createTodayButton];
        [self createSelectedButton];
        [self createHighlightTerminatorButton];
    }

    NSDateComponents *offset = [NSDateComponents new];
    offset.day = 1;

    self.todayButton.hidden = YES;
    self.indexOfTodayButton = -1;
    self.selectedButton.hidden = YES;
    self.indexOfSelectedButton = -1;
    self.highlightTerminatorButton.hidden = YES;
    self.indexOfHighlightTerminatorButton = -1;
    
    for (NSUInteger index = 0; index < self.daysInWeek; index++) {
        NSString *title = [self.dayFormatter stringFromDate:date];
        NSString *accessibilityLabel = [self.accessibilityFormatter stringFromDate:date];
        [[self.dayButtons objectAtIndex:index] setTitle:title forState:UIControlStateNormal ];
        [[self.dayButtons objectAtIndex:index] setAccessibilityLabel:accessibilityLabel];
        [[self.notThisMonthButtons objectAtIndex:index] setTitle:title forState:UIControlStateNormal ];
        [[self.notThisMonthButtons objectAtIndex:index] setAccessibilityLabel:accessibilityLabel];
        
        //Check to see if the date is inside the valid date range.
        NSDate * first = self.calendarView.firstValidDate;
        NSDate * last = self.calendarView.lastValidDate;
        
        bool *validDate = (first.timeIntervalSince1970 <= date.timeIntervalSince1970 && date.timeIntervalSince1970 <= last.timeIntervalSince1970);

        NSDateComponents *thisDateComponents = [self.calendar components:NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit fromDate:date];
        
        [[self.dayButtons objectAtIndex:index] setHidden:YES];
        [[self.notThisMonthButtons objectAtIndex:index] setHidden:YES];

        NSInteger thisDayMonth = thisDateComponents.month;
        if (self.monthOfBeginningDate != thisDayMonth) {
            [[self.notThisMonthButtons objectAtIndex:index] setHidden:NO];
            [[self.notThisMonthButtons objectAtIndex:index] setEnabled:validDate ];
        } else {
            if (self.highlightTerminatorDateComponents && [self.highlightTerminatorDateComponents isEqual:thisDateComponents]) {
                self.highlightTerminatorButton.hidden = NO;
                [self.highlightTerminatorButton setTitle:title forState:UIControlStateNormal];
                [self.highlightTerminatorButton setAccessibilityLabel:accessibilityLabel];
                self.indexOfHighlightTerminatorButton = index;
            } else if ([self.todayDateComponents isEqual:thisDateComponents]) {
                self.todayButton.hidden = NO;
                [self.todayButton setTitle:title forState:UIControlStateNormal];
                [self.todayButton setAccessibilityLabel: [accessibilityLabel stringByAppendingString:@" today"]];
                [self.todayButton setEnabled:validDate ];
                self.indexOfTodayButton = index;
            } else {
                UIButton *button = [self.dayButtons objectAtIndex:index];
                button.enabled = ![self.calendarView.delegate respondsToSelector:@selector(calendarView:shouldSelectDate:)] || [self.calendarView.delegate calendarView:self.calendarView shouldSelectDate:date];
                button.hidden = NO;
                
                if ([self.calendarView isDateHighlighted:date]) {
                    button.backgroundColor = self.highlightedBackgroundColor;
                    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                    button.titleLabel.font = [UIFont systemFontOfSize:19.0f];
                } else {
                    button.backgroundColor = [UIColor clearColor];
                    [self configureButton:button];
                }
            }
            
            
            
            [[self.dayButtons objectAtIndex:index] setEnabled:validDate ];
        }

        date = [self.calendar dateByAddingComponents:offset toDate:date options:0];
    }
}

- (void)setBottomRow:(BOOL)bottomRow;
{
    UIImageView *backgroundImageView = (UIImageView *)self.backgroundView;
    if ([backgroundImageView isKindOfClass:[UIImageView class]] && _bottomRow == bottomRow) {
        return;
    }

    _bottomRow = bottomRow;
    
    self.backgroundView = [[UIImageView alloc] initWithImage:self.backgroundImage];
    
    [self setNeedsLayout];
}

- (IBAction)dateButtonPressed:(id)sender;
{
    NSDateComponents *offset = [NSDateComponents new];
    offset.day = [self.dayButtons indexOfObject:sender];
    NSDate *selectedDate = [self.calendar dateByAddingComponents:offset toDate:self.beginningDate options:0];
    self.calendarView.selectedDate = selectedDate;
}

- (IBAction)todayButtonPressed:(id)sender;
{
    NSDateComponents *offset = [NSDateComponents new];
    offset.day = self.indexOfTodayButton;
    NSDate *selectedDate = [self.calendar dateByAddingComponents:offset toDate:self.beginningDate options:0];
    self.calendarView.selectedDate = selectedDate;
}

- (IBAction)highlightTerminatorButtonPressed:(id)sender;
{
    NSDateComponents *offset = [NSDateComponents new];
    offset.day = self.indexOfHighlightTerminatorButton;
    NSDate *selectedDate = [self.calendar dateByAddingComponents:offset toDate:self.beginningDate options:0];
    self.calendarView.selectedDate = selectedDate;
}

- (IBAction)notThisMonthDateButtonPressed:(id)sender;
{
    NSDateComponents *offset = [NSDateComponents new];
    offset.day = [self.notThisMonthButtons indexOfObject:sender];
    NSDate *selectedDate = [self.calendar dateByAddingComponents:offset toDate:self.beginningDate options:0];
    self.calendarView.selectedDate = selectedDate;
}

- (void)layoutSubviews;
{
    if (!self.backgroundView) {
        [self setBottomRow:NO];
    }
    
    [super layoutSubviews];
    
    self.backgroundView.frame = self.bounds;
}

- (void)layoutViewsForColumnAtIndex:(NSUInteger)index inRect:(CGRect)rect;
{
    UIButton *dayButton = [self.dayButtons objectAtIndex:index];
    UIButton *notThisMonthButton = [self.notThisMonthButtons objectAtIndex:index];
    
    dayButton.frame = rect;
    notThisMonthButton.frame = rect;

    if (self.indexOfTodayButton == (NSInteger)index) {
        self.todayButton.frame = rect;
    }
    if (self.indexOfSelectedButton == (NSInteger)index) {
        self.selectedButton.frame = rect;
    }
    if (self.indexOfHighlightTerminatorButton == (NSInteger)index) {
        self.highlightTerminatorButton.frame = rect;
    }
    
    rect.origin.y += self.columnSpacing;
    rect.size.height -= (self.bottomRow ? 2.0f : 1.0f) * self.columnSpacing;

}


- (void)selectColumnForDate:(NSDate *)date;
{
    if (!date && self.indexOfSelectedButton == -1) {
        return;
    }

    NSInteger newIndexOfSelectedButton = -1;
    if (date) {
        NSInteger thisDayMonth = [self.calendar components:NSMonthCalendarUnit fromDate:date].month;
        if (self.monthOfBeginningDate == thisDayMonth) {
            newIndexOfSelectedButton = [self.calendar components:NSDayCalendarUnit fromDate:self.beginningDate toDate:date options:0].day;
            if (newIndexOfSelectedButton >= (NSInteger)self.daysInWeek) {
                newIndexOfSelectedButton = -1;
            }
        }
    }

    self.indexOfSelectedButton = newIndexOfSelectedButton;
    
    if (newIndexOfSelectedButton >= 0) {
        self.selectedButton.hidden = NO;
        [self.selectedButton setTitle:[[self.dayButtons objectAtIndex:newIndexOfSelectedButton] currentTitle] forState:UIControlStateNormal];
        [self.selectedButton setAccessibilityLabel:[[self.dayButtons objectAtIndex:newIndexOfSelectedButton] accessibilityLabel]];
    } else {
        self.selectedButton.hidden = YES;
    }
    
    [self setNeedsLayout];
}

- (NSDateFormatter *)dayFormatter;
{
    if (!_dayFormatter) {
        _dayFormatter = [NSDateFormatter new];
        _dayFormatter.calendar = self.calendar;
        _dayFormatter.dateFormat = @"d";
    }
    return _dayFormatter;
}

- (NSDateFormatter *)accessibilityFormatter;
{
    if (!_accessibilityFormatter) {
        _accessibilityFormatter = [NSDateFormatter new];
        _accessibilityFormatter.calendar = self.calendar;
        _accessibilityFormatter.dateFormat = @"d MMMM yyyy";
    }
    return _accessibilityFormatter;
}

- (NSInteger)monthOfBeginningDate;
{
    if (!_monthOfBeginningDate) {
        _monthOfBeginningDate = [self.calendar components:NSMonthCalendarUnit fromDate:self.firstOfMonth].month;
    }
    return _monthOfBeginningDate;
}

- (void)setFirstOfMonth:(NSDate *)firstOfMonth;
{
    [super setFirstOfMonth:firstOfMonth];
    self.monthOfBeginningDate = 0;
}

- (NSDateComponents *)todayDateComponents;
{
    if (!_todayDateComponents) {
        self.todayDateComponents = [self.calendar components:NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit fromDate:self.calendarView.today];
    }
    return _todayDateComponents;
}

- (NSDateComponents *)highlightTerminatorDateComponents;
{
    if (!_highlightTerminatorDateComponents && self.calendarView.highlightTerminatorDate) {
        self.highlightTerminatorDateComponents = [self.calendar components:NSDayCalendarUnit|NSMonthCalendarUnit|NSYearCalendarUnit fromDate:self.calendarView.highlightTerminatorDate];
    }
    return _highlightTerminatorDateComponents;
}

//- (UIImage *)todayBackgroundImage;
//{
//    return [[UIImage imageNamed:@"CalendarTodaysDate.png"] stretchableImageWithLeftCapWidth:4 topCapHeight:4];
//}
//
//- (UIImage *)selectedBackgroundImage;
//{
//    return [[UIImage imageNamed:@"CalendarSelectedDate.png"] stretchableImageWithLeftCapWidth:4 topCapHeight:4];
//}
//
//- (UIImage *)notThisMonthBackgroundImage;
//{
//    return [[UIImage imageNamed:@"CalendarPreviousMonth.png"] stretchableImageWithLeftCapWidth:0 topCapHeight:0];
//}
//
- (UIImage *)backgroundImage;
{
    return [UIImage imageNamed:[NSString stringWithFormat:@"CalendarRow%@.png", self.bottomRow ? @"Bottom" : @""]];
}

@end
