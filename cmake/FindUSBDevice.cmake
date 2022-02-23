if((NOT STM32_CMSIS_${FAMILY}_PATH) AND (NOT STM32_CUBE_${FAMILY}_PATH) AND (DEFINED ENV{STM32_CUBE_${FAMILY}_PATH}))
# try to set path from environment variable. Note it could be ...-NOT-FOUND and it's fine
set(STM32_CUBE_${FAMILY}_PATH $ENV{STM32_CUBE_${FAMILY}_PATH} CACHE PATH "Path to STM32Cube${FAMILY}")
message(STATUS "ENV STM32_CUBE_${FAMILY}_PATH specified, using STM32_CUBE_${FAMILY}_PATH: ${STM32_CUBE_${FAMILY}_PATH}")
endif()

if((NOT STM32_CMSIS_${FAMILY}_PATH) AND (NOT STM32_CUBE_${FAMILY}_PATH))
set(STM32_CUBE_${FAMILY}_PATH /opt/STM32Cube${FAMILY} CACHE PATH "Path to STM32Cube${FAMILY}")
message(STATUS "Neither STM32_CUBE_${FAMILY}_PATH nor STM32_CMSIS_${FAMILY}_PATH specified using default STM32_CUBE_${FAMILY}_PATH: ${STM32_CUBE_${FAMILY}_PATH}")
endif()

SET(STM32_CUBE_USB_DEVICE_PATH ${STM32_CUBE_${FAMILY}_PATH}/Middlewares/ST/STM32_USB_Device_Library)

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

SET(USBDEVICE_COMPONENTS CDC DFU AUDIO Template MSC HID CustomHID)

SET(USBDEVICE_COMPONENTS_CDC_HEADERS
    Class/CDC/Inc/usbd_cdc.h
#    Class/CDC/Inc/usbd_cdc_if_template.h
)
SET(USBDEVICE_COMPONENTS_CDC_SOURCES
    Class/CDC/Src/usbd_cdc.c
#    Class/CDC/Src/usbd_cdc_if_template.c
)

SET(USBDEVICE_COMPONENTS_DFU_HEADERS
#    Class/DFU/Inc/usbd_dfu_media_template.h
    Class/DFU/Inc/usbd_dfu.h
)
SET(USBDEVICE_COMPONENTS_DFU_SOURCES
    Class/DFU/Src/usbd_dfu.c
#    Class/DFU/Src/usbd_dfu_media_template.c
)

SET(USBDEVICE_COMPONENTS_AUDIO_HEADERS
    Class/AUDIO/Inc/usbd_audio.h
#    Class/AUDIO/Inc/usbd_audio_if_template.h
)
SET(USBDEVICE_COMPONENTS_AUDIO_SOURCES
#    Class/AUDIO/Src/usbd_audio_if_template.c
    Class/AUDIO/Src/usbd_audio.c
)

SET(USBDEVICE_COMPONENTS_Template_HEADERS
    Class/Template/Inc/usbd_template.h
) 
SET(USBDEVICE_COMPONENTS_Template_SOURCES
    Class/Template/Src/usbd_template.c
)

SET(USBDEVICE_COMPONENTS_MSC_HEADERS
    Class/MSC/Inc/usbd_msc_scsi.h
#    Class/MSC/Inc/usbd_msc_storage_template.h
    Class/MSC/Inc/usbd_msc_data.h
    Class/MSC/Inc/usbd_msc.h
    Class/MSC/Inc/usbd_msc_bot.h
)
SET(USBDEVICE_COMPONENTS_MSC_SOURCES
    Class/MSC/Src/usbd_msc.c
    Class/MSC/Src/usbd_msc_data.c
    Class/MSC/Src/usbd_msc_bot.c
    Class/MSC/Src/usbd_msc_scsi.c
#    Class/MSC/Src/usbd_msc_storage_template.c
)

SET(USBDEVICE_COMPONENTS_HID_HEADERS
    Class/HID/Inc/usbd_hid.h
)
SET(USBDEVICE_COMPONENTS_HID_SOURCES
    Class/HID/Src/usbd_hid.c
)

SET(USBDEVICE_COMPONENTS_CustomHID_HEADERS
#    Class/CustomHID/Inc/usbd_customhid_if_template.h
    Class/CustomHID/Inc/usbd_customhid.h
)
SET(USBDEVICE_COMPONENTS_CustomHID_SOURCES
    Class/CustomHID/Src/usbd_customhid.c
#    Class/CustomHID/Src/usbd_customhid_if_template.c
)

IF(NOT USBDEVICE_FIND_COMPONENTS)
    SET(USBDEVICE_FIND_COMPONENTS ${USBDEVICE_COMPONENTS})
    MESSAGE(STATUS "No USBDevice components selected, using all: ${USBDevice_FIND_COMPONENTS}")
ENDIF()

FOREACH(cmp ${USBDEVICE_FIND_COMPONENTS})
    LIST(FIND USBDEVICE_COMPONENTS ${cmp} USBDEVICE_FOUND_INDEX)
    IF(${USBDEVICE_FOUND_INDEX} LESS 0)
        MESSAGE(FATAL_ERROR "Unknown USBDevice component: ${cmp}. Available components: ${USBDevice_COMPONENTS}")
    ENDIF()
    LIST(FIND USBDEVICE_COMPONENTS ${cmp} USBDEVICE_FOUND_INDEX)
    IF(NOT (${USBDEVICE_FOUND_INDEX} LESS 0))
        LIST(APPEND USBDEVICE_INC ${USBDEVICE_COMPONENTS_${cmp}_HEADERS})
        LIST(APPEND USBDEVICE_SRC ${USBDEVICE_COMPONENTS_${cmp}_SOURCES})
    ENDIF()
ENDFOREACH()

LIST(REMOVE_DUPLICATES USBDEVICE_INC)
LIST(REMOVE_DUPLICATES USBDEVICE_SRC)

FOREACH(INC ${USBDEVICE_INC})
    SET(INC_FILE INC_FILE-NOTFOUND)
    GET_FILENAME_COMPONENT(INC_FILE ${STM32_CUBE_USB_DEVICE_PATH}/${INC} DIRECTORY)
    MESSAGE(STATUS "Found ${INC}: ${INC_FILE}")
    LIST(APPEND USBDEVICE_INCLUDE_DIR ${INC_FILE})
ENDFOREACH()
LIST(REMOVE_DUPLICATES USBDEVICE_INCLUDE_DIR)

FOREACH(SRC ${USBDEVICE_SRC})
    SET(SRC_FILE SRC_FILE-NOTFOUND)
    FIND_FILE(SRC_FILE ${SRC}
        HINTS ${STM32_CUBE_USB_DEVICE_PATH}/
        CMAKE_FIND_ROOT_PATH_BOTH
    )
    MESSAGE(STATUS "Found ${SRC}: ${SRC_FILE}")
    LIST(APPEND USBDEVICE_SOURCES ${SRC_FILE})
ENDFOREACH()

message(TRACE "FindUSBDevice: creating library USBDEVICE")
add_library(USBDEVICE INTERFACE IMPORTED)
target_include_directories(USBDEVICE INTERFACE "${USBDEVICE_INCLUDE_DIR}")
target_sources(USBDEVICE INTERFACE "${USBDEVICE_SOURCES}")

INCLUDE(FindPackageHandleStandardArgs)

find_package_handle_standard_args(USBDEVICE DEFAULT_MSG USBDEVICE_INCLUDE_DIR USBDEVICE_SOURCES)
