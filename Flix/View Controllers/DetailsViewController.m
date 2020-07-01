//
//  DetailsViewController.m
//  Flix
//
//  Created by Diego de Jesus Ramirez on 25/06/20.
//  Copyright © 2020 DiegoRamirez. All rights reserved.
//

#import "DetailsViewController.h"
#import "UIImageView+AFNetworking.h"

@interface DetailsViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *backdropView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *synopsisLabel;
@property (weak, nonatomic) IBOutlet UIImageView *posterView;

@end

@implementation DetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Give the view rounded corners
    self.synopsisLabel.layer.cornerRadius = 10;
    self.synopsisLabel.layer.masksToBounds = true;
    
    // Set the poster and backdrop images
    [self.posterView setImageWithURL:self.movie.posterURL];
    [self.backdropView setImageWithURL:self.movie.backdropURL];
    
    // Set the title and synopsis
    self.titleLabel.text = self.movie.title;
    self.synopsisLabel.text = self.movie.synopsis;
    
    [self.titleLabel sizeToFit];
    [self.synopsisLabel sizeToFit];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
