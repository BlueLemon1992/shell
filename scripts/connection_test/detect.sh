#!/bin/bash

function connectionDetect()
{
    for URL in $(cat "${connectionURLTmpFile}" | sort | uniq)
    do
        echo -n "${URL};" >> "${resultFile}";
        echo -n "[$(date)] : " | tee -a "${logFile}";
        echo "${URL}" | tee -a "${logFile}";
        sleep 1 | /opt/sfw/bin/curl "${URL}" --connect-timeout "${timeOutSec}" | tee -a "${logFile}" 2>&1;
        retCode=$?;
        if [[ "X${retCode}" == "X0" ]];then
            echo -n "Y;${retCode};" >> "${resultFile}";
        else
            echo -n "N;${retCode};" >> "${resultFile}";
        fi
        for agr in $(fgrep "|${URL}" "${agreementURLMap}" | cut -d \| -f1)
        do
            echo -n "${agr}|" >> "${resultFile}";
        done
        echo >> "${resultFile}";
    done
}

server=$1;
timeOutSec=5;
logFile="$(dirname $0)/log.${server}.$(date "+%Y%m%d%H%M%S")";
resultFile="${server}.csv";
echo "FTP_URL;Result;RetCode;Agreement" > ${resultFile};
connectionURLTmpFile="${server}.url";
agreementURLMap="${server}.map"
connectionDetect;
