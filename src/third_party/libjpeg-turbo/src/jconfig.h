/* jconfig.h - minimal config for libjpeg-turbo */
#define JCONFIG_INCLUDED
#define HAVE_PROTOTYPES
#define HAVE_UNSIGNED_CHAR
#define HAVE_UNSIGNED_SHORT
#define HAVE_STDDEF_H
#define HAVE_STDLIB_H
#define HAVE_UNISTD_H
#define JPEG_LIB_VERSION 80
#define DEFAULT_QUALITY 75
#define BITS_IN_JSAMPLE 8
#define DCT_ISLOW_SUPPORTED
#define DCT_IFAST_SUPPORTED
#define DCT_FLOAT_SUPPORTED
#ifdef _MSC_VER
#include <io.h>
#endif
