//
//  AppleSearchObject.m
//

#import "AppleSearchObject.h"

@implementation AppleSearchObject

- (id)init {
    self = [super init];
    if (self) {
        self.country = @"";
        self.state = @"";
        self.city = @"";
        self.street = @"";
        self.houseNumber = @"";
    }
    return self;
}

+ (instancetype)appleSearchObject {
    AppleSearchObject *appleSearchObject = [[AppleSearchObject alloc] init];
    return appleSearchObject;
}

- (NSString *)description {
    return [NSString stringWithFormat:@"Country: %@ ; State: %@ ; City: %@ ; Street: %@ ; House number: %@ ;\n", self.country, self.state, self.city, self.street, self.houseNumber];
}

@end
