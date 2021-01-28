set(SOURCES main.cpp)

add_library(spaceage SHARED ${SOURCES})
target_link_libraries(spaceage gmod-module-base)

set_gmod_suffix_prefix(spaceage)
