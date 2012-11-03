//
//  TGRProfileImageView.m
//  TwitterTimeline
//
//  Created by guille on 27/10/12.
//  Copyright (c) 2012 Guillermo Gonzalez. All rights reserved.
//

#import "TGRProfileImageView.h"
#import "SDWebImageManagerDelegate.h"
#import "SDWebImageManager.h"

@interface TGRProfileImageView () <SDWebImageManagerDelegate>

// La imagen que vamos a mostrar
@property (strong, nonatomic) UIImage *image;

@end

@implementation TGRProfileImageView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    
    if (self) {
        // Nuestra vista es transparente y recorta lo que
        // está fuera de sus límites
        self.opaque = NO;
        self.clipsToBounds = YES;
    }
    
    return self;
}

- (void)drawRect:(CGRect)rect
{
    if (self.image) {
        // Dejamos 4 píxeles en los bordes laterales e inferior para la sombra
        CGRect imageRect = UIEdgeInsetsInsetRect(self.bounds, UIEdgeInsetsMake(0, 4, 4, 4));
        
        // Activamos el 'sombreado' en nuestro contexto gráfico
        CGContextSetShadow(UIGraphicsGetCurrentContext(), CGSizeMake(0, 1), 2);
        
        // Pintamos la imagen
        [self.image drawInRect:imageRect];
    }
}

- (void)setProfileImageURL:(NSURL *)url
{
    // Cancelamos cualquier descarga que tuvieramos antes
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    [manager cancelForDelegate:self];
    
    if (url) {
        // Descargamos la imagen de manera asíncrona. El manager nos avisa
        // cuando haya terminado llamando a webImageManager:didFinishWithImage:
        [manager downloadWithURL:url delegate:self];
    }
    else {
        // Reseteamos la imagen de perfil
        [self setProfileImage:nil];
    }
}

- (void)cancelCurrentImageLoad
{
    // Cancelamos la descarga de imágen que tengamos en este momento
    [[SDWebImageManager sharedManager] cancelForDelegate:self];
}

- (void)webImageManager:(SDWebImageManager *)imageManager didFinishWithImage:(UIImage *)image
{
    // La imagen se ha descargado. Llamamos a setProfileImage para
    // crear la imagen con bordes redondeados
    [self setProfileImage:image];
}

#pragma mark - Private methods

- (void)setProfileImage:(UIImage *)image
{
    // Si no es nil, creamos una versión de la misma con los bordes redondeados
    self.image = image ? [self roundedImageFromImage:image] : nil;
    
    // Nos aseguramos de que la vista se pinte
    [self setNeedsDisplay];
}

// Crea una versión de la imagen con los bordes redondeados
- (UIImage *)roundedImageFromImage:(UIImage *)image
{
    // Dejamos 4 píxeles en los bordes laterales e inferior para la sombra que vamos
    // a pintar en drawRect
    CGRect bounds = UIEdgeInsetsInsetRect(self.bounds, UIEdgeInsetsMake(0, 4, 4, 4));
    bounds.origin = CGPointZero;
    
    // Calculamos la relación de aspecto de la vista
    CGFloat targetAspect = bounds.size.width / bounds.size.height;
    
    // Calculamos la relación de aspecto de la imagen
    CGFloat sourceAspect = image.size.width / image.size.height;
    CGRect imageRect = CGRectZero;
    
    // A continuación calculamos las nuevas dimensiones de la imagen.
    
    // Vamos a llenar el contenido de la vista manteniendo la relación de
    // aspecto de la imagen, recortándola si es necesario. Esto es lo mismo
    // que hace UIImageView cuando configuramos su contentMode con el
    // valor UIViewContentModeScaleAspectFill.
    
    if (targetAspect >= sourceAspect) {
        imageRect.size.width = bounds.size.width;
        imageRect.size.height = imageRect.size.width / sourceAspect;
        imageRect.origin.y = (bounds.size.height - imageRect.size.height) * 0.5;
    }
    else {
        imageRect.size.height = bounds.size.height;
        imageRect.size.width = imageRect.size.height * sourceAspect;
        imageRect.origin.x = (bounds.size.width - imageRect.size.width) * 0.5;
    }
    
    // Creamos un contexto gráfico bitmap para nuestra imagen redondeada
    UIGraphicsBeginImageContextWithOptions(bounds.size, NO, 0);
    
    // Creamos un path con los bordes redondeados y lo añadimos al
    // contexto gráfico como región de corte
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:bounds
                                                    cornerRadius:5];
    [path addClip];
    
    // Pintamos la imagen
    [image drawInRect:imageRect];
    
    // Obtenemos una copia de lo que acabamos de pintar
    UIImage *roundedImage = UIGraphicsGetImageFromCurrentImageContext();
    
    // Cerramos el contexto gráfico
    UIGraphicsEndImageContext();
    
    return roundedImage;
}

@end
