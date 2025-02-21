#Get the line count without coloumn name
$ docker images | tail -n +2 | wc -l
$ docker ps | grep nginx

#list the processes running
ps aux

#GitHacks
git branch #list down tit local branches
git branch -r #list down git remote branches
git branch -a #list down all git local and remote branches, for remotes its prefix /remotes/
git branch -d branch_name #delete a git branch
git branch -D branch_name #force delete a git branch

kubectl exec etcd-controlplane -n kube-system -- sh -c "ETCDCTL_API=3 etcdctl get / --prefix --keys-only --limit=10 --cacert /etc/kubernetes/pki/etcd/ca.crt --cert /etc/kubernetes/pki/etcd/server.crt --key /etc/kubernetes/pki/etcd/server.key"