
We will install Hadoop on one or more machines, setup communication between the nodes and finally install Giraph.
Additionally will show how to use our graph conversion tool and how to run SSSP and PageRank applications with the converted graphs.

# Prerequisites
First install Open JDK, git and maven
```
sudo apt-get update
sudo apt-get upgrade
sudo apt-get install default-jdk git maven net-tools
```

The installation can be done with a `hadoop` group and `hduser` user.
We will however not use a different user for the installation. So the following is optional.
```
sudo addgroup hadoop
sudo adduser --ingroup hadoop hduser
```


## Download and install Hadoop
We will download hadoop from apache and install it in `/usr/local/hadoop`.
The Giraph quick start guide recommends the version 0.20.203. We found that using 0.20.205 solves a problem with `Failed map tasks`.
```
cd /usr/local
```
Giraphs quick start guide installs an outdated version of hadoop with which our giraph jobs only failed. So we recommend the following
```
sudo wget http://archive.apache.org/dist/hadoop/core/hadoop-0.20.205.0/hadoop-0.20.205.0.tar.gz
sudo tar xzf hadoop-0.20.205.0.tar.gz
sudo mv hadoop-0.20.205.0 hadoop
sudo rm hadoop-0.20.205.0.tar.gz
```


Now you will have to modify the permissions for this folder.
If you are using a dedicated user and group, allow read rights to the hadoop group and hduser,
```
sudo chown -R hduser:hadoop hadoop
```
else just make yourself the owner of the folder.
```
sudo chown -R <username> hadoop
```


# Configuring Hadoop
Find the name of the installed JDK folder by running 
```
ls /usr/lib/jvm
```
for us it was `/usr/lib/jvm/java-11-openjdk-amd64/`. Use this path in the following commands.
It *should* be possible to use the `/usr/lib/jvm/default-java` link.

(Switch to the hduser using `su hduser` and) append the following to the `$HOME/.bashrc`
```
export HADOOP_HOME=/usr/local/hadoop
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
export GIRAPH_HOME=/usr/local/giraph
```
Close, save and reload it.
```
source ~/.bashrc
```
Now edit `/usr/local/hadoop/conf/hadoop-env.sh`
```
export JAVA_HOME=/usr/lib/jvm/java-11-openjdk-amd64
export HADOOP_OPTS=-Djava.net.preferIPv4Stack=true
```
The second line will force Hadoop to use IPv4 instead of IPv6.


Create a temporary directory for hadoop to work on
```
sudo mkdir -p /app/hadoop/tmp
sudo chown <username> /app/hadoop/tmp
sudo chmod 750 /app/hadoop/tmp
```

## Setting up access to other nodes
*If the nodes you want to add to the cluster are available under a domain, rather than only via an IP address, you can skip this part and use that domain name in place of the hostnames you will have to put in the configuration later.*

Find out the ip of all machines with
```
hostname -I
```
and note that it might differ from the one used to ssh into the machine.
Now check that the `/etc/hosts` is correctly configured for each master and slave with
```
127.0.0.1 localhost
<IP> <master-hostname>
<IP> <slave1-hostname>
<IP> <slave2-hostname>
...
```
make sure to replace IP and hostname. The hostnames do not need to be the same as the actual hostnames of the machine. `master` or `slave1` is allowed.
*Use these hostnames in the configuration below.*

## Setting up password-less ssh between the nodes
*This is necessary regardless of the amount of nodes in the cluster, meaning you will need to perform this step even on a single node cluster!*

On the master, generate a set of ssh keys
```
ssh-keygen -t rsa -P ""
```

Add this key to the authorized keys to all machines.
So first allow password-less ssh from master to master by running
```
cat $HOME/.ssh/id_rsa.pub >> $HOME/.ssh/authorized_keys
```
this is the only step you will have to perform on a single node cluster.

For all other slaves, run
```
ssh-copy-id -i $HOME/.ssh/id_rsa.pub <username>@slave
```
to copy the public key to the slaves. It is important that you use the same username on all machines.
If this command does not work because access to the slaves is also only by rsa keypair, log into the slave and append the contents of `$HOME/.ssh/id_rsa.pub` to the slaves `$HOME/.ssh/authorized_keys` by hand.

