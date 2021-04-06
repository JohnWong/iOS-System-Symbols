#! /bin/bash
#
# Extract symbol
# Argument path should not contain any white space.
#
# How to use:
# sh extract.sh <path_to_ipsw_file> <path_to_extracted_arm64_symbols>
#

if [ $# != 2 ] ; then
	echo "Usage: \nsh extract.sh <path_to_ipsw_file> <path_to_extracted_arm64_symbols>"
	exit 1
fi

ipsw=$1
output=$2

temppath="/tmp/extract_symbol"
rm -rf temppath
mkdir -p temppath
unzip "$ipsw" -d "$temppath"

version=$(/usr/libexec/PlistBuddy -c "Print :ProductVersion" "$temppath/Restore.plist")
code=$(/usr/libexec/PlistBuddy -c "Print :ProductBuildVersion" "$temppath/Restore.plist")
dmg=$(/usr/libexec/PlistBuddy -c "Print :SystemRestoreImageFileSystems" "$temppath/Restore.plist" | grep = | tr -d ' ' | cut -d= -f1)
echo "$version $code $dmg"

mountresult=$(hdiutil attach "$temppath/$dmg" | grep "/Volumes")
mountid=$(echo "$mountresult" | cut -d$'\t' -f1 | tr -d ' ')
mounted=$(echo "$mountresult" | rev | cut -d$'\t' -f1 | rev)
echo "$mountid $mounted"

# Extract symbol
dyldpath="$mounted/System/Library/Caches/com.apple.dyld/"
for i in $(ls "$dyldpath"); do
	echo $i
	arch=$(echo $i | rev | cut -d_ -f1 | rev)
	symdir="$version ($code) $arch"
	echo $symdir
	sympath="$output/$symdir/Symbols"
	echo "$sympath"
	mkdir -p "$sympath"

	./dsc_extractor "$dyldpath/$i" "$sympath"

	# 补充dyld源文件
	symdyld="$sympath/System/Library/Caches/com.apple.dyld"
	mkdir -p "$symdyld"
	echo "$symdyld"
	cp "$dyldpath/$i" "$symdyld"
done

# Unmount
hdiutil detach "$mountid"


rm -rf "$temppath"



