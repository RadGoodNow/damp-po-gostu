mkdir ./../sdcard/data
log_file="./sdcard/data/UFSEYE_STRESS_LOG"
result_file="./sdcard/data/UFSEYE_STRESS_result"
if [ -d "${log_file}" ]; then
	echo "delete file"
	rm  -r ${log_file}
else
	echo "log_file Directory does not exist"
fi
if [ -d "${result_file}" ]; then
	echo "delete file"
	rm  -r ${result_file}
else
	echo "result_file Directory does not exist"
fi
mkdir ${log_file}
mkdir ${result_file}
project_info=$(getprop ro.product.device)
ufs_model=$(cat /sys/block/sda/device/model | tr -d ' ')
fw_version=$(cat /sys/block/sda/device/rev | tr -d ' ')
current_date_time=$(date +"%Y-%m-%d-%H-%M-%S")
echo ${current_date_time}
log_file_path=/sdcard/data/UFSEYE_STRESS_LOG/${project_info}_${ufs_model}_${fw_version}_${current_date_time}_UFSEYE_log.txt
result_file_path=/sdcard/data/UFSEYE_STRESS_result/UFSEYE_result.txt

max_width=0.39
max_height=70
device_lane0_eom_max_width=0
device_lane0_eom_max_height=0
device_lane1_eom_max_width=0
device_lane1_eom_max_height=0
host_lane0_eom_max_width=0
host_lane0_eom_max_height=0
host_lane1_eom_max_width=0
host_lane1_eom_max_height=0

min_width=1
min_height=700

counter=1
while [ $counter -le 2 ]
do
	#get the test log
	echo "step 1: get the test log"
	echo "do device_lane0 test" | tee -a $log_file_path
	device_lane0_log=$(cat /sys/devices/platform/soc/16810000.ufshci/eyemon/device_eye_lane0 | tee -a $log_file_path  )
	echo "do device_lane1 test" | tee -a $log_file_path
	device_lane1_log=$(cat /sys/devices/platform/soc/16810000.ufshci/eyemon/device_eye_lane1 | tee -a $log_file_path  )
	echo "do host_lane0 test" | tee -a $log_file_path
	host_lane0_log=$(cat /sys/devices/platform/soc/16810000.ufshci/eyemon/host_eye_lane0 | tee -a $log_file_path )
	echo "do host_lane1 test" | tee -a $log_file_path
	host_lane1_log=$(cat /sys/devices/platform/soc/16810000.ufshci/eyemon/host_eye_lane1 | tee -a $log_file_path )

	#anlysis the log to the the max eom width and height
	echo "step 3: anlysis the log to the the max eom width and height"
	device_lane0_eom_max_width=$(echo ${device_lane0_log} | grep -o "\[UFS\] max width:[0-9]\{1,5\}\.[0-9]\{1,5\} UI"  | grep -o "[0-9]\{1,5\}\.[0-9]\{1,5\}")
	device_lane0_eom_max_height=$(echo ${device_lane0_log} | grep -o "\[UFS\] eye height:[0-9]\{1,5\}\.[0-9]\{1,5\} mV"  | grep -o "[0-9]\{1,5\}\.[0-9]\{1,5\}")
	device_lane1_eom_max_width=$(echo ${device_lane1_log} | grep -o "\[UFS\] max width:[0-9]\{1,5\}\.[0-9]\{1,5\} UI"  | grep -o "[0-9]\{1,5\}\.[0-9]\{1,5\}")
	device_lane1_eom_max_height=$(echo ${device_lane1_log} | grep -o "\[UFS\] eye height:[0-9]\{1,5\}\.[0-9]\{1,5\} mV"  | grep -o "[0-9]\{1,5\}\.[0-9]\{1,5\}")
	host_lane0_eom_max_width=$(echo ${host_lane0_log} | grep -o "\[UFS\] max width:[0-9]\{1,5\}\.[0-9]\{1,5\} UI"  | grep -o "[0-9]\{1,5\}\.[0-9]\{1,5\}")
	host_lane0_eom_max_height=$(echo ${host_lane0_log} | grep -o "\[UFS\] eye height:[0-9]\{1,5\}\.[0-9]\{1,5\} mV"  | grep -o "[0-9]\{1,5\}\.[0-9]\{1,5\}")
	host_lane1_eom_max_width=$(echo ${host_lane1_log} | grep -o "\[UFS\] max width:[0-9]\{1,5\}\.[0-9]\{1,5\} UI"  | grep -o "[0-9]\{1,5\}\.[0-9]\{1,5\}")
	host_lane1_eom_max_height=$(echo ${host_lane1_log} | grep -o "\[UFS\] eye height:[0-9]\{1,5\}\.[0-9]\{1,5\} mV"  | grep -o "[0-9]\{1,5\}\.[0-9]\{1,5\}")
	
		#judge the result
	if [[ $(echo "$device_lane0_eom_max_width < $min_width" | bc -l) -eq 1 ]]; then
		min_width=$device_lane0_eom_max_width
	fi
	if [[ $(echo "$device_lane1_eom_max_width < $min_width" | bc -l) -eq 1 ]]; then
		min_width=$device_lane1_eom_max_width
	fi
	if [[ $(echo "$host_lane0_eom_max_width < $min_width" | bc -l) -eq 1 ]]; then
		min_width=$host_lane0_eom_max_width
	fi
	if [[ $(echo "$host_lane1_eom_max_width < $min_width" | bc -l) -eq 1 ]]; then
		min_width=$host_lane1_eom_max_width
	fi
	if [[ $(echo "$device_lane0_eom_max_height < $min_height" | bc -l) -eq 1 ]]; then
		min_height=$device_lane0_eom_max_height
	fi
	if [[ $(echo "$device_lane1_eom_max_height < $min_height" | bc -l) -eq 1 ]]; then
		min_height=$device_lane1_eom_max_height
	fi
	if [[ $(echo "$host_lane0_eom_max_height < $min_height" | bc -l) -eq 1 ]]; then
		min_height=$host_lane0_eom_max_height
	fi
	if [[ $(echo "$host_lane1_eom_max_height < $min_height" | bc -l) -eq 1 ]]; then
		min_height=$host_lane1_eom_max_height
	fi
	
	echo "step 4: wait for 30s"
	sleep 30 # loop test every 30s
	((counter++))
done

echo "min_width: \"${min_width}\"" | tee -a $result_file_path 
echo "min_height: \"${min_height}\"" | tee -a $result_file_path  
