#!/bin/bash


#varible declaration section
#service_in defines the no of running live services in the current server
service_in=35

#present working directory
pwd=$(pwd)

#Get the hostname of the server and store it in the host variable
host=$(hostname)

#`disk_out` is the number of partitions with usage greater than or equal to 80%
disk_out=$(df -h | awk '+$5>=80' | awk '{print $5}' | tr -d '%' | wc -l)

#`service_out` is the number of running services in the system
service_out=$(systemctl --type=service --state=running | awk '{print $1,$4}' | awk '(NR > 1)'| grep running | wc -l)

#`up_status` is the uptime status of the system
up_status=$(uptime | awk '{print $2" since "$3$4}' | tr -d ',')

#`Comment` is a message indicating the partitions with usage greater than or equal to 80%
Comment=$(df -h | awk '+$5>=80' | awk '{print $6 " is using " $5}')

#If the `Comment` variable is empty, assign the value "NA"
if [ -z "$Comment" ]; then
  Comment="NA"
else
  Comment=$(df -h | awk '$5 >= 80 { print $6 " is using " $5 }')
fi

#`total_memory` is the total memory of the system
total_memory=$(free -h | awk '{print $2}' | awk '(NR > 1)' | head -n 1)

#`free_memory` is the free memory of the system
free_memory=$(free -h | awk '{print $4}' | awk '(NR > 1)' | head -n 1)

#`free_memory_unit` is the unit of the free memory (e.g. "GB")
free_memory_unit=`echo $free_memory | grep -o "[A-Z]*"`

#`free_memory_number` is the numerical value of the free memory (e.g. "3.5")
free_memory_number=`echo $free_memory | grep -o "[0-9\.]*"`

#`total_memory_number` is the numerical value of the total memory (e.g. "16.0")
total_memory_number=`echo $total_memory | grep -o "[0-9\.]*"`

#`threshold` is 20% of the total memory
threshold=$(echo "$total_memory_number * 0.2" | bc)



# Check if the unit of free memory is GB, Gi, gb, gi, or G, if not convert it into the GB
if [[ "$free_memory_unit" == "GB" || "$free_memory_unit" == "Gi" || "$free_memory_unit" == "gb" || "$free_memory_unit" == "gi" || "$free_memory_unit" == "G" ]]
then
  free_memory_number=$(echo $free_memory_number | awk '{print $1}')
elif [[ "$free_memory_unit" == "MB" || "$free_memory_unit" == "Mi" || "$free_memory_unit" == "mb" || "$free_memory_unit" == "mi" || "$free_memory_unit" == "M" ]]
then
  free_memory_number=$(echo $free_memory_number | awk '{print $1 / 1024}')
fi


#entering master host
master_host=

#entering password
password=

#Total 8 cases possible

# case 1 : service = ok and diskout = breached and free_memory = ok
if [[ $service_out -eq $service_in && $disk_out -gt 0 && $(echo "$free_memory_number >= $threshold" | bc -l) -eq 1 ]]
then
    echo -e "Account\tHostname\tDisk_Space\tTotal_Memory\tFree_Memory\tFree_Memory_Status\tService\tUptime\tComments" > $host.csv
    echo -e "LUMI SP Prod\t$(hostname)\tBreached\t$(free -h | awk '{print $2}' | awk '(NR > 1)' | head -n 1)\t$(free -h | awk '{print $4}' | awk '(NR > 1)' | head -n 1)\tOK\tOK\t$up_status\t$Comment" >> $host.csv
# case 2 : service = ok and diskout = breached and free_memory = breached
elif [[ $service_out -eq $service_in && $disk_out -gt 0 && $(echo "$free_memory_number < $threshold" | bc -l) -eq 1 ]]
then
    echo -e "Account\tHostname\tDisk_Space\tTotal_Memory\tFree_Memory\tFree_Memory_Status\tService\tUptime\tComments" > $host.csv
    echo -e "LUMI SP Prod\t$(hostname)\tBreached\t$(free -h | awk '{print $2}' | awk '(NR > 1)' | head -n 1)\t$(free -h | awk '{print $4}' | awk '(NR > 1)' | head -n 1)\tBreached\tOK\t$up_status\t$Comment" >> $host.csv
