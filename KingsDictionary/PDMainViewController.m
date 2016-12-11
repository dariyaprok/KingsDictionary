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
@property (weak, nonatomic) IBOutlet UILabel *categoriesTitle;

@property (weak, nonatomic) IBOutlet UILabel *definitionsLabel;
@property (weak, nonatomic) IBOutlet UILabel *definitionsTitle;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *defnitionsLabelHeightConstraint;

@property (weak, nonatomic) IBOutlet UILabel *examplesLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *examplesLabelHeightConstraint;
@property (weak, nonatomic) IBOutlet UILabel *examplesTitle;

@end

static NSString *baseURL = @"https://od-api.oxforddictionaries.com/api/v1";
static NSString *applicationID = @"cce9efd7";
static NSString *applicationKey = @"907fae2dc9fca3c9521c4dc8b4f562e6";
static NSString *language = @"en";

@implementation PDMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.view addGestureRecognizer:tap];
}


- (IBAction)searchButtonPressed:(id)sender {
    NSString *word = [self.wordTextField.text lowercaseString];
    NSString *tenantURL = [NSString stringWithFormat:@"/entries/%@/%@", language, word];
    NSString *stringURL = [baseURL stringByAppendingString:tenantURL];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:stringURL]];
    [request setHTTPMethod:@"GET"];
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    //    [request setValue:@"application/json" forHTTPHeaderField:@"Content-type"];
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
                                      NSDictionary *responseDict = [NSJSONSerialization JSONObjectWithData:data
                                                                                                   options:kNilOptions
                                                                                                     error:&error];
                                      [self parserResults:responseDict[@"results"][0][@"lexicalEntries"]];
                                      NSString* body = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                      NSLog(@"Response Body:\n%@\n", body);
                                  }];
    [task resume];
}

- (IBAction)playButtonPressed:(id)sender {
}

#pragma mark - private
- (void)parserResults: (NSDictionary *)result {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"%@", result);
        NSString *categories = @"";
        NSString *examples = @"";
        NSString *definitions = @"";
        for (NSDictionary *dict in result) {
            categories = [NSString stringWithFormat:@"%@%@, ", categories, dict[@"lexicalCategory"]];
            for (NSDictionary *subDict in dict[@"entries"]) {
                for (NSDictionary *subSubDict in subDict[@"senses"]) {
                    definitions = [NSString stringWithFormat:@"%@%@, ", definitions, subSubDict[@"definitions"][0]];
                    examples = [NSString stringWithFormat:@"%@%@, ", definitions, subSubDict[@"examples"][0][@"text"]];
                }
            }
        }
        if ([categories length] > 0) {
            categories = [[categories substringToIndex:[categories length] - 2] stringByAppendingString:@"."];
        }
        [self setText:categories toLabel:self.categoriesLabel withHeightConstraint:self.categoriesLabelHeightConstraint];
        self.categoriesTitle.hidden = !categories.length;
        if ([definitions length] > 0) {
            definitions = [[definitions substringToIndex:[definitions length] - 2] stringByAppendingString:@"."];
        }
        [self setText:definitions toLabel:self.definitionsLabel withHeightConstraint:self.defnitionsLabelHeightConstraint];
        self.definitionsTitle.hidden = !definitions.length;
        if ([examples length] > 0) {
            examples = [[examples substringToIndex:[examples length] - 2] stringByAppendingString:@"."];
        }
        [self setText:examples toLabel:self.examplesLabel withHeightConstraint:self.examplesLabelHeightConstraint];
        self.examplesTitle.hidden = !examples.length;
    });
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
    heightConstraint.constant =  textLabelBounds.size.height + 5;
    [self.view layoutIfNeeded];
    label.text = text;
}

- (void)hideKeyboard {
    [self.wordTextField resignFirstResponder];
}


@end
