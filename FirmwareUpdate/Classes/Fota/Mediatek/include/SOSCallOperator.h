//
//  SOSCallOperator.h
//  MtkBleManager
//
//  Created by user on 15-1-22.
//  Copyright (c) 2015年 ___MTK___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SOSContact.h"

static const int CMD_TYPE_RESPONSE_ERROR = 0x11;
static const int CMD_TYPE_SUPPORT_INDICATION = 0x12;
static const int CMD_TYPE_RESPONSE_READ_NUM_NAME = 0X13;
static const int CMD_TYPE_RESPONSE_WRITE_NUM_NAME = 0x14;

static const int CMD_TYPE_REQUEST_READ = 0x03;
static const int CMD_TYPE_REQUEST_WRITE = 0x04;

//error response code
static const int ERR_UNKNOWN_CMD            = 0x01;
static const int ERR_INVALID_VALUE          = 0X02;
static const int ERR_INVALID_KEY            = 0x03;
static const int ERR_INVALID_VALUE_LENTH    = 0x04;
static const int ERR_SOSLIST_FULL           = 0x05;
static const int ERR_INVALID_PDU            = 0x06;

//read request/response value flag
static const int READ_VALUE_FLAG_NUM        = 0x01;
static const int READ_VALUE_FLAG_NAME       = 0x02;
static const int READ_VALUE_FLAG_MODE       = 0x03;
static const int READ_VALUE_FLAG_REPTIMES   = 0x04;

//write type
static const int WRITE_TYPE_ADD     = 0x00;
static const int WRITE_TYPE_MODIFY  = 0x01;
static const int WRITE_TYPE_DELETE  = 0x02;

//call mode
static const int CALL_MODE_AUTO = 0;
static const int CALL_MODE_MANUAL = 1;

/*!
 The delegate of SOSCallOperator object should adopt the SOSCallDataDelegate protocol.
 The delegate uses this protocol's method to monitor the indication and response from remote BLE device.
 */
@protocol SOSCallDataDelegate <NSObject>

/*!
 This method is invoked after GATT is connected and handshake for DOGP is done.
 Remote BLE device will report some information automatically through this method.
 
 
 @param keyCout   The hardware key count for SOS call supported by remote BLE device.
 @param indexC    the index count under every hardware key
 @param modeValue Call mode saved in remote BLE device
 @param repTimes  Repeate times saved in remote BLE device
 */
- (void)onIndication: (int)keyCout indexCount: (int)indexC mode: (int)modeValue repeatTimes: (int)repTimes;

/*!
 Invoked after you retrieve contact information from remote BLE device.
 NOTE: If some contacts already exist in remote BLE device, this method will also be invoke to report the contact information without calling  <code>sendReadContact:index:</code>
 
 @param keyId     Key ID
 @param index     Index ID
 @param nameVal   contact name saved in remote BLE device
 @param numberVal contact phone number saved in remote BLE device
 */
- (void)onReadNameNumber: (int)keyId indexId: (int)index name: (NSString *)nameVal number: (NSString *)numberVal;

/*!
 Invoked after you retrieve call mode from remote BLE device
 
 @param keyId   Key ID
 @param index   Index ID
 @param modeVal call mode returned from remote BLE device
 */
- (void)onReadMode: (int)keyId indexId: (int)index mode: (int)modeVal;

/*!
 Invoked after you retrieve repeate times from remote BLE device
 
 @param keyId       Key ID
 @param index       Key ID
 @param repTimesVal Repeate times return from remote BLE device
 */
- (void)onReadRepTimes: (int)keyId indexId: (int)index repTimes: (int)repTimesVal;

/*!
 Invoked after connect state changes
 
 @param state current connect state after change.
 <code>
 0: DISCONNECTED
 2: CONNECTED
 </code>
 */
- (void)onConnectStateChange: (int)state;

/*!
 Invoked after you write contact/mode/repeate time to remote BLE device successfully
 
 @param cmdLabel      Reserved for future use
 @param type          The write type parameter for the write command which triggers this callback.
 @param keyIdVal      The Key ID parameter for the write command which triggers this callback.
 @param indexIdVal    The Index ID parameter for the write command which triggers this callback.
 @param valueTagArray The tag array shows the value which is wrote/updated successfully to remote BLE device.
 tag:
 <code>
 0x01: contact number
 0x02: contact name
 0x03: call mode
 0x04: repeate times
 </code>
 */
