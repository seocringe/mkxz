cmake_minimum_required(VERSION 3.10)
project(mkxz VERSION 1.0 LANGUAGES C)

# Define variables for the script name and source
set(SCRIPT_NAME "mkxz")
set(SCRIPT_FILE "${SCRIPT_NAME}.zsh")

# List of sources (dependencies)
set(SOURCES
    ${SCRIPT_FILE}
)

# Create a directory where the compiled script will be stored
file(MAKE_DIRECTORY "${CMAKE_BINARY_DIR}/out/build/bin")

# Add a custom target that compiles the .zsh script into a .zwc bytecode file
add_custom_target(
    ${SCRIPT_NAME}
    COMMAND zsh -c "zcompile ${SCRIPT_FILE} -o ${SCRIPT_NAME}.zwc"
    DEPENDS ${SOURCES}
    WORKING_DIRECTORY "${CMAKE_BINARY_DIR}/out/build/bin"
)

# Optional: Add a command to display a message when building the mkxz target
add_custom_command(
    TARGET ${SCRIPT_NAME}
    PRE_BUILD
    COMMAND echo "Building ${SCRIPT_NAME} script..."
    DEPENDS ${SOURCES}
)

# Copy the compiled script to the installation directory
install(FILES "${CMAKE_BINARY_DIR}/out/build/bin/${SCRIPT_NAME}.zwc" DESTINATION bin)

# Optional: Add a custom install step command
install(CODE "message(\"Installing ${SCRIPT_NAME} script...\")")

set(CPACK_GENERATOR "TGZ;ZIP")
include(CPack)
