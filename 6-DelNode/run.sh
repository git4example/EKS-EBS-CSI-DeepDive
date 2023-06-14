#!/bin/bash
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
### Variables:
CLUSTER=syd-ebs-25
REGION=ap-southeast-2

echo " ### PARAMETERES IN USER >>> CLUSTER=$CLUSTER  ;  REGION=$REGION"

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
echo " ### 1- deleting node : "
kubectl delete node --all
eksctl scale nodegroup mng --cluster $CLUSTER -m=0 -N=0 -M=3 --region $REGION
sleep 60 

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
echo " ### 2- Recording Node , csiNode , SC , PVC , PV , POD  :"
kubectl get node -o yaml > node-0-oyaml.yaml
kubectl get csinode -o yaml > csinode-0-oyaml.yaml
kubectl get sc -o yaml > sc-0-oyaml.yaml
kubectl get pv -o yaml > pv-0-oyaml.yaml
kubectl get pvc -o yaml > pvc-0-oyaml.yaml
kubectl get pod -o yaml > pod-0-oyaml.yaml
kubectl get VolumeAttachment -o yaml > volumeattachment-0-oyaml.yaml
kubectl describe node  > node-0-describe.yaml
kubectl describe csinode > csinode-0-describe.yaml
kubectl describe sc > sc-0-describe.yaml
kubectl describe pv > pv-0-describe.yaml
kubectl describe pvc > pvc-0-describe.yaml
kubectl describe pod > pod-0-describe.yaml
kubectl get event > event-0.txt


### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
echo " ### 3-  re-create nodes and pod back again : "
eksctl scale nodegroup mng --cluster $CLUSTER -N=3 --region $REGION
sleep 300

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
echo " ### 4- Creating pod = app   : "
kubectl apply -f - <<EOF
apiVersion: v1
kind: Pod
metadata:
  name: app
spec:
  containers:
  - name: app
    image: centos
    command: ["/bin/sh"]
    args: ["-c", "while true; do echo \`date -u\` >> /data/out.txt; sleep 5; done"]
    volumeMounts:
    - name: persistent-storage
      mountPath: /data
  volumes:
  - name: persistent-storage
    persistentVolumeClaim:
      claimName: ebs-claim
EOF


### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
echo " ### 5- Recording after resurrection:"
kubectl get node -o yaml > node-oyaml.yaml
kubectl get csinode -o yaml > csinode-oyaml.yaml
kubectl get sc -o yaml > sc-oyaml.yaml
kubectl get pv -o yaml > pv-oyaml.yaml
kubectl get pvc -o yaml > pvc-oyaml.yaml
kubectl get pod -o yaml > pod-oyaml.yaml
kubectl get VolumeAttachment -o yaml > volumeattachment-oyaml.yaml
kubectl describe node  > node-describe.yaml
kubectl describe csinode > csinode-describe.yaml
kubectl describe sc > sc-describe.yaml
kubectl describe pv > pv-describe.yaml
kubectl describe pvc > pvc-describe.yaml
kubectl describe pod > pod-describe.yaml
kubectl get event > event.txt

kubectl -n kube-system logs -l app=ebs-csi-controller -c csi-provisioner > log__csi-provisioner.log
kubectl -n kube-system logs -l app=ebs-csi-controller -c csi-attacher > log__csi-attacher.log
kubectl -n kube-system logs -l app=ebs-csi-controller -c ebs-plugin > log__ebs-ctl-plugin.log
kubectl -n kube-system logs -l app=ebs-csi-node  -c  node-driver-registrar  > log__node-driver-registrar.log
kubectl -n kube-system logs -l app=ebs-csi-node -c ebs-plugin > log__ebs-node-plugin.log        



