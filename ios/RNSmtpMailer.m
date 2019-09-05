
#import "RNSmtpMailer.h"
#import <React/RCTConvert.h>
#import <Mailcore/Mailcore.h>
@implementation RNSmtpMailer

- (dispatch_queue_t)methodQueue
{
    return dispatch_get_main_queue();
}
RCT_EXPORT_MODULE();
RCT_EXPORT_METHOD(sendMail:(NSDictionary *)obj resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject)
{
    NSString *mailhost = [RCTConvert NSString:obj[@"mailhost"]];
    NSString *port = [RCTConvert NSString:obj[@"port"]];
    NSString *username = [RCTConvert NSString:obj[@"username"]];
    NSString *password = [RCTConvert NSString:obj[@"password"]];
    NSString *fromEmail = [RCTConvert NSString:obj[@"from"]];
    NSString *recipients = [RCTConvert NSString:obj[@"recipients"]];
    NSString *subject = [RCTConvert NSString:obj[@"subject"]];
    NSString *body = [RCTConvert NSString:obj[@"htmlBody"]];
    NSArray *attachmentPaths = [RCTConvert NSArray:obj[@"attachmentPaths"]];
    NSArray *attachmentNames = [RCTConvert NSArray:obj[@"attachmentNames"]];
    NSArray *attachmentTypes = [RCTConvert NSArray:obj[@"attachmentTypes"]];
    NSNumber *portNumber = [NSNumber numberWithLongLong:port.longLongValue];
    NSUInteger portInteger = portNumber.unsignedIntegerValue;
    
    MCOSMTPSession *smtpSession = [[MCOSMTPSession alloc] init];
    smtpSession.hostname = mailhost;
    smtpSession.port = portInteger;
    smtpSession.username = username;
    smtpSession.password = password;
    smtpSession.authType = MCOAuthTypeSASLLogin;
    smtpSession.connectionType = MCOConnectionTypeStartTLS;
    MCOMessageBuilder *builder = [[MCOMessageBuilder alloc] init];
    MCOAddress *from = [MCOAddress addressWithDisplayName:nil
                                                mailbox:fromEmail];
    MCOAddress *to = [MCOAddress addressWithDisplayName:nil
                                              mailbox:recipients];
    [[builder header] setFrom:from];
    [[builder header] setTo:@[to]];
    [[builder header] setSubject:subject];
    [builder setHTMLBody:body];
    int size = [attachmentPaths count];
    for(int i = 0; i < size; i++){
        [builder addAttachment:[MCOAttachment attachmentWithContentsOfFile:[attachmentPaths objectAtIndex:i]]];
    }
    NSData * rfc822Data = [builder data];
    
    MCOSMTPSendOperation *sendOperation =
    [smtpSession sendOperationWithData:rfc822Data];
    [sendOperation start:^(NSError *error) {
    if(error) {
      NSLog(@"Error sending email: %@", error);
      reject(@"Error",error.localizedDescription,error);
    } else {
      NSLog(@"Successfully sent email!");
      NSDictionary *result = @{@"status": @"SUCCESS"};
      resolve(result);
    }
    }];
}

@end
