#!/bin/sh

icon_basename="icon"
twitter_eps_url="https://twitter.com/images/resources/twitter-bird-white-on-blue.eps"

icon_source="$icon_basename"".eps"
# download icon source image from twitter
if ! [ -f "$icon_source" ]; then
  echo "download source image from" "$twitter_eps_url"
  curl "$twitter_eps_url" -o "$icon_source" -# 2> /dev/null
fi

# convert image with imagemagick
command_imagemagick="convert"
if ! (which $command_imagemagick) > /dev/null; then
  command_imagemagick="/usr/local/bin/convert"
  if ! [ -x "$command_imagemagick" ]; then
    command_imagemagick="/opt/local/bin/convert"
    if ! [ -x "$command_imagemagick" ]; then
      echo "\"$command_imagemagick\" not found"
      exit 1
    fi
  fi
fi

w=`$command_imagemagick -print %w $icon_source /dev/null`
x=`$command_imagemagick -print %x $icon_source /dev/null`
h=`$command_imagemagick -print %h $icon_source /dev/null`
y=`$command_imagemagick -print %y $icon_source /dev/null`

w_value=`expr $w \* $x`
h_value=`expr $h \* $y`

point=0
density=0
if [ $w_value -gt $h_value ]; then
point=$w
density=$x
else
point=$h
density=$y
fi

#$ GetIconName name size rertina(NO=0 or YES=1)
GetIconName()
{
if test $# -eq 3; then
  local name="$1"
  local size="$2"
  local retina="$3"
  local retina_string=""
  if [ $retina -ne 0 ]; then
    retina_string="@2x"
  fi
  icon_name="${name}_${size}x${size}${retina_string}.png"
  echo "$icon_name"
fi
}

# create .iconset folder
iconset_extension="iconset"
iconset_folder="${icon_basename}.${iconset_extension}"
if ! [ -d "$iconset_folder" ]; then
mkdir "$iconset_folder"
fi

icon_source_png="${icon_basename}.png"
sizes=(512 256 128 32 16)

for size in "${sizes[@]}"
do
  size_retina=`expr $size \* 2`
  # create source png image
  if ! [ -f "$icon_source_png" ]; then
    num=`expr $size_retina / $point`
    rest=`expr $size_retina % $point`
    if [ $rest -gt 0 ]; then
      num=`expr $num + 1`
    fi
    density_source=`expr $density \* $num`
    "$command_imagemagick" -density "$density_source" -flatten "$icon_source" "$icon_source_png"
  fi
  destination_path_normal=`GetIconName "$icon_basename" "$size" "0"`
  destination_path_retina=`GetIconName "$icon_basename" "$size" "1"`
  "$command_imagemagick" -geometry "${size}x${size}" "$icon_source_png" "./${iconset_folder}/${destination_path_normal}"
  "$command_imagemagick" -geometry "${size_retina}x${size_retina}" "$icon_source_png" "./${iconset_folder}/${destination_path_retina}"
done

