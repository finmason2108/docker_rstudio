# docker_rstudio
Finmasonized RStudio-Server in a docker container.
version is taken from branch name

## Running
In order to use users from the host machine, this container uses this https://jhrozek.wordpress.com/2015/03/31/authenticating-a-docker-container-against-hosts-unix-accounts/ as a suggestions.  All the host files were able to be used verbatim.  On ubuntu, you need `sssd-common sssd-proxy sssd` packages installed.

Then, to run, do `docker run -d -p 8787:8787 -v /storage/src:/storage/src -v /home:/home -v /var/lib/sss/pipes/:/var/lib/sss/pipes/:rw finmason/docker_rstudio`

Note that this requires SSSD running on the host.  See OPS-113 for details.

This provides Rstudio on 8787, with users provided via /etc/passwd on the host.

If you want to use this same image (now preloaded with R libraries to run scripts, you can do

```
docker run -it --name=testR --rm -v /home:/home -v /var/lib/sss/pipes/:/var/lib/sss/pipes/:rw -v /storage:/storage finmason/docker_rstudio Rscript /full/path/to/hello.r
```

This command can of course be aliased.  i.e:

```
alias docker_run_r="docker run -it --name=testR --rm -v /home:/home -v /var/lib/sss/pipes/:/var/lib/sss/pipes/:rw -v /storage:/storage finmason/docker_rstudio Rscript"
docker_run_r /full/path/to/hello.r
[1] "hello"
```

## Updating
You can update this yourself!  Documentation how to is in Confluence: https://finmason.atlassian.net/wiki/spaces/ID/pages/716242961/RStudio+and+base+R+containers
 

## Python
There are pre-prepared Packages_*.py2/3 files for handling python2/3 installation. Please bear in mind that at least one .py2 or .py3 file needs to be in place for Packages_xxx. 
