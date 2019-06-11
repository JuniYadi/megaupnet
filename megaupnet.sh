#!/bin/bash
# @Description: megaup.net file download script
# @Author: Juni Yadi
# @URL: https://github.com/JuniYadi/megaupnet
# @Version: 201906111948
# @Date: 2019-06-11
# @Usage: ./megaup.sh url

if [ -z "${1}" ]
then
    echo "usage: ${0} url"
    echo "batch usage: ${0} url-list.txt"
    echo "url-list.txt is a file that contains one megaup.net url per line"
    exit
fi

function megaupdownload()
{
    prefix="$( echo -n "${url}" | cut -d'/' -f4 )"
    cookiefile="/tmp/${prefix}-cookie.tmp"
    infofile="/tmp/${prefix}-info.tmp"
    infourl="/tmp/${prefix}-infourl.tmp"
    agent="Mozilla/5.0 (Windows NT 6.3; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/70.0.3538.102 Safari/537.36"

    # loop that makes sure the script actually finds a filename
    filename=""
    retry=0
    while [ -z "${filename}" -a ${retry} -lt 10 ]
    do
        let retry+=1
        rm -f "${cookiefile}" 2> /dev/null
        rm -f "${infofile}" 2> /dev/null
        curl -s -c "${cookiefile}" -o "${infofile}" -L "${url}"

        filename="$( grep 'heading-1' "${infofile}" | cut -d'>' -f2 | sed 's/<\/div//' )"
    done

    if [ "${retry}" -ge 10 ]
    then
        echo "could not download file"
        exit 1
    fi

    if [ -f "${infofile}" ]
    then

        dlbutton=$( grep '.download-timer...html...a' "${infofile}" | cut -d'"' -f2 | sed 's/href/#/' | cut -d '#' -f2 | cut -d'>' -f1 | sed "s/='//" | sed "s/'//")

        sleep 5

        if [ "${dlbutton}" ]; then

            # GET Location Header
            infolocation=$( curl -s -I -b "$cookiefile" -o "$infourl" "$dlbutton" )
            getlocation=$( cat "${infourl}" | grep 'location:' | sed 's/location: //' | tr -d '\r' )

            if [ ! "${getlocation}" ]; then
                getlocation=$( cat "${infourl}" | grep 'Location:' | sed 's/Location: //' | tr -d '\r' )
            fi
        else
           echo "could not get megaup.net url algorithm"
           exit 1
        fi
        
    else
        echo "can't find info file for ${prefix}"
        exit 1
    fi

    dl=$( echo "${getlocation}" | cut -d' ' -f2)

    if [ -f "$filename" ]; then
        echo "[ERROR] File  Exist : $filename - ${url}"
    else
        echo "[INFO] Download File : $filename - ${url}"

        # Start download file
        curl -# -b "${cookiefile}" -C - "${dl}" -o "${filename}"
    fi

    rm -f "${cookiefile}" 2> /dev/null
    rm -f "${infofile}" 2> /dev/null
    rm -f "${infourl}" 2> /dev/null
}

if [ -f "${1}" ]
then
    for url in $( cat "${1}" | grep -i 'megaup.net' )
    do
        megaupdownload "${url}"
    done
else
    url="${1}"
    megaupdownload "${url}"
fi