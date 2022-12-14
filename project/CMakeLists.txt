cmake_minimum_required(VERSION 3.22)

message("Entering ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt")

#
# Core project settings
#
set(PROJ_PATH                       ${CMAKE_CURRENT_SOURCE_DIR})
project(HelloWorld)
enable_language(C CXX ASM)
message("Build type: "              ${CMAKE_BUILD_TYPE})

# Setup compiler settings
set(CMAKE_C_STANDARD                99)
set(CMAKE_C_STANDARD_REQUIRED       ON)
set(CMAKE_C_EXTENSIONS              ON)
set(CMAKE_CXX_STANDARD              20)
set(CMAKE_CXX_STANDARD_REQUIRED     ON)
set(CMAKE_CXX_EXTENSIONS            ON)

#
# Core MCU flags, CPU, instruction set and FPU setup
#
set(CPU_PARAMETERS
    -mthumb
    # Other parameters
    # -mcpu, -mfloat, -mfloat-abi, ...
    -mcpu=cortex-m23
    #-mfloat-abi=soft
)

# Set linker script
set(linker_script_SRC               ${PROJ_PATH}/GD32L233x_FLASH.ld)
set(EXECUTABLE                      ${CMAKE_PROJECT_NAME})

#
# Source files
#
set(src_core_src_SRCS 
    ${PROJ_PATH}/src/main.c
    ${PROJ_PATH}/src/syscalls.c
    ${PROJ_PATH}/src/sysmem.c
    ${PROJ_PATH}/src/system_gd32l23x.c  
    ${PROJ_PATH}/src/gd32l23x_it.c    
    ${PROJ_PATH}/src/systick.c    
    ${PROJ_PATH}/src/gd32l233c_start.c
)

set(src_core_startup_SRCS 
    ${PROJ_PATH}/src/startup_gd32l23x.s
)
    
set(src_middlewares_src_SRCS

)   

set(src_hal_driver_SRCS
	${PROJ_PATH}/../libraries/Drivers/GD32L23x_standard_peripheral/Source/gd32l23x_gpio.c
	${PROJ_PATH}/../libraries/Drivers/GD32L23x_standard_peripheral/Source/gd32l23x_misc.c
	${PROJ_PATH}/../libraries/Drivers/GD32L23x_standard_peripheral/Source/gd32l23x_rcu.c
	${PROJ_PATH}/../libraries/Drivers/GD32L23x_standard_peripheral/Source/gd32l23x_syscfg.c
	${PROJ_PATH}/../libraries/Drivers/GD32L23x_standard_peripheral/Source/gd32l23x_exti.c
	${PROJ_PATH}/../libraries/Drivers/GD32L23x_standard_peripheral/Source/gd32l23x_pmu.c
)

#
# Include directories
#
set(include_c_DIRS	
    ${PROJ_PATH}/src/inc    
    ${PROJ_PATH}/../libraries/Drivers/CMSIS/GD/GD32L23x/Include
    ${PROJ_PATH}/../libraries/Drivers/CMSIS/core/CMSIS/Core/Include
    ${PROJ_PATH}/../libraries/Drivers/GD32L23x_standard_peripheral/Include
)
set(include_cxx_DIRS
    
)
set(include_asm_DIRS
    
)

#
# Symbols definition
#
set(symbols_c_SYMB    

)
set(symbols_cxx_SYMB
    
)
set(symbols_asm_SYMB
    
)

#
# Link directories setup
# Must be before executable is added
#
set(link_DIRS
    
)
link_directories(${EXECUTABLE} ${link_DIRS})

#
# Executable files
#
add_executable(${EXECUTABLE} 
    ${src_core_src_SRCS}
    ${src_core_startup_SRCS}
    ${src_hal_driver_SRCS}
    ${src_middlewares_src_SRCS})

#
# Add linked libraries for linker
#
set(link_LIBS
    
)
target_link_libraries(${EXECUTABLE} ${link_LIBS})

#
# Project symbols
#
target_compile_definitions(${EXECUTABLE} PRIVATE
    # Language specific only
    $<$<COMPILE_LANGUAGE:C>: ${symbols_c_SYMB}>
    $<$<COMPILE_LANGUAGE:CXX>: ${symbols_cxx_SYMB}>
    $<$<COMPILE_LANGUAGE:ASM>: ${symbols_asm_SYMB}>

    # Configuration specific
    $<$<CONFIG:Debug>:
        DEBUG
    >
    $<$<CONFIG:Release>: >
)

#
# Add include paths for each of the compiler
#
target_include_directories(${EXECUTABLE} PRIVATE
    # Language specific only
    $<$<COMPILE_LANGUAGE:C>: ${include_c_DIRS}>
    $<$<COMPILE_LANGUAGE:CXX>: ${include_cxx_DIRS}>
    $<$<COMPILE_LANGUAGE:ASM>: ${include_asm_DIRS}>

    # Configuration specific
    $<$<CONFIG:Debug>: >
    $<$<CONFIG:Release>: >
)

# Compiler and linker options
target_compile_options(${EXECUTABLE} PRIVATE
    ${CPU_PARAMETERS}
    -Wall
    -Wextra
    -Wpedantic
    -Wno-unused-parameter
    $<$<COMPILE_LANGUAGE:C>:

    >
    $<$<COMPILE_LANGUAGE:CXX>:
        #-Wno-volatile
        #-Wold-style-cast
        #-Wuseless-cast
        #-Wsuggest-override
    >
    $<$<COMPILE_LANGUAGE:ASM>:
        -x assembler-with-cpp
        -MMD
        -MP
    >
    $<$<CONFIG:Debug>:
        -O0 -g3 -ggdb
    >
    $<$<CONFIG:Release>:
        -O1
    >
)

# Setup linker parameters
target_link_options(${EXECUTABLE} PRIVATE
    -T${linker_script_SRC}
    ${CPU_PARAMETERS}
    -Wl,-Map=${CMAKE_PROJECT_NAME}.map
    #-u _printf_float              # STDIO float formatting support (remove if not used)
    --specs=nosys.specs
    -Wl,--start-group
    -lc
    -lm
    #-lstdc++
    #-lsupc++
    -Wl,--end-group
    -Wl,--print-memory-usage
)

# Execute post-build to print size
add_custom_command(TARGET ${EXECUTABLE} POST_BUILD
    COMMAND ${CMAKE_SIZE} $<TARGET_FILE:${EXECUTABLE}>
)

# Convert output to hex and binary
add_custom_command(TARGET ${EXECUTABLE} POST_BUILD
    COMMAND ${CMAKE_OBJCOPY} -O ihex $<TARGET_FILE:${EXECUTABLE}> ${EXECUTABLE}.hex
)

# Convert to bin file -> add conditional check?
add_custom_command(TARGET ${EXECUTABLE} POST_BUILD
    COMMAND ${CMAKE_OBJCOPY} -O binary $<TARGET_FILE:${EXECUTABLE}> ${EXECUTABLE}.bin
)

message("Exiting ${CMAKE_CURRENT_LIST_DIR}/CMakeLists.txt")
