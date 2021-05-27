# Perforce Server for Unreal in a Docker container

Author: Jonas Haberkorn
Sources: See the chapter below
Description: Setting up a perforce server in a docker container that is already configured for Unreal projects.


## Run

To setup the server, you'll need an x86_64 computer with docker installed, then run  

```
    docker build --target perforce-server . -t perforce-server:latest --no-cache
    docker run -d -p 8080:8080 -p 1666:1666 -h perforce --name perforce perforce-server
```  

## Update perforce version

Depending on the version you will use, you will need different elements. First, check the version you would like to use in the (Perforce release index)[https://www.perforce.com/support/software-release-index].  
Then check in the [Perforce yum repository](https://package.perforce.com/yum/) what RHEL version is needed.
Then do the following in the Dockerfile: 
1. Update the `version of the centos image` used based on what is needed (RHEL version)
2. Update the `perforce repo url` with the right RHEL number
3. Update the `P4_VERSION varaible` to match the desired version number (you must ommit the starting '20')


## Sources

This is based on the work of ambakshi on his repo [docker-perforce](https://github.com/ambakshi/docker-perforce)  
It is also based on the changes described by Froyok in his repo [froyok-perforce](https://github.com/Froyok/froyok-perforce) and documented in his [article](https://www.froyok.fr/blog/2018-09-setting-up-perforce-with-docker-for-unreal-engine-4/page.html)

## Disclaimer

I decline any responsibility in case of data loss or in case of a difficult (or even impossible) maintenance if you use this solution.  
I did this as a hobby for a small project with friends, nothing serious or professional.  
If you still want to use it for your project, I would suggest to setup or to do regularly backups of your project.  
