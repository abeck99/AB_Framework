- (CGRect) calculateClosedRectInView:(UIView*)view
{
    slidingConstraint.constant = self.closedConstant;
    [self.view updateConstraints];
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
    CGRect returnRect = slideContentView.frame;
    return returnRect;
}

- (CGRect) calculateOpenedRectInView:(UIView*)view
{
    slidingConstraint.constant = self.openConstant;
    [self.view updateConstraints];
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
    CGRect returnRect = slideContentView.frame;
    return returnRect;
}

- (void) dealloc
{
    for (UIView* interactionBar in interactionBars)
    {
        for (UIGestureRecognizer* rec in [interactionBar.gestureRecognizers copy])
        {
            [interactionBar removeGestureRecognizer:rec];
        }
    }
}

- (void) setupSidebarInController:(AB_BaseViewController*)controller
{
    [self openInView:controller.view
      withViewParent:controller
           inSection:controller.sectionParent];
}

- (CGFloat) distanceAlongDrag:(CGPoint)dragPoint
{
    return DistanceAlongSegmentOfPointClosestToPoint(dragPoint,
                                                     CGRectCenterPoint(closedRect),
                                                     CGRectCenterPoint(openRect));
}

- (void) setupOpenCloseFramesInView:(UIView*)insideView
{
    ignoreLayoutChanges = YES;
    openRect = [self calculateOpenedRectInView:insideView];
    closedRect = [self calculateClosedRectInView:insideView];
    NSLog(@"Open Rect: %@.... closed Rect: %@", NSStringFromCGRect(openRect), NSStringFromCGRect(closedRect));
    ignoreLayoutChanges = NO;
    self.openAmount = self.openAmount;
}

- (void) viewDidLayoutSubviews
{
    if (!ignoreLayoutChanges)
    {
        [self setupOpenCloseFramesInView:self.view.superview];
    }
}

- (void) bind
{
    [super bind];
    
    for (UIView* interactionBar in interactionBars)
    {
        UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc]
                                              initWithTarget:self
                                              action:@selector(interactionTapped:)];
        tapGesture.delegate = gestureDelegate;
        [interactionBar addGestureRecognizer:tapGesture];
        
        UIPanGestureRecognizer* panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                                     action:nil];
        panGesture.delegate = gestureDelegate;
        [interactionBar addGestureRecognizer:panGesture];
        
        @weakify(self)
        __block CGFloat startingDragPoint;
        __block CGFloat startingOpenAmount;
        [panGesture.rac_gestureSignal
         subscribeNext:^(UIPanGestureRecognizer* panGesture)
         {
            @strongify(self)
            CGPoint panGesturePoint = [panGesture locationInView:self.view.superview];
         
            switch (panGesture.state)
            {
                case UIGestureRecognizerStatePossible:
                    break;
                case UIGestureRecognizerStateBegan:
                {
         [animationDisposable dispose];
         animationDisposable = nil;
                    startingOpenAmount = self.openAmount;
                    startingDragPoint = [self distanceAlongDrag:panGesturePoint];
                }
                case UIGestureRecognizerStateChanged:
                {
         [animationDisposable dispose];
         animationDisposable = nil;
                    CGFloat curDragPoint = [self distanceAlongDrag:panGesturePoint];
                    CGFloat deltaDrag = (curDragPoint - startingDragPoint) * 0.5f;
                    CGFloat currentOpenAmount = Clamp(startingOpenAmount + deltaDrag, 0.f, 1.f);
                    self.openAmount = currentOpenAmount;
                }
                break;
         case UIGestureRecognizerStateCancelled:
         case UIGestureRecognizerStateEnded:
         case UIGestureRecognizerStateFailed:
         {
         CGFloat curDragPoint = [self distanceAlongDrag:panGesturePoint];// * dragScalar;
         CGFloat deltaDrag = curDragPoint - startingDragPoint;
         BOOL opened = startingOpenAmount + deltaDrag > 0.5f;
         CGPoint velocity = [panGesture velocityInView:self.view.superview];
         CGSize velocityPoint = CGSizeAdd(CGPointToCGSize(panGesturePoint), CGPointToCGSize(velocity));
         CGFloat velocityOnPath = [self distanceAlongDrag:CGSizeToCGPoint(velocityPoint)];
         
         if (velocityOnPath > 2.5f)
         {
            opened = YES;
         }
         else if (velocityOnPath < -2.5f)
         {
            opened = NO;
         }
         
         [self setOpened:opened animated:YES forced:YES];
         }
         break;
         }
         }];
    }
    
    for (UIView* view in viewsToHideWhenOpened)
    {
        RAC(view, alpha) = [RACObserve(self, openAmount)
                            map:^(NSNumber* amount)
                            {
                            return @(1.f - [amount floatValue]);
                            }];
    }

    for (UIView* view in viewsToHideWhenClosed)
    {
        RAC(view, alpha) = RACObserve(self, openAmount);
    }

    [self setOpened:self.startsOpen animated:NO forced:YES];
}

