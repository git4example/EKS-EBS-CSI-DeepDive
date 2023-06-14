#!/bin/bash
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
### Variables:
CLUSTER=syd-ebs-25
REGION=ap-southeast-2

echo " ### PARAMETERES IN USER >>> CLUSTER=$CLUSTER  ;  REGION=$REGION"



### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
echo " ### 1- Create cluster "

eksctl create cluster  -f - <<EOF
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig
metadata:
  name: $CLUSTER
  region: $REGION
  version: "1.25"

managedNodeGroups:
  - name: mng
    privateNetworking: true
    desiredCapacity: 2
    instanceType: t3.medium
    labels:
      worker: linux
    maxSize: 2
    minSize: 0
    volumeSize: 20

iam:
  withOIDC: true

cloudWatch:
  clusterLogging:
    enableTypes:
      - "*"

EOF

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
echo " ### 2- kubeconfig  : "
aws eks update-kubeconfig --name $CLUSTER --region $REGION


### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
echo " ### 3- Check cluster node and infrastructure pods  : "
kubectl get node
kubectl -n kube-system get pod 



### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
echo " ### 4- Recording Node , csiNode , SC , PVC , PV , POD  :"

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

# eksctl scale nodegroup mng --cluster $CLUSTER --region $REGION -N=2
sleep 180

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

kubectl get csidriver -o yaml > csidriver-oyaml.yaml
kubectl describe csidriver > csidriver-describe.yaml