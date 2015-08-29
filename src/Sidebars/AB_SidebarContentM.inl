- (CGRect) anchoredRect:(CGRect)testRect inView:(UIView*)view
{
    return [self anchoredRect:testRect
                       inView:view
           internalAnchorRect:CGRectFromComponents(CGSizeZero, testRect.size)];
}

- (CGRect) anchoredRect:(CGRect)testRect inView:(UIView*)view internalAnchorRect:(CGRect)anchorRect
{
    // TODO: Ugly stuff, is there a cleaner way to do this?
    CGSize conatinerSize = view.bounds.size;
    CGSize selfSize = testRect.size;
    CGSize containerHalfSized = CGSizeMultiplyScalar(conatinerSize, 0.5f);
    CGSize selfHalfSized = CGSizeMultiplyScalar(selfSize, 0.5f);
    
    CGSize selfCenteredInContainer = CGSizeAdd(containerHalfSized, CGSizeMultiplyScalar(selfHalfSized, -1.f));
    CGSize bottomAnchor = CGSizeMultiplyScalar(CGPointToCGSize(anchorRect.origin), -1.f);
    CGSize openTopAnchor = CGSizeAdd(conatinerSize,
                                     CGSizeMultiplyScalar(
                                                          CGSizeAdd(
                                                                    CGPointToCGSize(anchorRect.origin),
                                                                    anchorRect.size), -1.f));
    
    BOOL flexibleTop = [self.view hasFlexibleTopMargin];
    BOOL flexibleBottom = [self.view hasFlexibleBottomMargin];
    BOOL flexibleLeft = [self.view hasFlexibleLeftMargin];
    BOOL flexibleRight = [self.view hasFlexibleRightMargin];
    
    CGRect finalRect = CGRectFromComponents(CGSizeZero, selfSize);
    
    if (flexibleTop && !flexibleBottom)
    {
        finalRect.origin.y = openTopAnchor.height;
    }
    else if (!flexibleTop && flexibleBottom)
    {
        finalRect.origin.y = bottomAnchor.height;
    }
    else
    {
        finalRect.origin.y = selfCenteredInContainer.height;
    }
    
    if (flexibleLeft && !flexibleRight)
    {
        finalRect.origin.x = openTopAnchor.width;
    }
    else if (!flexibleLeft && flexibleRight)
    {
        finalRect.origin.x = bottomAnchor.width;
    }
    else
    {
        finalRect.origin.x = selfCenteredInContainer.width;
    }
    
    return finalRect;
}

- (CGRect) calculateClosedRectInView:(UIView*)view
{
    if (self.keepsFrameSize)
    {
        return [self anchoredRect:self.view.frame
                           inView:view
               internalAnchorRect:overhangFrame.frame];
    }
    return [self anchoredRect:overhangFrame.frame inView:view];
}

- (CGRect) calculateOpenedRectInView:(UIView*)view
{
    return [self anchoredRect:self.view.frame inView:view];
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
    CGSize containerSize = controller.view.frame.size;
    CGRect fullFrame = self.view.frame;
    fullFrame.size = CGSizeMake(
                                [self.view hasFlexibleWidth]
                                    ? containerSize.width
                                    : fullFrame.size.width,
                                [self.view hasFlexibleHeight]
                                    ? containerSize.height
                                    : fullFrame.size.height
                                );

    [self setupWithFrame:fullFrame];
    
    [self openInView:controller.view
      withViewParent:controller
           inSection:controller.sectionParent];
}

- (CGRect) openFrame
{
    return openView.frame;
}

- (CGRect) closedFrame
{
    return closedView.frame;
}

- (CGFloat) distanceAlongDrag:(CGPoint)dragPoint
{
    if (self.keepsFrameSize)
    {
        return DistanceAlongSegmentOfPointClosestToPoint(dragPoint,
                                                         self.closedFrame.origin,
                                                         self.openFrame.origin);
    }
    return DistanceAlongSegmentOfPointClosestToPoint(dragPoint,
                                                     CGRectCenterPoint(self.closedFrame),
                                                     CGRectCenterPoint(self.openFrame));
}

- (void) setupOpenCloseFramesInView:(UIView*)insideView
{
    [openView removeFromSuperview];
    [closedView removeFromSuperview];
    openView = nil;
    closedView = nil;

    CGRect openRect = [self calculateOpenedRectInView:insideView];
    CGRect closeRect = [self calculateClosedRectInView:insideView];
    
    openView = [[UIView alloc] initWithFrame:openRect];
    openView.userInteractionEnabled = NO;
    openView.backgroundColor = [UIColor clearColor];
    openView.autoresizingMask = self.view.autoresizingMask;
    [insideView addSubview:openView];
    
    closedView = [[UIView alloc] initWithFrame:closeRect];
    closedView.userInteractionEnabled = NO;
    closedView.backgroundColor = [UIColor clearColor];
    closedView.autoresizingMask = self.view.autoresizingMask;
    [insideView addSubview:closedView];
}

