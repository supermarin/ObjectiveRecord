//
//  OBRPerson.h
//  SampleProject
//
//  Created by Elliot Neal on 22/05/2013.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface OBRPerson : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * surname;
@property (nonatomic, retain) NSNumber * age;
@property (nonatomic, retain) NSNumber * isMember;

@end
