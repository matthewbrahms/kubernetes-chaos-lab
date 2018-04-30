# Building Your Own Kubernetes Chaos Environment!

* TODO: GCP & AWS Terraform support
* TODO: Document scaling procedure
* TODO: Document how this could be used on any three hosts (home lab, raspi 3, etc.)

### Credits:
Inspired by @tammybutow and https://www.gremlin.com/community/tutorials/ !!

## What you will need to get this lab environment working
1. Local computer setup with the following:
	* [Terraform](https://www.terraform.io/downloads.html)
	* [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html)
2. [Digital Ocean account](https://www.digitalocean.com/) with credits available
3. [DataDog account](https://www.datadoghq.com/) with 3 available agent licenses
4. [Gremlin account](https://www.gremlin.com/) for running attacks

## Instructions to bring up the lab environment:
1. Bring up the Digital Ocean set of servers (default is 3):
- Navigate to the `terraform` directory.
- Set variables in `variables.tf.example`
- Rename `variables.tf.example` to `variables.tf`
- Run the following commands:
```
terraform plan
terraform up
```
Be sure to take note of the pubic IP addresses output by Terraform. You will need them in the next step.

2. Start the bootstrap process for Kubernetes:
- Switch to the `ansible` directory
- In the file `k8s-chaos-cluster`, paste in the public IP addresses of your Digital Ocean droplets to set as the `ansible_host=` variables.  Be sure to save that file on exit!
- Next, copy your DataDog API Key onto your clipboard buffer ready to paste in when asked to do so.
- Run the following commands:
```
ansible-playbook 01-kubeadm-initialize.yml
```
At the end of this Ansible play running, you will see in the output logs the kubeadm join command.  You will need to copy/paste and then run an ad-hoc Ansible command against `k8s-node-2` and `k8s-node-3` which will look similar to the following:
```
ansible all -b -m shell -a 'kubeadm join <publicIPofK8Smaster>:6443 --token ntzkyq.c01ymoamv4bk2e6u --discovery-token-ca-cert-hash sha256:f875a5cb87e06873276fd286e8a1ee964f50b1d47ad0b7aec564e4d933b77af9' -l k8s-node-2:k8s-node-3
```

Now we can continue running more Ansible playbooks to finish the setup:
```
ansible-playbook 02-weave-network-initialize.yml
ansible-playbook 03-weave-sock-shop-deploy.yml
```

3. Configure the lab environment for Kubernetes monitoring and Gremlin attacks!
- First, fill in the DataDog API key in the `datadog-agent.yaml.example` file and rename it to `datadog-agent.yaml`
- Second, input your 2 secret keys for Gremlin in the `gremlin-daemonset.yaml.example` file. Save that file as `gremlin-daemonset.yaml`
- Now we need to run an Ansible play to get our k8s manifests to k8s-node-1:
```
ansilbe-playbook 04-post-k8s-install.yml
```
- Now we need to expose the Kubestate metrics for DataDog to scrape and display (this lights up some magical dashboards in DataDog!)  

SSH into the `k8s-node-1` host and run the following commands:
```
ssh -i ~/.ssh/key_for_your_server root@ip.of.k8s-node-1.here
```
```
git clone https://github.com/kubernetes/kube-state-metrics.git
kubectl apply -f ./kube-state-metrics/kubernetes
```
- Now run the setup for DataDog and Gremlin:
```
kubectl apply -f ./kubernetes-tooling/datadog-agent.yaml
kubectl apply -f ./kubernetes-tooling/gremlin-daemonset.yaml
```

At this point, you should head over to DataDog and enable the Kubernetes integration.  This will generate a magical Kubernetes Dashboard for your cluster (this is very cool!).

Alright, success!  

Now you have:
- A finished Kubernetes installation running the Weave Sock Shop
- A fully *instrumented and monitored* Kubernetes cluster
- Locked-and-loaded to run Gremlin attacks against it!

Head over to Gremlin and run your first attack (and watch the chaos graphically unfold in DataDog!)! 

## Cleaning up the environment (reset to beginning)
1. In the `terraform` directory, run the following command and enter "yes" when prompted:
```
terraform destroy
```
That kills everything...just a few more details.

2. In the `ansible` directory, remove the `kubeadm_join.log` file.

3. In the `k8s-chaos-cluster` file, remove the IP addresses you used for your hosts.

Alright, tear-down complete!
