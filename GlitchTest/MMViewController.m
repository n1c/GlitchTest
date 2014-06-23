//
//  MMViewController.m
//  GlitchTest
//
//  Created by Nic M on 2014/06/23.
//  Copyright (c) 2014 Nic M. All rights reserved.
//

#import "MMViewController.h"

@interface MMViewController ()

@property (strong, nonatomic) UIImage *selectedImage;
@property (nonatomic) int iterations;
@property (nonatomic) float quality;

@end

@implementation MMViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.iterations = 10;
    self.quality = 0.8f;
    self.selectedImage = [UIImage imageNamed:@"image.jpg"];
    self.imageView.image = self.selectedImage;

    [self.view addGestureRecognizer:[[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panDetected:)]];
    [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapDetected:)]];
} // viewDidLoad

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    NSLog(@"didReceiveMemoryWarning");
} // didReceiveMemoryWarning

- (void)panDetected: (UIPanGestureRecognizer *)gestureRecognizer {
    [self touchEvent:[gestureRecognizer locationInView:self.view]];
} // panDetected

- (void)tapDetected: (UITapGestureRecognizer *)gestureRecognizer {
    [self touchEvent:[gestureRecognizer locationInView:self.view]];
} // tapDetected

- (void)touchEvent: (CGPoint) location {
    CGRect viewRect = [self.view bounds];

    self.iterations = (location.x / viewRect.size.width) * 15;
    self.quality = location.y / viewRect.size.height;

    self.imageView.image = [self glitchImage:self.selectedImage withIterations:self.iterations andQuality:self.quality];
} // touchEvent

-(UIImage *)glitchImage: (UIImage *)image withIterations:(int) iterations andQuality:(int) quality {
    if (!image) return image;
 
    NSLog(@"glitchImage iterations: %i quality: %f", self.iterations, self.quality);

    NSData *rawImage = UIImageJPEGRepresentation(image, quality);
    
    int jpgHeaderLength = 417;
    uint8_t *bytes = (uint8_t *)[rawImage bytes];
    
    for (int i = 1; i <= rawImage.length; i++) {
        if (bytes[i] == 255 && bytes[i + 1] == 218) {
            jpgHeaderLength = i + 2;
            break;
        } // if we find our needle
    } // for rawImage length
    
    unsigned long maxIndex = rawImage.length - jpgHeaderLength - 4;
    
    for (int i = 0; i < iterations; i++) {
        // Find an index in the image to glitch.
        int glitchIndex = (arc4random() % maxIndex) + jpgHeaderLength;

        // Glitch the image at the index
        bytes[glitchIndex] = arc4random() % 256;
    } // for iterations
    
    // Rebuild the new glitched image from our array of bytes.
    NSData *glitchedImageData = [NSData dataWithBytes:bytes length:rawImage.length];
    return [UIImage imageWithData:glitchedImageData];
} // glitchImage

@end
