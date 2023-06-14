#!/bin/bash
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
### Variables:

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
echo " ### 1- deleting pod and PVC : "
kubectl delete pod --all
kubectl delete pvc --all
kubectl delete pv --all

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
echo " ### 2- Recording Node , csiNode , SC , PVC , PV , POD  :"

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

