#/bin/bash

margin=1

window_width=18
window_height=14

width=$((window_width - 2*margin))
height=$((window_height - 2*margin))

finger_width=$(((width - 1) / 5 + 1))
back_height=$((height / 3))
thumb_height=$((height / 4))
index_finger_height=$((height / 3))
straightened_middle_finger_height=$((height - back_height))
bent_middle_finger_height=$((height*10 / 24))
ring_finger_height=$((height / 3))
pinky_finger_height=$((height / 4))

repeat_char() {
	for i in $(seq 1 $2); do echo -n "$1"; done
}

generate_hand() {
	middle_finger_height=$1
	hand_str=""
	for (( line=$height; line>1; line-=1 )); do
		# Draw thumb
		if (( line > (finger_width - 2) + thumb_height )); then
			hand_str="$hand_str$(repeat_char ' ' $((finger_width - 1)))"
		elif (( line < (finger_width - 2) + thumb_height )); then
			hand_str="$hand_str│$(repeat_char ' ' $((finger_width - 2)))"
			if (( line > (finger_width - 2) )); then
				hand_str="$hand_str│"
			else
				hand_str="$hand_str "
			fi
		else
			hand_str="$hand_str┌$(repeat_char '─' $((finger_width - 2)))"
		fi

		# Draw index finger
		if (( line > back_height + index_finger_height )); then
			hand_str="$hand_str$(repeat_char ' ' $((finger_width - 1)))"
		elif (( line < back_height + index_finger_height )); then
			if (( line == (finger_width - 2) + thumb_height )); then
				if (( index_finger_height > thumb_height - (finger_width - 2) )); then
					hand_str="$hand_str┤"
				else
					hand_str="$hand_str┬"
				fi
			elif (( line > (finger_width - 2) + thumb_height )); then
				hand_str="$hand_str│"
			fi
			hand_str="$hand_str$(repeat_char ' ' $((finger_width - 2)))"
		else
			if (( index_finger_height == thumb_height - (finger_width - 2) )); then
				hand_str="$hand_str$(repeat_char '─' $((finger_width - 2)))"
			else
				hand_str="$hand_str┌$(repeat_char '─' $((finger_width - 2)))"
			fi
		fi

		# Draw middle finger
		if (( line > back_height + middle_finger_height )); then
			hand_str="$hand_str$(repeat_char ' ' $((finger_width - 1)))"
		elif (( line < back_height + middle_finger_height )); then
			if (( line == back_height + index_finger_height )); then
				if (( middle_finger_height > index_finger_height )); then
					hand_str="$hand_str┤"
				else
					hand_str="$hand_str┬"
				fi
			elif (( line > back_height )); then
				hand_str="$hand_str│"
			fi
			hand_str="$hand_str$(repeat_char ' ' $((finger_width - 2)))"
		else
			if (( middle_finger_height == index_finger_height )); then
				hand_str="$hand_str$(repeat_char '─' $((finger_width - 2)))"
			else
				hand_str="$hand_str┌$(repeat_char '─' $((finger_width - 2)))"
			fi
		fi

		# Draw ring finger
		if (( line > back_height + ring_finger_height )); then
			if (( line == back_height + middle_finger_height )); then
				hand_str="$hand_str┐"
			elif (( line < back_height + middle_finger_height )); then
				hand_str="$hand_str│"
			fi
			hand_str="$hand_str$(repeat_char ' ' $((finger_width - 1)))"
		elif (( line < back_height + ring_finger_height )); then
			if (( line == back_height + middle_finger_height )); then
				if (( ring_finger_height < middle_finger_height )); then
					hand_str="$hand_str├"
				else
					hand_str="$hand_str┬"
				fi
			elif (( line > back_height )); then
				hand_str="$hand_str│"
			fi
			hand_str="$hand_str$(repeat_char ' ' $((finger_width - 2)))"
		else
			if (( ring_finger_height == middle_finger_height )); then
				hand_str="$hand_str┬$(repeat_char '─' $((finger_width - 2)))"
			else
				hand_str="$hand_str├$(repeat_char '─' $((finger_width - 2)))"
			fi
		fi

		# Draw pinky finger
		if (( line > back_height + pinky_finger_height )); then
			if (( line == back_height + ring_finger_height )); then
				hand_str="$hand_str┐"
			elif (( line < back_height + ring_finger_height )); then
				hand_str="$hand_str│"
			fi
		elif (( line < back_height + pinky_finger_height )); then
			if (( line == back_height + ring_finger_height )); then
				if (( pinky_finger_height < ring_finger_height )); then
					hand_str="$hand_str├"
				else
					hand_str="$hand_str┬"
				fi
			elif ((line > back_height )); then
				hand_str="$hand_str│"
			else
				hand_str="$hand_str$(repeat_char ' ' $((finger_width - 1)))"
			fi
			hand_str="$hand_str$(repeat_char ' ' $((finger_width - 2)))│"
		else
			if (( pinky_finger_height == ring_finger_height )); then
				hand_str="$hand_str┬$(repeat_char '─' $((finger_width - 2)))┐"
			else
				hand_str="$hand_str├$(repeat_char '─' $((finger_width - 2)))┐"
			fi
		fi

		hand_str="$hand_str\n"
	done
	hand_str="$hand_str└$(repeat_char '─' $((width - 2)))┘"
	echo -ne "$hand_str"
}

echo "$(generate_hand straightened_middle_finger_height)"