Now check that everything works
```
ssh <username>@master
ssh <username>@slave1
...
```

## Config files of a single-node cluster
*Skip this if you want to set up a multi-node cluster.*

We are working in the `$HADOOP_HOME/conf` directory. Add the following between the `<configuration>...</configuration>` in the files specified below. Note that `<hostname>` has to be replaced with whatever you put in `/etc/hosts` file.
In `core-site.xml`
```
<property>
<name>hadoop.tmp.dir</name>
<value>/app/hadoop/tmp</value>
</property>

<property> 
<name>fs.default.name</name> 
<value>hdfs://<master-hostname>:54310</value> 
</property>
```

In `mapred-site.xml`
```
<property>
<name>mapred.job.tracker</name> 
<value><master-hostname>:54311</value>
</property>

<property>
<name>mapred.tasktracker.map.tasks.maximum</name>
<value>4</value>
</property>

<property>
<name>mapred.map.tasks</name>
<value>4</value>
</property>

<property>
  <name>mapred.child.java.opts</name>
  <value>-Xmx<some size>G</value>
</property>
```
Replace `<some size>` with the maximum Heap Size in GB you would like a mapred task to have.

In `hdfs-site.xml`
```
<property>
<name>dfs.replication</name> 
<value>1</value> 
</property>
```

Now edit both `$HADOOP_HOME/conf/masters` and `$HADOOP_HOME/conf/slaves` to only contain the master's hostname.


## Config files of a multi-node cluster
*Skip this if you want to set up a single-node cluster.*
### Configuration of the master
Edit `$HADOOP_HOME/conf/masters` to contain the hostname `<master-hostname` of the master.
Edit `$HADOOP_HOME/conf/slaves` to contain the hostnames of all nodes
```
<master-hostname>
<slave1-hostname>
<slave2-hostname>
...
```

### Configuration for all nodes
We will now need to set the configuration of all nodes (including the master) by copying the properties given below between the `<configuration>...</configuration>` tags.

In `$HADOOP_HOME/conf/core-site.xml` we add
```
<property>
  <name>hadoop.tmp.dir</name>
  <value>/app/hadoop/tmp</value>
</property>

<property>
  <name>fs.default.name</name>
  <value>hdfs://<master-hostname>:54310</value>
</property>
```
to specify the NameNode host and port. This is the master.


Second in `$HADOOP_HOME/conf/mapred-site.xml` we add
```
<property>
  <name>mapred.job.tracker</name>
  <value><master-hostname>:54311</value>
</property>

<property>
  <name>mapred.local.dir</name>
  <value>/app/hadoop/tmp/mapred</value>
</property>

<property>
  <name>mapred.child.java.opts</name>
  <value>-Xmx<some size>G</value>
</property>
```
Replace `<some size>` with the maximum Heap Size in GB you would like a mapred task to have.

And last we edit `$HADOOP_HOME/conf/hdfs-site.xml` to contain
```
<property>
  <name>dfs.replication</name>
  <value><your number></value>
</property>
```
where we will need to replace `<your number>` with an integer less or equal to the amount of nodes in the cluster. So for one master and one slave, put this to 2. The dfs.replication specifies the default block replication. It defines how many machines a single file should be replicated to before it becomes available. The default value is 3.

## Formatting the Hadoop DFS
On the master or the only node in a single node cluster, we run
```
$HADOOP_HOME/bin/hadoop namenode -format
```
to format the file system.

If this fails, check that you set the permissions to `/app/hadoop/tmp` correctly.

## Starting the single node cluster
Now start up the deamons by running
```
$HADOOP_HOME/bin/start-dfs.sh
$HADOOP_HOME/bin/start-mapred.sh
```

Check that everything worked by running `jps`. The output should be something like the following (on a single node cluster, ignore the PIDs)
```
12880 SecondaryNameNode
14272 Jps
13169 TaskTracker
12513 NameNode
12691 DataNode
12985 JobTracker
```

