#import "BTTestClientTokenFactory.h"

@implementation BTTestClientTokenFactory

+ (NSMutableDictionary *)tokenDataWithConfiguration {
    return [@{
              @"authorizationFingerprint": @"an_authorization_fingerprint",
              @"configUrl": @"https://api.example.com:443/merchants/a_merchant_id/client_api/v1/configuration",
              @"challenges": @[
                      @"cvv"
                      ],
              @"paymentApps": @[],
              @"clientApiUrl": @"https://api.example.com:443/merchants/a_merchant_id/client_api",
              @"assetsUrl": @"https://assets.example.com",
              @"authUrl": @"https://auth.venmo.example.com",
              @"analytics": @{
                      @"url": @"https://client-analytics.example.com"
                      },
              @"threeDSecureEnabled": @NO,
              @"paypalEnabled": @YES,
              @"paypal": @{
                      @"displayName": @"Acme Widgets, Ltd. (Sandbox)",
                      @"clientId": @"a_paypal_client_id",
                      @"privacyUrl": @"http://example.com/pp",
                      @"userAgreementUrl": @"http://example.com/tos",
                      @"baseUrl": @"https://assets.example.com",
                      @"assetsUrl": @"https://checkout.paypal.example.com",
                      @"directBaseUrl": [NSNull null],
                      @"allowHttp": @YES,
                      @"environmentNoNetwork": @YES,
                      @"environment": @"offline",
                      @"merchantAccountId": @"a_merchant_account_id",
                      @"currencyIsoCode": @"USD"
                      },
              @"merchantId": @"a_merchant_id",
              @"venmo": @"offline",
              @"applePay": @{
                      @"status": @"mock",
                      @"countryCode": @"US",
                      @"currencyCode": @"USD",
                      @"merchantIdentifier": @"apple-pay-merchant-id",
                      @"supportedNetworks": @[ @"visa",
                                               @"mastercard",
                                               @"amex" ]

                      },
              @"coinbaseEnabled": @YES,
              @"coinbase": @{
                      @"clientId": @"a_coinbase_client_id",
                      @"merchantAccount": @"coinbase-account@example.com",
                      @"scopes": @"authorizations:braintree user",
                      @"redirectUrl": @"https://assets.example.com/coinbase/oauth/redirect"
                      },
              @"merchantAccountId": @"some-merchant-account-id",
              } mutableCopy];
}

+ (NSMutableDictionary *)configuration {
    return [@{
              @"version": @3,
              @"challenges": @[
                      @"cvv"
                      ],
              @"paymentApps": @[],
              @"clientApiUrl": @"https://api.example.com:443/merchants/a_merchant_id/client_api",
              @"assetsUrl": @"https://assets.example.com",
              @"authUrl": @"https://auth.venmo.example.com",
              @"analytics": @{
                      @"url": @"https://client-analytics.example.com"
                      },
              @"threeDSecureEnabled": @NO,
              @"paypalEnabled": @YES,
              @"paypal": @{
                      @"displayName": @"Acme Widgets, Ltd. (Sandbox)",
                      @"clientId": @"a_paypal_client_id",
                      @"privacyUrl": @"http://example.com/pp",
                      @"userAgreementUrl": @"http://example.com/tos",
                      @"baseUrl": @"https://assets.example.com",
                      @"assetsUrl": @"https://checkout.paypal.example.com",

                      // Why was this null?
                      //@"directBaseUrl": [NSNull null],

                      @"directBaseUrl": @"http://api.paypal.example.com",

                      @"allowHttp": @YES,
                      @"environmentNoNetwork": @YES,
                      @"environment": @"offline",
                      @"merchantAccountId": @"a_merchant_account_id",
                      @"currencyIsoCode": @"USD"
                      },
              @"merchantId": @"a_merchant_id",
              @"venmo": @"offline",
              @"coinbaseEnabled": @YES,
              @"coinbase": @{
                      @"clientId": @"a_coinbase_client_id",
                      @"merchantAccount": @"coinbase-account@example.com",
                      @"scopes": @"authorizations:braintree user",
                      @"redirectUrl": @"https://assets.example.com/coinbase/oauth/redirect"
                      },
              @"applePay": @{
                      @"status": @"mock",
                      @"countryCode": @"US",
                      @"currencyCode": @"USD",
                      @"merchantIdentifier": @"merchant.com.braintreepayments.test",
                      @"supportedNetworks": @[
                                  @"visa",
                                  @"mastercard",
                                  @"amex"
                                  ],
                      },
              } mutableCopy];
}

+ (NSMutableDictionary *)configurationWithOverrides:(NSDictionary *)overrides {
    NSMutableDictionary *configurationDict = [self configuration];
    [self applyOverrides:overrides toMutableDictionary:&configurationDict];
    return configurationDict;
}

+ (NSMutableDictionary *)tokenDataWithoutConfiguration {
    return [@{
              @"authorizationFingerprint": @"an_authorization_fingerprint",
              @"configUrl": @"https://example.com:443/merchants/a_merchant_id/client_api/v1/configuration"
              } mutableCopy];
}

+ (NSString *)tokenWithVersion:(NSInteger)version {
    return [self tokenWithVersion:version overrides:nil];
}
+ (NSString *)tokenWithVersion:(NSInteger)version
                     overrides:(NSDictionary *)overrides {
    BOOL base64Encoded;
    NSMutableDictionary *baseTokenData;

    switch (version) {
        case 2:
            base64Encoded = YES;
            baseTokenData = [self tokenDataWithConfiguration];
            break;
        case 1:
            base64Encoded = NO;
            baseTokenData = [self tokenDataWithConfiguration];
            break;
        default:
            return nil;
            break;
    }

    baseTokenData[@"version"] = @(version);

    [self applyOverrides:overrides toMutableDictionary:&baseTokenData];

    NSError *jsonSerializationError;
    NSData *configurationData = [NSJSONSerialization dataWithJSONObject:baseTokenData
                                                                options:0
                                                                  error:&jsonSerializationError];
    NSAssert(jsonSerializationError == nil, @"Failed to generated test client token JSON: %@", jsonSerializationError);

    if (base64Encoded) {
        return [configurationData base64EncodedStringWithOptions:0];
    } else {
        return [[NSString alloc] initWithData:configurationData
                                     encoding:NSUTF8StringEncoding];
    }
}

+ (void)applyOverrides:(NSDictionary *)overrides toMutableDictionary:(NSMutableDictionary * __autoreleasing *)dictionary {
    [overrides enumerateKeysAndObjectsUsingBlock:^(id key, id obj, __unused BOOL *stop){
        if([obj isKindOfClass:[NSNull class]]) {
            [*dictionary removeObjectForKey:key];
        } else {
            if ([obj isKindOfClass:[NSDictionary class]] && [[*dictionary objectForKey:key] isKindOfClass:[NSDictionary class]]) {
                // Overriding values nested inside a dictionary
                NSMutableDictionary *dictToModify = [[*dictionary objectForKey:key] mutableCopy];
                [self applyOverrides:obj toMutableDictionary:&dictToModify];
                [*dictionary setObject:dictToModify forKey:key];
            } else {
                [*dictionary setObject:obj forKey:key];
            }
        }
    }];
}

@end
