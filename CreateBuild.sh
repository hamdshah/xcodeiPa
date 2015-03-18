#!/bin/sh

#CreateBuild.sh
#
#created by Hamdullah shah on 25/09/2014.
#

[ "$#" -lt 3 ] && echo "Usage: CreateBuild.sh <Project_Path> <Target_Name> <Bundle_Identifier>" && exit

if [ -z "$1" ]; then
  echo "ERROR: Provide Xcode Project path to this script as first parameter."
  exit 1
fi

if [ -z "$2" ]; then
  echo "ERROR: Provide the target name as second parameter."
  exit 1
fi

if [ -z "$3" ]; then
  echo "ERROR: Provide the bundle identifier as third parameter."
  exit 1
fi

#Findin Prov Profile
PROJDIR="$1";

PROJECT_NAME="$2"

BUNDLE_ID="$3"

ARCHIVE_NAME="${PROJECT_NAME}.xcarchive"

cd "${HOME}/Library/MobileDevice/Provisioning Profiles/"

#finding prov profile for this specific game
for f in *.mobileprovision; 
do
 fileText=$(openssl asn1parse -inform DER -in $f | grep -A1 -w application-identifier | grep -A1 -w $BUNDLE_ID ;)
size=${#fileText};
if [ $size -gt 0 ]
then 
 fileText=$(openssl asn1parse -inform DER -in $f | grep -A1 -w Name | grep -A1 "<string>";)
 fileText="${fileText/<string>/}"
 fileText="${fileText/<\/string>/}"

FILE_NAME=$fileText

FILE_NAME="${FILE_NAME#"${FILE_NAME%%[![:space:]]*}"}"   
FILE_NAME="${FILE_NAME%"${FILE_NAME##*[![:space:]]}"}" 

echo "Profile Name $(tput bold)$(tput setaf 6)${FILE_NAME}$(tput sgr0)"
break;
fi
done

echo "$(tput bold)$(tput setaf 6)Building Project$(tput sgr0)"
cd "$PROJDIR"

xcodebuild -archivePath "${ARCHIVE_NAME}" -scheme "${PROJECT_NAME}" -sdk iphoneos -configuration "Release" archive

#Check if build succeeded
if [ $? != 0 ]
then
exit 1
fi

echo "$(tput bold)$(tput setaf 6)Delete old ipa if exist$(tput sgr0)"

rm "${PROJECT_NAME}.ipa";

echo "$(tput bold)$(tput setaf 6)Creating iPA $(tput sgr0)"

 xcodebuild -exportArchive -exportFormat IPA -archivePath "${ARCHIVE_NAME}" -exportPath "${PROJECT_NAME}.ipa" -exportProvisioningProfile "${FILE_NAME}"

open . 
