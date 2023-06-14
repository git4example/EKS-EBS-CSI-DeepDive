#!/bin/bash
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
### Variables:
CLUSTER=syd-ebs-25
ACCOUNT=123456789012
REGION=ap-southeast-2
echo " ### PARAMETERES IN USER >>> CLUSTER=$CLUSTER  ;  ACCOUNT=$ACCOUNT ; REGION=$REGION "

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
echo " ### 1- Clean up  previous stage : deleting >  pod , pvc , pv : "
kubectl delete pod --all
kubectl delete pvc --all
kubectl delete pv --all


### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
echo " ### 2- Creating IRSA for EBS-CSI-Driver : "
eksctl create iamserviceaccount \
  --name ebs-csi-controller-sa \
  --namespace kube-system \
  --cluster $CLUSTER --region $REGION \
  --attach-policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy \
  --approve \
  --role-name AmazonEKS_EBS_CSI_DriverRole_$CLUSTER

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
echo " ### 3- Checking created ServiceAccount  : "
kubectl -n kube-system  describe sa ebs-csi-controller-sa

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
echo " ### 4- Installing aws-ebs-csi-driver with EKSCTL  : "
eksctl create addon --name aws-ebs-csi-driver --cluster $CLUSTER --force --region $REGION \
--service-account-role-arn arn:aws:iam::$ACCOUNT:role/AmazonEKS_EBS_CSI_DriverRole_$CLUSTER 

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
echo " ### 5- Checking created pods  : "
kubectl -n kube-system  get pod | grep csi 


### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
echo " ### 6- Recording Node , csiNode , SC , PVC , PV , POD  :"
kubectl get node -o yaml > node-0-oyaml.yaml
kubectl get csinode -o yaml > csinode-0-oyaml.yaml
kubectl get sc -o yaml > sc-0-oyaml.yaml
kubectl get pv -o yaml > pv-0-oyaml.yaml
kubectl get pvc -o yaml > pvc-0-oyaml.yaml
kubectl get pod -o yaml > pod-0-oyaml.yaml
kubectl get VolumeAttachment -o yaml > volumeattachment-0-oyaml.yaml
kubectl describe node  > node-0-describe.yaml
kubectl describe csinode > csinode-0-describe.yaml
kubectl get csidriver -o yaml > csidriver-0-oyaml.yaml
kubectl describe csidriver > csidriver-0-describe.yaml
kubectl describe sc > sc-0-describe.yaml
kubectl describe pv > pv-0-describe.yaml
kubectl describe pvc > pvc-0-describe.yaml
kubectl describe pod > pod-0-describe.yaml
kubectl -n kube-system logs -l app=ebs-csi-controller -c csi-provisioner > log__csi-provisioner-0.log
kubectl -n kube-system logs -l app=ebs-csi-controller -c csi-attacher > log__csi-attacher-0.log
kubectl -n kube-system logs -l app=ebs-csi-controller -c ebs-plugin > log__ebs-ctl-plugin-0.log
kubectl -n kube-system logs -l app=ebs-csi-node  -c  node-driver-registrar  > log__node-driver-registrar-0.log
kubectl -n kube-system logs -l app=ebs-csi-node -c ebs-plugin > log__ebs-node-plugin-0.log      

sleep 180 

kubectl get node -o yaml > node-oyaml.yaml
kubectl get csinode -o yaml > csinode-oyaml.yaml
kubectl get csidriver -o yaml > csidriver-oyaml.yaml
kubectl describe csidriver > csidriver-describe.yaml
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
kubectl -n kube-system logs -l app=ebs-csi-controller -c csi-provisioner > log__csi-provisioner.log
kubectl -n kube-system logs -l app=ebs-csi-controller -c csi-attacher > log__csi-attacher.log
kubectl -n kube-system logs -l app=ebs-csi-controller -c ebs-plugin > log__ebs-ctl-plugin.log
kubectl -n kube-system logs -l app=ebs-csi-node  -c  node-driver-registrar  > log__node-driver-registrar.log
kubectl -n kube-system logs -l app=ebs-csi-node -c ebs-plugin > log__ebs-node-plugin.log      

