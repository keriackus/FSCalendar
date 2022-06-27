//
//  FSCalendarWeekdayView.m
//  FSCalendar
//
//  Created by dingwenchao on 03/11/2016.
//  Copyright © 2016 Wenchao Ding. All rights reserved.
//

#import "FSCalendarWeekdayView.h"
#import "FSCalendar.h"
#import "FSCalendarDynamicHeader.h"
#import "FSCalendarExtensions.h"

@interface FSCalendarWeekdayView()

@property (strong, nonatomic) NSPointerArray *weekdayPointers;
@property (strong, nonatomic) NSPointerArray *weekdayNotficationPointers;
@property (weak  , nonatomic) UIView *contentView;
@property (weak  , nonatomic) FSCalendar *calendar;

- (void)commonInit;

@end

@implementation FSCalendarWeekdayView
CGFloat notificationDimen = 14;
- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    UIView *contentView = [[UIView alloc] initWithFrame:CGRectZero];
    [self addSubview:contentView];
    _contentView = contentView;
    
    _weekdayPointers = [NSPointerArray weakObjectsPointerArray];
    _weekdayNotficationPointers = [NSPointerArray weakObjectsPointerArray];
    for (int i = 0; i < 7; i++) {
        UILabel *weekdayLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        weekdayLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:weekdayLabel];
        [_weekdayPointers addPointer:(__bridge void * _Nullable)(weekdayLabel)];
        
        UILabel *notificationCircle = [[UILabel alloc] initWithFrame:CGRectZero];
        notificationCircle.hidden =  YES;
        notificationCircle.layer.cornerRadius = notificationDimen/2.0f;
        notificationCircle.backgroundColor =[UIColor redColor];
        notificationCircle.text = @"3";
        notificationCircle.textColor = [UIColor whiteColor];
        notificationCircle.textAlignment = NSTextAlignmentCenter;
        notificationCircle.layer.masksToBounds = YES;
        notificationCircle.font = [UIFont systemFontOfSize:9];
        [self.contentView addSubview:notificationCircle];
        [_weekdayNotficationPointers addPointer:(__bridge void * _Nullable)(notificationCircle)];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.contentView.frame = self.bounds;
    
    // Position Calculation
    NSInteger count = self.weekdayPointers.count;
    size_t size = sizeof(CGFloat)*count;
    CGFloat *widths = malloc(size);
    CGFloat contentWidth = self.contentView.fs_width;
    FSCalendarSliceCake(contentWidth, count, widths);
    
    BOOL opposite = NO;
    if (@available(iOS 9.0, *)) {
        UIUserInterfaceLayoutDirection direction = [UIView userInterfaceLayoutDirectionForSemanticContentAttribute:self.calendar.semanticContentAttribute];
        opposite = (direction == UIUserInterfaceLayoutDirectionRightToLeft);
    }
    
     __block CGFloat x = 0;
    [self.weekdayLabels enumerateObjectsUsingBlock:^(UILabel *weekdayLabel, NSUInteger index, BOOL *stop) {
        CGFloat width = widths[index];
        weekdayLabel.frame = CGRectMake(x, 0, width, self.contentView.fs_height);
        x += width;
    }];
    x = 0;
    [self.weekdayNotificationLabels enumerateObjectsUsingBlock:^(UILabel *notificationCircle, NSUInteger index, BOOL *stop) {
        CGFloat width = widths[index];
       // notificationCircle.text = [NSString stringWithFormat:@"%@",index];
        notificationCircle.frame = CGRectMake(((self.contentView.fs_width/7) *index) + (self.contentView.fs_width/7) - (notificationDimen) , 0, notificationDimen, notificationDimen);
        x += width;
    }];
    
    free(widths);
}

- (void)setCalendar:(FSCalendar *)calendar
{
    _calendar = calendar;
    [self configureAppearance];
}

- (void)showNotificationLabel:(int) index withCount: (int)count
{
    NSUInteger uiIndex = index;
    UILabel *notificationLabel = (UILabel*) [self.weekdayNotficationPointers.allObjects objectAtIndex:uiIndex];
    notificationLabel.hidden = NO;
    notificationLabel.text = [NSString stringWithFormat:@"%i", count];

#ifdef DATALOEN
    //notificationLabel.backgroundColor = KINDaySelectorColor;
#endif
   
}

- (void)hideNotificationLabel:(int) index
{
    NSUInteger uiIndex = index;
    UILabel *notificationLabel = (UILabel*) [self.weekdayNotficationPointers.allObjects objectAtIndex:uiIndex];
    notificationLabel.hidden = YES;
}

- (NSArray<UILabel *> *)weekdayLabels
{
    return self.weekdayPointers.allObjects;
}

- (NSArray<UILabel *> *)weekdayNotificationLabels
{
    return self.weekdayNotficationPointers.allObjects;
}

- (void)configureAppearance
{
    BOOL useVeryShortWeekdaySymbols = (self.calendar.appearance.caseOptions & (15<<4) ) == FSCalendarCaseOptionsWeekdayUsesSingleUpperCase;
    NSArray *weekdaySymbols = useVeryShortWeekdaySymbols ? self.calendar.gregorian.veryShortStandaloneWeekdaySymbols : self.calendar.gregorian.shortStandaloneWeekdaySymbols;
    BOOL useDefaultWeekdayCase = (self.calendar.appearance.caseOptions & (15<<4) ) == FSCalendarCaseOptionsWeekdayUsesDefaultCase;
    
    [self.weekdayLabels enumerateObjectsUsingBlock:^(UILabel * _Nonnull label, NSUInteger idx, BOOL * _Nonnull stop) {
        NSInteger index = idx;
        label.font = self.calendar.appearance.weekdayFont;
        label.textColor = self.calendar.appearance.weekdayTextColor;
        index += self.calendar.firstWeekday-1;
        index %= 7;
        label.text = useDefaultWeekdayCase ? weekdaySymbols[index] : [weekdaySymbols[index] uppercaseString];
    }];

}

@end
