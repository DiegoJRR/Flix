//
//  Movie.h
//  Flix
//
//  Created by Diego de Jesus Ramirez on 01/07/20.
//  Copyright © 2020 DiegoRamirez. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Movie : NSObject

@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSURL *posterURL;
@property (nonatomic, strong) NSURL *backdropURL;
@property (nonatomic, strong) NSString *synopsis;
@property (nonatomic, strong) NSNumber *voteAverage;

// Method to initialize an instance of the Movie object from a dictionary (as the one received from the API)
- (id)initWithDictionary:(NSDictionary *)dictionary;

@end

NS_ASSUME_NONNULL_END
