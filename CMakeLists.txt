cmake_minimum_required(VERSION 3.10)
project(mkxz VERSION 1.0 LANGUAGES C)

# Проверяем наличие Zsh
find_program(ZSH_PROGRAM zsh)
if(NOT ZSH_PROGRAM)
  message(FATAL_ERROR "zsh не найден. Установите zsh для продолжения.")
endif()

# Определение переменных для скриптов
set(SCRIPT_NAME "mkxz")
set(SCRIPT_FILE "${SCRIPT_NAME}.zsh")
set(COMPILED_SCRIPT_FILE "${SCRIPT_NAME}.zwc")
set(COMPILE_DIR "${CMAKE_BINARY_DIR}/out/build/bin")

# Создаем директорию для скомпилированного скрипта
file(MAKE_DIRECTORY ${COMPILE_DIR})

add_custom_target(compile_mkxz ALL
  COMMAND ${ZSH_PROGRAM} -c "zcompile '${CMAKE_SOURCE_DIR}/${SCRIPT_FILE}' '${COMPILE_DIR}/${COMPILED_SCRIPT_FILE}'"
  COMMENT "Компиляция ${SCRIPT_FILE} в ${COMPILED_SCRIPT_FILE}"
  WORKING_DIRECTORY ${COMPILE_DIR}
)

# Установка скомпилированного скрипта
install(FILES "${COMPILE_DIR}/${COMPILED_SCRIPT_FILE}" DESTINATION bin
        PERMISSIONS OWNER_EXECUTE OWNER_WRITE OWNER_READ GROUP_EXECUTE GROUP_READ WORLD_EXECUTE WORLD_READ)

# Дополнительные сообщения в процессе установки
install(CODE "message(\\\"Установка скрипта ${SCRIPT_NAME}...\\\")")

set(CPACK_GENERATOR "TGZ;ZIP")
include(CPack)
