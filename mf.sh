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

hide_cursor() {
	echo -ne "\x1b[?25l"
}

show_cursor() {
	echo -ne "\x1b[?25h"
}

clear_screen() {
	echo -ne "\x1b[2J"
	echo -ne "\x1b[H"
}

read_char() {
	read -n 1 -t 0.5 kbd
	echo -n "$kbd"
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
	if (( finger_width < 2 )); then finger_width=2; fi
	back_height=$((height / 3))
	thumb_height=$((height / 4))
	index_finger_height=$((height / 3))
	straightened_middle_finger_height=$((height - back_height))
	if (( straightened_middle_finger_height == 0 )); then
		straightened_middle_finger_height=1
	fi
	bent_middle_finger_height=$((height*10 / 24))
	ring_finger_height=$((height / 3))
	pinky_finger_height=$((height / 4))

	width=$(( (5*(finger_width - 1) + 1) ))
}

generate_hand() {
	local middle_finger_height=$1
	local hand_str=""

	if (( window_height <= 4 )); then
		hand_str="$(repeat_char '\n' $(( (window_height - 1) / 2 )))"
		local spaces="$(repeat_char ' ' $(( (window_width - 3) / 2 )))"
		if (( middle_finger_height == bent_middle_finger_height )); then
			hand_str="$hand_str$spaces..."
		else
			hand_str="$hand_str$spaces.|."
		fi
		echo -ne "$hand_str"
		return
	elif (( window_height <= 6 )); then
		local spaces="$(repeat_char ' ' $(( (window_width - 4) / 2 )))"
		if (( middle_finger_height == bent_middle_finger_height )); then
			hand_str="$(repeat_char '\n' $(( ( (window_height - 2) + 1) / 2 )))"
			hand_str="$hand_str$spaces┌┬┬┐\n$spaces└──┘"
		else
			hand_str="$(repeat_char '\n' $(( (window_height - 3) / 2 )))"
			hand_str="$hand_str$spaces ┌┐\n$spaces┌┤├┐\n$spaces└──┘"
		fi
		echo -ne "$hand_str"
		return
	fi

	local finger_heights=(thumb_height index_finger_height middle_finger_height ring_finger_height pinky_finger_height)
	local thumb_base_height=$((finger_width - 2))
	if (( height <= 8 )); then
		thumb_base_height=1
	fi
	local base_heights=(thumb_base_height back_height back_height back_height back_height)

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

run_animation() {
	local hand1=""
	local hand2=""
	while true; do
		if (( window_width != $(tput cols) )) || (( window_height != $(tput lines) )); then
			calculate_dimensions
			hand1="$(generate_hand bent_middle_finger_height)"
			hand2="$(generate_hand straightened_middle_finger_height)"
		else
			local tmp=$hand1
			hand1=$hand2
			hand2=$tmp
		fi
		clear_screen
		echo "$hand1"
		if [[ -n "$(read_char)" ]]; then break; fi
	done
}

switch_to_alternate_buffer
switch_to_raw_input_mode
hide_cursor
run_animation
show_cursor
switch_to_normal_input_mode
switch_to_normal_buffer