- (BOOL) sliderOpen
{
    return self.openAmount > 0.5f;
}

- (CGFloat) animationSpeed
{
    return 0.4f;
}

- (CGFloat) openAmount
{
    return _openAmount;
}

- (void) setOpenAmount:(CGFloat)openAmount
{
    _openAmount = openAmount;
    ignoreLayoutChanges = YES;
    slidingConstraint.constant = Lerp(self.closedConstant, self.openConstant, _openAmount);
    [self.view updateConstraints];
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
    ignoreLayoutChanges = NO;
    [self.view updateConstraints];
}

- (void) updatePositionFromStart:(CGFloat)startAmount toEnd:(CGFloat)endAmount startedAt:(NSDate*)startDate duration:(NSTimeInterval)duration
{
    NSTimeInterval timeSinceStart = fabs([startDate timeIntervalSinceNow]);
    
    if (timeSinceStart >= duration)
    {
        self.openAmount = endAmount;
        [animationDisposable dispose];
        animationDisposable = nil;
        return;
    }
    
    CGFloat normalizedDuration = timeSinceStart / duration;
    self.openAmount = EasingFunction(Lerp(startAmount, endAmount, normalizedDuration));
}

- (void) animate:(void(^)())animateBlock
    toDestination:(CGFloat)destination
    complete:(void(^)(BOOL finished))completeBlock
    animated:(BOOL)isAnimated
{
    [animationDisposable dispose];
    animationDisposable = nil;
    
    if (isAnimated)
    {
        CGFloat animationDuration = [self animationSpeed];
        NSDate* startDate = [NSDate date];
        CGFloat startOpenAmount = self.openAmount;
        CGFloat endOpenAmount = destination;

        @weakify(self)
        animationDisposable =
        [[RACScheduler mainThreadScheduler]
         after:startDate repeatingEvery:0.01f withLeeway:0.01f
         schedule:^
         {
            @strongify(self)
            [self updatePositionFromStart:startOpenAmount toEnd:endOpenAmount startedAt:startDate duration:animationDuration];
         }];
        
        [UIView animateWithDuration:animationDuration
                              delay:0.f
             usingSpringWithDamping:1.f
              initialSpringVelocity:0.f
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:animateBlock
                         completion:completeBlock];
    }
    else
    {
        self.openAmount = destination;
        animateBlock();
        completeBlock(YES);
    }
}

- (void) finishedOpen:(BOOL)wasAnimated
{
    
}

- (void) setOpened:(BOOL)opened animated:(BOOL)isAnimated forced:(BOOL)isForced
{
    if (!isForced && opened == self.sliderOpen)
    {
        return;
    }
    
    CGFloat desintation = opened ? 1.f : 0.f;
    [self
     animate:^
     {
     }
     toDestination:desintation
     complete:^(BOOL finished)
     {
        if (finished)
        {
            [self finishedOpen:isAnimated];
        }
     }
     animated:isAnimated];
}

- (void) setSliderOpen:(BOOL)opened
{
    [self setOpened:opened animated:YES forced:NO];
}

- (void) interactionTapped:(UITapGestureRecognizer*)tapGesture
{
    if (tapGesture.state != UIGestureRecognizerStateRecognized)
    {
        return;
    }
    
    self.sliderOpen = !self.sliderOpen;
}

//- (void) viewDidLayoutSubviews
//{
//    [super viewDidLayoutSubviews];
//    NSLog(@"Sidebar %@ viewDidLayoutSubviews", self);
//
//    if (self.view.superview)
//    {
//        CGSize containerSize = self.view.superview.frame.size;
//        CGRect fullFrame = self.view.frame;
//        fullFrame.size = CGSizeMake(
//                                    [self.view hasFlexibleWidth]
//                                    ? containerSize.width
//                                    : fullFrame.size.width,
//                                    [self.view hasFlexibleHeight]
//                                    ? containerSize.height
//                                    : fullFrame.size.height
//                                    );
//
//        originalFrame = CGRectMake(0.f, 0.f, openRect.size.width, openRe);
//        originalOverhangFrame = overhangFrame.frame;
//        
//        openRect = [self calculateOpenedRectInView:self.view.superview];
//        closeRect = [self calculateClosedRectInView:self.view.superview];
//    }
//}

- (int) priority
{
    return 0;
}

- (UIView*) sidebarView
{
    return self.view;
}

- (IBAction) toggleOpened:(id)sender
{
    self.sliderOpen = !self.sliderOpen;
}
