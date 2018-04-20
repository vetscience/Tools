#!/bin/bash
sh /root/initReps.sh
RepeatModeler $@
cp /root/Libraries/* /var/spool/cwl/Libraries
