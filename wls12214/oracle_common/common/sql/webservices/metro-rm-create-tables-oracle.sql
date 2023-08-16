DROP TABLE RM_UNACKED_MESSAGES;
DROP TABLE RM_SEQUENCES;
DROP TABLE RM_LOCALIDS;

CREATE TABLE RM_SEQUENCES (
ENDPOINT_UID VARCHAR2(512) NOT NULL,
ID VARCHAR2(256) NOT NULL,
TYPE CHAR NOT NULL,
EXP_TIME NUMBER(19,0) NOT NULL,
BOUND_ID VARCHAR2(256),
STR_ID VARCHAR2(256),
STATUS NUMBER(5,0) NOT NULL,
ACK_REQUESTED_FLAG CHAR,
LAST_MESSAGE_NUMBER NUMBER(19,0) NOT NULL,
LAST_ACTIVITY_TIME NUMBER(19,0) NOT NULL,
LAST_ACK_REQUEST_TIME NUMBER(19,0) NOT NULL,
CONSTRAINT RM_SEQUENCES_PK PRIMARY KEY (ENDPOINT_UID, ID));

CREATE INDEX IDX_RM_SEQUENCES_BOUND_ID ON RM_SEQUENCES (BOUND_ID);

CREATE TABLE RM_UNACKED_MESSAGES (
ENDPOINT_UID VARCHAR2(512) NOT NULL,
SEQ_ID VARCHAR2(256) NOT NULL,
MSG_NUMBER NUMBER(19,0) NOT NULL,
IS_RECEIVED CHAR NOT NULL,
CORRELATION_ID VARCHAR2(256),
NEXT_RESEND_COUNT NUMBER(10,0),
WSA_ACTION VARCHAR2(256),
MSG_DATA BLOB,
CONSTRAINT RM_UNACKED_MESSAGES_PK PRIMARY KEY (ENDPOINT_UID, SEQ_ID, MSG_NUMBER));

ALTER TABLE RM_UNACKED_MESSAGES
ADD CONSTRAINT FK_SEQUENCE
FOREIGN KEY (ENDPOINT_UID, SEQ_ID) REFERENCES RM_SEQUENCES(ENDPOINT_UID, ID);

CREATE INDEX IDX_RM_UNACKED_MSGS_COR_ID ON RM_UNACKED_MESSAGES (CORRELATION_ID);

CREATE TABLE RM_LOCALIDS (
LOCAL_ID VARCHAR2(512) NOT NULL,
SEQ_ID VARCHAR2(256) NOT NULL,
MSG_NUMBER NUMBER(19,0) NOT NULL,
CREATE_TIME NUMBER(19,0),
SEQ_TERMINATE_TIME NUMBER(19,0),
CONSTRAINT RM_LOCALIDS_PK PRIMARY KEY (LOCAL_ID));

COMMIT;
