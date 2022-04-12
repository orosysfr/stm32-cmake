
LIST(APPEND USBDEVICE_COMPONENTS_CLASS CDC DFU Audio Template MSC HIF CustomHID)
# This section fills the RTOS or family components list
set(USBDEVICE_FIND_COMPONENTS_FAMILIES "")
foreach(COMP ${USBDEVICE_FIND_COMPONENTS})
    string(TOLOWER ${COMP} COMP_L)
    string(TOUPPER ${COMP} COMP_U)

    string(REGEX MATCH "^STM32([FGHLUW][0-9BL])([0-9A-Z][0-9M][A-Z][0-9A-Z])?_?(M0PLUS|M4|M7)?.*$" COMP_U ${COMP_U})
    if(CMAKE_MATCH_1)
        list(APPEND USBDEVICE_FIND_COMPONENTS_FAMILIES ${COMP})
        message(TRACE "FindUSBDevice: append COMP ${COMP} to USBDEVICE_FIND_COMPONENTS_FAMILIES")
        continue()
    endif()
    if(${COMP} IN_LIST USBDEVICE_COMPONENTS_CLASS)
        list(APPEND USBDEVICE_FIND_COMPONENTS_CLASS ${COMP})
        message(TRACE "FindUSBDevice: append COMP ${COMP} to USBDEVICE_FIND_COMPONENTS_CLASS")
        continue()
    endif()
    message(FATAL_ERROR "FindUSBDevice: unknown component: ${COMP}")
endforeach()

message(STATUS "FindUSBDevice Search for HAL families: ${USBDEVICE_FIND_COMPONENTS_FAMILIES}")

SET(USBDEVICE_SRC
    Core/Src/usbd_ctlreq.c
    Core/Src/usbd_core.c
    Core/Src/usbd_ioreq.c
#    Core/Src/usbd_conf_template.c
)

SET(USBDEVICE_INC
    Core/Inc/usbd_ctlreq.h
    Core/Inc/usbd_ioreq.h
    Core/Inc/usbd_core.h
#    Core/Inc/usbd_conf_template.h
    Core/Inc/usbd_def.h
)



SET(USBDEVICE_COMPONENTS_CLASS_CDC_HEADERS
    Class/CDC/Inc/usbd_cdc.h
#    Class/CDC/Inc/usbd_cdc_if_template.h
)
SET(USBDEVICE_COMPONENTS_CLASS_CDC_SOURCES
    Class/CDC/Src/usbd_cdc.c
#    Class/CDC/Src/usbd_cdc_if_template.c
)

SET(USBDEVICE_COMPONENTS_CLASS_DFU_HEADERS
#    Class/DFU/Inc/usbd_dfu_media_template.h
    Class/DFU/Inc/usbd_dfu.h
)
SET(USBDEVICE_COMPONENTS_CLASS_DFU_SOURCES
    Class/DFU/Src/usbd_dfu.c
#    Class/DFU/Src/usbd_dfu_media_template.c
)

SET(USBDEVICE_COMPONENTS_CLASS_AUDIO_HEADERS
    Class/AUDIO/Inc/usbd_audio.h
#    Class/AUDIO/Inc/usbd_audio_if_template.h
)
SET(USBDEVICE_COMPONENTS_CLASS_AUDIO_SOURCES
#    Class/AUDIO/Src/usbd_audio_if_template.c
    Class/AUDIO/Src/usbd_audio.c
)

SET(USBDEVICE_COMPONENTS_CLASS_Template_HEADERS
    Class/Template/Inc/usbd_template.h
)
SET(USBDEVICE_COMPONENTS_CLASS_Template_SOURCES
    Class/Template/Src/usbd_template.c
)

SET(USBDEVICE_COMPONENTS_CLASS_MSC_HEADERS
    Class/MSC/Inc/usbd_msc_scsi.h
#    Class/MSC/Inc/usbd_msc_storage_template.h
    Class/MSC/Inc/usbd_msc_data.h
    Class/MSC/Inc/usbd_msc.h
    Class/MSC/Inc/usbd_msc_bot.h
)
SET(USBDEVICE_COMPONENTS_CLASS_MSC_SOURCES
    Class/MSC/Src/usbd_msc.c
    Class/MSC/Src/usbd_msc_data.c
    Class/MSC/Src/usbd_msc_bot.c
    Class/MSC/Src/usbd_msc_scsi.c
#    Class/MSC/Src/usbd_msc_storage_template.c
)

SET(USBDEVICE_COMPONENTS_CLASS_HID_HEADERS
    Class/HID/Inc/usbd_hid.h
)
SET(USBDEVICE_COMPONENTS_CLASS_HID_SOURCES
    Class/HID/Src/usbd_hid.c
)

SET(USBDEVICE_COMPONENTS_CLASS_CustomHID_HEADERS
#    Class/CustomHID/Inc/usbd_customhid_if_template.h
    Class/CustomHID/Inc/usbd_customhid.h
)
SET(USBDEVICE_COMPONENTS_CLASS_CustomHID_SOURCES
    Class/CustomHID/Src/usbd_customhid.c
#    Class/CustomHID/Src/usbd_customhid_if_template.c
)

