if JITBLT_ENABLED
SUBDIRS = jitblt pixman test
else
SUBDIRS = pixman test
endif

pkgconfigdir=$(libdir)/pkgconfig
pkgconfig_DATA=pixman.pc

$(pkgconfig_DATA): pixman.pc.in
