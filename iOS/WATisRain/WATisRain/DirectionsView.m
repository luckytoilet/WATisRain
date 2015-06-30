#import <Foundation/Foundation.h>
#import "DirectionsView.h"
#import "Route.h"

@implementation DirectionsView

- (void)awakeFromNib{
    // This is called on app startup, similar to viewDidLoad
    NSError *err = nil;
    NSString *html =
        @"<div style='font-size:11pt;font-family:sans-serif;'>"
        "I am a <b>map</b>!"
        "</div>";
    self.attributedText =
    [[NSAttributedString alloc]
        initWithData:[html dataUsingEncoding:NSUTF8StringEncoding]
        options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType}
        documentAttributes:nil
        error:&err];
    self.layer.borderWidth = 2.0f;
    self.layer.borderColor = [UIColor colorWithRed:0.6 green:0.6 blue:0.6 alpha:1].CGColor;
    
    // Tap listener
    UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(directionsViewTapped:)];
    singleTapRecognizer.numberOfTapsRequired = 1;
    singleTapRecognizer.numberOfTouchesRequired = 1;
    [self addGestureRecognizer:singleTapRecognizer];
}

- (void)drawTextInRect:(CGRect)rect{
    // Add an inset (aka padding) to the box
    UIEdgeInsets insets = {20, 20, -18, 20};
    [super drawTextInRect:UIEdgeInsetsInsetRect(rect, insets)];
}

- (void)directionsViewTapped:(UITapGestureRecognizer*)recognizer{
    NSLog(@"directions view tapped");
}

- (void)generateDirectionsFromRoute:(Route*) route{
    NSMutableString *sb = [[NSMutableString alloc] init];
    
    NSString *overall_building1 = [[route getStart] getBuildingName];
    int overall_floor1 = [[route getStart] getFloorNumber];
    NSString *overall_building2 = [[route getEnd] getBuildingName];
    int overall_floor2 = [[route getEnd] getFloorNumber];
    [sb appendString:@"Route found: <b>"];
    [sb appendString:overall_building1];
    [sb appendString:@"</b> to <b>"];
    [sb appendString:@"overall_building2"];
    [sb appendString:@"</b>"];
    
    [sb appendString:@"<br><br>"];
    
    [sb appendString:@"Start at <b>"];
    [sb appendString:overall_building1];
    [sb appendString:@" (floor "];
    [sb appendString:[@(overall_floor1) stringValue]];
    [sb appendString:@")</b>"];
    [sb appendString:@"<br><br>"];

    NSMutableArray *steps = [route routeSteps];
    for(int i = 0; i < [steps count]; i++){
        RouteStep *step = [steps objectAtIndex:i];
        
        int floor1 = [[step start] getFloorNumber];
        NSString *build2 = [[step end] getBuildingName];
        NSString *build2_formatted = [NSString stringWithFormat:@"<b>%@</b>", build2];
        int floor2 = [[step end] getFloorNumber];
        
        NSString *instr;
        if([[step path] pathType] == TYPE_OUTSIDE){
            instr = [NSString stringWithFormat:@"Take a walk outside to %@", build2_formatted];
        }
        else if([[step path] pathType] == TYPE_INDOOR_TUNNEL){
            instr = [NSString stringWithFormat:@"Take the indoor tunnel to %@", build2_formatted];
        }
        else if([[step path] pathType] == TYPE_UNDERGROUND_TUNNEL){
            instr = [NSString stringWithFormat:@"Take the underground tunnel to %@", build2_formatted];
        }
        else if([[step path] pathType] == TYPE_BRIEFLY_OUTSIDE){
            instr = [NSString stringWithFormat:@"Step briefly outside to %@", build2_formatted];
        }
        else if([[step path] pathType] == TYPE_INSIDE){
            instr = [NSString stringWithFormat:@"Go straight through to %@", build2_formatted];
        }
        else if([[step path] pathType] == TYPE_STAIR){
            NSString *up_or_down;
            int difference;
            if(floor2 < floor1){
                up_or_down = @"down";
                difference = floor1 - floor2;
            }else{
                up_or_down = @"up";
                difference = floor2 - floor1;
            }
            NSString *s_if_plural = @"";
            if(difference > 1)
                s_if_plural = @"s";
            
            instr = [NSString stringWithFormat:@"Climb %@ %d floor%@ to %@ </b>(floor %d)</b>", up_or_down, difference, s_if_plural, build2_formatted, floor2];
        }
        
        [sb appendString:@" "];
        [sb appendString:[@(i+1) stringValue]];
        [sb appendString:@". "];
        [sb appendString:instr];
        [sb appendString:@"<br>"];
    }

    [sb appendString:@"<br>"];
    [sb appendString:@"Arrive at <b>"];
    [sb appendString:overall_building2];
    [sb appendString:@" (floor "];
    [sb appendString:[@(overall_floor2) stringValue]];
    [sb appendString:@")</b>"];
}


@end

