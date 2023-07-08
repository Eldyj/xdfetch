# -- ~/.config/xdfetch/conf.ash

del="------------------";
info context "`user`@`host`";
info system "${del}";
info distro "`distro` `arch`";
info kernel "`kernel_version`";
info packages "`packages_installed_marked` (`package_manager`)";
info init "`init_system`";
info session "`session_type`";
info hardware "${del}";
info model "`model`";
info board "`board`";
info screen "`resolution`";
info cpu "`cpu_model`";
info gpu "`gpu_model`@`gpu_cores`";
info ram "`memory_usage`/`memory_capacity`";
info rom "`disk_usage`/`disk_capacity`";
info uptime "`since_uptime`";
info_flush;
