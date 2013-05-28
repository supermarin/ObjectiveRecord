//
//  Car.h
//  SampleProject
//
//  Created by Marin Usalj on 5/28/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Car : NSManagedObject

@property (nonatomic, retain) NSString * make;
@property (nonatomic, retain) NSNumber * horsePower;

@end
