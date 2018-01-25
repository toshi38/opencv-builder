### opencv-builder

This image is intended to be used to speed up CI builds of opencv projects.
It has gcc7 as well as CMake 3.10.2 installed.

While the image was intended to build one specific project, perhaps others will
find it useful.  We used it to avoid building/compiling/installing opencv on our CI
system cutting build times from ~1hr to < 5min.

