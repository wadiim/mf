#/bin/bash

declare -i margin
declare -i window_width
declare -i window_height
declare -i width
declare -i height
declare -i finger_width
declare -i back_height
declare -i thumb_height
declare -i index_finger_height
declare -i straightened_middle_finger_height
declare -i bent_middle_finger_height
declare -i ring_finger_height
declare -i pinky_finger_height

switch_to_alternate_buffer() {
	echo -ne "\x1b[?1049h\x1b[H"
}

switch_to_normal_buffer() {
	echo -ne "\x1b[?1049l"
}

switch_to_raw_input_mode() {
	stty -icanon -echo
}

switch_to_normal_input_mode() {
	stty icanon echo
}

repeat_char() {
	for i in $(seq 1 $2); do echo -n "$1"; done
}

calculate_dimensions() {
	margin=1

	window_width=$(tput cols)
	window_height=$(tput lines)

	width=$((window_width - 2*margin))
	height=$((window_height - 2*margin))

	while (( 7*width > 9*height )); do
		width=$((width - 1))
	done

	while (( 9*height > 7*width )); do
		height=$((height - 1))
	done

	finger_width=$(((width - 1) / 5 + 1))
	back_height=$((height / 3))
	thumb_height=$((height / 4))
	index_finger_height=$((height / 3))
	straightened_middle_finger_height=$((height - back_height))
	bent_middle_finger_height=$((height*10 / 24))
	ring_finger_height=$((height / 3))
	pinky_finger_height=$((height / 4))

	width=$(( (5*(finger_width - 1) + 1) ))
}

generate_hand() {
	local middle_finger_height=$1
	shift
	local finger_heights=(thumb_height index_finger_height middle_finger_height ring_finger_height pinky_finger_height)
	local hand_str=""
	local base_heights=($((finger_width - 2)) back_height back_height back_height back_height)

	# Center vertically
	for (( i=0; i<$(( (window_height - height) / 2 )); i+=1 )); do
		echo ""
	done

	for (( line=$height; line>1; line-=1 )); do
		# Center horizontally
		for (( i=0; i<$(( (window_width - width) / 2 )); i+=1 )); do
			hand_str="$hand_str "
		done

		for (( finger_idx=0; finger_idx<${#finger_heights[@]}; finger_idx+=1 )); do
			if (( line > base_heights[finger_idx] + finger_heights[finger_idx] )); then
				if (( finger_idx > 0 )) && (( line == base_heights[finger_idx - 1] + finger_heights[finger_idx - 1] )); then
					hand_str="$hand_str┐"
				elif (( finger_idx > 0)) && (( line < base_heights[finger_idx - 1] + finger_heights[finger_idx - 1] )); then
					hand_str="$hand_str│"
				fi
				hand_str="$hand_str$(repeat_char ' ' $((finger_width - 1)))"
			elif (( line < base_heights[finger_idx] + finger_heights[finger_idx] )); then
				if (( finger_idx > 0 )) && (( line == base_heights[finger_idx - 1] + finger_heights[finger_idx - 1] )); then
					hand_str="$hand_str┤"
				elif (( finger_idx == 0 )) || (( finger_idx == 1 && line > base_heights[finger_idx - 1] )) || (( line > base_heights[finger_idx - 1] + finger_heights[finger_idx - 1] )) || (( line > base_heights[finger_idx] )); then
					hand_str="$hand_str│"
				else
					hand_str="$hand_str "
				fi
				hand_str="$hand_str$(repeat_char ' ' $((finger_width - 2)))"
				if (( finger_idx == ${#finger_heights[@]} - 1 )); then
					hand_str="$hand_str│"
				fi
			else
				if (( finger_idx == 0 )) || (( base_heights[finger_idx - 1] + finger_heights[finger_idx - 1] < base_heights[finger_idx] + finger_heights[finger_idx] )); then
					hand_str="$hand_str┌"
				elif (( base_heights[finger_idx - 1] == base_heights[finger_idx] )) && (( finger_heights[finger_idx - 1] == finger_heights[finger_idx] )); then
					hand_str="$hand_str┬"
				else
					hand_str="$hand_str├"
				fi
				hand_str="$hand_str$(repeat_char '─' $((finger_width - 2)))"
				if (( finger_idx == ${#finger_heights[@]} - 1 )); then
					hand_str="$hand_str┐"
				fi
			fi
		done
		hand_str="$hand_str\n"
	done
	hand_str="$hand_str$(repeat_char ' ' $(( (window_width - width) / 2 )))└$(repeat_char '─' $((width - 2)))┘"
	echo -ne "$hand_str"
}

calculate_dimensions
switch_to_alternate_buffer
switch_to_raw_input_mode
echo "$(generate_hand straightened_middle_finger_height)"
read -n1 kbd
switch_to_normal_input_mode
switch_to_normal_buffer
