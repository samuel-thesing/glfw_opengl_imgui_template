include(FetchContent)

set(FETCHCONTENT_QUIET OFF) # show git clone progress

# spdlog
FetchContent_Declare(
    spdlog
    GIT_REPOSITORY https://github.com/gabime/spdlog.git
    GIT_TAG v1.17.0
    GIT_PROGRESS TRUE
    GIT_SHALLOW TRUE
    SYSTEM
)
FetchContent_MakeAvailable(spdlog)
set_target_properties(spdlog PROPERTIES POSITION_INDEPENDENT_CODE ON)

# glfw
FetchContent_Declare(
    glfw
    GIT_REPOSITORY https://github.com/glfw/glfw.git
    GIT_TAG "tags/3.5.1"
)
FetchContent_MakeAvailable(glfw)

# glad
find_program(CURL_EXE NAMES curl curl.exe REQUIRED)

execute_process(
    COMMAND ${CURL_EXE} --max-time 120 -f -D - -X POST -d language=c&specification=gl&api=gl%3D${GL_VERSION}&api=gles1%3Dnone&api=gles2%3Dnone&api=glsc2%3Dnone&profile=core&loader=on https://glad.dav1d.de/generate
    OUTPUT_VARIABLE curl_output
    RESULT_VARIABLE curl_result
    ERROR_VARIABLE curl_error
)
if (NOT curl_result EQUAL "0")
    message(WARNING "${CURL_EXE} returned ${curl_result}")
    if (curl_error)
        message(FATAL_ERROR "Error message: ${curl_error}")
    else ()
        message(FATAL_ERROR "Could not download glad")
    endif ()
endif()

string(REGEX MATCH "[Ll][Oo][Cc][Aa][Tt][Ii][Oo][Nn]:[ \t]*([^\r\n]+)" glad_location "${curl_output}")
set(glad_location "${CMAKE_MATCH_1}")
string(STRIP "${glad_location}" glad_location)
if (NOT glad_location OR glad_location STREQUAL "/")
    message(WARNING "Could not extract location from http response")
    message(FATAL_ERROR "Response: ${curl_output}")
endif ()

string(REGEX REPLACE "/$" "" glad_location "${glad_location}")
string(APPEND glad_location "/glad.zip")
if (NOT ${glad_location} MATCHES "^http")
    string(PREPEND glad_location "https://glad.dav1d.de")
endif ()
message(STATUS "Downloading glad loader sources for ${GL_VERSION_STRING} from ${glad_location}")
FetchContent_Declare(
    glad
    URL ${glad_location}
)
FetchContent_MakeAvailable(glad)

file(GLOB_RECURSE glad_sources ${glad_SOURCE_DIR}/*.c ${glad_SOURCE_DIR}/*.h)
add_library(glad STATIC ${glad_sources})
target_link_libraries(glad PRIVATE ${CMAKE_DL_LIBS})
target_include_directories(glad PUBLIC ${glad_SOURCE_DIR}/include)

# glm
FetchContent_Declare(
    glm
    GIT_REPOSITORY https://github.com/g-truc/glm.git
    GIT_TAG "tags/1.0.3"
)
FetchContent_MakeAvailable(glm)

# imgui
FetchContent_Declare(
    imgui
    GIT_REPOSITORY https://github.com/ocornut/imgui.git
    GIT_TAG "origin/docking"
)
FetchContent_MakeAvailable(imgui)

file(GLOB imgui_SRC ${imgui_SOURCE_DIR}/*.cpp ${imgui_SOURCE_DIR}/*.h)
add_library(imgui STATIC
    ${imgui_SRC}
    ${imgui_SOURCE_DIR}/backends/imgui_impl_opengl3.cpp
    ${imgui_SOURCE_DIR}/backends/imgui_impl_opengl3.h
    ${imgui_SOURCE_DIR}/backends/imgui_impl_glfw.cpp
    ${imgui_SOURCE_DIR}/backends/imgui_impl_glfw.h
)
target_link_libraries(imgui PUBLIC glfw)
target_link_libraries(imgui PRIVATE ${CMAKE_DL_LIBS})
target_include_directories(imgui PUBLIC
    ${imgui_SOURCE_DIR}
    ${imgui_SOURCE_DIR}/backends
)


