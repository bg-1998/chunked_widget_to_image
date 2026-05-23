
cmake_minimum_required(VERSION 3.14)

set(PROJECT_NAME "chunked_widget_to_image")
project(${PROJECT_NAME} LANGUAGES CXX)

# 创建一个STATIC库目标，可以使用POST_BUILD命令
add_library(${PROJECT_NAME} STATIC
        "dummy.cpp"  # 添加一个空的cpp文件
)

# 设置源文件内容（创建一个空的cpp文件）
file(WRITE "${CMAKE_CURRENT_SOURCE_DIR}/dummy.cpp" "")

# 自动获取lib目录下的所有DLL文件
file(GLOB DLL_FILES "${CMAKE_CURRENT_SOURCE_DIR}/lib/*.dll")

# 复制所有DLL文件到输出目录
foreach(dll_file ${DLL_FILES})
    add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
            COMMAND ${CMAKE_COMMAND} -E copy_if_different
            "${dll_file}"
            $<TARGET_FILE_DIR:${PROJECT_NAME}>)
endforeach()

# 更新捆绑库列表
set(chunked_widget_to_image_bundled_libraries
        ${DLL_FILES}
        PARENT_SCOPE
)