//
//  TGRTweetCell.m
//  TwitterTimeline
//
//  Created by guille on 23/10/12.
//  Copyright (c) 2012 Guillermo Gonzalez. All rights reserved.
//

#import "TGRTweetCell.h"
#import "TGRTweet.h"
#import "TGRTwitterUser.h"

#import "TGRProfileImageView.h"

// Estas constantes nos van a servir para calcular la altura
// y la disposición de los elementos de la celda
static const CGFloat kStatusWidth = 248;
static const CGFloat kStatusY = 28;
static const CGFloat kRetweetedHeight = 14;
static const CGFloat kMinRowHeight = 64;

@implementation TGRTweetCell

// Calcula la altura de la celda para un determinado tweet
+ (CGFloat)heightForTweet:(TGRTweet *)tweet
{
    // Primero calculamos el tamaño del texto del tweet
    CGSize statusSize = [tweet.text sizeWithFont:[self statusLabelFont]
                               constrainedToSize:CGSizeMake(kStatusWidth, FLT_MAX)];
    CGFloat height = kStatusY + statusSize.height;
    
    // Si es un retweet reservamos más espacio para la última línea
    if (tweet.retweetedBy) {
        height += 4 + kRetweetedHeight;
    }
    
    // Nos aseguramos de que haya una altura mínima
    return MAX(kMinRowHeight, height + 8);
}

// Configura la celda para un determinado tweet
- (void)configureWithTweet:(TGRTweet *)tweet
{
    // Configuramos la URL de la vista que muestra la imagen de perfil
    // Para las pantallas retina, tenemos que hacer un pequeño retoque
    // a la URL que nos proporciona Twitter
    
    if ([[UIScreen mainScreen] scale] == 1.0) {
        [self.profileImageView setProfileImageURL:[NSURL URLWithString:tweet.user.imageLink]];
    }
    else {
        NSString *imageLink = [tweet.user.imageLink stringByReplacingOccurrencesOfString:@"_normal" withString:@"_bigger"];
        [self.profileImageView setProfileImageURL:[NSURL URLWithString:imageLink]];
    }
    
    // Configuramos las etiquetas
    
    self.nameLabel.text = tweet.user.name;
    self.statusLabel.text = tweet.text;
    
    [self configureDateLabelWithDate:tweet.publicationDate];
    
    if (tweet.retweetedBy) {
        NSString *format = NSLocalizedString(@"Retweeted by %@", @"");
        self.retweetedByLabel.text = [NSString stringWithFormat:format, tweet.retweetedBy.name];
        self.retweetedByLabel.hidden = NO;
    }
    else {
        self.retweetedByLabel.text = nil;
        self.retweetedByLabel.hidden = YES;
    }
    
    // Nos aseguramos de que el sistema llame a layoutSubviews
    
    [self setNeedsLayout];
}

// Configura la etiqueta que muestra la fecha
- (void)configureDateLabelWithDate:(NSDate *)date
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDate *now = [NSDate date];
    
    // Separamos la fecha en componentes
    
    NSUInteger unitFlags = NSSecondCalendarUnit | NSMinuteCalendarUnit | NSHourCalendarUnit | NSDayCalendarUnit;
    NSDateComponents *components = [calendar components:unitFlags
                                               fromDate:now
                                                 toDate:date
                                                options:0];
    
    NSString *dateString = NSLocalizedString(@"now", @"");
    
    // Configuramos la etiqueta con el componente de la fecha que mayor peso tenga
    
    if ([components day] != 0) {
        NSUInteger days = ABS([components day]);
        dateString = [NSString stringWithFormat:NSLocalizedString(@"%ud", @""), days];
    }
    else if ([components hour] != 0) {
        NSUInteger hours = ABS([components hour]);
        dateString = [NSString stringWithFormat:NSLocalizedString(@"%uh", @""), hours];
    }
    else if ([components minute] != 0) {
        NSUInteger minutes = ABS([components minute]);
        dateString = [NSString stringWithFormat:NSLocalizedString(@"%um", @""), minutes];
    }
    else if ([components second] != 0) {
        NSUInteger seconds = ABS([components second]);
        dateString = [NSString stringWithFormat:NSLocalizedString(@"%us", @""), seconds];
    }
    
    self.dateLabel.text = dateString;
}

// Inicializa la celda
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if (self) {
        _profileImageView = [[TGRProfileImageView alloc] initWithFrame:CGRectMake(4, 8, 56, 52)];
        
        [self.contentView addSubview:_profileImageView];
        
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(64, 8, 196, 20)];
        _nameLabel.font = [UIFont boldSystemFontOfSize:16];
        _nameLabel.highlightedTextColor = [UIColor whiteColor];
        
        [self.contentView addSubview:_nameLabel];
        
        _dateLabel = [[UILabel alloc] initWithFrame:CGRectMake(280, 12, 32, 14)];
        _dateLabel.font = [UIFont boldSystemFontOfSize:11];
        _dateLabel.textColor = [UIColor lightGrayColor];
        _dateLabel.highlightedTextColor = [UIColor whiteColor];
        _dateLabel.textAlignment = NSTextAlignmentRight;
        
        [self.contentView addSubview:_dateLabel];
        
        _statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(64, kStatusY, kStatusWidth, 20)];
        _statusLabel.font = [[self class] statusLabelFont];
        _statusLabel.highlightedTextColor = [UIColor whiteColor];
        _statusLabel.numberOfLines = 0;
        
        [self.contentView addSubview:_statusLabel];
        
        _retweetedByLabel = [[UILabel alloc] initWithFrame:CGRectMake(64, 0, kStatusWidth, kRetweetedHeight)];
        _retweetedByLabel.font = [UIFont boldSystemFontOfSize:11];
        _retweetedByLabel.textColor = [UIColor colorWithRed:92/255.0 green:115/255.0 blue:152/255.0 alpha:1];
        _retweetedByLabel.highlightedTextColor = [UIColor whiteColor];
        
        [self.contentView addSubview:_retweetedByLabel];
    }
    
    return self;
}

// Configura la disposición de los elementos de la celda
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    // Sólo tenemos que cambiar los frames de la etiqueta que muestra el texto y
    // el usuario que ha retuiteado. Los demás elementos no cambian de posición
    // ni de tamaño
    
    CGRect statusFrame = self.statusLabel.frame;
    statusFrame.size = [self.statusLabel.text sizeWithFont:self.statusLabel.font
                                         constrainedToSize:CGSizeMake(kStatusWidth, FLT_MAX)];
    self.statusLabel.frame = statusFrame;
    
    CGRect retweetedFrame = self.retweetedByLabel.frame;
    retweetedFrame.origin.y = CGRectGetMaxY(statusFrame) + 4;
    self.retweetedByLabel.frame = retweetedFrame;
}

// Este método se llama cada vez que la celda se recicla
- (void)prepareForReuse
{
    [super prepareForReuse];
    
    // Nos aseguramos de cancelar la descarga de la imagen de perfil
    [self.profileImageView cancelCurrentImageLoad];
    [self.profileImageView setProfileImageURL:nil];
}

#pragma mark - Private methods

+ (UIFont *)statusLabelFont
{
    return [UIFont systemFontOfSize:16];
}

@end
