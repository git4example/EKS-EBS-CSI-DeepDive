#!/bin/bash
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
### Variables:

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
echo " ### 1- Clean up  previous stage : deleting >  pod , pvc , pv : "
kubectl delete pod --all
kubectl delete pvc --all
kubectl delete pv --all

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
echo " ### 2- Creating dynamic volume claim = ebs-claim with default Storageclass = gp2 : "
kubectl apply -f - <<EOF
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: ebs-claim
spec:
  accessModes:
    - ReadWriteOnce
#  storageClassName: gp2
  resources:
    requests:
      storage: 2Gi
EOF

kubectl get pv -o yaml > pv-0-oyaml.yaml
kubectl get pvc -o yaml > pvc-0-oyaml.yaml
kubectl describe pvc > pvc-0-describe.yaml
kubectl describe pod > pod-0-describe.yaml
### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
echo " ### 3- Creating pod = app   : "
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
    args: ["-c", "while true; do echo $(date -u) >> /data/out.txt; sleep 5; done"]
    volumeMounts:
    - name: persistent-storage
      mountPath: /data
  volumes:
  - name: persistent-storage
    persistentVolumeClaim:
      claimName: ebs-claim
EOF

### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ### ###
echo " ### 4- Recording Node , csiNode , SC , PVC , PV , POD  :"
kubectl get node -o yaml > node-0-oyaml.yaml
kubectl get csinode -o yaml > csinode-0-oyaml.yaml
kubectl get sc -o yaml > sc-0-oyaml.yaml

kubectl get pod -o yaml > pod-0-oyaml.yaml
kubectl get VolumeAttachment -o yaml > volumeattachment-0-oyaml.yaml
kubectl describe node  > node-0-describe.yaml
kubectl describe csinode > csinode-0-describe.yaml
kubectl describe sc > sc-0-describe.yaml
kubectl describe pv > pv-0-describe.yaml

kubectl get csidriver -o yaml > csidriver-0-oyaml.yaml
kubectl describe csidriver > csidriver-0-describe.yaml
Sleep 180 

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

