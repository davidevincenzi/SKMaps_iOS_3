//
//  SKTTexture.h
//  ProtobufParsing
//
//

#import <Foundation/Foundation.h>

@interface SKTTexture : NSObject

@property (nonatomic, strong) NSString *file;
@property (nonatomic, assign) long long size;
@property (nonatomic, assign) long long unzipsize;
@property (nonatomic, strong) NSString *texturesbigfile;
@property (nonatomic, assign) long long sizebigfile;

@end