- (void)onWriteCallBack: (int)cmdLabel writeType: (int)type keyId: (int)keyIdVal indexId: (int)indexIdVal valueTag: (NSArray *)valueTagArray;
@end

@interface SOSCallOperator : NSObject

/*!
 If the default object does not exists yet, it is created.
 
 @return Returns the defaults object.
 */
+ (id)getSosCallOperaterInstance;

- (void)registerSOSCallDelegate: (id<SOSCallDataDelegate>)delegate;
- (void)unRegisterSOSCallDelegate: (id<SOSCallDataDelegate>)delegate;


/*!
 Set contact info including name and phone number to remote BLE device.
 When it sets contacts successfully to remote device, it calls <code>onWriteCallBack</code> method of its delegate.
 
 @param keyId      the key ID which is to be set
 @param indexId    the index ID belongs to the key which is to be set
 @param contactVal the contact value
 @param updateType should be <code>WRITE_TYPE_ADD</code>, <code>WRITE_TYPE_MODIFY</code> or <code>WRITE_TYPE_DELETE</code>
 */
- (void)setContact: (int)keyId index: (int)indexId contact: (SOSContact *)contactVal updateType: (int)updateType;

/*!
 Set only contact name to remote BLE device.
 When it sets contact name successfully to remote device, it calls <code>onWriteCallBack</code> method of its delegate.
 
 @param keyId   the key ID which is to be set
 @param indexId the index ID belongs to the key which is to be set
 @param nameVal contact name
 @param type    should be <code>WRITE_TYPE_ADD</code>, <code>WRITE_TYPE_MODIFY</code> or <code>WRITE_TYPE_DELETE</code>
 */
-(void)sendWriteContactName: (int)keyId index: (int)indexId name: (NSString *)nameVal updateType: (int)type;

/*!
 Set only contact phone number to remote BLE device.
 When it sets contact phone number successfully to remote device, it calls <code>onWriteCallBack</code> method of its delegate.
 
 @param keyId   the key ID which is to be set
 @param indexId the index ID belongs to the key which is to be set
 @param numVal  contact phone number
 @param type    should be <code>WRITE_TYPE_ADD</code>, <code>WRITE_TYPE_MODIFY</code> or <code>WRITE_TYPE_DELETE</code>
 */
- (void)sendWriteContactNumber: (int)keyId index: (int)indexId number: (NSString *)numVal updateType: (int)type;

/*!
 Retrieves contact info from remote BLE device.
 The delegate <code>onReadNameNumber</code> will be called if get contact successfully
 
 @param keyId   Key ID
 @param indexId Index ID
 */
- (void)sendReadContact: (int)keyId index: (int)indexId;

/*!
 Delete contact at remote BLE device.
 When it deletes contact successfully in remote device, it calls <code>onWriteCallBack</code> method of its delegate.
 
 @param keyId   Key ID
 @param indexId Index ID
 */
- (void)sendDeleteContact: (int)keyId index: (int)indexId;

/*!
 Set call mode to remote BLE device.
 When it writes call mode successfully to remote device, it calls <code>onWriteCallBack</code> method of its delegate.
 
 @param keyId   Key ID
 @param indexId Index ID
 @param modeVal call mode value which is to be set
 */
- (void)sendWriteMode: (int)keyId index: (int)indexId mode: (int)modeVal;

/*!
 Retrieves call mode from remote BLE  device
 The delegate <code>onReadMode</code> will be called if get contact successfully
 
 @param keyId   Key ID
 @param indexId Index ID
 */
- (void)sendReadMode: (int)keyId index: (int)indexId;

/*!
 Set Repeat Times to remote BLE device.
 When it sets repeate times successfully to remote device, it calls <code>onWriteCallBack</code> method of its delegate.
 
 @param keyId       Key ID
 @param indexId     Index ID
 @param repTimesVal Repeat times which to be set
 */
- (void)sendWriteRepeatTime: (int)keyId index: (int)indexId repeat: (int)repTimesVal;

/*!
 Retrieves Repeat times from remote BLE device.
 The delegate <code>onReadRepTimes</code> will be called if get contact successfully
 
 @param keyId   Key ID
 @param indexId Index ID
 */
- (void)sendReadRepeatTime: (int)keyId index: (int)indexId;

@end
