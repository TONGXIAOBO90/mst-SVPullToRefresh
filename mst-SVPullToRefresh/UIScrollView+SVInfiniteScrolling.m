//
// UIScrollView+SVInfiniteScrolling.m
//
// Created by Sam Vermette on 23.04.12.
// Copyright (c) 2012 samvermette.com. All rights reserved.
//
// https://github.com/samvermette/SVPullToRefresh
//

#import <QuartzCore/QuartzCore.h>
#import "UIScrollView+SVInfiniteScrolling.h"
#import "LLARingSpinnerView.h"


static CGFloat const SVInfiniteScrollingViewHeight = 60;

@interface SVInfiniteScrollingView ()

@property (nonatomic, copy) void (^infiniteScrollingHandler)(void);

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) LLARingSpinnerView *llARingSpinnerView;
@property (nonatomic, readwrite) SVInfiniteScrollingState state;
@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, readwrite) CGFloat originalBottomInset;
@property (nonatomic, assign) BOOL wasTriggeredByUser;
@property (nonatomic, assign) BOOL isObserving;
@property (nonatomic, strong) NSMutableArray *titles;

- (void)resetScrollViewContentInset;
- (void)setScrollViewContentInsetForInfiniteScrolling;
- (void)setScrollViewContentInsetFoBegin;
- (void)setScrollViewContentInset:(UIEdgeInsets)insets;

@end


#pragma mark - UIScrollView (SVInfiniteScrollingView)
#import <objc/runtime.h>

static char UIScrollViewInfiniteScrollingView;
UIEdgeInsets scrollViewOriginalContentInsets;

@implementation UIScrollView (SVInfiniteScrolling)

@dynamic infiniteScrollingView;

- (void)addInfiniteScrollingWithActionHandler:(void (^)(void))actionHandler {
    
    if(!self.infiniteScrollingView) {
        SVInfiniteScrollingView *view = [[SVInfiniteScrollingView alloc] initWithFrame:CGRectMake(0, self.contentSize.height, self.bounds.size.width, SVInfiniteScrollingViewHeight)];
        view.infiniteScrollingHandler = actionHandler;
        view.scrollView = self;;
        [self addSubview:view];
        view.originalBottomInset = self.contentInset.bottom;
        self.infiniteScrollingView = view;
        self.showsInfiniteScrolling = YES;
    }
}

- (void)triggerInfiniteScrolling {
    self.infiniteScrollingView.state = SVInfiniteScrollingStateTriggered;
    [self.infiniteScrollingView startAnimating];
}

- (void)setInfiniteScrollingView:(SVInfiniteScrollingView *)infiniteScrollingView {
    [self willChangeValueForKey:@"UIScrollViewInfiniteScrollingView"];
    objc_setAssociatedObject(self, &UIScrollViewInfiniteScrollingView,
                             infiniteScrollingView,
                             OBJC_ASSOCIATION_ASSIGN);
    [self didChangeValueForKey:@"UIScrollViewInfiniteScrollingView"];
}

- (SVInfiniteScrollingView *)infiniteScrollingView {
    return objc_getAssociatedObject(self, &UIScrollViewInfiniteScrollingView);
}

- (void)setShowsInfiniteScrolling:(BOOL)showsInfiniteScrolling {
    self.infiniteScrollingView.hidden = !showsInfiniteScrolling;
    
    if(!showsInfiniteScrolling) {
        if (self.infiniteScrollingView.isObserving) {
            [self removeObserver:self.infiniteScrollingView forKeyPath:@"contentOffset"];
            [self removeObserver:self.infiniteScrollingView forKeyPath:@"contentSize"];
            [self.infiniteScrollingView resetScrollViewContentInset];
            self.infiniteScrollingView.isObserving = NO;
        }
    }
    else {
        if (!self.infiniteScrollingView.isObserving) {
            [self addObserver:self.infiniteScrollingView forKeyPath:@"contentOffset" options:NSKeyValueObservingOptionNew context:nil];
            [self addObserver:self.infiniteScrollingView forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
            self.infiniteScrollingView.isObserving = YES;
            [self.infiniteScrollingView setScrollViewContentInsetFoBegin];
            [self.infiniteScrollingView setNeedsLayout];
            self.infiniteScrollingView.frame = CGRectMake(0, self.contentSize.height, self.infiniteScrollingView.bounds.size.width, SVInfiniteScrollingViewHeight);
        }
    }
}

- (BOOL)showsInfiniteScrolling {
    return !self.infiniteScrollingView.hidden;
}

@end


#pragma mark - SVInfiniteScrollingView
@implementation SVInfiniteScrollingView

// public properties
@synthesize infiniteScrollingHandler;

@synthesize state = _state;
@synthesize scrollView = _scrollView;

- (id)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        
        // default styling values
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, self.bounds.size.width, 20)];
        self.titleLabel.font = [UIFont systemFontOfSize:14];
        self.titleLabel.textColor = [UIColor darkGrayColor];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.titleLabel];
        
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.state = SVInfiniteScrollingStateStopped;
        self.enabled = YES;
        
        self.titles = [NSMutableArray arrayWithObjects:@"上拉加载更多", @"松开以加载更多", @"正在加载更多···", @"加载完成", nil];
    }
    
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (self.superview && newSuperview == nil) {
        UIScrollView *scrollView = (UIScrollView *)self.superview;
        if (scrollView.showsInfiniteScrolling) {
          if (self.isObserving) {
            [scrollView removeObserver:self forKeyPath:@"contentOffset"];
            [scrollView removeObserver:self forKeyPath:@"contentSize"];
            self.isObserving = NO;
          }
        }
    }
}

