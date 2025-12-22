//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <libvips_ffi_linux/libvips_ffi_linux_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) libvips_ffi_linux_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "LibvipsFfiLinuxPlugin");
  libvips_ffi_linux_plugin_register_with_registrar(libvips_ffi_linux_registrar);
}
