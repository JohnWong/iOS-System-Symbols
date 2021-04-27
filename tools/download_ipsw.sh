#! /bin/bash
#
# Extract symbol
# Argument path should not contain any white space.
#
# How to use:
# sh extract.sh <path_to_ipsw_file> <path_to_extracted_arm64_symbols>
#

if [ $# != 2 ] ; then
	echo "Usage: \nsh download_ipsw.sh model code \neg: sh download_ipsw.sh iPhone8,1 18B92"
	exit 1
fi

model=$1
buildid=$2

temppath="/tmp/ipsw"
mkdir -p "$temppath"
ipsw="$temppath/$buildid.ipsw"

# https://ipswdownloads.docs.apiary.io/#reference/api/ipswdownloadidentifierbuildid/v-4-.-download-ipsw


curl -L "https://api.ipsw.me/v4/ipsw/download/$model/$buildid" > "$ipsw"
unzip "$ipsw" -d "$temppath"

# version=$(/usr/libexec/PlistBuddy -c "Print :ProductVersion" "$temppath/Restore.plist")
# code=$(/usr/libexec/PlistBuddy -c "Print :ProductBuildVersion" "$temppath/Restore.plist")
# dmg=$(/usr/libexec/PlistBuddy -c "Print :SystemRestoreImageFileSystems" "$temppath/Restore.plist" | grep = | tr -d ' ' | cut -d= -f1)
# echo "$version $code $dmg"

# mountresult=$(hdiutil attach "$temppath/$dmg" | grep "/Volumes")
# mountid=$(echo "$mountresult" | cut -d$'\t' -f1 | tr -d ' ')
# mounted=$(echo "$mountresult" | rev | cut -d$'\t' -f1 | rev)
# echo "$mountid $mounted"

# # Extract symbol
# dyldpath="$mounted/System/Library/Caches/com.apple.dyld/"
# for i in $(ls "$dyldpath"); do
# 	echo $i
# 	arch=$(echo $i | rev | cut -d_ -f1 | rev)
# 	if [[ "$arch" == "arm64e" ]]; then
# 		symdir="$version ($code) arm64e"
# 	else
# 		symdir="$version ($code)"
# 	fi
# 	echo $symdir
# 	sympath="$output/$symdir/Symbols"
# 	echo "$sympath"
# 	mkdir -p "$sympath"

# 	./dsc_extractor "$dyldpath/$i" "$sympath"

# 	# 补充dyld源文件
# 	symdyld="$sympath/System/Library/Caches/com.apple.dyld"
# 	mkdir -p "$symdyld"
# 	echo "$symdyld"
# 	cp "$dyldpath/$i" "$symdyld"
# 	touch "$symdyld/.copied_$i"
# 	touch "$symdyld/.processed_$i"
# done

# # Unmount
# hdiutil detach "$mountid"


# rm -rf "$temppath"





