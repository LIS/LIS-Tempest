#!/bin/bash

# Copyright 2014 Cloudbase Solutions Srl
#
#    Licensed under the Apache License, Version 2.0 (the "License"); you may
#    not use this file except in compliance with the License. You may obtain
#    a copy of the License at
#
#         http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
#    WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
#    License for the specific language governing permissions and limitations
#    under the License.

ICA_TESTRUNNING="TestRunning"
ICA_TESTCOMPLETED="TestCompleted"
ICA_TESTABORTED="TestAborted"
ICA_TESTFAILED="TestFailed"

LogMsg()
{
    echo `date "+%a %b %d %T %Y"` $1   # To add the timestamp to the log file
}

UpdateTestState()
{
    echo $1
    # > ~/state.txt
}

# adding check for summary.log
if [ -e ~/summary.log ]; then
    LogMsg "Cleaning up previous copies of summary.log"
    rm -rf ~/summary.log
fi

#
# Create the state.txt file so the ICA script knows
# we are running
#
# UpdateTestState $ICA_TESTRUNNING

# if [ -e ~/constants.sh ]; then
# 	. ~/constants.sh
# else
# 	LogMsg "ERROR: Unable to source the constants file."
# 	UpdateTestState "TestAborted"
# 	exit 1
# fi

# #Check for Testcase count
# if [ ! ${TC_COUNT} ]; then
#     LogMsg "The TC_COUNT variable is not defined."
# 	echo "The TC_COUNT variable is not defined." >> ~/summary.log
#     LogMsg "Terminating the test."
#     UpdateTestState "TestAborted"
#     exit 1
# fi

# echo "Covers : ${TC_COUNT}" >> ~/summary.log

### Display info on the Hyper-V modules that are loaded ###

#
# Get the modules tree
#
MODULES=~/modules.txt
lsmod | grep hv_ > $MODULES


#
# Did VMBus load
#
LogMsg "Checking if VMBus loaded"

grep -q "vmbus" $MODULES
if [ $? -ne 0 ]; then
    msg="Vmbus not loaded"
    LogMsg "Error: ${msg}"
    echo $msg >> ~/summary.log
    UpdateTestState $ICA_TESTFAILED
    exit 20
fi

#
# Did storvsc load
#
LogMsg "Checking if storvsc loaded"

grep -q "storvsc" $MODULES
if [ $? -ne 0 ]; then
    msg="storvsc not loaded"
    LogMsg "Error: ${msg}"
    echo $msg >> ~/summary.log
    UpdateTestState $ICA_TESTFAILED
    exit 30
fi


# Did netvsc load
#
LogMsg "Checking if netvsc loaded"

grep -q "netvsc" $MODULES
if [ $? -ne 0 ]; then
    msg="netvsc not loaded"
    LogMsg "Error: ${msg}"
    echo $msg >> ~/summary.log
    UpdateTestState $ICA_TESTFAILED
    exit 30
fi


#
# Did utils load
#
LogMsg "Checking if utils loaded"

grep -q "utils" $MODULES
if [ $? -ne 0 ]; then
    msg="utils not loaded"
    LogMsg "Error: ${msg}"
    echo $msg >> ~/summary.log
    UpdateTestState $ICA_TESTFAILED
    exit 30
fi


#
# Is boot disk under LIS control
#
#DMESGBOOT=/var/log/boot.log
LogMsg "Checking if boot device is under LIS control"

dmesg | grep -q "sda: sda1 sda2"
if [ $? -ne 0 ]; then
    msg="Boot disk not controlled by LIS"
    LogMsg "Error: ${msg}"
    echo $msg >> ~/summary.log
    UpdateTestState $ICA_TESTFAILED
    exit 70
fi

#
# If we got here, all tests passed
#
echo "LIS modules verified" >> ~/summary.log
LogMsg "Updating test case state to completed"

UpdateTestState $ICA_TESTCOMPLETED

exit 0