- (void) openInView:(UIView*)insideView
withViewParent:(AB_BaseViewController*)viewParent_
inSection:(AB_SectionViewController*)sectionParent_
{
    [self setupOpenCloseFramesInView:insideView];
    
    [super openInView:insideView
       withViewParent:viewParent_
            inSection:sectionParent_];
    
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
        __block CGFloat startingViewPoint;
        __block CGFloat startingDragPoint;
        [panGesture.rac_gestureSignal
         subscribeNext:^(UIPanGestureRecognizer* panGesture)
         {
         @strongify(self)
         // TODO: Figure out a general solution to this..
         CGFloat dragScalar = self.keepsFrameSize ? 1.f : 0.5f;
         CGPoint panGesturePoint = [panGesture locationInView:self.view.superview];
         
         switch (panGesture.state)
         {
         case UIGestureRecognizerStatePossible:
         break;
         case UIGestureRecognizerStateBegan:
         {
         CGRect curRect = ((CALayer*)[self.view.layer presentationLayer]).frame;
         startingDragPoint = [self distanceAlongDrag:panGesturePoint] * dragScalar;
         if (self.keepsFrameSize)
         {
         startingViewPoint = [self distanceAlongDrag:curRect.origin];
         }
         else
         {
         startingViewPoint = [self distanceAlongDrag:CGRectCenterPoint(curRect)];
         }
         }
         case UIGestureRecognizerStateChanged:
         {
         CGFloat curDragPoint = [self distanceAlongDrag:panGesturePoint] * dragScalar;
         CGFloat deltaDrag = curDragPoint - startingDragPoint;
         CGFloat curViewPoint = Clamp(startingViewPoint + deltaDrag, 0.f, 1.f);
         CGRect curFrame = CGRectLerp(self.closedFrame, self.openFrame, curViewPoint);
         self.view.frame = curFrame;
                  
         Underscore.array(viewsToHideWhenOpened)
         .each(^(UIView* toHideOrShowView)
               {
                   toHideOrShowView.alpha = 1.f - curViewPoint;
                   toHideOrShowView.hidden = toHideOrShowView.alpha == 0.f;
               });

         Underscore.array(viewsToHideWhenClosed)
         .each(^(UIView* toHideOrShowView)
               {
                   toHideOrShowView.alpha = curViewPoint;
                   toHideOrShowView.hidden = toHideOrShowView.alpha == 0.f;
               });
         }
         break;
         case UIGestureRecognizerStateCancelled:
         case UIGestureRecognizerStateEnded:
         case UIGestureRecognizerStateFailed:
         {
         CGFloat curDragPoint = [self distanceAlongDrag:panGesturePoint] * dragScalar;
         CGFloat deltaDrag = curDragPoint - startingDragPoint;
         BOOL opened = startingViewPoint + deltaDrag > 0.5f;
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
    
    [self setOpened:self.startsOpen animated:NO forced:YES];
}

- (void) closeView
{
    [super closeView];
    [openView removeFromSuperview];
    [closedView removeFromSuperview];
}

- (BOOL) opened
{
    return isOpened;
}

- (CGFloat) animationSpeed
{
    return 0.4f;
}

- (void) animate:(void(^)())animateBlock
complete:(void(^)(BOOL finished))completeBlock
animated:(BOOL)isAnimated
{
    if (isAnimated)
    {
        [UIView animateWithDuration:[self animationSpeed]
                              delay:0.f
             usingSpringWithDamping:1.f
              initialSpringVelocity:0.f
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:animateBlock
                         completion:completeBlock];
    }
    else
    {
        animateBlock();
        completeBlock(YES);
    }
}

- (void) finishedOpen:(BOOL)wasAnimated
{
    
}

- (void) setOpened:(BOOL)opened animated:(BOOL)isAnimated forced:(BOOL)isForced
{
    if (!isForced && opened == self.opened)
    {
        return;
    }
    
    isOpened = opened;
    
    CGRect desintation = self.opened ? self.openFrame : self.closedFrame;
    [self
     animate:^
     {
     self.view.frame = desintation;
     
     Underscore.array(viewsToHideWhenClosed)
     .each(^(UIView* toHideOrShowView)
           {
               toHideOrShowView.alpha = !isOpened ? 0.f : 1.f;
               toHideOrShowView.hidden = toHideOrShowView.alpha == 0.f;
           });

     Underscore.array(viewsToHideWhenOpened)
     .each(^(UIView* toHideOrShowView)
           {
               toHideOrShowView.alpha = isOpened ? 0.f : 1.f;
               toHideOrShowView.hidden = toHideOrShowView.alpha == 0.f;
           });
     }
     complete:^(BOOL finished)
     {
        if (finished)
        {
            [self finishedOpen:isAnimated];
        }
     }
     animated:isAnimated];
}

- (void) setOpened:(BOOL)opened
{
    [self setOpened:opened animated:YES forced:NO];
}

- (void) interactionTapped:(UITapGestureRecognizer*)tapGesture
{
    if (tapGesture.state != UIGestureRecognizerStateRecognized)
    {
        return;
    }
    
    self.opened = !self.opened;
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
    self.opened = !self.opened;
}
