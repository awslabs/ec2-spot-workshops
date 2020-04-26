#!/bin/bash 

echo "Hello World from EC2 Spot Team..."


yum update -y
yum -y install jq amazon-efs-utils


#Global Settings
MY_NAME=""
SECONDARY_VOLUME_ID=""
SECONDARY_PRIVATE_IP=""


EFS_FS_ID=fs-2b2540aa
EFS_MOUNT_POINT=/jp
SPOT_IP_STATUS_FILE=spot_ip_status.txt
SPOT_VOLUME_STATUS_FILE=spot_volume_status.txt
SPOT_STATE_FILE=spot_state.txt
SPOT_INSTANCE_STATUS_FILE=spot_instance_status.txt


#EBS Settings

EBS_TYPE=gp2
EBS_SIZE=8
EBS_DEV=/dev/xvdb

#SECONDARY_PRIVATE_IP="172.31.81.24"
MAC=$(curl -s http://169.254.169.254/latest/meta-data/mac)
INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)
AWS_AVAIALABILITY_ZONE=$(curl -s 169.254.169.254/latest/dynamic/instance-identity/document | jq -r '.availabilityZone')
AWS_REGION=$(curl -s 169.254.169.254/latest/dynamic/instance-identity/document | jq -r '.region')
INTERFACE_ID=$(curl -s http://169.254.169.254/latest/meta-data/network/interfaces/macs/$MAC/interface-id)

aws configure set default.region ${AWS_REGION}


echo "MY_NAME=$MY_NAME"

echo "MAC=$MAC INSTANCE_ID=$INSTANCE_ID INTERFACE_ID=$INTERFACE_ID  "

mkdir -p $EFS_MOUNT_POINT
sudo mount -t efs -o tls $EFS_FS_ID:/ $EFS_MOUNT_POINT

if [ ! -f $EFS_MOUNT_POINT/$SPOT_INSTANCE_STATUS_FILE ]; then
    echo "File $EFS_MOUNT_POINT/$SPOT_INSTANCE_STATUS_FILE does not exist. Hence creating..."
    touch $EFS_MOUNT_POINT/$SPOT_INSTANCE_STATUS_FILE
fi


if [ ! -f $EFS_MOUNT_POINT/$SPOT_STATE_FILE ]; then
    echo "File $EFS_MOUNT_POINT/$SPOT_STATE_FILE does not exist. Hence creating..."
    touch $EFS_MOUNT_POINT/$SPOT_STATE_FILE
fi

function Check_If_secondary_IP_Already_Exists()
{
    
    input="$EFS_MOUNT_POINT/$SPOT_STATE_FILE"
    
    while IFS= read -r line
    do
      echo "line=$line"
      
      fields=$(echo $line | tr "=" "\n")
      
      arr=($fields)
      if [[ "${arr[3]}" == "AVAILABLE" ]]; then
         MY_NAME="${arr[0]}"
         SECONDARY_VOLUME_ID="${arr[1]}"
         SECONDARY_PRIVATE_IP="${arr[2]}"
         #echo "${arr[0]}"
         break
      fi
    done < "$input"
}

Check_If_secondary_IP_Already_Exists

echo "MY_NAME=$MY_NAME SECONDARY_VOLUME_ID=$SECONDARY_VOLUME_ID SECONDARY_PRIVATE_IP=$SECONDARY_PRIVATE_IP"

    if [[ ! -z $SECONDARY_VOLUME_ID ]] &&  [[ ! -z $SECONDARY_PRIVATE_IP ]]; then
        echo "SECONDARY_VOLUME_ID $SECONDARY_VOLUME_ID and SECONDARY_PRIVATE_IP $SECONDARY_PRIVATE_IP already exists in EFS. So let me attach to them and change state in EFS."
        sleep 15
        aws ec2 attach-volume --volume-id $SECONDARY_VOLUME_ID --instance-id $INSTANCE_ID --device $EBS_DEV
        sleep 30
        aws ec2 assign-private-ip-addresses --network-interface-id $INTERFACE_ID --private-ip-addresses $SECONDARY_PRIVATE_IP
        service network restart
        
        sed -i "s/$MY_NAME=$SECONDARY_VOLUME_ID=$SECONDARY_PRIVATE_IP=AVAILABLE/$MY_NAME=$SECONDARY_VOLUME_ID=$SECONDARY_PRIVATE_IP=IN_USE/g" $EFS_MOUNT_POINT/$SPOT_STATE_FILE
        
    else
         echo "SECONDARY_VOLUME_ID $SECONDARY_VOLUME_ID and SECONDARY_PRIVATE_IP $SECONDARY_PRIVATE_IP are Empty. Looks like I am launching for the first time. Let me create both of them..."
         AMI_ID=$(curl -s http://169.254.169.254/latest/meta-data/ami-launch-index)
         if [ $AMI_ID == "0" ]; then
            MY_NAME="MASTER"
         else
            MY_NAME="SLAVE_"$AMI_ID
         fi

         SECONDARY_VOLUME_ID=$(aws ec2 create-volume --volume-type $EBS_TYPE  --size $EBS_SIZE   --availability-zone $AWS_AVAIALABILITY_ZONE | jq -r '.VolumeId')
         echo "SECONDARY_VOLUME_ID=$SECONDARY_VOLUME_ID"
         aws ec2 wait volume-available  --volume-ids $SECONDARY_VOLUME_ID
            
         aws ec2 attach-volume --volume-id $SECONDARY_VOLUME_ID --instance-id $INSTANCE_ID --device $EBS_DEV
         sleep 15
         mkfs -t xfs $EBS_DEV

         aws ec2 assign-private-ip-addresses --network-interface-id $INTERFACE_ID --secondary-private-ip-address-count 1
         service network restart
         sleep 10
         PRIVATE_IPS=$(curl -s http://169.254.169.254/latest/meta-data/network/interfaces/macs/$MAC/local-ipv4s)
         array=($PRIVATE_IPS)
         PRIMARY_PRIVATE_IP="${array[0]}"
         SECONDARY_PRIVATE_IP="${array[1]}"
    
         echo "Changing state for SECONDARY_VOLUME_ID $SECONDARY_VOLUME_ID and SECONDARY_PRIVATE_IP $SECONDARY_PRIVATE_IP in EFS..."
         echo "$MY_NAME=$SECONDARY_VOLUME_ID=$SECONDARY_PRIVATE_IP=IN_USE" >> $EFS_MOUNT_POINT/$SPOT_STATE_FILE
    fi
    
    mkdir -p /var/www/html/
    mount $EBS_DEV /var/www/
    
    yum -y install httpd
    service httpd start
    chkconfig httpd on

    PRIVATE_IPS=$(curl -s http://169.254.169.254/latest/meta-data/network/interfaces/macs/$MAC/local-ipv4s)
    array=($PRIVATE_IPS)
    PRIMARY_PRIVATE_IP="${array[0]}"
    SECONDARY_PRIVATE_IP="${array[1]}"    
    
    echo "<html> <body> <h4>Myname: $MY_NAME Time: $(date) Instance Id: $INSTANCE_ID PUBLIC_IP: $PUBLIC_IP SECONDARY_PRIVATE_IP: $SECONDARY_PRIVATE_IP SECONDARY_VOLUME_ID:$SECONDARY_VOLUME_ID</h4> </body> </html>" >> /var/www/html/index.html


cat <<EOF > /usr/local/bin/spot-instance-termination-notice-handler.sh
#!/bin/bash
while sleep 5; do

if [ -z \$(curl -Isf http://169.254.169.254/latest/meta-data/spot/termination-time)]; then
   echo "$INSTANCE_ID with $MY_NAME=$SECONDARY_VOLUME_ID=$SECONDARY_PRIVATE_IP is running fine at \$(date)" >> $EFS_MOUNT_POINT/$SPOT_INSTANCE_STATUS_FILE
   /bin/false
else
   echo "$INSTANCE_ID with $MY_NAME=$SECONDARY_VOLUME_ID=$SECONDARY_PRIVATE_IP got spot interruption at \$(date)" >> $EFS_MOUNT_POINT/$SPOT_INSTANCE_STATUS_FILE
   service httpd stop
   umount /var/www/
   yum -y removed httpd
   rm -rf /var/www/
   aws ec2 detach-volume --volume-id $SECONDARY_VOLUME_ID
   
   sed -i "s/$MY_NAME=$SECONDARY_VOLUME_ID=$SECONDARY_PRIVATE_IP=IN_USE/$MY_NAME=$SECONDARY_VOLUME_ID=$SECONDARY_PRIVATE_IP=AVAILABLE/g" $EFS_MOUNT_POINT/$SPOT_STATE_FILE

   umount $EFS_MOUNT_POINT
   rm -rf $EFS_MOUNT_POINT
   sleep 120
 
fi
done
EOF
chmod +x /usr/local/bin/spot-instance-termination-notice-handler.sh
/usr/local/bin/spot-instance-termination-notice-handler.sh &

