//
//  HAZenDeskNewNameViewController.m
//  HelpApp
//
//  Created by Tenmiles on 25/10/13.
//  Copyright (c) 2013 Anand. All rights reserved.
//

#import "HSUserDetailsViewController.h"
#import "HSHelpStack.h"

@interface HSUserDetailsViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *firstNameField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameField;
@property (weak, nonatomic) IBOutlet UITextField *emailField;


@property (strong, nonatomic) UIBarButtonItem* nextButtonItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *submitButton;

@end

@implementation HSUserDetailsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.nextButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Next" style:UIBarButtonItemStyleDone target:self action:@selector(submitPressed:)];
    self.navigationItem.rightBarButtonItem = self.nextButtonItem;
    
    HSAppearance* appearance = [[HSHelpStack instance] appearance];
    self.view.backgroundColor = [appearance getBackgroundColor];
   
    self.title = @"Creating New Issue";
}

- (IBAction)submitPressed:(id)sender
{
    if([self checkValidity]) {

        UIActivityIndicatorView* indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [indicatorView startAnimating];

        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:indicatorView];

        [self.ticketSource registerUserWithFirstName:self.firstNameField.text lastName:self.lastNameField.text email:self.emailField.text success:^ {

            self.navigationItem.rightBarButtonItem = self.nextButtonItem;
            
            [self startIssueReportController];


        } failure:^(NSError *error) {

            self.navigationItem.rightBarButtonItem = self.nextButtonItem;

            UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Oops! Some error." message:@"There was some error registering you. Can you try some other email address?" delegate:self cancelButtonTitle:@"No, Leave it." otherButtonTitles:@"Ok", nil];
            alertView.tag = 20;

            [alertView show];

        }];

    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSInteger cancelButtonIndex = [alertView cancelButtonIndex];
    if (cancelButtonIndex != -1 && cancelButtonIndex == buttonIndex) {
        [self cancelPressed:nil];
    }
}

- (IBAction)cancelPressed:(id)sender
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

/*Validates the email address entered by the user */
- (BOOL)checkValidity {

    if(self.firstNameField.text ==nil || self.firstNameField.text.length == 0) {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Missing First Name" message:@"Please give your first name." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
        return NO;
    }

    if(self.lastNameField.text ==nil || self.lastNameField.text.length == 0) {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Missing Last Name" message:@"Please give your last name." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
        return NO;
    }

    if(self.emailField.text == nil || self.emailField.text.length == 0 || ![self isValidEmail:self.emailField.text]) {
        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Missing Email" message:@"Please give your valid email address." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alertView show];
        return NO;
    }

    return YES;
}

- (Boolean) isValidEmail: (NSString*) email {
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:
                                  @"[a-z0-9!#$%&'*+/=?^_`{|}~-]+(?:.[a-z0-9!#$%&'*+/=?^_`{|}~-]+)*@(?:[a-z0-9](?:[a-z0-9-]*[a-z0-9])?.)+[a-z0-9](?:[a-z0-9-]*[a-z0-9])?"
                                                                           options:NSRegularExpressionCaseInsensitive error:&error];
    
    NSArray* matchesInString = [regex matchesInString:email options:0 range:NSMakeRange(0, [email length])];
    if([matchesInString count]==1)
        return true;
    else
        return false;
}


- (void)startIssueReportController {
    HSNewIssueViewController* controller = [self.storyboard instantiateViewControllerWithIdentifier:@"HSReportIssue"];
    controller.createNewTicket = self.createNewTicket;
    controller.delegate = self.delegate;
    controller.ticketSource = self.ticketSource;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    HSNewIssueViewController* controller = (HSNewIssueViewController *)[segue destinationViewController];
    controller.createNewTicket = self.createNewTicket;
    controller.delegate = self.delegate;
    controller.ticketSource = self.ticketSource;
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField {

    if(textField == self.firstNameField) {
        [self.lastNameField becomeFirstResponder];
        return YES;
    }else if (textField == self.lastNameField){
        [self.emailField becomeFirstResponder];
        return YES;
    }else if(textField == self.emailField) {
        [self submitPressed:nil];
        return YES;
    }
    
    return NO;
}


@end