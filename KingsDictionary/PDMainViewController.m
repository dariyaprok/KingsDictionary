//
//  PDMainViewController.m
//  KingsDictionary
//
//  Created by админ on 12/8/16.
//  Copyright © 2016 dashaproduction. All rights reserved.
//

#import "PDMainViewController.h"

@interface PDMainViewController () <NSURLConnectionDelegate, NSURLSessionDataDelegate>

@property (weak, nonatomic) IBOutlet UITextField *wordTextField;

@property (weak, nonatomic) IBOutlet UILabel *categoriesLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *categoriesLabelHeightConstraint;

@property (weak, nonatomic) IBOutlet UILabel *definitionsLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *defnitionsLabelHeightConstraint;

@property (weak, nonatomic) IBOutlet UILabel *examplesLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *examplesLabelHeightConstraint;


@end

static NSString *baseURL = @"https://od-api.oxforddictionaries.com/api/v1";
static NSString *applicationID = @"cce9efd7";
static NSString *applicationKey = @"	907fae2dc9fca3c9521c4dc8b4f562e6";
static NSString *language = @"en";

@implementation PDMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


- (IBAction)searchButtonPressed:(id)sender {
    NSString *word = [self.wordTextField.text lowercaseString];
    NSString *tenantURL = [NSString stringWithFormat:@"/entries/%@/%@", language, word];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:[baseURL stringByAppendingString:tenantURL]]];
    [request setHTTPMethod:@"GET"];
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    [request setValue:applicationID forHTTPHeaderField:@"app_id"];
    [request setValue:applicationKey forHTTPHeaderField:@"app_key"];
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:
                                  ^(NSData *data, NSURLResponse *response, NSError *error) {
                                      
                                      if (error) {
                                          NSLog(@"%@",error);
                                          return;
                                      }
                                      
                                      if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
                                          NSLog(@"Response HTTP Status code: %ld\n", (long)[(NSHTTPURLResponse *)response statusCode]);
                                          NSLog(@"Response HTTP Headers:\n%@\n", [(NSHTTPURLResponse *)response allHeaderFields]);
                                      }
                                      
                                      NSString* body = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                      NSLog(@"Response Body:\n%@\n", body);
                                  }];
    [task resume];
}

- (IBAction)playButtonPressed:(id)sender {
}

- (void)setText:(NSString *)text toLabel:(UILabel *)label withHeightConstraint: (NSLayoutConstraint *)heightConstraint {
    CGSize maximumLabelSize = CGSizeMake([UIScreen mainScreen].bounds.size.width - 20, CGFLOAT_MAX);
    NSStringDrawingOptions options = NSStringDrawingTruncatesLastVisibleLine |
    NSStringDrawingUsesLineFragmentOrigin;
    
    NSDictionary *attr = @{
                           NSFontAttributeName: [UIFont systemFontOfSize:17],
                           };
    CGRect textLabelBounds = [text boundingRectWithSize:maximumLabelSize
                                                options:options
                                             attributes:attr
                                                context:nil];
    heightConstraint.constant =  textLabelBounds.size.height;
    label.text = text;
}

@end
