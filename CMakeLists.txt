cmake_minimum_required(VERSION 3.10)
project(mkxz VERSION 1.0 LANGUAGES C)

# Проверяем наличие Zsh и требуем его наличия
find_program(ZSH_PROGRAM zsh REQUIRED)

# Определение директории для скомпилированных скриптов
set(COMPILE_DIR "${CMAKE_BINARY_DIR}/out/build/bin")

# Создаем директорию для скомпилированного скрипта
file(MAKE_DIRECTORY ${COMPILE_DIR})
message("Директория ${COMPILE_DIR} создана.")
# Функция для добавления целей компиляции
function(add_zsh_compile_target target_name script_name)
  set(script_file "${script_name}.zsh")
  set(compiled_script_file "${script_name}.zwc")

  add_custom_target("${target_name}" ALL
    COMMAND ${ZSH_PROGRAM} -c "zcompile '${CMAKE_SOURCE_DIR}/${script_file}' > '${COMPILE_DIR}/${compiled_script_file}'"
    COMMENT "Компиляция ${script_file} в .zwc"
    WORKING_DIRECTORY ${COMPILE_DIR}
  )

  # Установка скомпилированного скрипта
  install(FILES "${COMPILE_DIR}/${compiled_script_file}" DESTINATION bin
          PERMISSIONS OWNER_EXECUTE OWNER_WRITE OWNER_READ GROUP_EXECUTE GROUP_READ WORLD_EXECUTE WORLD_READ)
endfunction()

# Добавляем цели компиляции для обоих скриптов
add_zsh_compile_target(compile_mkxz "mkxz")
add_zsh_compile_target(compile_modified_mkxz "modified_mkxz")

# Сообщения в процессе установки
install(CODE "message(\"Установка скриптов mkxz и modified_mkxz...\")")

set(CPACK_GENERATOR "TGZ;ZIP")
include(CPack)