To stop the deamons, run the corresponding `$HADOOP_HOME/bin/stop-*.sh` commands in *reverse order*.

## Starting the multi node cluster
On the master, run 
```
$HADOOP_HOME/bin/start-dfs.sh
```

To check that everything is working as intended, run `jps` on master and slave. We expect
```
32880 DataNode
33075 SecondaryNameNode
33144 Jps
32701 NameNode
```
on master and 
```
31415 DataNode
31484 Jps
```
on the slaves. Ignore the Process IDs.

We will now start the map-reduce deamons. Run 
```
$HADOOP_HOME/bin/start-mapred.sh
```
on the master.

If you run `jps` again, there should now be a `TaskTracker` running on every node and a `JobTracker` on the master.

To stop the deamons, run the corresponding `$HADOOP_HOME/bin/stop-*.sh` commands in *reverse order*.


# Installing Giraph
We install giraph on the master node. First clone the repository
```
cd /usr/local/
sudo git clone https://github.com/apache/giraph.git
sudo chown -R <username> giraph
```
and then install the package using maven. *Note:* If you plan on using our or your own Applications, read the following subsection first.
(Re-)Package the giraph jar using the command
```
cd $GIRAPH_HOME
mvn package -DskipTests
```
You do *not* need to copy the resulting jar to all nodes of the cluster!
Giraph can now be used to run jobs.


## Installing our or your own Applications
*This step is optional*

Since Giraph does not provide a useful SSSP application - the start node could not be parameterized, we had to modify the given example.
The supplied file `GeneralShortestPathsComputation.java` is copied in the already existing examples folder
```
$GIRAPH_HOME/giraph-examples/src/main/java/org/apache/giraph/examples
```

For the BFS application we used, the supplied file `SimpleBFSStructureComputation.java` is copied in the examples folder as well.

You will need to repackage after adding applications.
```
cd $GIRAPH_HOME
mvn package -DskipTests
```

Our Conversion tool writes the vertex input graph format
`org.apache.giraph.io.formats.JsonLongDoubleFloatDoubleVertexInputFormat`, this is used as input format in our examples.


# Running Giraph Jobs
Running Griaph applications is relatively straight forward from this point on.
You will need to convert input graphs into a format readable by Giraph and load all input graphs on the HDFS before attempting to start a job.

## Converting Graphs
We have written a conversion of edge list graphs into the `org.apache.giraph.io.formats.JsonLongDoubleFloatDoubleVertexInputFormat`. All initial vertex weights will be set to 1, also for an unweighted input graph, the edge weights will be set to 1.
In the case of an unweighted input graph, convert using
```
./sortEdgeList --in <inputGraph> -g <outputGraph>
```
or for a weighted input graph
```
./sortEdgeList --in <inputGraph> -g <outputGraph> --weighted
```
where sortEdgeList is our conversion tool available at `scripts/sortEdgeList.cpp`.

## Copying graph files to the HDFS
All input and output files must be copied to the hadoop dfs. Only there are they accessible through Giraph. You can copy to the HDFS with
```
$HADOOP_HOME/bin/hadoop dfs -copyFromLocal <path on regular fs> <path on hdfs>
```
And then check the contents of the directory with
```
$HADOOP_HOME/bin/hadoop dfs -ls <path on hdfs>
```
## Loading data from the HDFS
In the same way, you can retrieve the output from HDFS by running
```
$HADOOP_HOME/bin/hadoop dfs -copyToLocal <path on hdfs> <path on regular fs> 
```

## SSSP
We run the computation with the following command. It specifies the input and output format, our computation class followed by the start vertex id and the paths to the input and output files.
You will need to replace the following
* `<start vertex id>`: The vertex id from which to start the SSSP.
* `<input path>`: The input graph filename/path to the input graph. Remember that this path is on the HDFS (check above on how to copy to HDFS).
* `output path>`: The output folder name/output path. Remember that this path is on the HDFS (check above on how to copy from the HDFS). Always remember to specify a new directory in the output path flag. Otherwise, the computation will crash.
* `<cluster size>`: Make sure to set the `-w` flag to the amount of workers i.e. the amount of nodes in the cluster!

