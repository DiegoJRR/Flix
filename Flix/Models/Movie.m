//
//  Movie.m
//  Flix
//
//  Created by Diego de Jesus Ramirez on 01/07/20.
//  Copyright © 2020 DiegoRamirez. All rights reserved.
//

#import "Movie.h"

@implementation Movie

- (id)initWithDictionary:(NSDictionary *)dictionary {
    self = [super init];

    self.title = dictionary[@"title"];
    
    // Construct the poster URL
    NSString *baseURLString = @"https://image.tmdb.org/t/p/w500";
    NSString *posterURLString = dictionary[@"poster_path"];
    NSString *fullPosterURLString = [baseURLString stringByAppendingString:posterURLString];
    
    self.posterURL = [NSURL URLWithString:fullPosterURLString];
    self.synopsis = dictionary[@"overview"];
    self.voteAverage = [dictionary[@"vote_average"] doubleValue];
    
    // Check if the backdrop_path exists, if not, use the poster path
    NSString *backdropURLString = nil;
    if ([dictionary[@"backdrop_path"]  isKindOfClass:[NSNull class]]) {
        backdropURLString = dictionary[@"poster_path"];
    } else {
        backdropURLString = dictionary[@"backdrop_path"];
    }
    
    NSString *fullBackdropURLString = [baseURLString stringByAppendingString:backdropURLString];
    self.backdropURL = [NSURL URLWithString:fullBackdropURLString];
    
    return self;
}

@end
