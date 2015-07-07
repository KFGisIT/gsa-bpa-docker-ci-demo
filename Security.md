#Security
##Docker Security Issues

Since security was mentioned in the RFP, our internal security team reviewed the Dockerfile configuration for the Drupal host. Typically, many of the "official" Dockerfiles (even for projects like MySQL) do little beyond installing the target package. Our Dockerfile, while still not intended for production use, does a number of things that help ease the burden on system administrators:
1. The dockerfile installs and configures unattended-upgrades -- this installs important security updates automatically via the internal OS package management system. It will optionally email system administrators in order to keep an eye on things. In this way, containers need not be rebuilt for simple security updates. 
2. The dockerfile automatically installs any public keys in the authoirzed_keys files in the project's root. If you don't have a key, you can run docker_setup_container_ssh.sh which will generate a public key for your user if you don't have one or it will copy your id_rsa key into authorized keys. Many Dockerfiles on Dockerhub explicitly set a root password and enable password login for root in SSHd which we frown upon.
3. Similarly, MySQL and MariaDB services are  typically bundled with a secure_mysql installation script. We provide this in the repository, and the Dockerfile locks down the mysql installation by removing guest accounts, setting a randomly generated mysql password and then saves that password to /root/.my.cnf for future use. 
4. The site's username and password can be specified in the docker file; we left that for conveinence of the user. You are strongly encouraged to change it. 
5. The site's database username and password can be changed at the top of the file. This is useful if your mysql server is not running on the same container. We did it this way to make it easier for developers and testers to deploy this project quickly.
6. Steps are taken to drop privileges in the Apache server process, and to secure the Drupal installation. In a typical Drupal installation, the www-data user has no permission to upload executable code. This helps mitigate security issues by preventing mallicious users from uploading PHP scripts. Toward the end of the Dockerfile, steps are taken to follow Drupal best practices and establish this configuration. 

Though it is possible to run these Docker containers completely without SSH, we prefer to try to use the same Dockerfiles for staging and pre-production testing, and not to give developers access to the hosts on which containers run for the purposes of attaching to a running container. SSH is also convenient when developers have more than one workstation (e.g. MacOS and Linux).

Other steps can be taken to lock these images down further; production use is not recommended.



