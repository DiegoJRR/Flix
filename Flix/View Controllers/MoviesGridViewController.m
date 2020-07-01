//
//  MoviesGridViewController.m
//  Flix
//
//  Created by Diego de Jesus Ramirez on 26/06/20.
//  Copyright © 2020 DiegoRamirez. All rights reserved.
//

#import "MoviesGridViewController.h"
#import "MovieCollectionCell.h"
#import "UIImageView+AFNetworking.h"
#import "DetailsViewController.h"
#import "Movie.h"

@interface MoviesGridViewController () <UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic, strong) NSMutableArray *movies;
@property (strong, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@end

@implementation MoviesGridViewController

/**
fetchMovies is an instance method to request the first page of movies similar to Blodshoot (id: 338762) from The Movie Database API. These are the ones considered Superheroe movies. (https://developers.themoviedb.org/3/getting-started).

It saves the movies to a class property NSDictionary
*/
-(void) fetchMovies {
    // Setup the alert message
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Network error" message:@"There was an error fetching the movies. Check your internet connection." preferredStyle:(UIAlertControllerStyleAlert)];
    
    // Adding cancel and try again actions to the alert controller instance
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {}];
    [alert addAction:cancelAction];

    UIAlertAction *tryAgain = [UIAlertAction actionWithTitle:@"Try Again" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self fetchMovies];
    }];
    [alert addAction:tryAgain];
    
    // Set the url for the network request
    NSURL *url = [NSURL URLWithString:@"https://api.themoviedb.org/3/movie/338762/similar?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed&language=en-US&page=1"];
    // Set the url request object
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    
    // Instantiate a session to make requests to the Movies API
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    
    [self.activityIndicator startAnimating];
    
    // Task to request data to API and handle results
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
           if (error != nil) {
               NSLog(@"%@", [error localizedDescription]);
           }
           else {
               NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
               
               
               NSArray *dictionaries = dataDictionary[@"results"];
               
               for (NSDictionary *dictionary in dictionaries) {
                   // Allocate memory for object and initialize it with the dictionary
                   Movie *movie = [[Movie alloc] initWithDictionary:dictionary];
                   
                   // Add the object to the movies array
                   [self.movies addObject:movie];
               }
               
               [self.collectionView reloadData];
           }
        
        // Stop the refreshing animation and the activity indicator
        [self.refreshControl endRefreshing];
        [self.activityIndicator stopAnimating];
       }];
    [task resume];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.movies = [[NSMutableArray alloc] init];
    
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    
    [self fetchMovies];
    self.refreshControl = [[UIRefreshControl alloc] init];
    
    // Create target-action pair with the control value change that calls the fetchMovies function
    [self.refreshControl addTarget:self action:@selector(fetchMovies) forControlEvents:UIControlEventValueChanged];
    [self.collectionView insertSubview:self.refreshControl atIndex:0];
    
    
    // Instantiation and logic to layout the poster images in the collection.
    UICollectionViewFlowLayout *layout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    
    // The spacing between and number of posters per lines is constant, the cells resize accordingly
    layout.minimumInteritemSpacing = 2;
    layout.minimumLineSpacing = 2;
    CGFloat postersPerLine = 3;
    
    CGFloat itemWidth = (self.collectionView.frame.size.width - (postersPerLine - 1) * layout.minimumInteritemSpacing) / postersPerLine;
    CGFloat itemHeight = itemWidth * 1.5;
    
    layout.itemSize = CGSizeMake(itemWidth, itemHeight);
}

- (nonnull __kindof UICollectionViewCell *)collectionView:(nonnull UICollectionView *)collectionView cellForItemAtIndexPath:(nonnull NSIndexPath *)indexPath {
    
    MovieCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"MovieCollectionCell" forIndexPath:indexPath];
    
    Movie *movie = self.movies[indexPath.item];
    
    // Create the request for the poster image
    NSURLRequest *request = [NSURLRequest requestWithURL:movie.posterURL];
    
    // Set poster to nil to remove the old one (when refreshing) and query for the new one
    cell.posterView.image = nil;
    
    // Instantiate a weak link to the cell and fade in the image in the request
    __weak MovieCollectionCell *weakSelf = cell;
    [weakSelf.posterView setImageWithURLRequest:request placeholderImage:nil
                    success:^(NSURLRequest *imageRequest, NSHTTPURLResponse *imageResponse, UIImage *image) {
                        
                        // imageResponse will be nil if the image is cached
                        if (imageResponse) {
                            weakSelf.posterView.alpha = 0.0;
                            weakSelf.posterView.image = image;
                            
                            //Animate UIImageView back to alpha 1 over 0.3sec
                            [UIView animateWithDuration:0.5 animations:^{
                                weakSelf.posterView.alpha = 1.0;
                            }];
                        }
                        else {
                            weakSelf.posterView.image = image;
                        }
                    }
                    failure:^(NSURLRequest *request, NSHTTPURLResponse * response, NSError *error) {
                        // do something for the failure condition
                    }];

    return cell;
}

- (NSInteger)collectionView:(nonnull UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.movies.count;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Set the tappedCell as the cell that initiated the segue
    UICollectionView *tappedCell = sender;
    
    // Get the corresponding indexPath of that cell
    NSIndexPath *indexPath = [self.collectionView indexPathForCell:(UICollectionViewCell *)tappedCell];
    
    // Get the cell corresponding to that cell
    Movie *movie = self.movies[indexPath.row];
    
    // Set the viewController to segue into and pass the movie object
    DetailsViewController *detailsViewController = [segue destinationViewController];
    detailsViewController.movie = movie;
}


@end