- (void)layoutSubviews {
    self.llARingSpinnerView.center = CGPointMake(self.bounds.size.width/2.0, self.bounds.size.height/2.0 + 8);
    self.titleLabel.text = [self.titles objectAtIndex:self.state];
}

#pragma mark - Scroll View

- (void)resetScrollViewContentInset {
    UIEdgeInsets currentInsets = self.scrollView.contentInset;
    currentInsets.bottom = self.originalBottomInset;
    [self.scrollView setContentInset:currentInsets];
}

- (void)setScrollViewContentInsetForInfiniteScrolling {
    UIEdgeInsets currentInsets = self.scrollView.contentInset;
    currentInsets.bottom = self.originalBottomInset + SVInfiniteScrollingViewHeight;
    [self setScrollViewContentInset:currentInsets];
}

- (void)setScrollViewContentInsetFoBegin{
    UIEdgeInsets currentInsets = self.scrollView.contentInset;
    currentInsets.bottom = self.originalBottomInset + SVInfiniteScrollingViewHeight;
    [self setScrollViewContentInset:currentInsets];
}

- (void)setScrollViewContentInset:(UIEdgeInsets)contentInset {
    [UIView animateWithDuration:0.3
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction|UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.scrollView.contentInset = contentInset;
                     }
                     completion:NULL];
}

#pragma mark - Observing

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {    
    if([keyPath isEqualToString:@"contentOffset"])
    {
        [self scrollViewDidScroll:[[change valueForKey:NSKeyValueChangeNewKey] CGPointValue]];
    }
    else if([keyPath isEqualToString:@"contentSize"]) {
        self.frame = CGRectMake(0, self.scrollView.contentSize.height, self.bounds.size.width, SVInfiniteScrollingViewHeight);
        [self layoutSubviews];
    }
}

- (void)scrollViewDidScroll:(CGPoint)contentOffset {
    if(self.state != SVInfiniteScrollingStateLoading && self.enabled) {
        CGFloat scrollViewContentHeight = self.scrollView.contentSize.height;
        CGFloat scrollOffsetThreshold = scrollViewContentHeight-self.scrollView.bounds.size.height + _originalBottomInset + SVInfiniteScrollingViewHeight;
        
        if(!self.scrollView.isDragging && self.state == SVInfiniteScrollingStateTriggered){
            self.state = SVInfiniteScrollingStateLoading;
        }
        else if(contentOffset.y > scrollOffsetThreshold && self.state == SVInfiniteScrollingStateStopped && self.scrollView.isDragging){
            self.state = SVInfiniteScrollingStateTriggered;
            [self layoutSubviews];
        }
        else if(contentOffset.y < scrollOffsetThreshold  && self.state != SVInfiniteScrollingStateStopped){
            self.state = SVInfiniteScrollingStateStopped;
            [self layoutSubviews];
        }
    }
}

#pragma mark - Getters

- (LLARingSpinnerView *)llARingSpinnerView
{
    if (!_llARingSpinnerView) {
        _llARingSpinnerView = [[LLARingSpinnerView alloc] initWithFrame:CGRectMake(0, 0, 18, 18)];
        _llARingSpinnerView.tintColor = [UIColor colorWithRed:115.f/255 green:179.f/255 blue:25.f/255 alpha:1];
    }
    return _llARingSpinnerView;
}

#pragma mark -

- (void)triggerRefresh {
    self.state = SVInfiniteScrollingStateTriggered;
    self.state = SVInfiniteScrollingStateLoading;
}

- (void)startAnimating{
    self.state = SVInfiniteScrollingStateLoading;
}

- (void)stopAnimating {
    self.state = SVInfiniteScrollingStateFinished;
    UIEdgeInsets insets = self.scrollView.contentInset;
    insets.bottom -= SVInfiniteScrollingViewHeight;
    [self layoutSubviews];
}

- (void)setState:(SVInfiniteScrollingState)newState {
    
    if(_state == newState)
        return;
    
    SVInfiniteScrollingState previousState = _state;
    _state = newState;
        
        switch (newState) {
            case SVInfiniteScrollingStateStopped:
                [self.llARingSpinnerView stopAnimating];
                [self.llARingSpinnerView removeFromSuperview];
                break;
                
            case SVInfiniteScrollingStateTriggered:
                break;
                
            case SVInfiniteScrollingStateLoading:
                [self.llARingSpinnerView startAnimating];
                [self addSubview:self.llARingSpinnerView];
                break;
        }
    
    if(previousState == SVInfiniteScrollingStateTriggered && newState == SVInfiniteScrollingStateLoading && self.infiniteScrollingHandler && self.enabled)
        self.infiniteScrollingHandler();
}

@end
