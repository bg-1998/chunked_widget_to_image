/* jconfigint.h - minimal config for libjpeg-turbo */
#define BUILD  ""
#define HIDDEN
#undef inline
#define INLINE  inline
#define THREAD_LOCAL
#define PACKAGE_NAME  "libjpeg-turbo"
#define VERSION  "3.1.2"
#define SIZEOF_SIZE_T  8
#define BITS_IN_JSAMPLE  8
#define C_ARITH_CODING_SUPPORTED 1
#define D_ARITH_CODING_SUPPORTED 1
#undef WITH_SIMD
#if defined(__has_attribute)
#if __has_attribute(fallthrough)
#define FALLTHROUGH  __attribute__((fallthrough));
#else
#define FALLTHROUGH
#endif
#else
#define FALLTHROUGH
#endif
