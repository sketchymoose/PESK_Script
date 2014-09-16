cd ~
#!/bin/bash
# Script to install Kibana & Elastic Search
# Tested on Ubuntu 14.04 64 bit LTS Server
# @sk3tchymoos3

echo "Please give me the IP of the ElasticSearch instance: "
read ip
	
function install_base_packages() {
	echo "Downloading some packages..."
	sudo apt-get update
	#the python-dev is so enable speedups.c for simplejason
	sudo apt-get install -y vim python-software-properties software-properties-common apache2 screen git python-setuptools apache2-utils python-dev 
}

function install_elasticsearch(){
	echo "Installing Elasticsearch..."
	cd $HOME
	#wget https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.3.2.tar.gz
	#tar -zxf elasticsearch-1.3.2.tar.gz
	wget https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.3.2.deb
	sudo dpkg -i elasticsearch-1.3.2.deb
	sudo sed -i "s/#network\.bind_host.*/network.bind_host: $ip/" /etc/elasticsearch/elasticsearch.yml
	sudo bash -c "echo 'script.disable_dynamic: true' >> /etc/elasticsearch/elasticsearch.yml"	
}
function install_kibana() {
	echo "Installing Kibana...."
	sudo add-apt-repository ppa:webupd8team/java
	sudo apt-get update
	sudo apt-get install -y oracle-java7-installer
	cd $HOME
	wget https://download.elasticsearch.org/kibana/kibana/kibana-3.1.0.tar.gz
	tar -zxf kibana-3.1.0.tar.gz
	sed -i "s/elasticsearch:.*/elasticsearch: \"http:\/\/$ip:9200\",/" $HOME/kibana-3.1.0/config.js
	cd $HOME/kibana-3.1.0/
	sudo cp -r ./* /var/www/html
}

function install_plaso(){
	echo "Installing Plaso..."
	sudo add-apt-repository ppa:sift/stable
	sudo apt-get update
	sudo apt-get install -y python-plaso
	cd /tmp	
	git clone https://github.com/rhec/pyelasticsearch.git
	cd pyelasticsearch
	python setup.py build
	sudo python setup.py install
	sudo wget -O /var/www/html/app/dashboards/plaso.json https://plaso.googlecode.com/git/extra/plaso_kibana_example.json 
}

install_base_packages
install_elasticsearch
install_kibana
install_plaso

echo "Ok done! Do you want me to start things for you?(y/n)"
read answer
if answer="y"
then
	sudo /etc/init.d/apache2 start
	sudo /etc/init.d/elasticsearch restart
	echo "Ok, the web server is started and elastic search is running, now just use psort.py to import some dump files!"
	exit
else
	exit
fi
