#! /bin/bash
#
# Extract symbol
# Argument path should not contain any white space.
#

if [ $# != 3 ] ; then
	echo "Usage: \nsymbol.sh <model> <code> <path_to_extracted_arm64_symbols>"
	exit 1
fi

model=$1
buildid=$2
output=$3

temppath="/tmp/extract_symbol"
ipsw="$temppath/$buildid.ipsw"

# curl -L "https://api.ipsw.me/v4/ipsw/download/$model/$buildid" > "$ipsw"

mkdir -p "$temppath"
unzip "$ipsw" -d "$temppath"

version=$(/usr/libexec/PlistBuddy -c "Print :ProductVersion" "$temppath/Restore.plist")
code=$(/usr/libexec/PlistBuddy -c "Print :ProductBuildVersion" "$temppath/Restore.plist")
dmg=$(/usr/libexec/PlistBuddy -c "Print :SystemRestoreImageFileSystems" "$temppath/Restore.plist" | grep = | tr -d ' ' | cut -d= -f1)
echo "$version $code $dmg"

mountresult=$(hdiutil attach "$temppath/$dmg" | grep "/Volumes")
mountid=$(echo "$mountresult" | cut -d$'\t' -f1 | tr -d ' ')
mounted=$(echo "$mountresult" | rev | cut -d$'\t' -f1 | rev)
echo "$mountid $mounted"

script_full_path=$(dirname "$0")

# Extract symbol
dyldpath="$mounted/System/Library/Caches/com.apple.dyld/"
for i in $(ls "$dyldpath"); do
	echo $i
	arch=$(echo $i | rev | cut -d_ -f1 | rev)
	if [[ "$arch" == "arm64e" ]]; then
		symdir="$version ($code) arm64e"
	else
		symdir="$version ($code)"
	fi
	echo $symdir
	sympath="$output/$symdir/Symbols"
	echo "$sympath"
	mkdir -p "$sympath"

	"$script_full_path/dsc_extractor" "$dyldpath/$i" "$sympath"

	# 补充dyld源文件
	symdyld="$sympath/System/Library/Caches/com.apple.dyld"
	mkdir -p "$symdyld"
	echo "$symdyld"
	cp "$dyldpath/$i" "$symdyld"
	touch "$symdyld/.copied_$i"
	touch "$symdyld/.processed_$i"
done

# Unmount
hdiutil detach "$mountid"