*We recommend copying this command in a text editor and editing it before putting it in the console..*
```
$HADOOP_HOME/bin/hadoop jar $GIRAPH_HOME/giraph-examples/target/giraph-examples-1.3.0-SNAPSHOT-for-hadoop-1.2.1-jar-with-dependencies.jar org.apache.giraph.GiraphRunner org.apache.giraph.examples.GeneralShortestPathsComputation <start vertex id> -vif org.apache.giraph.io.formats.JsonLongDoubleFloatDoubleVertexInputFormat -vip <input path> -vof org.apache.giraph.io.formats.IdWithValueTextOutputFormat -op <output path> -w <cluster size>
```


## PageRank
We run the computation with the following command. It specifies the input and output format, some classes required for computation and the paths to the input and output files.
* `<input path>`: The input graph filename/path to the input graph. Remember that this path is on the HDFS (check above on how to copy to HDFS).
* `<output path>`: The output folder name/output path. Remember that this path is on the HDFS (check above on how to copy from the HDFS). Always remember to specify a new directory in the output path flag. Otherwise, the computation will crash.
* `<cluster size>`: Make sure to set the `-w` flag to the amount of workers i.e. the amount of nodes in the cluster!

*We recommend copying this command in a text editor and editing it before putting it in the console..*
```
$HADOOP_HOME/bin/hadoop jar $GIRAPH_HOME/giraph-examples/target/giraph-examples-1.3.0-SNAPSHOT-for-hadoop-1.2.1-jar-with-dependencies.jar org.apache.giraph.GiraphRunner org.apache.giraph.examples.SimplePageRankComputation -vif org.apache.giraph.io.formats.JsonLongDoubleFloatDoubleVertexInputFormat -vip <input path> -vof org.apache.giraph.io.formats.IdWithValueTextOutputFormat -op <output path> -mc org.apache.giraph.examples.SimplePageRankComputation\$SimplePageRankMasterCompute -wc org.apache.giraph.examples.SimplePageRankComputation\$SimplePageRankWorkerContext -w <cluster size>
```

## BFS
We run the computation with the following command. It specifies the input and output format and the paths to the input and output files.
* `<start vertex id>`: The vertex id from which to start the BFS.
* `<input path>`: The input graph filename/path to the input graph. Remember that this path is on the HDFS (check above on how to copy to HDFS).
* `<output path>`: The output folder name/output path. Remember that this path is on the HDFS (check above on how to copy from the HDFS). Always remember to specify a new directory in the output path flag. Otherwise, the computation will crash.
* `<cluster size>`: Make sure to set the `-w` flag to the amount of workers i.e. the amount of nodes in the cluster!

```
$HADOOP_HOME/bin/hadoop jar $GIRAPH_HOME/giraph-examples/target/giraph-examples-1.3.0-SNAPSHOT-for-hadoop-1.2.1-jar-with-dependencies.jar org.apache.giraph.GiraphRunner org.apache.giraph.examples.SimpleBFSStructureComputation <start node> -vif org.apache.giraph.io.formats.JsonLongDoubleFloatDoubleVertexInputFormat -vip <input path> -vof org.apache.giraph.io.formats.IdWithValueTextOutputFormat -op <output path> -w <cluster size>
```


### Some problems and how to fix them:
* The `class org.apache.giraph.examples.SimplePageRankComputation not <some other class>` exception. In this case, you selected the inner class of the MasterCompute or WorkerContext falsely. The correct way to adress those is `packageName.OuterClass\$InnerClass`! The backslash is very important. Check the supplied command above, the WorkerContext and MasterCompute  are selected correctly.
* The console output is very short and the log file contains the exception
`Tried to access reducer which wasn't registered <aggregator name>; Aggregators can be registered from MasterCompute by calling registerReducer function\. [...]`. Here you forgot to create a MasterCompute class or failed to tell giraph which one to use. Just add the `-mc` flag followed by the class name of a `MasterCompute`.

---
