# Backup and Restore a Kubernetes cluster implemented using kubeadm

kubectl get pod etcd-controlplane -n kube-system -o yaml # check image version
#get following information:
--listen-client-urls=https://127.0.0.1:2379,https://192.23.8.3:2379  #address can you reach the ETCD cluster from the controlplane node
--cert-file=/etc/kubernetes/pki/etcd/server.crt  # server certificate file
--trusted-ca-file=/etc/kubernetes/pki/etcd/ca.crt # ca certificate file
--key-file=/etc/kubernetes/pki/etcd/server.key # server key file

/opt/snapshot-pre-boot.db # file and directory we are going to take backup


#------- Save snapshot 
ENDPOINT="127.0.0.1:2379"
ETCDCTL_API=3 etcdctl --endpoints $ENDPOINT snapshot save /opt/snapshot-pre-boot.db \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt

#----check the status
ENDPOINT="127.0.0.1:2379"
ETCDCTL_API=3 etcdctl --endpoints $ENDPOINT snapshot status /opt/snapshot-pre-boot.db \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt
 
#---- restore from snapshot

ETCDCTL_API=3 etcdctl snapshot restore /opt/snapshot-pre-boot.db --data-dir /var/lib/etcd-from-backup \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt
  
 # edit the --data-dir=/var/lib/etcd-from-backup in /etc/kubernetes/manifests/etcd.yaml  file , makesure to configure the same path for volume mounts
 # finally it will spin-up etcd-controlplane pod , if didnt spin-up just delete it, it will recreate since its a static pod
 
 kubectl logs -n kube-system etcd-controlplane # check logs


 #TODO -----  work with multiple kubernetes clusters where , the practice backing up and restoring the ETCD database. --------#
kubectl config get-clusters #get available clusters
kubectl config use-context cluster1 # switch to cluster1
kubectl config use-context cluster2 # switch to cluster2

#---------------------------
kubectl config get-clusters
kubectl config use-context cluster1
k get nodes

kubectl config use-context cluster2 
k get nodes

cluster1-controlplane
cluster1-node01 

cluster2-controlplane
cluster2-node01 

# when configuring etcd as a pod , we call it stacked etcd
 kubectl get pod kube-apiserver-cluster2-controlplane -n kube-system -o yaml  # if its showing the same ip as controlplane node or localhost, its a stacked etcd
- --etcd-servers=https://192.9.219.15:2379

#What is the default data directory used the for ETCD datastore used in cluster1?
kubectl get pod etcd-cluster1-controlplane -n kube-system -o yaml
- --data-dir=/var/lib/etcd


# accessing etcd server of cluster 2
ssh etcd-server
# On cluster 2 : Connected etcd Server 
service etcd status # this gives me information about
/etc/systemd/system/etcd.service
--data-dir=/var/lib/etcd-data
vim /etc/systemd/system/etcd.service

# getting member (How many nodes are part of etcd cluster) list of ETCD server of cluster 2
--trusted-ca-file=/etc/etcd/pki/ca.pem
https://127.0.0.1:2379
--key-file=/etc/etcd/pki/etcd-key.pem
--cert-file=/etc/etcd/pki/etcd.pem

ETCDCTL_API=3 etcdctl --endpoints 127.0.0.1:2379 \
  --cert=/etc/etcd/pki/etcd.pem \
  --key=/etc/etcd/pki/etcd-key.pem \
  --cacert=/etc/etcd/pki/ca.pem \
  member list

# gets the etcd members of ETCD server of cluster 1
ssh cluster1-controlplane

# Take a backup of etcd on cluster1 and save it on the student-node at the path /opt/cluster1.db
#information
--data-dir=/var/lib/etcd
--cert-file=/etc/kubernetes/pki/etcd/server.crt
--advertise-client-urls=192.9.219.22:2379
--key-file=/etc/kubernetes/pki/etcd/server.key
--trusted-ca-file=/etc/kubernetes/pki/etcd/ca.crt

ETCDCTL_API=3 etcdctl --endpoints 192.9.219.22:2379 \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  member list

# saving snapshot
ETCDCTL_API=3 etcdctl --endpoints 192.9.219.22:2379 snapshot save /opt/cluster1.db \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt

scp cluster1-controlplane:/opt/cluster1.db /opt/cluster1.db
ls /opt/cluster1.db


#---- restore from snapshot for ETCD server of cluster 2
# from student node
scp /opt/cluster2.db etcd-server:/opt/cluster2.db

ETCDCTL_API=3 etcdctl --endpoints 127.0.0.1:2379 snapshot restore /opt/cluster2.db --data-dir /var/lib/etcd-data-new \
  --cert=/etc/kubernetes/pki/etcd/server.crt \
  --key=/etc/kubernetes/pki/etcd/server.key \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt

vim /etc/systemd/system/etcd.service

chown -R etcd:etcd /var/lib/etcd-data-new #make sure the permissions are set

# restart etcd service
systemctl daemon-reload
service etcd restart

#Job done