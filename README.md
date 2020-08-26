# lockdown-sudo-for-elasticsearch

Some users of Elasticsearch may want to store data that is sensitive. Elastic already provides a number of ways to secure access to data in a cluster but what about infrastructure admins?

Imagine patient record data that is held in a cluster which has been secured to provide the appropriate doctors access to only their own patients. There will always be adminitrators of the cluster and administrators of infrastructre and normally this is acceptable to opperate a system but where you may have a large number of SREs or administrators which need to manage the infrastructure and therefore require sudo access, you may want to look at additional controls that could be put in place to both limit access and provide a security aduit as much as possible to reduce the risk of administrators accessing sensitive data.

In this example we will add some additional controls to an example system based on Centos.


## Setup
(Tested on GCP Red Hat 7)
sudo yum install -y git
git clone https://github.com/m-adams/lockdown-sudo-for-elasticsearch.git
cd lockdown-sudo-for-elasticsearch/
sudo ./setup.sh

## Notes/TODO
- Create an example sudo admin
- Add Elasticsearch
- Add some data
- Elasticsearch security and audit config
- Add Auditbeat to monitor the data dir
https://www.thegeekdiary.com/how-to-audit-file-access-on-linux/
-w /etc/hosts -p r -k hosts_read
We would need to drop any events by the elastic user in auditbeat

- SeLinux config
https://wiki.gentoo.org/wiki/SELinux/Tutorials/How_SELinux_controls_file_and_directory_accesses
http://blog.siphos.be/2015/07/restricting-even-root-access-to-a-folder/

- Filebeat to monitor Audit logs
