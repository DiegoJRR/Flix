//
//  MoviesViewController.m
//  Flix
//
//  Created by Diego de Jesus Ramirez on 24/06/20.
//  Copyright © 2020 DiegoRamirez. All rights reserved.
//

#import "MoviesViewController.h"
#import "MovieCell.h"
#import "UIImageView+AFNetworking.h"
#import "DetailsViewController.h"

@interface MoviesViewController () <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *movies;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end

@implementation MoviesViewController

/**
 fetchMovies is an instance method to request the first page of movies currently playing in theathers from The Movie Database API (https://developers.themoviedb.org/3/getting-started).
 
 It saves the movies to a class property NSDictionary, and handles the AlertController for network errors and the activityIndicator
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
    NSURL *url = [NSURL URLWithString:@"https://api.themoviedb.org/3/movie/now_playing?api_key=a07e22bc18f5cb106bfe4cc1f83ad8ed"];
    
    // Set the url request object
    NSURLRequest *request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10.0];
    
    // Instantiate a session to make requests to the Movies API
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
    
    [self.activityIndicator startAnimating];
    
    // Task to request data to API and handle results
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
           if (error != nil) {
               NSLog(@"%@", [error localizedDescription]);
               [self presentViewController:alert animated:YES completion:^{
                   // Optional code
               }];
           }
           else {
               // Set the dataDirectionary with the request's response and store the results on the movies array property of the view controller
               NSDictionary *dataDictionary = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
               self.movies = dataDictionary[@"results"];
               
               // Reload the table data to reflect changes
               [self.tableView  reloadData];
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
    
    // Set self as dataSource and delegate for the tableView
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
    // Fetch the movies from the API
    [self fetchMovies];
    self.refreshControl = [[UIRefreshControl alloc] init];
    
    // Create target-action pair with the control value change that calls the fetchMovies function
    [self.refreshControl addTarget:self action:@selector(fetchMovies) forControlEvents:UIControlEventValueChanged];
    [self.tableView insertSubview:self.refreshControl atIndex:0];

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.movies.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    MovieCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MovieCell"];
    
    // Get the movie for the corresponding row from the class property
    NSDictionary *movie = self.movies[indexPath.row];
    
    // Set the text of the cell to the movie title
    cell.titleLabel.text = movie[@"title"];
    cell.descriptionLabel.text = movie[@"overview"];
    
    // Construct the poster URL
    NSString *baseURLString = @"https://image.tmdb.org/t/p/w500";
    NSString *posterURLString = movie[@"poster_path"];
    NSString *fullPosterURLString = [baseURLString stringByAppendingString:posterURLString];
    NSURL *posterURL = [NSURL URLWithString:fullPosterURLString];
    
    // Create the request for the poster image
    NSURLRequest *request = [NSURLRequest requestWithURL:posterURL];
    
    // Set poster to nil to remove the old one (when refreshing) and query for the new one
    cell.posterView.image = nil;
    
    // Instantiate a weak link to the cell and fade in the image in the request
    __weak MovieCell *weakSelf = cell;
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


#pragma mark - Navigation


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Set the tappedCell as the cell that initiated the segue
    UITableViewCell *tappedCell = sender;
    
    // Get the corresponding indexPath of that cell
    NSIndexPath *indexPath = [self.tableView indexPathForCell:tappedCell];
    
    // Get the cell corresponding to that cell
    NSDictionary *movie = self.movies[indexPath.row];
    
    // Set the viewController to segue into and pass the movie object
    DetailsViewController *detailsViewController = [segue destinationViewController];
    detailsViewController.movie = movie;
}

@end
