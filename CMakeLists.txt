cmake_minimum_required(VERSION 3.10)
project(insert)

set(CMAKE_CXX_STANDARD 11)

# 添加包含目录
include_directories(include)

# 指定源文件
set(SOURCES
    src/db_insert/insert.cpp
    src/db_config/db_info.cpp
)

set(SOURCES_DIR
    src/db_insert/insert_summary.cpp
    src/db_config/db_info.cpp
)

set(SOURCES_DIR_
    src/db_insert/insert_passage.cpp
    src/db_config/db_info.cpp
)

set(SOURCES_SEARCH
    src/db_select/search.cpp
    src/db_config/db_info.cpp)
# 创建可执行文件
# add_executable(insert ${SOURCES})
# add_executable(insert_summary ${SOURCES_DIR})
# add_executable(insert_passage ${SOURCES_DIR_})
add_executable(search ${SOURCES_SEARCH})

# 链接库
# target_link_libraries(insert mariadbcpp)  # 如果需要，替换为正确的链接库名称
# target_link_libraries(insert_summary mariadbcpp)
# target_link_libraries(insert_passage mariadbcpp)
target_link_libraries(search mariadbcpp)

# 添加清理规则，删除可执行文件和构建文件
add_custom_target(clean-all
    COMMAND ${CMAKE_COMMAND} -E echo "Cleaning build files..."
    COMMAND ${CMAKE_COMMAND} -E remove $<TARGET_FILE:insert>  # 删除可执行文件
    COMMAND ${CMAKE_COMMAND} -E remove $<TARGET_FILE:insert_passage>  # 删除可执行文件
    COMMAND ${CMAKE_COMMAND} -E remove $<TARGET_FILE:insert_summary>  # 删除可执行文件
    COMMAND ${CMAKE_COMMAND} -E remove $<TARGET_FILE:search>  # 删除可执行文件
    COMMAND ${CMAKE_COMMAND} -E remove_directory ${CMAKE_BINARY_DIR}/CMakeFiles  # 删除 CMake 生成的文件夹
    COMMAND ${CMAKE_COMMAND} -E remove ${CMAKE_BINARY_DIR}/CMakeCache.txt  # 删除 CMakeCache.txt
    COMMAND ${CMAKE_COMMAND} -E remove ${CMAKE_BINARY_DIR}/cmake_install.cmake  # 删除 cmake_install.cmake
    COMMAND ${CMAKE_COMMAND} -E remove ${CMAKE_BINARY_DIR}/Makefile  # 删除 Makefile
    COMMAND ${CMAKE_COMMAND} -E remove ${CMAKE_BINARY_DIR}/install_manifest.txt  # 删除可执行文件
    COMMAND ${CMAKE_COMMAND} -E echo "Cleaned build files."
)

# 默认清理目标
# set_directory_properties(PROPERTIES ADDITIONAL_MAKE_CLEAN_FILES ${CMAKE_BINARY_DIR}/insert)

install(TARGETS insert insert_summary insert_passage search
        DESTINATION /usr/bin)
