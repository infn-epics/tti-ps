#!../../bin/linux-x86_64/streamdeviceSample

< envPaths


epicsEnvSet("IOC","streamdeviceSample")
epicsEnvSet("TOP","/app/TTI-magnets-")
epicsEnvSet("EPICS_BASE","/epics/epics-base")
epicsEnvSet("ASYN","/epics/support/asyn")
epicsEnvSet("CALC","/epics/support/calc")
epicsEnvSet("SUPPORT","/epics/support")
epicsEnvSet("STREAMDEVICE","/epics/support/StreamDevice")

epicsEnvSet("STREAM_PROTOCOL_PATH", "$(TOP)/db")

cd "$(TOP)"

dbLoadDatabase "dbd/streamdeviceSample.dbd"
streamdeviceSample_registerRecordDeviceDriver pdbbase

drvAsynIPPortConfigure("TTI1", "192.168.197.125:4001", 0, 0, 0)

asynSetOption("TTI1", 0, "disconnectOnReadTimeout", "Y")

dbLoadRecords("db/TTI.template", "P=SPARC:,R=TTI:,PORT=TTI1")

cd "$(TOP)/iocBoot/$(IOC)"

iocInit
epicsThreadSleep 1
dbl 