IF(NOT USBDEVICE_FIND_COMPONENTS)
    SET(USBDEVICE_FIND_COMPONENTS ${USBDEVICE_COMPONENTS_CLASS})
    MESSAGE(STATUS "No USBDevice components selected, using all: ${USBDEVICE_COMPONENTS_CLASS}")
ENDIF()

FOREACH(cmp ${USBDEVICE_FIND_COMPONENTS_CLASS})
    LIST(FIND USBDEVICE_COMPONENTS_CLASS ${cmp} USBDEVICE_FOUND_INDEX)
    IF(${USBDEVICE_FOUND_INDEX} LESS 0)
        MESSAGE(FATAL_ERROR "Unknown USBDevice component: ${cmp}. Available components: ${USBDevice_COMPONENTS}")
    ENDIF()
    LIST(FIND USBDEVICE_COMPONENTS_CLASS ${cmp} USBDEVICE_FOUND_INDEX)
    IF(NOT (${USBDEVICE_FOUND_INDEX} LESS 0))
        LIST(APPEND USBDEVICE_INC ${USBDEVICE_COMPONENTS_CLASS_${cmp}_HEADERS})
        LIST(APPEND USBDEVICE_SRC ${USBDEVICE_COMPONENTS_CLASS_${cmp}_SOURCES})
    ENDIF()
ENDFOREACH()

list(REMOVE_DUPLICATES USBDEVICE_INC)
list(REMOVE_DUPLICATES USBDEVICE_SRC)
foreach(COMP ${USBDEVICE_FIND_COMPONENTS_FAMILIES})

    set(USBDEVICE_SOURCES "")
    set(USBDEVICE_INCLUDE_DIR "")


    string(TOUPPER ${COMP} COMP_U)

    string(REGEX MATCH "^STM32([FGHLUW][0-9BL])([0-9A-Z][0-9M][A-Z][0-9A-Z])?_?(M0PLUS|M4|M7)?.*$" COMP_U ${COMP_U})
    if(CMAKE_MATCH_3)
        set(CORE ${CMAKE_MATCH_3})
        set(CORE_C "::${CORE}")
        set(CORE_U "_${CORE}")
    else()
        unset(CORE)
        unset(CORE_C)
        unset(CORE_U)
    endif()

    set(FAMILY ${CMAKE_MATCH_1})
    string(TOLOWER ${FAMILY} FAMILY_L)
    find_path(HAL_${FAMILY}_PATH
        NAMES Inc/stm32${FAMILY_L}xx_hal.h
        PATHS "${STM32_HAL_${FAMILY}_PATH}" "${STM32_CUBE_${FAMILY}_PATH}/Drivers/STM32${FAMILY}xx_HAL_Driver"
        NO_DEFAULT_PATH
    )
    if (NOT HAL_${FAMILY}_PATH)
        message(DEBUG "Missing HAL_${FAMILY}_PATH path")
        continue()
    endif()
    SET(STM32_CUBE_USB_DEVICE_PATH ${STM32_CUBE_${FAMILY}_PATH}/Middlewares/ST/STM32_USB_Device_Library)
    foreach(INC ${USBDEVICE_INC})
        set(INC_FILE INC_FILE-NOTFOUND)
        get_filename_component(INC_FILE ${STM32_CUBE_USB_DEVICE_PATH}/${INC} DIRECTORY)
        message(TRACE "Found ${INC}: ${INC_FILE}")
        list(APPEND USBDEVICE_INCLUDE_DIR ${INC_FILE})
        endforeach()
    list(REMOVE_DUPLICATES USBDEVICE_INCLUDE_DIR)


    foreach(SRC ${USBDEVICE_SRC})
        set(SRC_FILE SRC_FILE-NOTFOUND)
        find_file(SRC_FILE ${SRC}
            HINTS ${STM32_CUBE_USB_DEVICE_PATH}/
            CMAKE_FIND_ROOT_PATH_BOTH
        )
        message(TRACE "Found ${SRC}: ${SRC_FILE}")
        list(APPEND USBDEVICE_SOURCES ${SRC_FILE})
        endforeach()

    message(STATUS "FindUSBDevice: creating library USBDEVICE::${FAMILY}")
    add_library(USBDEVICE::${FAMILY} INTERFACE IMPORTED)
    target_include_directories(USBDEVICE::${FAMILY} INTERFACE "${USBDEVICE_INCLUDE_DIR}")
    target_sources(USBDEVICE::${FAMILY} INTERFACE "${USBDEVICE_SOURCES}")
endforeach()

include(FindPackageHandleStandardArgs)

find_package_handle_standard_args(USBDEVICE DEFAULT_MSG USBDEVICE_INCLUDE_DIR USBDEVICE_SOURCES)

