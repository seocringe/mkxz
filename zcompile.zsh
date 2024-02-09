#!/usr/bin/zsh
/usr/bin/zsh -c "mkdir -p ${CMAKE_BINARY_DIR}/out/build/bin/ && /usr/bin/zcompile -C -f -v -d -p -D -n -F -t -s -l ${SOURCES} -o ${CMAKE_BINARY_DIR}/out/build/bin/mkxz.zwc"