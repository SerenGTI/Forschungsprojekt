
# Things

First install Open JDK
```
sudo apt-get install default-jdk
``


Create a new group hadoop and user hduser
```
sudo addgroup hadoop
sudo adduser --ingroup hadoop hduser
```



Download and install hadoop.
```
cd /usr/local
sudo wget http://archive.apache.org/dist/hadoop/core/hadoop-0.20.203.0/hadoop-0.20.203.0rc1.tar.gz
sudo tar xzf hadoop-0.20.203.0rc1.tar.gz
sudo mv hadoop-0.20.203.0 hadoop
```
Allow read rights to hadoop group
```
sudo chown -R hduser:hadoop hadoop
```


Find the name of the installed JDK folder by running 
```
ls /usr/lib/jvm
```
for us it was `/usr/lib/jvm/java-11-openjdk-amd64`. User this path in the following commands.

Switch to the hduser using `su hduser` and append the following to their `$HOME/.bashrc`
```

```


Now edit `/usr/local/hadoop/conf/hadoop-env.sh`
```
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
export HADOOP_OPTS=-Djava.net.preferIPv4Stack=true
```


Switch back to the admin user and create a temporary directory
```
sudo mkdir -p /app/hadoop/tmp
sudo chown hduser:hadoop /app/hadoop/tmp
sudo chmod 750 /app/hadoop/tmp
```

Now check that the `/etc/hosts` is correctly configured with
```
127.0.0.1 localhost
<IP> <hostname>
```
make sure to replace IP and hostname with the current IP of this machine and the hostname with the corresponding hostname.