# case 3 : service = ok and diskout = ok and free_memory = breached
elif [[ $service_out -eq $service_in  && $(echo "$free_memory_number < $threshold" | bc -l) -eq 1 ]]
then
    echo -e "Account\tHostname\tDisk_Space\tTotal_Memory\tFree_Memory\tFree_Memory_Status\tService\tUptime\tComments" > $host.csv
    echo -e "LUMI SP Prod\t$(hostname)\tOK\t$(free -h | awk '{print $2}' | awk '(NR > 1)' | head -n 1)\t$(free -h | awk '{print $4}' | awk '(NR > 1)' | head -n 1)\tBreached\tOK\t$up_status\t$Comment" >> $host.csv
# case 4 : service = ok and diskout = ok and free_memory = ok
elif [[ $service_out -eq $service_in  && $(echo "$free_memory_number >= $threshold" | bc -l) -eq 1 ]]
then
    echo -e "Account\tHostname\tDisk_Space\tTotal_Memory\tFree_Memory\tFree_Memory_Status\tService\tUptime\tComments" > $host.csv
    echo -e "LUMI SP Prod\t$(hostname)\tOK\t$(free -h | awk '{print $2}' | awk '(NR > 1)' | head -n 1)\t$(free -h | awk '{print $4}' | awk '(NR > 1)' | head -n 1)\tOK\tOK\t$up_status\t$Comment" >> $host.csv
# case 5: service = breached and diskout = ok and free_memory = ok
elif [[ $service_out -ne $service_in && $(echo "$free_memory_number >= $threshold" | bc -l) -eq 1 ]]
then
    echo -e "Account\tHostname\tDisk_Space\tTotal_Memory\tFree_Memory\tFree_Memory_Status\tService\tUptime\tComments" > $host.csv
    echo -e "LUMI SP Prod\t$(hostname)\tOK\t$(free -h | awk '{print $2}' | awk '(NR > 1)' | head -n 1)\t$(free -h | awk '{print $4}' | awk '(NR > 1)' | head -n 1)\tOK\tBreached\t$up_status\t$Comment" >> $host.csv
# case 6: service = breached and diskout = ok and free_memory = breached
elif [[ $service_out -ne $service_in && $(echo "$free_memory_number < $threshold" | bc -l) -eq 1 ]]
then
    echo -e "Account\tHostname\tDisk_Space\tTotal_Memory\tFree_Memory\tFree_Memory_Status\tService\tUptime\tComments" > $host.csv
    echo -e "LUMI SP Prod\t$(hostname)\tOK\t$(free -h | awk '{print $2}' | awk '(NR > 1)' | head -n 1)\t$(free -h | awk '{print $4}' | awk '(NR > 1)' | head -n 1)\tBreached\tBreached\t$up_status\t$Comment" >> $host.csv
# case 7: service = breached and diskout = breached and free_memory = ok
elif [[ $service_out -ne $service_in && $disk_out -gt 0 && $(echo "$free_memory_number >= $threshold" | bc -l) -eq 1 ]]
then
    echo -e "Account\tHostname\tDisk_Space\tTotal_Memory\tFree_Memory\tFree_Memory_Status\tService\tUptime\tComments" > $host.csv
    echo -e "LUMI SP Prod\t$(hostname)\tBreached\t$(free -h | awk '{print $2}' | awk '(NR > 1)' | head -n 1)\t$(free -h | awk '{print $4}' | awk '(NR > 1)' | head -n 1)\tOK\tBreached\t$up_status\t$Comment" >> $host.csv
# case 8: service = breached and diskout = breached and free_memory = breached
else
    echo -e "Account\tHostname\tDisk_Space\tTotal_Memory\tFree_Memory\tFree_Memory_Status\tService\tUptime\tComments" > $host.csv
    echo -e "LUMI SP Prod\t$(hostname)\tBreached\t$(free -h | awk '{print $2}' | awk '(NR > 1)' | head -n 1)\t$(free -h | awk '{print $4}' | awk '(NR > 1)' | head -n 1)\tBreached\tBreached\t$up_status\t$Comment" >> $host.csv
fi

#directing files to master path
cat $host.csv
host_ip=$(hostname -i)
if [ $? -eq 0 ]
then
    sshpass -p $password scp -r /present_location/$host.csv hostname@$master_host:destination_location
else
    echo -e "Hostname\t$host_ip\tdetails are not available" > $host.csv
    sshpass -p $password scp -r /present_location/$host.csv hostname@$master_host:destination_location
fi
