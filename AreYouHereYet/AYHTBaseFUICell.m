//
//  AYHTBaseFUICell.m
//  AreYouHereYet
//
//  Created by Maksim Pecherskiy on 9/3/13.
//  Copyright (c) 2013 Maksim Pecherskiy. All rights reserved.
//

#import "AYHTBaseFUICell.h"

@implementation AYHTBaseFUICell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor blueColor];
    }
    return self;
}

-(id)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor blueColor];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
