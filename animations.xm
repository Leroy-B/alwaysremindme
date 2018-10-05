// ############################# ANIMATIONS ### START ####################################

// takes 'UIView' and changes the backgroundColor with delay after each change
static void performRainbowAnimated(UIView *currentView, NSNumber *delay){

    [UIView animateWithDuration:0.01 delay:0 options:UIViewAnimationOptionTransitionNone animations:^{
        currentView.backgroundColor = [UIColor colorWithHue:drand48() saturation:1.0 brightness:1.0 alpha:1.0];
    } completion:^(BOOL finished){
        // executes block after delay has passed
        double delayInSeconds = [delay floatValue];
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            performRainbowAnimated(currentView, delay);
        });
    }];

}// rainbow func end

// takes a 'UILabel' and roatates it by the given speed, delays by given value after completion before redoing it indefinitely
static void performRotationAnimated(UILabel *twTextLabel, NSNumber *speed, NSNumber *delay, NSNumber *count){

    [UIView animateWithDuration:([speed floatValue]/2)
                          delay:[delay floatValue]
                        options:UIViewAnimationOptionCurveLinear
                     animations:^{
                         twTextLabel.transform = CGAffineTransformMakeRotation(M_PI);
                     }
                     completion:^(BOOL finished){
                         [UIView animateWithDuration:([speed floatValue]/2)
                                               delay:0
                                             options:UIViewAnimationOptionCurveLinear
                                          animations:^{
                                              twTextLabel.transform = CGAffineTransformMakeRotation(0);
                                          }
                                          completion:^(BOOL finished){
                                              if([count intValue] == 0){
                                                  performRotationAnimated(twTextLabel, speed, delay, count);
                                              } else if(countInLoop <= [count intValue]){ // maybe this will show one to few ?
                                                  performRotationAnimated(twTextLabel, speed, delay, count);
                                                  countInLoop++;
                                              }
                                          }];
                     }];

 }// rotate func end

// takes a 'UIView' and moves (x and or y or one one of thoes) it over time,
static void performShakeAnimated(UIView *currentView, NSNumber *duration, NSNumber *xAmount, NSNumber *yAmount, NSNumber *count){

    CABasicAnimation *shakeAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
    shakeAnimation.duration = [duration floatValue];
    shakeAnimation.fromValue = [NSValue valueWithCGPoint:CGPointMake([currentView center].x - [xAmount floatValue], [currentView center].y - [yAmount floatValue])];
    shakeAnimation.toValue = [NSValue valueWithCGPoint:CGPointMake([currentView center].x + [xAmount floatValue], [currentView center].y + [yAmount floatValue])];

    shakeAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    shakeAnimation.autoreverses = YES;
    if([count intValue] == 0){
        shakeAnimation.repeatCount = HUGE_VALF;
    } else {
        shakeAnimation.repeatCount = [count floatValue];
    }
    [currentView.layer addAnimation:shakeAnimation forKey:nil];

}// shake func end

// takes a 'UIView' and pulsates it to given size, duration of the animation can also be given
static void performPulseAnimated(UIView *currentView, NSNumber *size, NSNumber *duration, NSNumber *count){

    CABasicAnimation *pulseAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    pulseAnimation.duration = [duration floatValue];
    pulseAnimation.fromValue = 0;
    pulseAnimation.toValue = [NSNumber numberWithFloat: [size floatValue]];
    pulseAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    pulseAnimation.autoreverses = YES;
    if([count intValue] == 0){
        pulseAnimation.repeatCount = HUGE_VALF;
    } else {
        pulseAnimation.repeatCount = [count floatValue];
    }
    [currentView.layer addAnimation:pulseAnimation forKey:nil];

}// Pulse func end

// takes 'UIView' and fades it over time and back
static void performBlinkAnimated(UIView *currentView, NSNumber *duration, NSNumber *count){

    CABasicAnimation *shakeAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    shakeAnimation.duration = [duration floatValue];
    shakeAnimation.fromValue = [NSNumber numberWithFloat: 1];
    shakeAnimation.toValue = [NSNumber numberWithFloat: 0];

    shakeAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    shakeAnimation.autoreverses = YES;
    if([count intValue] == 0){
        shakeAnimation.repeatCount = HUGE_VALF;
    } else {
        shakeAnimation.repeatCount = [count floatValue];
    }
    [currentView.layer addAnimation:shakeAnimation forKey:nil];

}// blink func end

// ############################# ANIMATIONS ### END ####################################
