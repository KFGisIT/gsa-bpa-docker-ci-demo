#Knowledge Facilitation Group#
##Response to RFQ993471##

![alt tag](screenshot.png)

Visit our demo sites 

*	[Yuck.io](http://yuckio.kfgisit.com "demo site"), Food and Drug Enforcement Where *You* Live
* [Drupal Dataset Publication Platform](http://bpadatasets.kfgisit.com "Drupal Dataset"), our dataset publishing platform

#Description#

Thank you for evaluating this work in response to the RFQ. Given the aggressive timeline of the RFQ, we decided to approach the problem by recycling work from past projects based on open source componentry. Given the language in the RFQ and the tone of reduce, reuse, recycle we thought it would be appropriate to show how we would approach the problem and leverage the combination of several open source packages working in concert to solve a problem.
Please note that we normally use a non-public git-based version control system, [Phabricator](http://phabricator.org/ "phabricator") with our project workflow process for clients. While we love GitHub, usually our clients are not comfortable using public repos for their projects. 
Our response to the RFQ is divided into two pieces: 

1.	[Drupal Dataset Publication Platform] (http://bpadatasets.kfgisit.com "Drupal Dataset Front End"),
A Drupal-based website that essentially a “dataset publishing platform” (similar to data.gov.uk) that is capable of cataloging, graphing and displaying many generic datasets (including GeoJSON, CSV and others)
 
2. [Yuck.io] ("http://yuckio.kfgisit.com"), A sample scenario-specific front-end, titled “Yuck.io” which is a website that finds food and drug recalls in your state. The “Yuck.io” site is based on Bootstrap, Django. 
###Getting Up And Running###Build a container that contains Drupal and the starter database from the installation profile. 

```bash# docker build -t bpademo/drupal  -f Dockerfile  .# docker run -d -p 80:8000 [image id]
```
          Build a container that contains the “Yuck.io” project ```bash# docker build -t bpademo/yuckio  -f Dockerfile-yuckio  .          # docker run -d -p 81:8000 [image id]     
```
       You can learn more about what’s involved with setting these sites up by reading the Dockerfiles associated with each project because they contain comments. This repository also contains helper scripts called by and explained further in the Dockerfiles’ comments. For simplicity of communication, we have opted not to use fig/compose for this demonstration (which would better support multi-container applications). 
###Hosting/Servers###The demonstration URLs are hosted on our development machines. However, they are ordinary docker containers and have been tested to be compatible with [Machine] (https://docs.docker.com/machine/), a tool that helps containers run in Amazon AWS, Digital Ocean, etc. We have experience deploying this in Amazon’s FedRAMP cloud space, too. 
###Background###
The “Yuck.io” site is a completely original project that is meant to demonstrate a “high-fidelity” front-end project that re-uses technology our teams are familiar with under the hood, and incorporates technologies mentioned in RFQ. It is a site that could be used by anonymous public visitors to query food and drug recalls in their state. The dataset is delivered via JSONP queries to the FDA’s JSON API. It was also something our designers and copywriters could have a hand in contributing to because it is an original work. With a new food recall or illness story on the news seemingly every day, more people are looking to the government, specifically the FDA, to make sure their families are safe. This natural reaction to news stories is the concept behind the site. Yuck.io is a new web application that pulls FDA's enforcement information for the general public to view recent enforcement activity related to food and drugs. The Drupal Dataset Publishing Platform is an entire dataset publishing platform. It is a similar concept to data.gov.uk and can syndicate many different kinds of datasets including CSV, JSON, GeoJSON and more. The site has several example datasets, and more can be created and published for anonymous public consumption through the backend GUI on the site. This type of project scales very well to large teams because it can be worked on in parallel by several different teams. This is because we leverage continuous integration and automation to easily provide teams with access to their own sandboxes by leveraging Docker automation to orchestrate automation of the underlying technologies to quickly create a turn-key Drupal-based Dataset Publishing platform. 
 [DIAGRAM HERE SHOWING HOW MODULES/THEMES CAN BE CLONED WITH GIT IN THE DOCKERFILE OR CAN MAKE THEIR WAY INTO THE INSTALL PROFILE?] 
 In such a workflow, continuous integration and testing is important. As such, for this Drupal project, which is based on PHP, we leverage [Travis](https://travis-ci.org), [Selenium](http://www.seleniumhq.org/), and [PHPUnit](https://phpunit.de/) for Unit Testing.

#Approach#

To address the modern enterprise and in line with our user story of a highly mobile user community, we chose to employ the Twitter Bootstrap Responsive Design Framework based in HTML5, CSS3, and jQuery. This allows our design to flex for devices across the mobile (phone/tablet) and desktop platforms. 

To test our work, rather than modeling individal testers and test plans, we make use of automated testing via the Python Selenium framework. This allows us to make assertions about the user experience and implement true test-driven agile development from the functional level as well as the unit testing level. These tests are all committed into the project repository and allow for future extensibiliy with full regression tesing capabilites.

To accomplish this, we broke the project down into three phases. Each phase employs interactive feedback between the designers, developers & engineers to create and deploy the prototype.

1.	Design
2. 	Development
3. 	Deployment

[Used an interactive approach-feedback informed subsequent work or versions of the prototype]

##Design Process##
***asked Krista***

[Understand what 'people' need, by including people in the prototype design process]

[Used at least 3 'human-centered design' tools and techniques]

[Created or used a design style guide or a pattern library]

##Architecture##
*	Linux-Apache-Python Server Stack
*	Docker
*	HTML5
* 	CSS3
*	Python 3.3.*
*	Django 1.7.*
*	Selenium 2.46.*
*	JavaScript 
*	jQuery 2.1.4
* 	Bootstrap 3.3.*
* 	Bower 0.1.0
*	Npm 2.10.1
*	Pip 7.0.3

##Systems Engineering##
	
###Configuration Management###

**Installation**

Based in Python3 & Django's web framework, getting Yuck.io up and running couldn't be easier.

*Install Prerequisites*

**Python Requirements**

```bash
$ pip install -r requirements.txt
```

**Node Requirements**

```bash
$ npm install -g bower
```

*Clone the Yuck.io Repository*

```bash
$ git clone git@github.com:KFGisIT/gsa-bpa-django.git
```

*Pull Dependencies*

```bash
$ cd gsa-bpa-django
$ bower install
```

*Setup Apache to Serve Django*

```apacheconf
WSGIScriptAlias / /path/to/gsa-bpa-django/app/wsgi.py
WSGIPythonPath /path/to/gsa-bpa-django

<Directory /path/to/gsa-bpa-django/app> 
<Files wsgi.py>
Require all granted
</Files>
</Directory>
```

*Docker Container*

[Reference to the DockerFile]

##Deployment##
***ask wendell***

[IaaS or PaaS- list provider]

*	Docker based
* 	works on anything

[Performed usability tests with people]

[Continuous Monitoring]
[Continuous Integration]
Travis as Build System
**Dan to Add Stuff**

-Git webhook 

-Git webhook kicks off Travis job for testing, autostaging docker files & report back via email or travis

-Drupal part = CKAN data warehouse, Drupal FE, Drupal Modules for Integration (Data API), FE to huge dataset, which is a wide data set

-Example Application = Yuck.io in Django, small scope site

#Licences#
This product is licensed under the [MIT license agreement](./License.md "License")

#Credits#
*  	Krista Diamond, Visual Designer
*	Amanda Furman, Product Manager
* 	Daniel Furman, Technical Architect
*	Paul Makarov, Frontend & Backend Web Developer
* 	Wendell Wilson, DevOps Engineer
*  	Ryan Elliott, Backend
*  	Jeff Edwards, Frontend, Copywriter, UX, Validation, Drupal View Dude
*  	Miles Briggs, Frontend Integration
*	Wade Simmons, Frontend (Middleware)