//
//  Defines_h
//  SUOTA
//
//  Created by Martijn Houtman on 02/10/14_
//  Copyright (c) 2014 Martijn Houtman_ All rights reserved_
//

#ifndef SUOTA_Defines_h
#define SUOTA_Defines_h

typedef enum {
    SUOTA,
    SPOTA
} TYPE_SUOTA_OR_SPOTA;

typedef enum {
    MEM_TYPE_SUOTA_I2C            = 0x12,
    MEM_TYPE_SUOTA_SPI            = 0x13,
    MEM_TYPE_SPOTA_SYSTEM_RAM     = 0x00,
    MEM_TYPE_SPOTA_RETENTION_RAM  = 0x01,
    MEM_TYPE_SPOTA_I2C            = 0x02,
    MEM_TYPE_SPOTA_SPI            = 0x03
} MEM_TYPE;

typedef enum {
    MEM_BANK_OLDEST = 0,
    MEM_BANK_1      = 1,
    MEM_BANK_2      = 2,
} MEM_BANK;

typedef enum {
    P0_0 = 0x00,
    P0_1 = 0x01,
    P0_2 = 0x02,
    P0_3 = 0x03,
    P0_4 = 0x04,
    P0_5 = 0x05,
    P0_6 = 0x06,
    P0_7 = 0x07,
    P1_0 = 0x10,
    P1_1 = 0x11,
    P1_2 = 0x12,
    P1_3 = 0x13,
    P2_0 = 0x20,
    P2_1 = 0x21,
    P2_2 = 0x22,
    P2_3 = 0x23,
    P2_4 = 0x24,
    P2_5 = 0x25,
    P2_6 = 0x26,
    P2_7 = 0x27,
    P2_8 = 0x28,
    P2_9 = 0x29,
    P3_0 = 0x30,
    P3_1 = 0x31,
    P3_2 = 0x32,
    P3_3 = 0x33,
    P3_4 = 0x34,
    P3_5 = 0x35,
    P3_6 = 0x36,
    P3_7 = 0x37
} GPIO;

typedef enum {
    // Value zero must not be used !! Notifications are sent when status changes.
    SPOTAR_SRV_STARTED      = 0x01,     // Valid memory device has been configured by initiator. No sleep state while in this mode
    SPOTAR_CMP_OK           = 0x02,     // SPOTA process completed successfully.
    SPOTAR_SRV_EXIT         = 0x03,     // Forced exit of SPOTAR service.
    SPOTAR_CRC_ERR          = 0x04,     // Overall Patch Data CRC failed
    SPOTAR_PATCH_LEN_ERR    = 0x05,     // Received patch Length not equal to PATCH_LEN characteristic value
    SPOTAR_EXT_MEM_WRITE_ERR= 0x06,     // External Mem Error (Writing to external device failed)
    SPOTAR_INT_MEM_ERR      = 0x07,     // Internal Mem Error (not enough space for Patch)
    SPOTAR_INVAL_MEM_TYPE   = 0x08,     // Invalid memory device
    SPOTAR_APP_ERROR        = 0x09,     // Application error
    
    // SUOTAR application specific error codes
    SPOTAR_IMG_STARTED      = 0x10,     // SPOTA started for downloading image (SUOTA application)
    SPOTAR_INVAL_IMG_BANK   = 0x11,     // Invalid image bank
    SPOTAR_INVAL_IMG_HDR    = 0x12,     // Invalid image header
    SPOTAR_INVAL_IMG_SIZE   = 0x13,     // Invalid image size
    SPOTAR_INVAL_PRODUCT_HDR= 0x14,     // Invalid product header
    SPOTAR_SAME_IMG_ERR     = 0x15,     // Same Image Error
    SPOTAR_EXT_MEM_READ_ERR = 0x16,     // Failed to read from external memory device
    
} SPOTA_STATUS_VALUES;

#define SPOTA_SERVICE_UUID     0xFEF5
#define SPOTA_MEM_DEV_UUID     @"8082CAA8-41A6-4021-91C6-56F9B954CC34"
#define SPOTA_GPIO_MAP_UUID    @"724249F0-5EC3-4B5F-8804-42345AF08651"
#define SPOTA_MEM_INFO_UUID    @"6C53DB25-47A1-45FE-A022-7C92FB334FD4"
#define SPOTA_PATCH_LEN_UUID   @"9D84B9A3-000C-49D8-9183-855B673FDA31"
#define SPOTA_PATCH_DATA_UUID  @"457871E8-D516-4CA1-9116-57D0B17B9CB2"
#define SPOTA_SERV_STATUS_UUID @"5F78DF94-798C-46F5-990A-B3EB6A065C88"

#define HOMEKIT_UUID                                                0xFED4

#define ORG_BLUETOOTH_SERVICE_DEVICE_INFORMATION                    0x180A
#define ORG_BLUETOOTH_CHARACTERISTIC_MANUFACTURER_NAME_STRING       0x2A29
#define ORG_BLUETOOTH_CHARACTERISTIC_MODEL_NUMBER_STRING            0x2A24
#define ORG_BLUETOOTH_CHARACTERISTIC_SERIAL_NUMBER_STRING           0x2A25
#define ORG_BLUETOOTH_CHARACTERISTIC_HARDWARE_REVISION_STRING       0x2A27
#define ORG_BLUETOOTH_CHARACTERISTIC_FIRMWARE_REVISION_STRING       0x2A26
#define ORG_BLUETOOTH_CHARACTERISTIC_SOFTWARE_REVISION_STRING       0x2A28
#define ORG_BLUETOOTH_CHARACTERISTIC_SYSTEM_ID                      0x2A23
#define ORG_BLUETOOTH_CHARACTERISTIC_IEEE_11073                     0x2A2A
#define ORG_BLUETOOTH_CHARACTERISTIC_PNP_ID                         0x2A50

#define ORG_BLUETOOTH_SERVICE_HEALTH_THERMOMETER                    0x1809

#define ORG_BLUETOOTH_SERVICE_ALERT_LEVEL                           0x2A06

#define ORG_BLUETOOTH_SERVICE_IMMEDIATE_ALERT                       0x1802
#define ORG_BLUETOOTH_SERVICE_LINK_LOSS                             0x1803
#define ORG_BLUETOOTH_SERVICE_TX_POWER                              0x1804

#define ORG_BLUETOOTH_SERVICE_BATTERY_SERVICE                       0x180F
#define ORG_BLUETOOTH_SERVICE_BATTERY_LEVEL                         0x2A19

#endif
